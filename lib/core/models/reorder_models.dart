enum ReorderStatus {
  needed,
  ordered,
  partiallyReceived,
  received,
  cancelled,
  canceled,
}

class ReorderRequest {
  const ReorderRequest({
    required this.id,
    required this.itemId,
    required this.requestedQuantity,
    required this.receivedQuantity,
    required this.unitOfMeasureId,
    required this.supplier,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.orderedAt,
    required this.receivedAt,
    required this.cancelledAt,
    required this.createdByUserId,
    required this.orderedByUserId,
    required this.receivedByUserId,
    required this.destinationLocationId,
    required this.purchaseUnitOfMeasureId,
    required this.purchaseQuantity,
    required this.purchaseToStockConversionFactor,
    required this.expectedCost,
    required this.orderNumber,
  });

  final String id;
  final String itemId;
  final double requestedQuantity;
  final double receivedQuantity;
  final String unitOfMeasureId;
  final String? supplier;
  final ReorderStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? orderedAt;
  final DateTime? receivedAt;
  final DateTime? cancelledAt;
  final String? createdByUserId;
  final String? orderedByUserId;
  final String? receivedByUserId;
  final String? destinationLocationId;
  final String? purchaseUnitOfMeasureId;
  final double? purchaseQuantity;
  final double? purchaseToStockConversionFactor;
  final double? expectedCost;
  final String? orderNumber;

  double get remainingQuantity {
    final remaining = requestedQuantity - receivedQuantity;
    return remaining <= 0 ? 0 : remaining;
  }

  bool get isOpen =>
      status == ReorderStatus.needed ||
      status == ReorderStatus.ordered ||
      status == ReorderStatus.partiallyReceived;

  bool get isCancelled =>
      status == ReorderStatus.cancelled || status == ReorderStatus.canceled;

  ReorderRequest copyWith({
    String? id,
    String? itemId,
    double? requestedQuantity,
    double? receivedQuantity,
    String? unitOfMeasureId,
    String? supplier,
    ReorderStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? orderedAt,
    DateTime? receivedAt,
    DateTime? cancelledAt,
    String? createdByUserId,
    String? orderedByUserId,
    String? receivedByUserId,
    String? destinationLocationId,
    String? purchaseUnitOfMeasureId,
    double? purchaseQuantity,
    double? purchaseToStockConversionFactor,
    double? expectedCost,
    String? orderNumber,
    bool clearSupplier = false,
    bool clearNotes = false,
    bool clearOrderedAt = false,
    bool clearReceivedAt = false,
    bool clearCancelledAt = false,
    bool clearOrderNumber = false,
  }) {
    return ReorderRequest(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      requestedQuantity: requestedQuantity ?? this.requestedQuantity,
      receivedQuantity: receivedQuantity ?? this.receivedQuantity,
      unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
      supplier: clearSupplier ? null : supplier ?? this.supplier,
      status: status ?? this.status,
      notes: clearNotes ? null : notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      orderedAt: clearOrderedAt ? null : orderedAt ?? this.orderedAt,
      receivedAt: clearReceivedAt ? null : receivedAt ?? this.receivedAt,
      cancelledAt: clearCancelledAt ? null : cancelledAt ?? this.cancelledAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      orderedByUserId: orderedByUserId ?? this.orderedByUserId,
      receivedByUserId: receivedByUserId ?? this.receivedByUserId,
      destinationLocationId:
          destinationLocationId ?? this.destinationLocationId,
      purchaseUnitOfMeasureId:
          purchaseUnitOfMeasureId ?? this.purchaseUnitOfMeasureId,
      purchaseQuantity: purchaseQuantity ?? this.purchaseQuantity,
      purchaseToStockConversionFactor:
          purchaseToStockConversionFactor ??
          this.purchaseToStockConversionFactor,
      expectedCost: expectedCost ?? this.expectedCost,
      orderNumber: clearOrderNumber ? null : orderNumber ?? this.orderNumber,
    );
  }
}

String reorderStatusLabel(ReorderStatus status) {
  return switch (status) {
    ReorderStatus.needed => 'Needed',
    ReorderStatus.ordered => 'Ordered',
    ReorderStatus.partiallyReceived => 'Partially Received',
    ReorderStatus.received => 'Received',
    ReorderStatus.cancelled || ReorderStatus.canceled => 'Cancelled',
  };
}
