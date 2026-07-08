import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/reorder_models.dart';
import 'cloud_auth_service.dart';
import 'cloud_purchasing_models.dart';
import 'supabase_config.dart';

class CloudPurchasingSyncResult {
  const CloudPurchasingSyncResult({
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

class CloudPurchasingService {
  const CloudPurchasingService({
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

  Future<List<CloudPurchaseOrder>> fetchWorkspacePurchaseOrders(
    String workspaceId, {
    String? status,
    DateTime? since,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    final rows = status == null && since == null
        ? await client
              .from('workspace_purchase_orders')
              .select()
              .eq('workspace_id', workspaceId)
              .order('created_at', ascending: false)
        : status != null && since == null
        ? await client
              .from('workspace_purchase_orders')
              .select()
              .eq('workspace_id', workspaceId)
              .eq('status', status)
              .order('created_at', ascending: false)
        : status == null && since != null
        ? await client
              .from('workspace_purchase_orders')
              .select()
              .eq('workspace_id', workspaceId)
              .gte('updated_at', since.toUtc().toIso8601String())
              .order('created_at', ascending: false)
        : await client
              .from('workspace_purchase_orders')
              .select()
              .eq('workspace_id', workspaceId)
              .eq('status', status!)
              .gte('updated_at', since!.toUtc().toIso8601String())
              .order('created_at', ascending: false);
    return [
      for (final row in rows as List<dynamic>)
        CloudPurchaseOrder.fromJson(row as Map<String, dynamic>),
    ];
  }

  Future<List<CloudPurchaseOrder>> fetchOpenWorkspacePurchaseOrders(
    String workspaceId,
  ) async {
    final orders = await fetchWorkspacePurchaseOrders(workspaceId);
    return orders.where((order) {
      return order.status == 'needed' ||
          order.status == 'ordered' ||
          order.status == 'partiallyReceived';
    }).toList();
  }

  Future<CloudPurchaseOrder> upsertWorkspacePurchaseOrder(
    CloudPurchaseOrder order,
  ) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(order.workspaceId);
    final row = await client
        .from('workspace_purchase_orders')
        .upsert(
          order.toUpsertJson(),
          onConflict: 'workspace_id,local_purchase_order_id',
        )
        .select()
        .single();
    return CloudPurchaseOrder.fromJson(row);
  }

  Future<int> upsertWorkspacePurchaseOrders(
    List<CloudPurchaseOrder> orders,
  ) async {
    if (orders.isEmpty) {
      return 0;
    }
    final client = _requireClient();
    _requireUser();
    final workspaceId = orders.first.workspaceId;
    _requireWorkspaceId(workspaceId);
    for (final order in orders) {
      if (order.workspaceId != workspaceId) {
        throw ArgumentError(
          'All purchase orders must belong to the same workspace.',
        );
      }
    }
    await client.from('workspace_purchase_orders').upsert([
      for (final order in orders) order.toUpsertJson(),
    ], onConflict: 'workspace_id,local_purchase_order_id');
    return orders.length;
  }

  Future<CloudPurchaseOrder?> findCloudPurchaseOrderByLocalId({
    required String workspaceId,
    required String localPurchaseOrderId,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    final row = await client
        .from('workspace_purchase_orders')
        .select()
        .eq('workspace_id', workspaceId)
        .eq('local_purchase_order_id', localPurchaseOrderId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    return CloudPurchaseOrder.fromJson(row);
  }

  Future<void> softDeleteWorkspacePurchaseOrder({
    required String workspaceId,
    required String localPurchaseOrderId,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    await client
        .from('workspace_purchase_orders')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('workspace_id', workspaceId)
        .eq('local_purchase_order_id', localPurchaseOrderId);
  }

  Future<CloudPurchasingSyncResult> pushLocalPurchaseOrders({
    required String workspaceId,
    required List<ReorderRequest> reorders,
    Map<String, String?> workspaceItemIdsByLocalItemId = const {},
    Map<String, String?> workspaceSupplierIdsByLocalSupplierId = const {},
    required bool includeCosts,
  }) async {
    _requireWorkspaceId(workspaceId);
    final cloudOrders = [
      for (final reorder in reorders)
        CloudPurchaseOrder.fromLocalReorder(
          workspaceId: workspaceId,
          reorder: reorder,
          workspaceItemId: workspaceItemIdsByLocalItemId[reorder.itemId],
          workspaceSupplierId: reorder.supplierId == null
              ? null
              : workspaceSupplierIdsByLocalSupplierId[reorder.supplierId],
          includeCosts: includeCosts,
        ),
    ];
    final uploadedCount = await upsertWorkspacePurchaseOrders(cloudOrders);
    final downloaded = await pullWorkspacePurchaseOrders(workspaceId);
    return CloudPurchasingSyncResult(
      uploadedCount: uploadedCount,
      downloadedCount: downloaded.length,
      skippedCount: 0,
      isUploadOnly: true,
    );
  }

  Future<List<CloudPurchaseOrder>> pullWorkspacePurchaseOrders(
    String workspaceId, {
    String? status,
    DateTime? since,
  }) {
    return fetchWorkspacePurchaseOrders(
      workspaceId,
      status: status,
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
      throw StateError('Sign in to sync purchasing records.');
    }
    return user;
  }

  void _requireWorkspaceId(String workspaceId) {
    if (workspaceId.trim().isEmpty) {
      throw ArgumentError('A workspace is required.');
    }
  }
}
