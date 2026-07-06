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
      _activeWorkspace = workspace;
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
        _activeWorkspace = workspace;
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
  }

  CloudWorkspace? getActiveWorkspace() {
    return _activeWorkspace;
  }

  void clearActiveWorkspace() {
    _activeWorkspace = null;
  }
}

String _friendlyDatabaseError(String message) {
  final lower = message.toLowerCase();
  if (lower.contains('does not exist') ||
      lower.contains('schema cache') ||
      lower.contains('permission denied')) {
    return 'Cloud workspace tables are not ready yet. Run the workspace SQL migration in Supabase.';
  }
  return message.isEmpty ? 'Cloud workspace request failed.' : message;
}
