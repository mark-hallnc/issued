import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import 'cloud_auth_service.dart';
import 'supabase_config.dart';

class WorkspaceResult<T> {
  const WorkspaceResult({
    required this.success,
    required this.data,
    this.message,
  });

  const WorkspaceResult.success(this.data, {this.message}) : success = true;

  const WorkspaceResult.failure(this.message) : success = false, data = null;

  final bool success;
  final T? data;
  final String? message;
}

class WorkspaceService {
  WorkspaceService([this._authService = const CloudAuthService()]);

  final CloudAuthService _authService;
  CloudWorkspace? _activeWorkspace;
  static const _activeWorkspaceFileName = 'issued_active_workspace_id.txt';

  SupabaseClient? get _client {
    if (!SupabaseConfig.isConfigured) {
      return null;
    }
    return Supabase.instance.client;
  }

  Future<WorkspaceResult<List<CloudWorkspace>>> fetchMyWorkspaces() async {
    final client = _client;
    final user = _authService.currentUser;
    if (client == null) {
      return WorkspaceResult.failure(SupabaseConfig.missingConfigMessage);
    }
    if (user == null) {
      return const WorkspaceResult.failure('Sign in to view workspaces.');
    }
    try {
      final memberships = await client
          .from('workspace_members')
          .select('workspaces(id,name,slug,created_at,updated_at)')
          .eq('user_id', user.id)
          .eq('status', 'active');
      final workspaces = <CloudWorkspace>[];
      for (final row in memberships as List<dynamic>) {
        final workspace = (row as Map<String, dynamic>)['workspaces'];
        if (workspace is Map<String, dynamic>) {
          workspaces.add(CloudWorkspace.fromJson(workspace));
        }
      }
      workspaces.sort((left, right) => left.name.compareTo(right.name));
      return WorkspaceResult.success(workspaces);
    } on PostgrestException catch (error) {
      return WorkspaceResult.failure(_friendlyDatabaseError(error.message));
    } catch (_) {
      return const WorkspaceResult.failure('Could not load workspaces.');
    }
  }

  Future<WorkspaceResult<List<CloudWorkspaceMember>>> fetchMembersForWorkspace(
    String workspaceId,
  ) async {
    final client = _client;
    if (client == null) {
      return WorkspaceResult.failure(SupabaseConfig.missingConfigMessage);
    }
    if (_authService.currentUser == null) {
      return const WorkspaceResult.failure('Sign in to view members.');
    }
    try {
      final rows = await client
          .from('workspace_members')
          .select()
          .eq('workspace_id', workspaceId)
          .order('email');
      return WorkspaceResult.success([
        for (final row in rows as List<dynamic>)
          CloudWorkspaceMember.fromJson(row as Map<String, dynamic>),
      ]);
    } on PostgrestException catch (error) {
      return WorkspaceResult.failure(_friendlyDatabaseError(error.message));
    } catch (_) {
      return const WorkspaceResult.failure('Could not load workspace members.');
    }
  }

  Future<WorkspaceResult<List<CloudWorkspaceInvite>>> fetchInvitesForWorkspace(
    String workspaceId,
  ) async {
    final client = _client;
    if (client == null) {
      return WorkspaceResult.failure(SupabaseConfig.missingConfigMessage);
    }
    if (_authService.currentUser == null) {
      return const WorkspaceResult.failure('Sign in to view invites.');
    }
    try {
      final rows = await client
          .from('workspace_invites')
          .select()
          .eq('workspace_id', workspaceId)
          .order('created_at', ascending: false);
      return WorkspaceResult.success([
        for (final row in rows as List<dynamic>)
          CloudWorkspaceInvite.fromJson(row as Map<String, dynamic>),
      ]);
    } on PostgrestException catch (error) {
      return WorkspaceResult.failure(_friendlyDatabaseError(error.message));
    } catch (_) {
      return const WorkspaceResult.failure('Could not load workspace invites.');
    }
  }

