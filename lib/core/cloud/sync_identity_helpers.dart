import '../models/inventory_models.dart';
import '../models/supplier_models.dart';
import 'cloud_item_models.dart';
import 'cloud_supplier_models.dart';
import 'sync_merge_models.dart';
import 'sync_models.dart';

String? normalizedId(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

String? normalizedLookup(String? value) {
  final trimmed = normalizedId(value);
  return trimmed?.toLowerCase();
}

ItemMatchResult matchCloudItemToLocal({
  required CloudWorkspaceItem cloudItem,
  required List<Item> localItems,
}) {
  final localItemId = normalizedId(cloudItem.localItemId);
  if (localItemId != null) {
    final matches = localItems.where((item) => item.id == localItemId).toList();
    if (matches.length == 1) {
      return ItemMatchResult.match(matches.single);
    }
    if (matches.length > 1) {
      return const ItemMatchResult.duplicate('Multiple local items use this id.');
    }
  }

  final barcode = normalizedLookup(cloudItem.barcode);
  if (barcode != null) {
    final matches = localItems
        .where((item) => normalizedLookup(item.barcode) == barcode)
        .toList();
    if (matches.length == 1) {
      return ItemMatchResult.match(matches.single);
    }
    if (matches.length > 1) {
      return const ItemMatchResult.duplicate(
        'Multiple local items use this barcode.',
      );
    }
  }

  final sku = normalizedLookup(cloudItem.sku);
  if (sku != null) {
    final matches = localItems
        .where((item) => normalizedLookup(item.sku) == sku)
        .toList();
    if (matches.length == 1) {
      return ItemMatchResult.match(matches.single);
    }
    if (matches.length > 1) {
      return const ItemMatchResult.duplicate(
        'Multiple local items use this SKU.',
      );
    }
  }

  return const ItemMatchResult.noMatch();
}

SupplierMatchResult matchCloudSupplierToLocal({
  required CloudSupplier cloudSupplier,
  required List<Supplier> localSuppliers,
}) {
  final localSupplierId = normalizedId(cloudSupplier.localSupplierId);
  if (localSupplierId != null) {
    final matches = localSuppliers
        .where((supplier) => supplier.id == localSupplierId)
        .toList();
    if (matches.length == 1) {
      return SupplierMatchResult.match(matches.single);
    }
    if (matches.length > 1) {
      return const SupplierMatchResult.duplicate(
        'Multiple local suppliers use this id.',
      );
    }
  }

  final name = normalizedLookup(cloudSupplier.name);
  if (name != null) {
    final matches = localSuppliers
        .where((supplier) => normalizedLookup(supplier.name) == name)
        .toList();
    if (matches.length == 1) {
      return SupplierMatchResult.match(matches.single);
    }
    if (matches.length > 1) {
      return const SupplierMatchResult.duplicate(
        'Multiple local suppliers use this name.',
      );
    }
  }

  return const SupplierMatchResult.noMatch();
}

class ItemMatchResult {
  const ItemMatchResult._({
    this.item,
    this.duplicateMessage,
  });

  const ItemMatchResult.match(Item item) : this._(item: item);
  const ItemMatchResult.noMatch() : this._();
  const ItemMatchResult.duplicate(String message)
    : this._(duplicateMessage: message);

  final Item? item;
  final String? duplicateMessage;
  bool get isDuplicate => duplicateMessage != null;
}

class SupplierMatchResult {
  const SupplierMatchResult._({
    this.supplier,
    this.duplicateMessage,
  });

  const SupplierMatchResult.match(Supplier supplier)
    : this._(supplier: supplier);
  const SupplierMatchResult.noMatch() : this._();
  const SupplierMatchResult.duplicate(String message)
    : this._(duplicateMessage: message);

  final Supplier? supplier;
  final String? duplicateMessage;
  bool get isDuplicate => duplicateMessage != null;
}

SyncMergeConflict mergeConflict({
  required CloudSyncEntity entityType,
  String? localId,
  String? cloudId,
  String? field,
  Object? localValue,
  Object? cloudValue,
  required String message,
}) {
  return SyncMergeConflict(
    entityType: entityType,
    localId: localId,
    cloudId: cloudId,
    field: field,
    localValue: localValue?.toString(),
    cloudValue: cloudValue?.toString(),
    message: message,
    createdAt: DateTime.now(),
  );
}
