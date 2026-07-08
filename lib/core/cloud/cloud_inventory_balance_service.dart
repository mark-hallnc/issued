import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/item_location_balance_models.dart';
import 'cloud_auth_service.dart';
import 'cloud_inventory_balance_models.dart';
import 'supabase_config.dart';

class CloudInventoryBalanceSyncResult {
  const CloudInventoryBalanceSyncResult({
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

class CloudInventoryBalanceService {
  const CloudInventoryBalanceService({
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

  Future<List<CloudInventoryBalance>> fetchWorkspaceBalances(
    String workspaceId, {
    DateTime? since,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    final rows = since == null
        ? await client
              .from('workspace_inventory_balances')
              .select()
              .eq('workspace_id', workspaceId)
              .order('updated_at', ascending: false)
        : await client
              .from('workspace_inventory_balances')
              .select()
              .eq('workspace_id', workspaceId)
              .gte('updated_at', since.toUtc().toIso8601String())
              .order('updated_at', ascending: false);
    return [
      for (final row in rows as List<dynamic>)
        CloudInventoryBalance.fromJson(row as Map<String, dynamic>),
    ];
  }

  Future<CloudInventoryBalance> upsertWorkspaceBalance(
    CloudInventoryBalance balance,
  ) async {
    final client = _requireClient();
    final user = _requireUser();
    _requireWorkspaceId(balance.workspaceId);
    final row = await client
        .from('workspace_inventory_balances')
        .upsert(
          balance.toUpsertJson(userId: user.id),
          onConflict: 'workspace_id,local_item_id,location_id',
        )
        .select()
        .single();
    return CloudInventoryBalance.fromJson(row);
  }

  Future<int> upsertWorkspaceBalances(
    List<CloudInventoryBalance> balances,
  ) async {
    if (balances.isEmpty) {
      return 0;
    }
    final client = _requireClient();
    final user = _requireUser();
    final workspaceId = balances.first.workspaceId;
    _requireWorkspaceId(workspaceId);
    for (final balance in balances) {
      if (balance.workspaceId != workspaceId) {
        throw ArgumentError('All balances must belong to the same workspace.');
      }
    }
    await client.from('workspace_inventory_balances').upsert([
      for (final balance in balances) balance.toUpsertJson(userId: user.id),
    ], onConflict: 'workspace_id,local_item_id,location_id');
    return balances.length;
  }

  Future<void> softDeleteWorkspaceBalance({
    required String workspaceId,
    required String localItemId,
    required String locationId,
  }) async {
    final client = _requireClient();
    final user = _requireUser();
    _requireWorkspaceId(workspaceId);
    await client
        .from('workspace_inventory_balances')
        .update({
          'deleted_at': DateTime.now().toUtc().toIso8601String(),
          'updated_by': user.id,
        })
        .eq('workspace_id', workspaceId)
        .eq('local_item_id', localItemId)
        .eq('location_id', locationId);
  }

  Future<CloudInventoryBalanceSyncResult> pushLocalBalances({
    required String workspaceId,
    required List<ItemLocationBalance> balances,
    Map<String, String?> workspaceItemIdsByLocalItemId = const {},
    String? Function(ItemLocationBalance balance)? locationNameForBalance,
  }) async {
    _requireWorkspaceId(workspaceId);
    final cloudBalances = [
      for (final balance in balances)
        CloudInventoryBalance.fromLocalBalance(
          workspaceId: workspaceId,
          balance: balance,
          workspaceItemId: workspaceItemIdsByLocalItemId[balance.itemId],
          locationName: locationNameForBalance?.call(balance),
        ),
    ];
    final uploadedCount = await upsertWorkspaceBalances(cloudBalances);
    final downloaded = await pullWorkspaceBalances(workspaceId);
    return CloudInventoryBalanceSyncResult(
      uploadedCount: uploadedCount,
      downloadedCount: downloaded.length,
      skippedCount: 0,
      isUploadOnly: true,
    );
  }

  Future<List<CloudInventoryBalance>> pullWorkspaceBalances(
    String workspaceId, {
    DateTime? since,
  }) {
    return fetchWorkspaceBalances(workspaceId, since: since);
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
      throw StateError('Sign in to sync inventory balances.');
    }
    return user;
  }

  void _requireWorkspaceId(String workspaceId) {
    if (workspaceId.trim().isEmpty) {
      throw ArgumentError('A workspace is required.');
    }
  }
}