  Future<WorkspaceResult<List<CloudWorkspaceInvite>>>
  fetchPendingInvitesForCurrentUser() async {
    final client = _client;
    final email = _authService.currentUser?.email?.trim().toLowerCase();
    if (client == null) {
      return WorkspaceResult.failure(SupabaseConfig.missingConfigMessage);
    }
    if (email == null || email.isEmpty) {
      return const WorkspaceResult.failure('Sign in to view invites.');
    }
    try {
      final rows = await client
          .from('workspace_invites')
          .select('*,workspaces(name)')
          .eq('email', email)
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      return WorkspaceResult.success([
        for (final row in rows as List<dynamic>)
          CloudWorkspaceInvite.fromJson(row as Map<String, dynamic>),
      ]);
    } on PostgrestException catch (error) {
      return WorkspaceResult.failure(_friendlyDatabaseError(error.message));
    } catch (_) {
      return const WorkspaceResult.failure('Could not load pending invites.');
    }
  }

  Future<WorkspaceResult<void>> inviteWorkspaceMember({
    required String workspaceId,
    required String email,
    required CloudWorkspaceRole role,
    String? displayName,
  }) async {
    final client = _client;
    final normalizedEmail = email.trim().toLowerCase();
    if (client == null) {
      return WorkspaceResult.failure(SupabaseConfig.missingConfigMessage);
    }
    if (_authService.currentUser == null) {
      return const WorkspaceResult.failure('Sign in to invite members.');
    }
    if (!_looksLikeEmail(normalizedEmail)) {
      return const WorkspaceResult.failure('Enter a valid email address.');
    }
    if (role == CloudWorkspaceRole.owner) {
      return const WorkspaceResult.failure('Owner cannot be invited.');
    }
    try {
      final response = await client.functions.invoke(
        'invite-workspace-member',
        body: {
          'workspaceId': workspaceId,
          'email': normalizedEmail,
          'role': role.name,
          if (displayName != null && displayName.trim().isNotEmpty)
            'displayName': displayName.trim(),
        },
      );
      final data = response.data;
      if (data is Map) {
        final success = data['success'] == true;
        final warning = data['warning']?.toString();
        final message = warning ?? data['message']?.toString();
        return success
            ? WorkspaceResult.success(null, message: message ?? 'Invite sent.')
            : WorkspaceResult.failure(message ?? 'Invite could not be sent.');
      }
      return const WorkspaceResult.success(
        null,
        message:
            'Invite sent. They should open the email and sign in with that email address.',
      );
    } catch (error) {
      return WorkspaceResult.failure(_friendlyDatabaseError(error.toString()));
    }
  }

  Future<WorkspaceResult<void>> resendWorkspaceInvite(String inviteId) async {
    final client = _client;
    if (client == null) {
      return WorkspaceResult.failure(SupabaseConfig.missingConfigMessage);
    }
    if (_authService.currentUser == null) {
      return const WorkspaceResult.failure('Sign in to resend invites.');
    }
    try {
      final row = await client
          .from('workspace_invites')
          .select()
          .eq('id', inviteId)
          .single();
      final invite = CloudWorkspaceInvite.fromJson(row);
      return inviteWorkspaceMember(
        workspaceId: invite.workspaceId,
        email: invite.email,
        role: invite.role,
      );
    } on PostgrestException catch (error) {
      return WorkspaceResult.failure(_friendlyDatabaseError(error.message));
    } catch (_) {
      return const WorkspaceResult.failure('Could not resend invite.');
    }
  }

  Future<WorkspaceResult<void>> revokeWorkspaceInvite(String inviteId) async {
    final client = _client;
    if (client == null) {
      return WorkspaceResult.failure(SupabaseConfig.missingConfigMessage);
    }
    if (_authService.currentUser == null) {
      return const WorkspaceResult.failure('Sign in to revoke invites.');
    }
    try {
      await client.rpc(
        'revoke_workspace_invite',
        params: {'invite_id': inviteId},
      );
      return const WorkspaceResult.success(null, message: 'Invite revoked.');
    } on PostgrestException catch (error) {
      return WorkspaceResult.failure(_friendlyDatabaseError(error.message));
    } catch (_) {
      return const WorkspaceResult.failure('Could not revoke invite.');
    }
  }

