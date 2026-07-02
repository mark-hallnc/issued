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
    required this.barcode,
    required this.sku,
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
  final String? barcode;
  final String? sku;
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
    String? barcode,
    String? sku,
    String? supplier,
    double? unitCost,
    String? photoPath,
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
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
      supplier: supplier ?? this.supplier,
      unitCost: unitCost ?? this.unitCost,
      photoPath: photoPath ?? this.photoPath,
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
    required this.type,
    required this.parentLocationId,
    required this.isActive,
  });

  final String id;
  final String name;
  final String type;
  final String? parentLocationId;
  final bool isActive;

  Location copyWith({
    String? id,
    String? name,
    String? type,
    String? parentLocationId,
    bool? isActive,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parentLocationId: parentLocationId ?? this.parentLocationId,
      isActive: isActive ?? this.isActive,
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
    required this.performedByUserId,
    required this.notes,
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
  final String? performedByUserId;
  final String? notes;
  final DateTime createdAt;

  InventoryTransaction copyWith({
    String? id,
    String? itemId,
    InventoryTransactionType? transactionType,
    double? quantityDelta,
    String? unitOfMeasureId,
    String? fromLocationId,
    String? toLocationId,
    String? assignedToPersonId,
    String? performedByUserId,
    String? notes,
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
      performedByUserId: performedByUserId ?? this.performedByUserId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
