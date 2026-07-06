enum ItemType { consumable, returnable, asset }

enum InventoryTransactionType {
  receive,
  issue,
  checkout,
  returnItem,
  transfer,
  adjustment,
  markLost,
  markDamaged,
  cycleCountAdjustment,
  correction,
}

class Item {
  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.itemType,
    required this.category,
    required this.locationId,
    required this.quantityOnHand,
    required this.minimumQuantity,
    required this.unitOfMeasureId,
    required this.purchaseUnitOfMeasureId,
    required this.purchaseToStockConversionFactor,
    required this.purchaseUnitLabel,
    required this.barcode,
    required this.sku,
    required this.supplierId,
    required this.supplier,
    required this.unitCost,
    required this.photoPath,
    required this.isActive,
    required this.allowFractionalQuantity,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final ItemType itemType;
  final String category;
  final String locationId;
  final double quantityOnHand;
  final double minimumQuantity;
  final String unitOfMeasureId;
  final String? purchaseUnitOfMeasureId;
  final double? purchaseToStockConversionFactor;
  final String? purchaseUnitLabel;
  final String? barcode;
  final String? sku;
  final String? supplierId;
  final String? supplier;
  final double? unitCost;
  final String? photoPath;
  final bool isActive;
  final bool allowFractionalQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  Item copyWith({
    String? id,
    String? name,
    String? description,
    ItemType? itemType,
    String? category,
    String? locationId,
    double? quantityOnHand,
    double? minimumQuantity,
    String? unitOfMeasureId,
    String? purchaseUnitOfMeasureId,
    double? purchaseToStockConversionFactor,
    String? purchaseUnitLabel,
    bool clearPurchaseUnitOfMeasureId = false,
    bool clearPurchaseToStockConversionFactor = false,
    bool clearPurchaseUnitLabel = false,
    String? barcode,
    String? sku,
    String? supplierId,
    String? supplier,
    double? unitCost,
    String? photoPath,
    bool clearPhotoPath = false,
    bool? isActive,
    bool? allowFractionalQuantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      itemType: itemType ?? this.itemType,
      category: category ?? this.category,
      locationId: locationId ?? this.locationId,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      minimumQuantity: minimumQuantity ?? this.minimumQuantity,
      unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
      purchaseUnitOfMeasureId: clearPurchaseUnitOfMeasureId
          ? null
          : purchaseUnitOfMeasureId ?? this.purchaseUnitOfMeasureId,
      purchaseToStockConversionFactor: clearPurchaseToStockConversionFactor
          ? null
          : purchaseToStockConversionFactor ??
                this.purchaseToStockConversionFactor,
      purchaseUnitLabel: clearPurchaseUnitLabel
          ? null
          : purchaseUnitLabel ?? this.purchaseUnitLabel,
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
      supplierId: supplierId ?? this.supplierId,
      supplier: supplier ?? this.supplier,
      unitCost: unitCost ?? this.unitCost,
      photoPath: clearPhotoPath ? null : photoPath ?? this.photoPath,
      isActive: isActive ?? this.isActive,
      allowFractionalQuantity:
          allowFractionalQuantity ?? this.allowFractionalQuantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UnitOfMeasure {
  const UnitOfMeasure({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.allowsDecimal,
    required this.isActive,
  });

  final String id;
  final String name;
  final String abbreviation;
  final bool allowsDecimal;
  final bool isActive;

  UnitOfMeasure copyWith({
    String? id,
    String? name,
    String? abbreviation,
    bool? allowsDecimal,
    bool? isActive,
  }) {
    return UnitOfMeasure(
      id: id ?? this.id,
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      allowsDecimal: allowsDecimal ?? this.allowsDecimal,
      isActive: isActive ?? this.isActive,
    );
  }
}

class Location {
  const Location({
    required this.id,
    required this.name,
    required this.description,
    required this.code,
    required this.type,
    required this.parentLocationId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final String? code;
  final String type;
  final String? parentLocationId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Location copyWith({
    String? id,
    String? name,
    String? description,
    String? code,
    String? type,
    String? parentLocationId,
    bool clearDescription = false,
    bool clearCode = false,
    bool clearParentLocationId = false,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      description: clearDescription ? null : description ?? this.description,
      code: clearCode ? null : code ?? this.code,
      type: type ?? this.type,
      parentLocationId: clearParentLocationId
          ? null
          : parentLocationId ?? this.parentLocationId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class InventoryTransaction {
  const InventoryTransaction({
    required this.id,
    required this.itemId,
    required this.transactionType,
    required this.quantityDelta,
    required this.unitOfMeasureId,
    required this.fromLocationId,
    required this.toLocationId,
    required this.assignedToPersonId,
    this.assignedToLocationId,
    required this.assignedToTargetId,
    required this.assignedToText,
    required this.performedByUserId,
    required this.notes,
    this.reversedByTransactionId,
    this.reversesTransactionId,
    this.correctionReason,
    this.correctedAt,
    required this.createdAt,
  });

  final String id;
  final String itemId;
  final InventoryTransactionType transactionType;
  final double quantityDelta;
  final String unitOfMeasureId;
  final String? fromLocationId;
  final String? toLocationId;
  final String? assignedToPersonId;
  final String? assignedToLocationId;
  final String? assignedToTargetId;
  final String? assignedToText;
  final String? performedByUserId;
  final String? notes;
  final String? reversedByTransactionId;
  final String? reversesTransactionId;
  final String? correctionReason;
  final DateTime? correctedAt;
  final DateTime createdAt;

  bool get isReversal => reversesTransactionId != null;
  bool get isReversed => reversedByTransactionId != null;

  InventoryTransaction copyWith({
    String? id,
    String? itemId,
    InventoryTransactionType? transactionType,
    double? quantityDelta,
    String? unitOfMeasureId,
    String? fromLocationId,
    String? toLocationId,
    String? assignedToPersonId,
    String? assignedToLocationId,
    String? assignedToTargetId,
    String? assignedToText,
    String? performedByUserId,
    String? notes,
    String? reversedByTransactionId,
    String? reversesTransactionId,
    String? correctionReason,
    DateTime? correctedAt,
    DateTime? createdAt,
  }) {
    return InventoryTransaction(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      transactionType: transactionType ?? this.transactionType,
      quantityDelta: quantityDelta ?? this.quantityDelta,
      unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
      fromLocationId: fromLocationId ?? this.fromLocationId,
      toLocationId: toLocationId ?? this.toLocationId,
      assignedToPersonId: assignedToPersonId ?? this.assignedToPersonId,
      assignedToLocationId: assignedToLocationId ?? this.assignedToLocationId,
      assignedToTargetId: assignedToTargetId ?? this.assignedToTargetId,
      assignedToText: assignedToText ?? this.assignedToText,
      performedByUserId: performedByUserId ?? this.performedByUserId,
      notes: notes ?? this.notes,
      reversedByTransactionId:
          reversedByTransactionId ?? this.reversedByTransactionId,
      reversesTransactionId:
          reversesTransactionId ?? this.reversesTransactionId,
      correctionReason: correctionReason ?? this.correctionReason,
      correctedAt: correctedAt ?? this.correctedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