  Future<WorkspaceResult<CloudWorkspace>> acceptWorkspaceInvite(
    String inviteId,
  ) async {
    final client = _client;
    if (client == null) {
      return WorkspaceResult.failure(SupabaseConfig.missingConfigMessage);
    }
    if (_authService.currentUser == null) {
      return const WorkspaceResult.failure('Sign in to accept invites.');
    }
    try {
      final workspaceId = await client.rpc(
        'accept_workspace_invite',
        params: {'invite_id': inviteId},
      );
      final row = await client
          .from('workspaces')
          .select()
          .eq('id', workspaceId.toString())
          .single();
      final workspace = CloudWorkspace.fromJson(row);
      setActiveWorkspace(workspace);
      return WorkspaceResult.success(workspace, message: 'Invite accepted.');
    } on PostgrestException catch (error) {
      return WorkspaceResult.failure(_friendlyDatabaseError(error.message));
    } catch (_) {
      return const WorkspaceResult.failure('Could not accept invite.');
    }
  }

  Future<WorkspaceResult<CloudWorkspace>> acceptInviteByToken(
    String token,
  ) async {
    final client = _client;
    final cleanToken = token.trim();
    if (client == null) {
      return WorkspaceResult.failure(SupabaseConfig.missingConfigMessage);
    }
    if (_authService.currentUser == null) {
      return const WorkspaceResult.failure('Sign in to accept the invite.');
    }
    if (cleanToken.isEmpty) {
      return const WorkspaceResult.failure(
        'Invite link is missing or invalid.',
      );
    }
    try {
      final response = await client.rpc(
        'accept_workspace_invite_by_token',
        params: {'p_token': cleanToken},
      );
      final row = response is List && response.isNotEmpty
          ? response.first as Map<String, dynamic>
          : response as Map<String, dynamic>;
      final workspaceId = row['workspace_id']?.toString();
      if (workspaceId == null || workspaceId.isEmpty) {
        return const WorkspaceResult.failure('Invite could not be accepted.');
      }
      final workspaceRow = await client
          .from('workspaces')
          .select()
          .eq('id', workspaceId)
          .single();
      final workspace = CloudWorkspace.fromJson(workspaceRow);
      setActiveWorkspace(workspace);
      return WorkspaceResult.success(workspace, message: 'Workspace joined.');
    } on PostgrestException catch (error) {
      return WorkspaceResult.failure(_friendlyDatabaseError(error.message));
    } catch (_) {
      return const WorkspaceResult.failure('Could not accept invite.');
    }
  }

  Future<WorkspaceResult<CloudWorkspaceMember>> updateWorkspaceMemberRole({
    required String memberId,
    required CloudWorkspaceRole role,
  }) async {
    if (role == CloudWorkspaceRole.owner) {
      return const WorkspaceResult.failure(
        'Owner role cannot be assigned here.',
      );
    }
    return _updateWorkspaceMember(
      memberId: memberId,
      values: {'role': role.name},
      successMessage: 'Member role updated.',
    );
  }

  Future<WorkspaceResult<CloudWorkspaceMember>> disableWorkspaceMember(
    String memberId,
  ) {
    return _updateWorkspaceMember(
      memberId: memberId,
      values: {'status': CloudWorkspaceMemberStatus.disabled.name},
      successMessage: 'Member disabled.',
    );
  }

  Future<WorkspaceResult<CloudWorkspaceMember>> enableWorkspaceMember(
    String memberId,
  ) {
    return _updateWorkspaceMember(
      memberId: memberId,
      values: {'status': CloudWorkspaceMemberStatus.active.name},
      successMessage: 'Member enabled.',
    );
  }

  Future<WorkspaceResult<CloudWorkspaceMember>> _updateWorkspaceMember({
    required String memberId,
    required Map<String, Object?> values,
    required String successMessage,
  }) async {
    final client = _client;
    if (client == null) {
      return WorkspaceResult.failure(SupabaseConfig.missingConfigMessage);
    }
    if (_authService.currentUser == null) {
      return const WorkspaceResult.failure('Sign in to manage members.');
    }
    try {
      final row = await client
          .from('workspace_members')
          .update(values)
          .eq('id', memberId)
          .select()
          .single();
      return WorkspaceResult.success(
        CloudWorkspaceMember.fromJson(row),
        message: successMessage,
      );
    } on PostgrestException catch (error) {
      return WorkspaceResult.failure(_friendlyDatabaseError(error.message));
    } catch (_) {
      return const WorkspaceResult.failure('Could not update member.');
    }
  }

