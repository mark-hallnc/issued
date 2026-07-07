import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../models/cloud_models.dart';
import 'cloud_auth_service.dart';
import 'supabase_config.dart';
import 'sync_models.dart';
import 'workspace_service.dart';

class CloudSyncService {
  CloudSyncService({
    required this._workspaceService,
    required AppDatabase database,
    this._authService = const CloudAuthService(),
    SupabaseClient? client,
  }) : _database = database,
       _clientOverride = client;

  final WorkspaceService _workspaceService;
  final AppDatabase _database;
  final CloudAuthService _authService;
  final SupabaseClient? _clientOverride;

  CloudSyncSummary _summary = CloudSyncSummary.disabled();
  String? _activeWorkspaceId;
  String? _activeWorkspaceName;
  bool _paused = false;

  AppDatabase get database => _database;

  SupabaseClient? get _client {
    if (!SupabaseConfig.isConfigured) {
      return null;
    }
    return _clientOverride ?? Supabase.instance.client;
  }

  CloudSyncSummary getSyncSummary() => _summary;

  Future<CloudSyncSummary> initializeForWorkspace(
    String workspaceId, {
    String? workspaceName,
  }) async {
    _activeWorkspaceId = workspaceId;
    _activeWorkspaceName = workspaceName;
    _summary = _summary.copyWith(
      status: _paused ? CloudSyncStatus.disabled : CloudSyncStatus.ready,
      activeWorkspaceId: workspaceId,
      activeWorkspaceName: workspaceName,
      isCloudEnabled: SupabaseConfig.isConfigured,
      isWorkspaceSelected: workspaceId.isNotEmpty,
      clearLastError: true,
    );
    return _summary;
  }

  Future<void> queueLocalChange({
    required CloudSyncEntity entity,
    required String entityId,
    required CloudSyncOperation operation,
    Map<String, Object?>? payload,
  }) async {
    if (_summary.status == CloudSyncStatus.disabled || _paused) {
      return;
    }
    _summary = _summary.copyWith(
      pendingUploadCount: _summary.pendingUploadCount + 1,
    );
  }

  Future<CloudSyncResult> syncNow() async {
    final client = _client;
    final user = _authService.currentUser;
    final workspaceId =
        _activeWorkspaceId ?? _workspaceService.getActiveWorkspace()?.id;
    final workspaceName =
        _activeWorkspaceName ??
        _workspaceService.getActiveWorkspace()?.name ??
        'Selected workspace';

    if (client == null) {
      final message =
          SupabaseConfig.missingConfigMessage ?? 'Supabase is not configured.';

      _summary = CloudSyncSummary.disabled().copyWith(
        status: CloudSyncStatus.disabled,
        lastError: message,
      );

      return CloudSyncResult.failure(message: message);
    }
    if (user == null) {
      _setNeedsSetup('Sign in to use cloud sync.');
      return const CloudSyncResult.failure(
        message: 'Sign in to use cloud sync.',
      );
    }
    if (workspaceId == null || workspaceId.isEmpty) {
      _setNeedsSetup('Select a workspace before syncing.');
      return const CloudSyncResult.failure(
        message: 'Select a workspace before syncing.',
      );
    }
    if (_paused) {
      _summary = _summary.copyWith(
        status: CloudSyncStatus.disabled,
        activeWorkspaceId: workspaceId,
        activeWorkspaceName: workspaceName,
        isCloudEnabled: true,
        isWorkspaceSelected: true,
      );
      return const CloudSyncResult.failure(message: 'Cloud sync is paused.');
    }

    final startedAt = DateTime.now();
    _summary = _summary.copyWith(
      status: CloudSyncStatus.syncing,
      lastSyncAt: startedAt,
      activeWorkspaceId: workspaceId,
      activeWorkspaceName: workspaceName,
      isCloudEnabled: true,
      isWorkspaceSelected: true,
      clearLastError: true,
    );

    try {
      final members = await _workspaceService.fetchMembersForWorkspace(
        workspaceId,
      );
      if (!members.success) {
        final message = members.message ?? 'Could not verify workspace access.';
        _summary = _summary.copyWith(
          status: _looksOffline(message)
              ? CloudSyncStatus.offline
              : CloudSyncStatus.error,
          lastError: message,
        );
        return CloudSyncResult.failure(message: message);
      }
      final hasMembership = (members.data ?? const <CloudWorkspaceMember>[])
          .any(
            (member) =>
                member.userId == user.id &&
                member.status == CloudWorkspaceMemberStatus.active,
          );
      if (!hasMembership) {
        const message = 'Your workspace membership is not active.';
        _summary = _summary.copyWith(
          status: CloudSyncStatus.needsSetup,
          lastError: message,
        );
        return const CloudSyncResult.failure(message: message);
      }

      await _recordSyncClientSeen(client, workspaceId, user.id);
      final finishedAt = DateTime.now();
      _summary = _summary.copyWith(
        status: CloudSyncStatus.ready,
        lastSyncAt: finishedAt,
        lastSuccessfulSyncAt: finishedAt,
        pendingDownloadCount: 0,
        clearLastError: true,
      );
      return const CloudSyncResult.success(
        message:
            'Cloud sync foundation is ready. Inventory sync is not enabled yet.',
        skippedCount: 0,
      );
    } on SocketException catch (error) {
      return _offlineResult(error);
    } on TimeoutException catch (error) {
      return _offlineResult(error);
    } on PostgrestException catch (error) {
      final message = _friendlySyncError(error.message);
      _summary = _summary.copyWith(
        status: _looksOffline(message)
            ? CloudSyncStatus.offline
            : CloudSyncStatus.error,
        lastError: message,
      );
      return CloudSyncResult.failure(message: message, error: error);
    } catch (error) {
      final message = _friendlySyncError(error.toString());
      _summary = _summary.copyWith(
        status: _looksOffline(message)
            ? CloudSyncStatus.offline
            : CloudSyncStatus.error,
        lastError: message,
      );
      return CloudSyncResult.failure(message: message, error: error);
    }
  }

