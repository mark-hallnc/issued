enum ReorderStatus { needed, ordered, received, canceled }

class ReorderRequest {
  const ReorderRequest({
    required this.id,
    required this.itemId,
    required this.requestedQuantity,
    required this.unitOfMeasureId,
    required this.supplier,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.orderedAt,
    required this.receivedAt,
    required this.createdByUserId,
  });

  final String id;
  final String itemId;
  final double requestedQuantity;
  final String unitOfMeasureId;
  final String? supplier;
  final ReorderStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? orderedAt;
  final DateTime? receivedAt;
  final String? createdByUserId;

  ReorderRequest copyWith({
    String? id,
    String? itemId,
    double? requestedQuantity,
    String? unitOfMeasureId,
    String? supplier,
    ReorderStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? orderedAt,
    DateTime? receivedAt,
    String? createdByUserId,
  }) {
    return ReorderRequest(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      requestedQuantity: requestedQuantity ?? this.requestedQuantity,
      unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
      supplier: supplier ?? this.supplier,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      orderedAt: orderedAt ?? this.orderedAt,
      receivedAt: receivedAt ?? this.receivedAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
    );
  }
}

String reorderStatusLabel(ReorderStatus status) {
  return switch (status) {
    ReorderStatus.needed => 'Needs reorder',
    ReorderStatus.ordered => 'Ordered',
    ReorderStatus.received => 'Received',
    ReorderStatus.canceled => 'Canceled',
  };
}
