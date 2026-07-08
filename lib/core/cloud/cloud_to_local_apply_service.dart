import '../database/app_database.dart';
import '../database/model_mappers.dart';
import '../models/checkout_models.dart';
import '../models/cycle_count_models.dart';
import '../models/inventory_models.dart';
import '../models/item_location_balance_models.dart';
import '../models/reorder_models.dart';
import '../models/supplier_models.dart';
import 'cloud_checkout_models.dart';
import 'cloud_cycle_count_models.dart';
import 'cloud_inventory_balance_models.dart';
import 'cloud_inventory_transaction_models.dart';
import 'cloud_item_models.dart';
import 'cloud_purchasing_models.dart';
import 'cloud_supplier_models.dart';
import 'sync_identity_helpers.dart';
import 'sync_merge_models.dart';
import 'sync_models.dart';

class CloudToLocalApplyService {
  const CloudToLocalApplyService({required this.database});

  final AppDatabase database;

  Future<SyncMergeSummary> applyCloudItems({
    required List<CloudWorkspaceItem> cloudItems,
    required List<Item> localItems,
    required String defaultUnitOfMeasureId,
    required String defaultLocationId,
    DateTime? lastFullSyncAt,
  }) async {
    var summary = const SyncMergeSummary();
    final workingItems = [...localItems];

    for (final cloudItem in cloudItems) {
      if (cloudItem.deletedAt != null || !cloudItem.isActive) {
        summary = summary.increment(
          SyncMergeDecision.deletedOrArchived,
          message:
              'Skipped archived cloud item ${cloudItem.localItemId ?? cloudItem.id}.',
        );
        continue;
      }
      if (normalizedId(cloudItem.name) == null) {
        summary = summary.increment(
          SyncMergeDecision.unsupported,
          message: 'Skipped cloud item ${cloudItem.id} without a name.',
        );
        continue;
      }

      final match = matchCloudItemToLocal(
        cloudItem: cloudItem,
        localItems: workingItems,
      );
      if (match.isDuplicate) {
        summary = summary.increment(
          SyncMergeDecision.duplicate,
          message: match.duplicateMessage,
        );
        continue;
      }

      final localItem = match.item;
      if (localItem == null) {
        final localItemId = normalizedId(cloudItem.localItemId);
        if (localItemId == null) {
          summary = summary.increment(
            SyncMergeDecision.unsupported,
            message:
                'Skipped cloud item ${cloudItem.id}; it has no local item id.',
          );
          continue;
        }
        final created = _itemFromCloud(
          cloudItem,
          localItemId: localItemId,
          defaultUnitOfMeasureId: defaultUnitOfMeasureId,
          defaultLocationId: defaultLocationId,
        );
        await database.upsertItem(created.toCompanion());
        workingItems.add(created);
        summary = summary.increment(
          SyncMergeDecision.createLocal,
          message: 'Created local item ${created.name} from cloud catalog.',
        );
        continue;
      }

      final decision = _safeUpdateDecision(
        localUpdatedAt: localItem.updatedAt,
        cloudUpdatedAt: cloudItem.updatedAt,
        lastFullSyncAt: lastFullSyncAt,
      );
      if (decision == SyncMergeDecision.conflict) {
        summary = summary.addConflict(
          mergeConflict(
            entityType: CloudSyncEntity.item,
            localId: localItem.id,
            cloudId: cloudItem.id,
            field: 'updatedAt',
            localValue: localItem.updatedAt,
            cloudValue: cloudItem.updatedAt,
            message:
                'Item ${localItem.name} changed locally and in cloud since last sync.',
          ),
        );
        continue;
      }
      if (decision == SyncMergeDecision.skipLocalNewer) {
        summary = summary.increment(SyncMergeDecision.skipLocalNewer);
        continue;
      }

      final updated = _mergeItem(
        localItem,
        cloudItem,
        allowOverwrite: lastFullSyncAt != null,
      );
      if (_itemsEquivalent(localItem, updated)) {
        summary = summary.increment(SyncMergeDecision.skipCloudNewerButUnsafe);
        continue;
      }
      await database.upsertItem(updated.toCompanion());
      _replaceItem(workingItems, updated);
      summary = summary.increment(
        SyncMergeDecision.updateLocal,
        message: 'Updated local item ${updated.name} from cloud catalog.',
      );
    }

    return summary;
  }

