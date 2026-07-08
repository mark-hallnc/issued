import '../database/app_database.dart';
import 'cloud_checkout_service.dart';
import 'cloud_cycle_count_service.dart';
import 'cloud_inventory_balance_service.dart';
import 'cloud_inventory_transaction_service.dart';
import 'cloud_item_service.dart';
import 'cloud_purchasing_service.dart';
import 'cloud_supplier_service.dart';
import 'cloud_sync_service.dart';
import 'sync_models.dart';
import 'sync_outbox_service.dart';
import 'sync_reconciliation_models.dart';

class SyncReconciliationService {
  const SyncReconciliationService({
    required this.database,
    required this.syncService,
    required this.outboxService,
    required this.itemService,
    required this.balanceService,
    required this.transactionService,
    required this.checkoutService,
    required this.supplierService,
    required this.purchasingService,
    required this.cycleCountService,
  });

  final AppDatabase database;
  final CloudSyncService syncService;
  final SyncOutboxService outboxService;
  final CloudItemService itemService;
  final CloudInventoryBalanceService balanceService;
  final CloudInventoryTransactionService transactionService;
  final CloudCheckoutService checkoutService;
  final CloudSupplierService supplierService;
  final CloudPurchasingService purchasingService;
  final CloudCycleCountService cycleCountService;

  Future<SyncReconciliationSummary> buildSummary(
    String workspaceId, {
    String? workspaceName,
  }) async {
    final entities = <SyncEntityReconciliation>[];
    final messages = <String>[];
    for (final entity in _supportedEntities) {
      final reconciliation = await reconcileEntity(entity, workspaceId);
      entities.add(reconciliation);
      if (reconciliation.status != SyncHealthStatus.healthy) {
        messages.add('${syncEntityLabel(entity)}: ${reconciliation.message}');
      }
    }
    return SyncReconciliationSummary(
      workspaceId: workspaceId,
      workspaceName: workspaceName,
      checkedAt: DateTime.now(),
      overallStatus: _overallStatus(entities),
      entities: entities,
      messages: messages,
    );
  }

  Future<SyncEntityReconciliation> reconcileEntity(
    CloudSyncEntity entity,
    String workspaceId,
  ) async {
    try {
      final localCount = await getLocalEntityCount(entity);
      final cloudCount = await getCloudEntityCount(entity, workspaceId);
      final pendingCount = await getPendingCount(entity, workspaceId);
      final failedCount = await getFailedCount(entity, workspaceId);
      final conflictCount = getConflictCount(entity);
      final lastLocalChangeAt = await getLastLocalChangeAt(entity);
      final lastCloudChangeAt = await getLastCloudChangeAt(entity, workspaceId);
      final status = _entityStatus(
        localCount: localCount,
        cloudCount: cloudCount,
        pendingCount: pendingCount,
        failedCount: failedCount,
        conflictCount: conflictCount,
      );
      return SyncEntityReconciliation(
        entityType: entity,
        localCount: localCount,
        cloudCount: cloudCount,
        pendingUploadCount: pendingCount,
        failedUploadCount: failedCount,
        conflictCount: conflictCount,
        lastLocalChangeAt: lastLocalChangeAt,
        lastCloudChangeAt: lastCloudChangeAt,
        status: status,
        message: _messageFor(
          status: status,
          localCount: localCount,
          cloudCount: cloudCount,
          pendingCount: pendingCount,
          failedCount: failedCount,
          conflictCount: conflictCount,
        ),
      );
    } catch (error) {
      return SyncEntityReconciliation(
        entityType: entity,
        localCount: await _safeLocalCount(entity),
        cloudCount: null,
        pendingUploadCount: await getPendingCount(entity, workspaceId),
        failedUploadCount: await getFailedCount(entity, workspaceId),
        conflictCount: getConflictCount(entity),
        status: SyncHealthStatus.unknown,
        message: 'Cloud count unavailable: $error',
      );
    }
  }

