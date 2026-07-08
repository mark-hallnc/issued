import '../database/model_mappers.dart';
import '../models/inventory_models.dart';
import '../models/supplier_models.dart';
import 'cloud_sync_service.dart';
import 'cloud_to_local_apply_service.dart';
import 'sync_conflict_resolution_models.dart';
import 'sync_merge_models.dart';
import 'sync_models.dart';
import 'sync_outbox_service.dart';

class SyncConflictResolutionService {
  const SyncConflictResolutionService({
    required this.syncService,
    required this.applyService,
    required this.outboxService,
  });

  final CloudSyncService syncService;
  final CloudToLocalApplyService applyService;
  final SyncOutboxService outboxService;

  List<SyncMergeConflict> listConflicts() {
    return syncService.getMergeConflicts();
  }

  Future<SyncConflictResolutionResult> resolveConflict(
    SyncMergeConflict conflict,
    SyncConflictResolutionAction action, {
    required String workspaceId,
    List<Item> localItems = const [],
    List<Supplier> localSuppliers = const [],
    String defaultUnitOfMeasureId = 'uom-each',
    String defaultLocationId = 'loc-main',
  }) {
    return switch (action) {
      SyncConflictResolutionAction.keepLocal => keepLocal(
        conflict,
        workspaceId: workspaceId,
      ),
      SyncConflictResolutionAction.useCloud => useCloud(
        conflict,
        workspaceId: workspaceId,
        localItems: localItems,
        localSuppliers: localSuppliers,
        defaultUnitOfMeasureId: defaultUnitOfMeasureId,
        defaultLocationId: defaultLocationId,
      ),
      SyncConflictResolutionAction.markReviewed => markReviewed(conflict),
      SyncConflictResolutionAction.retry => retryConflict(conflict),
      SyncConflictResolutionAction.unsupported => Future.value(
        SyncConflictResolutionResult.failure(
          action: action,
          entityType: conflict.entityType,
          localId: conflict.localId,
          cloudId: conflict.cloudId,
          message: 'This conflict cannot be resolved automatically.',
        ),
      ),
    };
  }

  Future<SyncConflictResolutionResult> keepLocal(
    SyncMergeConflict conflict, {
    required String workspaceId,
  }) async {
    final localId = conflict.localId;
    if (localId == null || localId.isEmpty) {
      return _failure(
        conflict,
        SyncConflictResolutionAction.keepLocal,
        'This conflict has no local record to upload.',
      );
    }
    if (!_canKeepLocal(conflict.entityType)) {
      return _failure(
        conflict,
        SyncConflictResolutionAction.keepLocal,
        _unsupportedMessage(conflict.entityType),
      );
    }
    await outboxService.enqueueUniqueChange(
      workspaceId: workspaceId,
      entity: conflict.entityType,
      entityId: localId,
      operation: _operationFor(conflict.entityType),
    );
    syncService.resolveMergeConflict(
      conflict,
      SyncConflictResolutionAction.keepLocal,
    );
    return SyncConflictResolutionResult(
      success: true,
      action: SyncConflictResolutionAction.keepLocal,
      entityType: conflict.entityType,
      localId: conflict.localId,
      cloudId: conflict.cloudId,
      message: 'Local version queued for upload. Run Sync now to finish.',
      requiresSyncRetry: true,
    );
  }

