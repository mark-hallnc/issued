import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cycle_count_models.dart';
import 'cloud_auth_service.dart';
import 'cloud_cycle_count_models.dart';
import 'supabase_config.dart';

class CloudCycleCountSyncResult {
  const CloudCycleCountSyncResult({
    required this.uploadedCount,
    required this.downloadedCount,
    required this.skippedCount,
    required this.isUploadOnly,
  });

  final int uploadedCount;
  final int downloadedCount;
  final int skippedCount;
  final bool isUploadOnly;
}

class CloudCycleCountPullResult {
  const CloudCycleCountPullResult({required this.counts, required this.lines});

  final List<CloudCycleCount> counts;
  final List<CloudCycleCountLine> lines;
}

class CloudCycleCountService {
  const CloudCycleCountService({
    this.authService = const CloudAuthService(),
    this.client,
  });

  final CloudAuthService authService;
  final SupabaseClient? client;

  SupabaseClient? get _client {
    if (!SupabaseConfig.isConfigured) {
      return null;
    }
    return client ?? Supabase.instance.client;
  }

  Future<List<CloudCycleCount>> fetchWorkspaceCycleCounts(
    String workspaceId, {
    String? status,
    DateTime? since,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    final rows = status == null && since == null
        ? await client
              .from('workspace_cycle_counts')
              .select()
              .eq('workspace_id', workspaceId)
              .order('created_at', ascending: false)
        : status != null && since == null
        ? await client
              .from('workspace_cycle_counts')
              .select()
              .eq('workspace_id', workspaceId)
              .eq('status', status)
              .order('created_at', ascending: false)
        : status == null && since != null
        ? await client
              .from('workspace_cycle_counts')
              .select()
              .eq('workspace_id', workspaceId)
              .gte('updated_at', since.toUtc().toIso8601String())
              .order('created_at', ascending: false)
        : await client
              .from('workspace_cycle_counts')
              .select()
              .eq('workspace_id', workspaceId)
              .eq('status', status!)
              .gte('updated_at', since!.toUtc().toIso8601String())
              .order('created_at', ascending: false);
    return [
      for (final row in rows as List<dynamic>)
        CloudCycleCount.fromJson(row as Map<String, dynamic>),
    ];
  }

  Future<List<CloudCycleCountLine>> fetchWorkspaceCycleCountLines(
    String workspaceId, {
    String? localCountId,
    DateTime? since,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    final rows = localCountId == null && since == null
        ? await client
              .from('workspace_cycle_count_lines')
              .select()
              .eq('workspace_id', workspaceId)
              .order('created_at', ascending: false)
        : localCountId != null && since == null
        ? await client
              .from('workspace_cycle_count_lines')
              .select()
              .eq('workspace_id', workspaceId)
              .eq('local_count_id', localCountId)
              .order('created_at', ascending: false)
        : localCountId == null && since != null
        ? await client
              .from('workspace_cycle_count_lines')
              .select()
              .eq('workspace_id', workspaceId)
              .gte('updated_at', since.toUtc().toIso8601String())
              .order('created_at', ascending: false)
        : await client
              .from('workspace_cycle_count_lines')
              .select()
              .eq('workspace_id', workspaceId)
              .eq('local_count_id', localCountId!)
              .gte('updated_at', since!.toUtc().toIso8601String())
              .order('created_at', ascending: false);
    return [
      for (final row in rows as List<dynamic>)
        CloudCycleCountLine.fromJson(row as Map<String, dynamic>),
    ];
  }

  Future<CloudCycleCount> upsertWorkspaceCycleCount(
    CloudCycleCount count,
  ) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(count.workspaceId);
    final row = await client
        .from('workspace_cycle_counts')
        .upsert(count.toUpsertJson(), onConflict: 'workspace_id,local_count_id')
        .select()
        .single();
    return CloudCycleCount.fromJson(row);
  }

  Future<int> upsertWorkspaceCycleCounts(List<CloudCycleCount> counts) async {
    if (counts.isEmpty) {
      return 0;
    }
    final client = _requireClient();
    _requireUser();
    final workspaceId = counts.first.workspaceId;
    _requireWorkspaceId(workspaceId);
    for (final count in counts) {
      if (count.workspaceId != workspaceId) {
        throw ArgumentError('All cycle counts must belong to one workspace.');
      }
    }
    await client.from('workspace_cycle_counts').upsert([
      for (final count in counts) count.toUpsertJson(),
    ], onConflict: 'workspace_id,local_count_id');
    return counts.length;
  }

  Future<CloudCycleCountLine> upsertWorkspaceCycleCountLine(
    CloudCycleCountLine line,
  ) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(line.workspaceId);
    final row = await client
        .from('workspace_cycle_count_lines')
        .upsert(
          line.toUpsertJson(),
          onConflict: 'workspace_id,local_count_line_id',
        )
        .select()
        .single();
    return CloudCycleCountLine.fromJson(row);
  }

