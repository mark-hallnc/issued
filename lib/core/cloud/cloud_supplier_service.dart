import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/supplier_models.dart';
import 'cloud_auth_service.dart';
import 'cloud_supplier_models.dart';
import 'supabase_config.dart';

class CloudSupplierSyncResult {
  const CloudSupplierSyncResult({
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

class CloudSupplierService {
  const CloudSupplierService({
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

  Future<List<CloudSupplier>> fetchWorkspaceSuppliers(
    String workspaceId, {
    DateTime? since,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    final rows = since == null
        ? await client
              .from('workspace_suppliers')
              .select()
              .eq('workspace_id', workspaceId)
              .order('name', ascending: true)
        : await client
              .from('workspace_suppliers')
              .select()
              .eq('workspace_id', workspaceId)
              .gte('updated_at', since.toUtc().toIso8601String())
              .order('name', ascending: true);
    return [
      for (final row in rows as List<dynamic>)
        CloudSupplier.fromJson(row as Map<String, dynamic>),
    ];
  }

  Future<CloudSupplier> upsertWorkspaceSupplier(CloudSupplier supplier) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(supplier.workspaceId);
    final row = await client
        .from('workspace_suppliers')
        .upsert(
          supplier.toUpsertJson(),
          onConflict: 'workspace_id,local_supplier_id',
        )
        .select()
        .single();
    return CloudSupplier.fromJson(row);
  }

  Future<int> upsertWorkspaceSuppliers(List<CloudSupplier> suppliers) async {
    if (suppliers.isEmpty) {
      return 0;
    }
    final client = _requireClient();
    _requireUser();
    final workspaceId = suppliers.first.workspaceId;
    _requireWorkspaceId(workspaceId);
    for (final supplier in suppliers) {
      if (supplier.workspaceId != workspaceId) {
        throw ArgumentError('All suppliers must belong to the same workspace.');
      }
    }
    await client.from('workspace_suppliers').upsert([
      for (final supplier in suppliers) supplier.toUpsertJson(),
    ], onConflict: 'workspace_id,local_supplier_id');
    return suppliers.length;
  }

  Future<CloudSupplier?> findCloudSupplierByLocalId({
    required String workspaceId,
    required String localSupplierId,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    final row = await client
        .from('workspace_suppliers')
        .select()
        .eq('workspace_id', workspaceId)
        .eq('local_supplier_id', localSupplierId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    return CloudSupplier.fromJson(row);
  }

  Future<void> softDeleteWorkspaceSupplier({
    required String workspaceId,
    required String localSupplierId,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    await client
        .from('workspace_suppliers')
        .update({
          'deleted_at': DateTime.now().toUtc().toIso8601String(),
          'is_active': false,
        })
        .eq('workspace_id', workspaceId)
        .eq('local_supplier_id', localSupplierId);
  }

  Future<CloudSupplierSyncResult> pushLocalSuppliers({
    required String workspaceId,
    required List<Supplier> suppliers,
    required bool includeCosts,
  }) async {
    _requireWorkspaceId(workspaceId);
    final cloudSuppliers = [
      for (final supplier in suppliers)
        CloudSupplier.fromLocalSupplier(
          workspaceId: workspaceId,
          supplier: supplier,
          includeCosts: includeCosts,
        ),
    ];
    final uploadedCount = await upsertWorkspaceSuppliers(cloudSuppliers);
    final downloaded = await pullWorkspaceSuppliers(workspaceId);
    return CloudSupplierSyncResult(
      uploadedCount: uploadedCount,
      downloadedCount: downloaded.length,
      skippedCount: 0,
      isUploadOnly: true,
    );
  }

  Future<List<CloudSupplier>> pullWorkspaceSuppliers(
    String workspaceId, {
    DateTime? since,
  }) {
    return fetchWorkspaceSuppliers(workspaceId, since: since);
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
      throw StateError('Sign in to sync suppliers.');
    }
    return user;
  }

  void _requireWorkspaceId(String workspaceId) {
    if (workspaceId.trim().isEmpty) {
      throw ArgumentError('A workspace is required.');
    }
  }
}