  void pauseSync() {
    _paused = true;
    _summary = _summary.copyWith(status: CloudSyncStatus.disabled);
  }

  Future<CloudSyncSummary> resumeSync() async {
    _paused = false;
    final workspaceId = _activeWorkspaceId;
    if (workspaceId == null || workspaceId.isEmpty) {
      _summary = _summary.copyWith(status: CloudSyncStatus.needsSetup);
      return _summary;
    }
    _summary = _summary.copyWith(status: CloudSyncStatus.ready);
    return _summary;
  }

  void clearSyncError() {
    final nextStatus = _activeWorkspaceId == null
        ? CloudSyncStatus.needsSetup
        : CloudSyncStatus.ready;
    _summary = _summary.copyWith(status: nextStatus, clearLastError: true);
  }

  bool isCloudSyncReady() {
    return _summary.status == CloudSyncStatus.ready &&
        _summary.isCloudEnabled &&
        _summary.isWorkspaceSelected &&
        !_paused;
  }

  void clearWorkspaceState() {
    _activeWorkspaceId = null;
    _activeWorkspaceName = null;
    _paused = false;
    _summary = CloudSyncSummary.disabled();
  }

  void _setNeedsSetup(String message) {
    _summary = _summary.copyWith(
      status: CloudSyncStatus.needsSetup,
      lastError: message,
      isCloudEnabled: SupabaseConfig.isConfigured,
      isWorkspaceSelected: _activeWorkspaceId != null,
    );
  }

  Future<void> _recordSyncClientSeen(
    SupabaseClient client,
    String workspaceId,
    String userId,
  ) async {
    await client.from('sync_clients').upsert({
      'workspace_id': workspaceId,
      'user_id': userId,
      'device_name': 'Issued Flutter client',
      'platform': Platform.operatingSystem,
      'last_seen_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'workspace_id,user_id,device_name');
  }

  CloudSyncResult _offlineResult(Object error) {
    const message = 'Cloud sync is offline. Local inventory remains available.';
    _summary = _summary.copyWith(
      status: CloudSyncStatus.offline,
      lastError: message,
    );
    return CloudSyncResult.failure(message: message, error: error);
  }
}

String _friendlySyncError(String message) {
  final lower = message.toLowerCase();
  if (lower.contains('does not exist') || lower.contains('schema cache')) {
    return 'Cloud sync tables are not ready yet. Run the sync SQL migration in Supabase.';
  }
  if (lower.contains('failed host lookup') ||
      lower.contains('network') ||
      lower.contains('connection')) {
    return 'Cloud sync is offline. Local inventory remains available.';
  }
  if (lower.contains('permission') ||
      lower.contains('forbidden') ||
      lower.contains('not allowed')) {
    return 'You do not have permission to sync this workspace.';
  }
  return message.isEmpty ? 'Cloud sync request failed.' : message;
}

bool _looksOffline(String message) {
  final lower = message.toLowerCase();
  return lower.contains('offline') ||
      lower.contains('network') ||
      lower.contains('connection') ||
      lower.contains('host lookup');
}