  Future<SyncMergeSummary> applyCloudSuppliers({
    required List<CloudSupplier> cloudSuppliers,
    required List<Supplier> localSuppliers,
    DateTime? lastFullSyncAt,
  }) async {
    var summary = const SyncMergeSummary();
    final workingSuppliers = [...localSuppliers];

    for (final cloudSupplier in cloudSuppliers) {
      if (cloudSupplier.deletedAt != null || !cloudSupplier.isActive) {
        summary = summary.increment(
          SyncMergeDecision.deletedOrArchived,
          message:
              'Skipped archived cloud supplier ${cloudSupplier.localSupplierId}.',
        );
        continue;
      }
      if (normalizedId(cloudSupplier.name) == null) {
        summary = summary.increment(
          SyncMergeDecision.unsupported,
          message: 'Skipped cloud supplier ${cloudSupplier.id} without a name.',
        );
        continue;
      }

      final match = matchCloudSupplierToLocal(
        cloudSupplier: cloudSupplier,
        localSuppliers: workingSuppliers,
      );
      if (match.isDuplicate) {
        summary = summary.increment(
          SyncMergeDecision.duplicate,
          message: match.duplicateMessage,
        );
        continue;
      }

      final localSupplier = match.supplier;
      if (localSupplier == null) {
        final localSupplierId = normalizedId(cloudSupplier.localSupplierId);
        if (localSupplierId == null) {
          summary = summary.increment(
            SyncMergeDecision.unsupported,
            message:
                'Skipped cloud supplier ${cloudSupplier.id}; it has no local supplier id.',
          );
          continue;
        }
        final created = _supplierFromCloud(
          cloudSupplier,
          localSupplierId: localSupplierId,
        );
        await database.upsertSupplier(created.toCompanion());
        workingSuppliers.add(created);
        summary = summary.increment(
          SyncMergeDecision.createLocal,
          message: 'Created local supplier ${created.name} from cloud.',
        );
        continue;
      }

      final decision = _safeUpdateDecision(
        localUpdatedAt: localSupplier.updatedAt,
        cloudUpdatedAt: cloudSupplier.updatedAt,
        lastFullSyncAt: lastFullSyncAt,
      );
      if (decision == SyncMergeDecision.conflict) {
        summary = summary.addConflict(
          mergeConflict(
            entityType: CloudSyncEntity.supplier,
            localId: localSupplier.id,
            cloudId: cloudSupplier.id,
            field: 'updatedAt',
            localValue: localSupplier.updatedAt,
            cloudValue: cloudSupplier.updatedAt,
            message:
                'Supplier ${localSupplier.name} changed locally and in cloud since last sync.',
          ),
        );
        continue;
      }
      if (decision == SyncMergeDecision.skipLocalNewer) {
        summary = summary.increment(SyncMergeDecision.skipLocalNewer);
        continue;
      }

      final updated = _mergeSupplier(
        localSupplier,
        cloudSupplier,
        allowOverwrite: lastFullSyncAt != null,
      );
      if (_suppliersEquivalent(localSupplier, updated)) {
        summary = summary.increment(SyncMergeDecision.skipCloudNewerButUnsafe);
        continue;
      }
      await database.upsertSupplier(updated.toCompanion());
      _replaceSupplier(workingSuppliers, updated);
      summary = summary.increment(
        SyncMergeDecision.updateLocal,
        message: 'Updated local supplier ${updated.name} from cloud.',
      );
    }

    return summary;
  }

  Future<SyncMergeSummary> applyCloudInventoryBalances({
    required List<CloudInventoryBalance> cloudBalances,
    required List<ItemLocationBalance> localBalances,
  }) async {
    return SyncMergeSummary(
      unsupportedCount: cloudBalances.length,
      messages: const [
        'Inventory balance cloud-to-local apply is staged until durable outbox/conflict rules are available.',
      ],
    );
  }

  Future<SyncMergeSummary> applyCloudInventoryTransactions({
    required List<CloudInventoryTransaction> cloudTransactions,
    required List<InventoryTransaction> localTransactions,
  }) async {
    return SyncMergeSummary(
      unsupportedCount: cloudTransactions.length,
      messages: const [
        'Transaction cloud-to-local apply is staged to avoid double-applying movement effects.',
      ],
    );
  }

  Future<SyncMergeSummary> applyCloudCheckouts({
    required List<CloudCheckout> cloudCheckouts,
    required List<CheckoutRecord> localCheckouts,
  }) async {
    return SyncMergeSummary(
      unsupportedCount: cloudCheckouts.length,
      messages: const [
        'Checkout cloud-to-local apply is staged to avoid overwriting local return state.',
      ],
    );
  }

