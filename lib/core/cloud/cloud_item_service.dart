import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/inventory_models.dart';
import 'cloud_auth_service.dart';
import 'cloud_item_models.dart';
import 'supabase_config.dart';

class CloudItemCatalogSyncResult {
  const CloudItemCatalogSyncResult({
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

class CloudItemService {
  const CloudItemService({
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

  Future<List<CloudWorkspaceItem>> fetchWorkspaceItems(
    String workspaceId,
  ) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    final rows = await client
        .from('workspace_items')
        .select()
        .eq('workspace_id', workspaceId)
        .order('updated_at', ascending: false);
    return [
      for (final row in rows as List<dynamic>)
        CloudWorkspaceItem.fromJson(row as Map<String, dynamic>),
    ];
  }

  Future<CloudWorkspaceItem> upsertWorkspaceItem(
    CloudWorkspaceItem item,
  ) async {
    final client = _requireClient();
    final user = _requireUser();
    _requireWorkspaceId(item.workspaceId);
    final row = await client
        .from('workspace_items')
        .upsert(
          item.toUpsertJson(userId: user.id),
          onConflict: 'workspace_id,local_item_id',
        )
        .select()
        .single();
    return CloudWorkspaceItem.fromJson(row);
  }

  Future<int> upsertWorkspaceItems(List<CloudWorkspaceItem> items) async {
    if (items.isEmpty) {
      return 0;
    }
    final client = _requireClient();
    final user = _requireUser();
    final workspaceId = items.first.workspaceId;
    _requireWorkspaceId(workspaceId);
    for (final item in items) {
      if (item.workspaceId != workspaceId) {
        throw ArgumentError('All items must belong to the same workspace.');
      }
    }
    await client.from('workspace_items').upsert([
      for (final item in items) item.toUpsertJson(userId: user.id),
    ], onConflict: 'workspace_id,local_item_id');
    return items.length;
  }

  Future<void> softDeleteWorkspaceItem({
    required String workspaceId,
    required String localItemId,
  }) async {
    final client = _requireClient();
    final user = _requireUser();
    _requireWorkspaceId(workspaceId);
    await client
        .from('workspace_items')
        .update({
          'is_active': false,
          'deleted_at': DateTime.now().toUtc().toIso8601String(),
          'updated_by': user.id,
        })
        .eq('workspace_id', workspaceId)
        .eq('local_item_id', localItemId);
  }

  Future<CloudWorkspaceItem?> findCloudItemByLocalId({
    required String workspaceId,
    required String localItemId,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    final row = await client
        .from('workspace_items')
        .select()
        .eq('workspace_id', workspaceId)
        .eq('local_item_id', localItemId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    return CloudWorkspaceItem.fromJson(row);
  }

  Future<List<CloudWorkspaceItem>> pullItemCatalog(String workspaceId) {
    return fetchWorkspaceItems(workspaceId);
  }

  Future<CloudItemCatalogSyncResult> pushItemCatalog({
    required String workspaceId,
    required List<Item> items,
    String? Function(Item item)? unitForItem,
  }) async {
    _requireWorkspaceId(workspaceId);
    final cloudItems = [
      for (final item in items)
        CloudWorkspaceItem.fromLocalItem(
          workspaceId: workspaceId,
          item: item,
          unit: unitForItem?.call(item),
        ),
    ];
    final uploadedCount = await upsertWorkspaceItems(cloudItems);
    final downloaded = await pullItemCatalog(workspaceId);
    return CloudItemCatalogSyncResult(
      uploadedCount: uploadedCount,
      downloadedCount: downloaded.length,
      skippedCount: 0,
      isUploadOnly: true,
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
      throw StateError('Sign in to sync item catalog.');
    }
    return user;
  }

  void _requireWorkspaceId(String workspaceId) {
    if (workspaceId.trim().isEmpty) {
      throw ArgumentError('A workspace is required.');
    }
  }
}
