import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/inventory_models.dart';
import 'cloud_auth_service.dart';
import 'cloud_inventory_transaction_models.dart';
import 'supabase_config.dart';

class CloudInventoryTransactionSyncResult {
  const CloudInventoryTransactionSyncResult({
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

class CloudInventoryTransactionService {
  const CloudInventoryTransactionService({
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

  Future<List<CloudInventoryTransaction>> fetchWorkspaceTransactions(
    String workspaceId, {
    DateTime? since,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    final rows = since == null
        ? await client
              .from('workspace_inventory_transactions')
              .select()
              .eq('workspace_id', workspaceId)
              .order('occurred_at', ascending: false)
        : await client
              .from('workspace_inventory_transactions')
              .select()
              .eq('workspace_id', workspaceId)
              .gte('occurred_at', since.toUtc().toIso8601String())
              .order('occurred_at', ascending: false);
    return [
      for (final row in rows as List<dynamic>)
        CloudInventoryTransaction.fromJson(row as Map<String, dynamic>),
    ];
  }

  Future<CloudInventoryTransaction> upsertWorkspaceTransaction(
    CloudInventoryTransaction transaction,
  ) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(transaction.workspaceId);
    final row = await client
        .from('workspace_inventory_transactions')
        .upsert(
          transaction.toUpsertJson(),
          onConflict: 'workspace_id,local_transaction_id',
        )
        .select()
        .single();
    return CloudInventoryTransaction.fromJson(row);
  }

  Future<int> upsertWorkspaceTransactions(
    List<CloudInventoryTransaction> transactions,
  ) async {
    if (transactions.isEmpty) {
      return 0;
    }
    final client = _requireClient();
    _requireUser();
    final workspaceId = transactions.first.workspaceId;
    _requireWorkspaceId(workspaceId);
    for (final transaction in transactions) {
      if (transaction.workspaceId != workspaceId) {
        throw ArgumentError(
          'All transactions must belong to the same workspace.',
        );
      }
    }
    await client.from('workspace_inventory_transactions').upsert([
      for (final transaction in transactions) transaction.toUpsertJson(),
    ], onConflict: 'workspace_id,local_transaction_id');
    return transactions.length;
  }

  Future<CloudInventoryTransaction?> findCloudTransactionByLocalId({
    required String workspaceId,
    required String localTransactionId,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    final row = await client
        .from('workspace_inventory_transactions')
        .select()
        .eq('workspace_id', workspaceId)
        .eq('local_transaction_id', localTransactionId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    return CloudInventoryTransaction.fromJson(row);
  }

  Future<void> softDeleteWorkspaceTransaction({
    required String workspaceId,
    required String localTransactionId,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    await client
        .from('workspace_inventory_transactions')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('workspace_id', workspaceId)
        .eq('local_transaction_id', localTransactionId);
  }

  Future<CloudInventoryTransactionSyncResult> pushLocalTransactions({
    required String workspaceId,
    required List<InventoryTransaction> transactions,
    Map<String, String?> workspaceItemIdsByLocalItemId = const {},
    String? Function(String? locationId)? locationNameForId,
    String? Function(InventoryTransaction transaction)? assignmentLabelFor,
    String? Function(String? userId)? performedByNameFor,
    String? Function(String? userId)? performedByEmailFor,
  }) async {
    _requireWorkspaceId(workspaceId);
    final cloudTransactions = [
      for (final transaction in transactions)
        CloudInventoryTransaction.fromLocalTransaction(
          workspaceId: workspaceId,
          transaction: transaction,
          workspaceItemId: workspaceItemIdsByLocalItemId[transaction.itemId],
          locationNameForId: locationNameForId,
          assignmentLabelFor: assignmentLabelFor,
          performedByNameFor: performedByNameFor,
          performedByEmailFor: performedByEmailFor,
        ),
    ];
    final uploadedCount = await upsertWorkspaceTransactions(cloudTransactions);
    final downloaded = await pullWorkspaceTransactions(workspaceId);
    return CloudInventoryTransactionSyncResult(
      uploadedCount: uploadedCount,
      downloadedCount: downloaded.length,
      skippedCount: 0,
      isUploadOnly: true,
    );
  }

  Future<List<CloudInventoryTransaction>> pullWorkspaceTransactions(
    String workspaceId, {
    DateTime? since,
  }) {
    return fetchWorkspaceTransactions(workspaceId, since: since);
  }

  Future<int> countWorkspaceTransactions(String workspaceId) async {
    final rows = await _fetchCountRows(
      'workspace_inventory_transactions',
      workspaceId,
    );
    return rows.length;
  }

  Future<DateTime?> latestWorkspaceTransactionUpdateAt(String workspaceId) {
    return _latestUpdatedAt('workspace_inventory_transactions', workspaceId);
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
      throw StateError('Sign in to sync inventory transactions.');
    }
    return user;
  }

  void _requireWorkspaceId(String workspaceId) {
    if (workspaceId.trim().isEmpty) {
      throw ArgumentError('A workspace is required.');
    }
  }

  Future<List<dynamic>> _fetchCountRows(
    String table,
    String workspaceId,
  ) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    final rows = await client
        .from(table)
        .select('id')
        .eq('workspace_id', workspaceId);
    return rows as List<dynamic>;
  }

  Future<DateTime?> _latestUpdatedAt(String table, String workspaceId) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    final rows = await client
        .from(table)
        .select('updated_at')
        .eq('workspace_id', workspaceId)
        .order('updated_at', ascending: false)
        .limit(1);
    if (rows.isEmpty) {
      return null;
    }
    final row = rows.first;
    final value = row['updated_at'];
    return value is String ? DateTime.tryParse(value) : null;
  }
}