  Future<SyncMergeSummary> applyCloudPurchasing({
    required List<CloudPurchaseOrder> cloudPurchaseOrders,
    required List<ReorderRequest> localPurchaseOrders,
  }) async {
    return SyncMergeSummary(
      unsupportedCount: cloudPurchaseOrders.length,
      messages: const [
        'Purchasing cloud-to-local apply is staged to avoid recalculating received inventory.',
      ],
    );
  }

  Future<SyncMergeSummary> applyCloudCycleCounts({
    required List<CloudCycleCount> cloudCycleCounts,
    required List<CloudCycleCountLine> cloudCycleCountLines,
    required List<CycleCountSession> localCycleCounts,
    required List<CycleCountLine> localCycleCountLines,
  }) async {
    return SyncMergeSummary(
      unsupportedCount: cloudCycleCounts.length + cloudCycleCountLines.length,
      messages: const [
        'Cycle count cloud-to-local apply is staged to avoid duplicate variance adjustments.',
      ],
    );
  }
}

SyncMergeDecision _safeUpdateDecision({
  required DateTime localUpdatedAt,
  required DateTime cloudUpdatedAt,
  required DateTime? lastFullSyncAt,
}) {
  if (lastFullSyncAt != null &&
      localUpdatedAt.isAfter(lastFullSyncAt) &&
      cloudUpdatedAt.isAfter(lastFullSyncAt)) {
    return SyncMergeDecision.conflict;
  }
  if (localUpdatedAt.isAfter(cloudUpdatedAt)) {
    return SyncMergeDecision.skipLocalNewer;
  }
  if (cloudUpdatedAt.isAfter(localUpdatedAt)) {
    return SyncMergeDecision.updateLocal;
  }
  return SyncMergeDecision.skipCloudNewerButUnsafe;
}

Item _itemFromCloud(
  CloudWorkspaceItem cloudItem, {
  required String localItemId,
  required String defaultUnitOfMeasureId,
  required String defaultLocationId,
}) {
  final now = DateTime.now();
  return Item(
    id: localItemId,
    name: cloudItem.name,
    description: cloudItem.description ?? '',
    itemType: ItemType.consumable,
    category: cloudItem.category ?? '',
    locationId: defaultLocationId,
    quantityOnHand: 0,
    minimumQuantity: cloudItem.reorderPoint ?? 0,
    unitOfMeasureId: defaultUnitOfMeasureId,
    purchaseUnitOfMeasureId: null,
    purchaseToStockConversionFactor: null,
    purchaseUnitLabel: null,
    barcode: normalizedId(cloudItem.barcode),
    sku: normalizedId(cloudItem.sku),
    supplierId: null,
    supplier: null,
    unitCost: cloudItem.unitCost,
    photoPath: null,
    isActive: cloudItem.isActive,
    allowFractionalQuantity: false,
    createdAt: cloudItem.createdAt,
    updatedAt: cloudItem.updatedAt.isAfter(cloudItem.createdAt)
        ? cloudItem.updatedAt
        : now,
  );
}

Item _mergeItem(
  Item localItem,
  CloudWorkspaceItem cloudItem, {
  required bool allowOverwrite,
}) {
  final shouldOverwrite = allowOverwrite;
  return localItem.copyWith(
    name: shouldOverwrite && normalizedId(cloudItem.name) != null
        ? cloudItem.name
        : null,
    description: _mergeString(
      localItem.description,
      cloudItem.description,
      allowOverwrite: shouldOverwrite,
    ),
    category: _mergeString(
      localItem.category,
      cloudItem.category,
      allowOverwrite: shouldOverwrite,
    ),
    barcode: _mergeString(
      localItem.barcode,
      cloudItem.barcode,
      allowOverwrite: shouldOverwrite,
    ),
    sku: _mergeString(
      localItem.sku,
      cloudItem.sku,
      allowOverwrite: shouldOverwrite,
    ),
    minimumQuantity: shouldOverwrite || localItem.minimumQuantity == 0
        ? cloudItem.reorderPoint
        : null,
    unitCost: shouldOverwrite || localItem.unitCost == null
        ? cloudItem.unitCost
        : null,
    isActive: shouldOverwrite ? cloudItem.isActive : null,
    updatedAt: cloudItem.updatedAt,
  );
}

