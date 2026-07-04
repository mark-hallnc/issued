class ItemLocationBalance {
  const ItemLocationBalance({
    required this.id,
    required this.itemId,
    required this.locationId,
    required this.quantityOnHand,
    required this.minimumQuantity,
    required this.updatedAt,
  });

  final String id;
  final String itemId;
  final String locationId;
  final double quantityOnHand;
  final double minimumQuantity;
  final DateTime updatedAt;

  ItemLocationBalance copyWith({
    String? id,
    String? itemId,
    String? locationId,
    double? quantityOnHand,
    double? minimumQuantity,
    DateTime? updatedAt,
  }) {
    return ItemLocationBalance(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      locationId: locationId ?? this.locationId,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      minimumQuantity: minimumQuantity ?? this.minimumQuantity,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