  Future<SyncConflictResolutionResult> useCloud(
    SyncMergeConflict conflict, {
    required String workspaceId,
    required List<Item> localItems,
    required List<Supplier> localSuppliers,
    required String defaultUnitOfMeasureId,
    required String defaultLocationId,
  }) async {
    if (conflict.entityType == CloudSyncEntity.item) {
      final cloudItems = await syncService.itemService.fetchWorkspaceItems(
        workspaceId,
      );
      final cloudItem = _firstWhereOrNull(
        cloudItems,
        (item) =>
            item.id == conflict.cloudId || item.localItemId == conflict.localId,
      );
      if (cloudItem == null) {
        return _failure(
          conflict,
          SyncConflictResolutionAction.useCloud,
          'Cloud item could not be found.',
        );
      }
      final localItem = _firstWhereOrNull(
        localItems,
        (item) => item.id == (cloudItem.localItemId ?? conflict.localId),
      );
      if (localItem == null) {
        await applyService.applyCloudItems(
          cloudItems: [cloudItem],
          localItems: localItems,
          defaultUnitOfMeasureId: defaultUnitOfMeasureId,
          defaultLocationId: defaultLocationId,
        );
      } else {
        final updated = localItem.copyWith(
          name: _nonBlank(cloudItem.name) ?? localItem.name,
          description:
              _nonBlank(cloudItem.description) ?? localItem.description,
          category: _nonBlank(cloudItem.category) ?? localItem.category,
          barcode: _nonBlank(cloudItem.barcode) ?? localItem.barcode,
          sku: _nonBlank(cloudItem.sku) ?? localItem.sku,
          minimumQuantity: cloudItem.reorderPoint ?? localItem.minimumQuantity,
          unitCost: cloudItem.unitCost ?? localItem.unitCost,
          isActive: cloudItem.isActive,
          updatedAt: cloudItem.updatedAt,
        );
        await applyService.database.upsertItem(updated.toCompanion());
      }
      syncService.resolveMergeConflict(
        conflict,
        SyncConflictResolutionAction.useCloud,
      );
      return _success(
        conflict,
        SyncConflictResolutionAction.useCloud,
        'Cloud item applied locally.',
      );
    }
    if (conflict.entityType == CloudSyncEntity.supplier) {
      final cloudSuppliers = await syncService.supplierService
          .fetchWorkspaceSuppliers(workspaceId);
      final cloudSupplier = _firstWhereOrNull(
        cloudSuppliers,
        (supplier) =>
            supplier.id == conflict.cloudId ||
            supplier.localSupplierId == conflict.localId,
      );
      if (cloudSupplier == null) {
        return _failure(
          conflict,
          SyncConflictResolutionAction.useCloud,
          'Cloud supplier could not be found.',
        );
      }
      final localSupplier = _firstWhereOrNull(
        localSuppliers,
        (supplier) => supplier.id == cloudSupplier.localSupplierId,
      );
      if (localSupplier == null) {
        await applyService.applyCloudSuppliers(
          cloudSuppliers: [cloudSupplier],
          localSuppliers: localSuppliers,
        );
      } else {
        final updated = localSupplier.copyWith(
          name: _nonBlank(cloudSupplier.name) ?? localSupplier.name,
          contactName:
              _nonBlank(cloudSupplier.contactName) ?? localSupplier.contactName,
          email: _nonBlank(cloudSupplier.email) ?? localSupplier.email,
          phone: _nonBlank(cloudSupplier.phone) ?? localSupplier.phone,
          website: _nonBlank(cloudSupplier.website) ?? localSupplier.website,
          address: _nonBlank(cloudSupplier.address) ?? localSupplier.address,
          accountNumber:
              _nonBlank(cloudSupplier.accountNumber) ??
              localSupplier.accountNumber,
          notes: _nonBlank(cloudSupplier.notes) ?? localSupplier.notes,
          defaultLeadTimeDays:
              cloudSupplier.defaultLeadTimeDays ??
              localSupplier.defaultLeadTimeDays,
          minimumOrderAmount:
              cloudSupplier.minimumOrderAmount ??
              localSupplier.minimumOrderAmount,
          isActive: cloudSupplier.isActive,
          updatedAt: cloudSupplier.updatedAt,
        );
        await applyService.database.upsertSupplier(updated.toCompanion());
      }
      syncService.resolveMergeConflict(
        conflict,
        SyncConflictResolutionAction.useCloud,
      );
      return _success(
        conflict,
        SyncConflictResolutionAction.useCloud,
        'Cloud supplier applied locally.',
      );
    }
    return _failure(
      conflict,
      SyncConflictResolutionAction.useCloud,
      _unsupportedMessage(conflict.entityType),
    );
  }

  Future<SyncConflictResolutionResult> markReviewed(
    SyncMergeConflict conflict,
  ) async {
    syncService.resolveMergeConflict(
      conflict,
      SyncConflictResolutionAction.markReviewed,
    );
    return _success(
      conflict,
      SyncConflictResolutionAction.markReviewed,
      'Conflict marked reviewed.',
    );
  }

  Future<SyncConflictResolutionResult> retryConflict(
    SyncMergeConflict conflict,
  ) async {
    return _success(
      conflict,
      SyncConflictResolutionAction.retry,
      'Run Sync now to retry this entity.',
      requiresSyncRetry: true,
    );
  }

  bool _canKeepLocal(CloudSyncEntity entity) {
    return switch (entity) {
      CloudSyncEntity.item ||
      CloudSyncEntity.supplier ||
      CloudSyncEntity.transaction ||
      CloudSyncEntity.checkout ||
      CloudSyncEntity.purchaseOrder ||
      CloudSyncEntity.count ||
      CloudSyncEntity.countLine => true,
      _ => false,
    };
  }

  CloudSyncOperation _operationFor(CloudSyncEntity entity) {
    return entity == CloudSyncEntity.transaction
        ? CloudSyncOperation.create
        : CloudSyncOperation.update;
  }

  SyncConflictResolutionResult _success(
    SyncMergeConflict conflict,
    SyncConflictResolutionAction action,
    String message, {
    bool requiresSyncRetry = false,
  }) {
    return SyncConflictResolutionResult(
      success: true,
      action: action,
      entityType: conflict.entityType,
      localId: conflict.localId,
      cloudId: conflict.cloudId,
      message: message,
      requiresSyncRetry: requiresSyncRetry,
    );
  }

  SyncConflictResolutionResult _failure(
    SyncMergeConflict conflict,
    SyncConflictResolutionAction action,
    String message, {
    Object? error,
  }) {
    return SyncConflictResolutionResult.failure(
      action: action,
      entityType: conflict.entityType,
      localId: conflict.localId,
      cloudId: conflict.cloudId,
      message: message,
      error: error,
    );
  }
}

String _unsupportedMessage(CloudSyncEntity entity) {
  return switch (entity) {
    CloudSyncEntity.inventoryBalance =>
      'Balance conflicts should be resolved by reviewing transactions or doing a count.',
    CloudSyncEntity.transaction =>
      'Transaction history is append-only. Review duplicates instead of overwriting movement history.',
    CloudSyncEntity.checkout =>
      'Checkout conflicts can affect return state and balances, so automatic cloud overwrite is disabled.',
    CloudSyncEntity.purchaseOrder =>
      'Purchasing conflicts can affect received state, so automatic cloud overwrite is disabled.',
    CloudSyncEntity.count || CloudSyncEntity.countLine =>
      'Cycle count conflicts can create duplicate variance adjustments, so automatic cloud overwrite is disabled.',
    _ => 'This conflict type is review-only.',
  };
}

T? _firstWhereOrNull<T>(Iterable<T> values, bool Function(T value) test) {
  for (final value in values) {
    if (test(value)) {
      return value;
    }
  }
  return null;
}

String? _nonBlank(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