Supplier _supplierFromCloud(
  CloudSupplier cloudSupplier, {
  required String localSupplierId,
}) {
  return Supplier(
    id: localSupplierId,
    name: cloudSupplier.name,
    contactName: normalizedId(cloudSupplier.contactName),
    email: normalizedId(cloudSupplier.email),
    phone: normalizedId(cloudSupplier.phone),
    website: normalizedId(cloudSupplier.website),
    address: normalizedId(cloudSupplier.address),
    accountNumber: normalizedId(cloudSupplier.accountNumber),
    notes: normalizedId(cloudSupplier.notes),
    defaultLeadTimeDays: cloudSupplier.defaultLeadTimeDays,
    minimumOrderAmount: cloudSupplier.minimumOrderAmount,
    isActive: cloudSupplier.isActive,
    createdAt: cloudSupplier.createdAt,
    updatedAt: cloudSupplier.updatedAt,
  );
}

Supplier _mergeSupplier(
  Supplier localSupplier,
  CloudSupplier cloudSupplier, {
  required bool allowOverwrite,
}) {
  return localSupplier.copyWith(
    name: allowOverwrite ? normalizedId(cloudSupplier.name) : null,
    contactName: _mergeString(
      localSupplier.contactName,
      cloudSupplier.contactName,
      allowOverwrite: allowOverwrite,
    ),
    email: _mergeString(
      localSupplier.email,
      cloudSupplier.email,
      allowOverwrite: allowOverwrite,
    ),
    phone: _mergeString(
      localSupplier.phone,
      cloudSupplier.phone,
      allowOverwrite: allowOverwrite,
    ),
    website: _mergeString(
      localSupplier.website,
      cloudSupplier.website,
      allowOverwrite: allowOverwrite,
    ),
    address: _mergeString(
      localSupplier.address,
      cloudSupplier.address,
      allowOverwrite: allowOverwrite,
    ),
    accountNumber: _mergeString(
      localSupplier.accountNumber,
      cloudSupplier.accountNumber,
      allowOverwrite: allowOverwrite,
    ),
    notes: _mergeString(
      localSupplier.notes,
      cloudSupplier.notes,
      allowOverwrite: allowOverwrite,
    ),
    defaultLeadTimeDays:
        allowOverwrite || localSupplier.defaultLeadTimeDays == null
        ? cloudSupplier.defaultLeadTimeDays ?? localSupplier.defaultLeadTimeDays
        : null,
    minimumOrderAmount:
        allowOverwrite || localSupplier.minimumOrderAmount == null
        ? cloudSupplier.minimumOrderAmount ?? localSupplier.minimumOrderAmount
        : null,
    isActive: allowOverwrite ? cloudSupplier.isActive : null,
    updatedAt: cloudSupplier.updatedAt,
  );
}

String? _mergeString(
  String? localValue,
  String? cloudValue, {
  bool allowOverwrite = true,
}) {
  final normalizedCloud = normalizedId(cloudValue);
  if (normalizedCloud == null) {
    return null;
  }
  if (allowOverwrite || normalizedId(localValue) == null) {
    return normalizedCloud;
  }
  return null;
}

void _replaceItem(List<Item> items, Item updated) {
  final index = items.indexWhere((item) => item.id == updated.id);
  if (index != -1) {
    items[index] = updated;
  }
}

void _replaceSupplier(List<Supplier> suppliers, Supplier updated) {
  final index = suppliers.indexWhere((supplier) => supplier.id == updated.id);
  if (index != -1) {
    suppliers[index] = updated;
  }
}

bool _itemsEquivalent(Item left, Item right) {
  return left.name == right.name &&
      left.description == right.description &&
      left.category == right.category &&
      left.barcode == right.barcode &&
      left.sku == right.sku &&
      left.minimumQuantity == right.minimumQuantity &&
      left.unitCost == right.unitCost &&
      left.isActive == right.isActive;
}

bool _suppliersEquivalent(Supplier left, Supplier right) {
  return left.name == right.name &&
      left.contactName == right.contactName &&
      left.email == right.email &&
      left.phone == right.phone &&
      left.website == right.website &&
      left.address == right.address &&
      left.accountNumber == right.accountNumber &&
      left.notes == right.notes &&
      left.defaultLeadTimeDays == right.defaultLeadTimeDays &&
      left.minimumOrderAmount == right.minimumOrderAmount &&
      left.isActive == right.isActive;
}