  Future<int> upsertWorkspaceCycleCountLines(
    List<CloudCycleCountLine> lines,
  ) async {
    if (lines.isEmpty) {
      return 0;
    }
    final client = _requireClient();
    _requireUser();
    final workspaceId = lines.first.workspaceId;
    _requireWorkspaceId(workspaceId);
    for (final line in lines) {
      if (line.workspaceId != workspaceId) {
        throw ArgumentError(
          'All cycle count lines must belong to one workspace.',
        );
      }
    }
    await client.from('workspace_cycle_count_lines').upsert([
      for (final line in lines) line.toUpsertJson(),
    ], onConflict: 'workspace_id,local_count_line_id');
    return lines.length;
  }

  Future<CloudCycleCount?> findCloudCycleCountByLocalId({
    required String workspaceId,
    required String localCountId,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    final row = await client
        .from('workspace_cycle_counts')
        .select()
        .eq('workspace_id', workspaceId)
        .eq('local_count_id', localCountId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    return CloudCycleCount.fromJson(row);
  }

  Future<CloudCycleCountLine?> findCloudCycleCountLineByLocalId({
    required String workspaceId,
    required String localCountLineId,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    final row = await client
        .from('workspace_cycle_count_lines')
        .select()
        .eq('workspace_id', workspaceId)
        .eq('local_count_line_id', localCountLineId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    return CloudCycleCountLine.fromJson(row);
  }

  Future<void> softDeleteWorkspaceCycleCount({
    required String workspaceId,
    required String localCountId,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    await client
        .from('workspace_cycle_counts')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('workspace_id', workspaceId)
        .eq('local_count_id', localCountId);
  }

  Future<void> softDeleteWorkspaceCycleCountLine({
    required String workspaceId,
    required String localCountLineId,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    await client
        .from('workspace_cycle_count_lines')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('workspace_id', workspaceId)
        .eq('local_count_line_id', localCountLineId);
  }

  Future<CloudCycleCountSyncResult> pushLocalCycleCounts({
    required String workspaceId,
    required List<CycleCountSession> sessions,
    required List<CycleCountLine> lines,
    Map<String, String?> workspaceItemIdsByLocalItemId = const {},
    String? Function(String locationId)? locationNameFor,
    String? Function(String? userId)? userNameFor,
    String? Function(String? userId)? userEmailFor,
    double? Function(CycleCountLine line)? varianceValueFor,
  }) async {
    _requireWorkspaceId(workspaceId);
    final cloudCounts = [
      for (final session in sessions)
        CloudCycleCount.fromLocalCycleCount(
          workspaceId: workspaceId,
          session: session,
          userNameFor: userNameFor,
          userEmailFor: userEmailFor,
        ),
    ];
    final uploadedCounts = await upsertWorkspaceCycleCounts(cloudCounts);
    final pulledCounts = await fetchWorkspaceCycleCounts(workspaceId);
    final sessionIdsByLocalCountId = {
      for (final count in pulledCounts) count.localCountId: count.id,
    };
    final sessionsById = {for (final session in sessions) session.id: session};
    final cloudLines = [
      for (final line in lines)
        CloudCycleCountLine.fromLocalCycleCountLine(
          workspaceId: workspaceId,
          line: line,
          session: sessionsById[line.sessionId],
          workspaceCycleCountId: sessionIdsByLocalCountId[line.sessionId],
          workspaceItemId: workspaceItemIdsByLocalItemId[line.itemId],
          locationNameFor: locationNameFor,
          userNameFor: userNameFor,
          userEmailFor: userEmailFor,
          varianceValueFor: varianceValueFor,
        ),
    ];
    final uploadedLines = await upsertWorkspaceCycleCountLines(cloudLines);
    final pulledLines = await pullWorkspaceCycleCountLines(workspaceId);
    return CloudCycleCountSyncResult(
      uploadedCount: uploadedCounts + uploadedLines,
      downloadedCount: pulledCounts.length + pulledLines.length,
      skippedCount: 0,
      isUploadOnly: true,
    );
  }

  Future<CloudCycleCountPullResult> pullWorkspaceCycleCounts(
    String workspaceId, {
    DateTime? since,
  }) async {
    final counts = await fetchWorkspaceCycleCounts(workspaceId, since: since);
    final lines = await fetchWorkspaceCycleCountLines(
      workspaceId,
      since: since,
    );
    return CloudCycleCountPullResult(counts: counts, lines: lines);
  }

  Future<List<CloudCycleCountLine>> pullWorkspaceCycleCountLines(
    String workspaceId, {
    String? localCountId,
    DateTime? since,
  }) {
    return fetchWorkspaceCycleCountLines(
      workspaceId,
      localCountId: localCountId,
      since: since,
    );
  }

  SupabaseClient _requireClient() {
    final client = _client;
    if (client == null) {
      throw StateError(
        SupabaseConfig.missingConfigMessage ?? 'Supabase is not configured.',
      );
    }
    return client;
  }

  User _requireUser() {
    final user = authService.currentUser;
    if (user == null) {
      throw StateError('Sign in to sync cycle counts.');
    }
    return user;
  }

  void _requireWorkspaceId(String workspaceId) {
    if (workspaceId.trim().isEmpty) {
      throw ArgumentError('A workspace is required.');
    }
  }
}