  Future<WorkspaceResult<CloudWorkspace>> createWorkspace(String name) async {
    final client = _client;
    final user = _authService.currentUser;
    final workspaceName = name.trim();
    if (client == null) {
      return WorkspaceResult.failure(SupabaseConfig.missingConfigMessage);
    }
    if (user == null) {
      return const WorkspaceResult.failure('Sign in to create a workspace.');
    }
    if (workspaceName.isEmpty) {
      return const WorkspaceResult.failure('Workspace name is required.');
    }
    try {
      final workspaceId = await client.rpc(
        'create_workspace_with_owner',
        params: {'workspace_name': workspaceName},
      );
      final row = await client
          .from('workspaces')
          .select()
          .eq('id', workspaceId.toString())
          .single();
      final workspace = CloudWorkspace.fromJson(row);
      setActiveWorkspace(workspace);
      return WorkspaceResult.success(workspace, message: 'Workspace created.');
    } on PostgrestException catch (rpcError) {
      try {
        final row = await client
            .from('workspaces')
            .insert({'name': workspaceName, 'created_by': user.id})
            .select()
            .single();
        final workspace = CloudWorkspace.fromJson(row);
        await client.from('workspace_members').insert({
          'workspace_id': workspace.id,
          'user_id': user.id,
          'email': user.email ?? '',
          'role': 'owner',
          'status': 'active',
        });
        setActiveWorkspace(workspace);
        return WorkspaceResult.success(
          workspace,
          message: 'Workspace created.',
        );
      } on PostgrestException catch (fallbackError) {
        return WorkspaceResult.failure(
          _friendlyDatabaseError(
            '${rpcError.message} ${fallbackError.message}',
          ),
        );
      } catch (_) {
        return const WorkspaceResult.failure('Could not create workspace.');
      }
    } catch (_) {
      return const WorkspaceResult.failure('Could not create workspace.');
    }
  }

  void setActiveWorkspace(CloudWorkspace workspace) {
    _activeWorkspace = workspace;
    unawaited(_saveActiveWorkspaceId(workspace.id));
  }

  CloudWorkspace? getActiveWorkspace() {
    return _activeWorkspace;
  }

  void clearActiveWorkspace() {
    _activeWorkspace = null;
    unawaited(_clearActiveWorkspaceId());
  }

  Future<String?> getStoredActiveWorkspaceId() async {
    try {
      final file = await _activeWorkspaceFile();
      if (!await file.exists()) {
        return null;
      }
      final value = (await file.readAsString()).trim();
      return value.isEmpty ? null : value;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveActiveWorkspaceId(String workspaceId) async {
    try {
      final file = await _activeWorkspaceFile();
      await file.writeAsString(workspaceId);
    } catch (_) {
      // Active workspace persistence is a convenience cache.
    }
  }

  Future<void> _clearActiveWorkspaceId() async {
    try {
      final file = await _activeWorkspaceFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Active workspace persistence is a convenience cache.
    }
  }

  Future<File> _activeWorkspaceFile() async {
    final directory = await getApplicationSupportDirectory();
    return File(p.join(directory.path, _activeWorkspaceFileName));
  }
}

String _friendlyDatabaseError(String message) {
  final lower = message.toLowerCase();
  if (lower.contains('does not exist') || lower.contains('schema cache')) {
    return 'Cloud workspace tables are not ready yet. Run the workspace SQL migration in Supabase.';
  }
  if (lower.contains('not authenticated')) {
    return 'Sign in to continue.';
  }
  if (lower.contains('expired')) {
    return 'This invite has expired. Ask the workspace admin to send a new one.';
  }
  if (lower.contains('no longer available')) {
    return 'This invite is no longer available.';
  }
  if (lower.contains('does not match')) {
    return 'This invite belongs to a different email address. Sign in with the email that received the invite.';
  }
  if (lower.contains('missing or invalid')) {
    return 'Invite link is missing or invalid.';
  }
  if (lower.contains('not allowed') ||
      lower.contains('permission') ||
      lower.contains('forbidden') ||
      lower.contains('only workspace owners')) {
    return 'You do not have permission to do that in this workspace.';
  }
  if (lower.contains('already an active workspace member')) {
    return 'That person is already a workspace member.';
  }
  return message.isEmpty ? 'Cloud workspace request failed.' : message;
}

bool _looksLikeEmail(String value) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
}