  Future<int?> getLocalEntityCount(CloudSyncEntity entity) async {
    return switch (entity) {
      CloudSyncEntity.item => (await database.getAllItems()).length,
      CloudSyncEntity.inventoryBalance =>
        (await database.getAllItemLocationBalances()).length,
      CloudSyncEntity.transaction => (await database.getAllTransactions()).length,
      CloudSyncEntity.checkout =>
        (await database.getAllCheckoutRecords()).length,
      CloudSyncEntity.supplier => (await database.getAllSuppliers()).length,
      CloudSyncEntity.purchaseOrder =>
        (await database.getAllReorderRequests()).length,
      CloudSyncEntity.count =>
        (await database.getAllCycleCountSessions()).length,
      CloudSyncEntity.countLine =>
        (await database.getAllCycleCountLines()).length,
      _ => null,
    };
  }

  Future<int?> getCloudEntityCount(CloudSyncEntity entity, String workspaceId) {
    return switch (entity) {
      CloudSyncEntity.item => itemService.countWorkspaceItems(workspaceId),
      CloudSyncEntity.inventoryBalance => balanceService.countWorkspaceBalances(
        workspaceId,
      ),
      CloudSyncEntity.transaction =>
        transactionService.countWorkspaceTransactions(workspaceId),
      CloudSyncEntity.checkout => checkoutService.countWorkspaceCheckouts(
        workspaceId,
      ),
      CloudSyncEntity.supplier => supplierService.countWorkspaceSuppliers(
        workspaceId,
      ),
      CloudSyncEntity.purchaseOrder =>
        purchasingService.countWorkspacePurchaseOrders(workspaceId),
      CloudSyncEntity.count => cycleCountService.countWorkspaceCycleCounts(
        workspaceId,
      ),
      CloudSyncEntity.countLine =>
        cycleCountService.countWorkspaceCycleCountLines(workspaceId),
      _ => Future<int?>.value(null),
    };
  }

  Future<int> getPendingCount(
    CloudSyncEntity entity,
    String workspaceId,
  ) async {
    final entries = await outboxService.getEntriesForWorkspace(workspaceId);
    return entries
        .where(
          (entry) =>
              entry.entity == entity &&
              (entry.status == SyncOutboxStatus.pending ||
                  entry.status == SyncOutboxStatus.syncing),
        )
        .length;
  }

  Future<int> getFailedCount(CloudSyncEntity entity, String workspaceId) async {
    final entries = await outboxService.getEntriesForWorkspace(workspaceId);
    return entries
        .where(
          (entry) =>
              entry.entity == entity && entry.status == SyncOutboxStatus.failed,
        )
        .length;
  }

  int getConflictCount(CloudSyncEntity entity) {
    return syncService
        .getMergeConflicts()
        .where((conflict) => conflict.entityType == entity)
        .length;
  }

  Future<DateTime?> getLastLocalChangeAt(CloudSyncEntity entity) async {
    return switch (entity) {
      CloudSyncEntity.item => _maxDate(
        (await database.getAllItems()).map((item) => item.updatedAt),
      ),
      CloudSyncEntity.inventoryBalance => _maxDate(
        (await database.getAllItemLocationBalances()).map(
          (balance) => balance.updatedAt,
        ),
      ),
      CloudSyncEntity.transaction => _maxDate(
        (await database.getAllTransactions()).map(
          (transaction) => transaction.createdAt,
        ),
      ),
      CloudSyncEntity.checkout => _maxDate(
        (await database.getAllCheckoutRecords()).map(
          (checkout) => checkout.returnedAt ?? checkout.checkedOutAt,
        ),
      ),
      CloudSyncEntity.supplier => _maxDate(
        (await database.getAllSuppliers()).map(
          (supplier) => supplier.updatedAt,
        ),
      ),
      CloudSyncEntity.purchaseOrder => _maxDate(
        (await database.getAllReorderRequests()).map(
          (request) =>
              request.receivedAt ??
              request.cancelledAt ??
              request.orderedAt ??
              request.createdAt,
        ),
      ),
      CloudSyncEntity.count => _maxDate(
        (await database.getAllCycleCountSessions()).map(
          (session) =>
              session.approvedAt ?? session.submittedAt ?? session.createdAt,
        ),
      ),
      CloudSyncEntity.countLine => null,
      _ => null,
    };
  }

  Future<DateTime?> getLastCloudChangeAt(
    CloudSyncEntity entity,
    String workspaceId,
  ) {
    return switch (entity) {
      CloudSyncEntity.item => itemService.latestWorkspaceItemUpdateAt(
        workspaceId,
      ),
      CloudSyncEntity.inventoryBalance =>
        balanceService.latestWorkspaceBalanceUpdateAt(workspaceId),
      CloudSyncEntity.transaction =>
        transactionService.latestWorkspaceTransactionUpdateAt(workspaceId),
      CloudSyncEntity.checkout =>
        checkoutService.latestWorkspaceCheckoutUpdateAt(workspaceId),
      CloudSyncEntity.supplier =>
        supplierService.latestWorkspaceSupplierUpdateAt(workspaceId),
      CloudSyncEntity.purchaseOrder =>
        purchasingService.latestWorkspacePurchaseOrderUpdateAt(workspaceId),
      CloudSyncEntity.count =>
        cycleCountService.latestWorkspaceCycleCountUpdateAt(workspaceId),
      CloudSyncEntity.countLine =>
        cycleCountService.latestWorkspaceCycleCountLineUpdateAt(workspaceId),
      _ => Future<DateTime?>.value(null),
    };
  }

  Future<int?> _safeLocalCount(CloudSyncEntity entity) async {
    try {
      return getLocalEntityCount(entity);
    } catch (_) {
      return null;
    }
  }
}

const _supportedEntities = [
  CloudSyncEntity.item,
  CloudSyncEntity.inventoryBalance,
  CloudSyncEntity.transaction,
  CloudSyncEntity.checkout,
  CloudSyncEntity.supplier,
  CloudSyncEntity.purchaseOrder,
  CloudSyncEntity.count,
  CloudSyncEntity.countLine,
];

SyncHealthStatus _overallStatus(List<SyncEntityReconciliation> entities) {
  if (entities.any((entity) => entity.status == SyncHealthStatus.failed)) {
    return SyncHealthStatus.failed;
  }
  if (entities.any((entity) => entity.status == SyncHealthStatus.conflict)) {
    return SyncHealthStatus.conflict;
  }
  if (entities.any((entity) => entity.status == SyncHealthStatus.mismatch)) {
    return SyncHealthStatus.mismatch;
  }
  if (entities.any((entity) => entity.status == SyncHealthStatus.pending)) {
    return SyncHealthStatus.pending;
  }
  if (entities.any((entity) => entity.status == SyncHealthStatus.unknown)) {
    return SyncHealthStatus.unknown;
  }
  return SyncHealthStatus.healthy;
}

SyncHealthStatus _entityStatus({
  required int? localCount,
  required int? cloudCount,
  required int pendingCount,
  required int failedCount,
  required int conflictCount,
}) {
  if (failedCount > 0) {
    return SyncHealthStatus.failed;
  }
  if (conflictCount > 0) {
    return SyncHealthStatus.conflict;
  }
  if (pendingCount > 0) {
    return SyncHealthStatus.pending;
  }
  if (localCount == null || cloudCount == null) {
    return SyncHealthStatus.unknown;
  }
  if (localCount != cloudCount) {
    return SyncHealthStatus.mismatch;
  }
  return SyncHealthStatus.healthy;
}

String _messageFor({
  required SyncHealthStatus status,
  required int? localCount,
  required int? cloudCount,
  required int pendingCount,
  required int failedCount,
  required int conflictCount,
}) {
  return switch (status) {
    SyncHealthStatus.healthy => 'Local and cloud counts match.',
    SyncHealthStatus.pending => '$pendingCount local changes are waiting.',
    SyncHealthStatus.failed =>
      '$failedCount uploads failed and can be retried.',
    SyncHealthStatus.conflict => '$conflictCount records need review.',
    SyncHealthStatus.mismatch =>
      'Local count ${localCount ?? 'unknown'} does not match cloud count ${cloudCount ?? 'unknown'}.',
    SyncHealthStatus.unsupported => 'This entity is not reconciled yet.',
    SyncHealthStatus.unknown => 'Reconciliation could not be completed.',
  };
}

DateTime? _maxDate(Iterable<DateTime?> values) {
  DateTime? max;
  for (final value in values) {
    if (value == null) {
      continue;
    }
    if (max == null || value.isAfter(max)) {
      max = value;
    }
  }
  return max;
}
