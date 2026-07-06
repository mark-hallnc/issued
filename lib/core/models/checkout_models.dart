enum CheckoutStatus {
  open,
  partiallyReturned,
  returned,
  damaged,
  lost,
  cancelled,
  checkedOut,
}

enum CheckoutReturnCondition { good, damaged, lost }

class CheckoutRecord {
  const CheckoutRecord({
    required this.id,
    required this.itemId,
    required this.assignedToPersonId,
    required this.assignedToLocationId,
    required this.assignedToTargetId,
    required this.assignedToText,
    required this.quantity,
    required this.quantityReturned,
    required this.sourceLocationId,
    required this.unitOfMeasureId,
    required this.status,
    required this.checkedOutAt,
    required this.dueAt,
    required this.returnedAt,
    required this.checkedOutByUserId,
    required this.returnedByUserId,
    required this.notes,
    required this.returnNotes,
    required this.conditionOnReturn,
  });

  final String id;
  final String itemId;
  final String? assignedToPersonId;
  final String? assignedToLocationId;
  final String? assignedToTargetId;
  final String? assignedToText;
  final double quantity;
  final double quantityReturned;
  final String? sourceLocationId;
  final String unitOfMeasureId;
  final CheckoutStatus status;
  final DateTime checkedOutAt;
  final DateTime? dueAt;
  final DateTime? returnedAt;
  final String? checkedOutByUserId;
  final String? returnedByUserId;
  final String? notes;
  final String? returnNotes;
  final CheckoutReturnCondition? conditionOnReturn;

  double get quantityCheckedOut => quantity;
  double get quantityOpen {
    final open = quantity - quantityReturned;
    return open < 0 ? 0 : open;
  }

  bool get isOpen =>
      status == CheckoutStatus.open ||
      status == CheckoutStatus.checkedOut ||
      status == CheckoutStatus.partiallyReturned;

  CheckoutRecord copyWith({
    String? id,
    String? itemId,
    String? assignedToPersonId,
    String? assignedToLocationId,
    String? assignedToTargetId,
    String? assignedToText,
    double? quantity,
    double? quantityReturned,
    String? sourceLocationId,
    String? unitOfMeasureId,
    CheckoutStatus? status,
    DateTime? checkedOutAt,
    DateTime? dueAt,
    DateTime? returnedAt,
    String? checkedOutByUserId,
    String? returnedByUserId,
    String? notes,
    String? returnNotes,
    CheckoutReturnCondition? conditionOnReturn,
  }) {
    return CheckoutRecord(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      assignedToPersonId: assignedToPersonId ?? this.assignedToPersonId,
      assignedToLocationId: assignedToLocationId ?? this.assignedToLocationId,
      assignedToTargetId: assignedToTargetId ?? this.assignedToTargetId,
      assignedToText: assignedToText ?? this.assignedToText,
      quantity: quantity ?? this.quantity,
      quantityReturned: quantityReturned ?? this.quantityReturned,
      sourceLocationId: sourceLocationId ?? this.sourceLocationId,
      unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
      status: status ?? this.status,
      checkedOutAt: checkedOutAt ?? this.checkedOutAt,
      dueAt: dueAt ?? this.dueAt,
      returnedAt: returnedAt ?? this.returnedAt,
      checkedOutByUserId: checkedOutByUserId ?? this.checkedOutByUserId,
      returnedByUserId: returnedByUserId ?? this.returnedByUserId,
      notes: notes ?? this.notes,
      returnNotes: returnNotes ?? this.returnNotes,
      conditionOnReturn: conditionOnReturn ?? this.conditionOnReturn,
    );
  }
}

String checkoutStatusLabel(CheckoutStatus status) {
  return switch (status) {
    CheckoutStatus.open || CheckoutStatus.checkedOut => 'Open',
    CheckoutStatus.partiallyReturned => 'Partially Returned',
    CheckoutStatus.returned => 'Returned',
    CheckoutStatus.lost => 'Lost',
    CheckoutStatus.damaged => 'Damaged',
    CheckoutStatus.cancelled => 'Cancelled',
  };
}

String checkoutReturnConditionLabel(CheckoutReturnCondition condition) {
  return switch (condition) {
    CheckoutReturnCondition.good => 'Good',
    CheckoutReturnCondition.damaged => 'Damaged',
    CheckoutReturnCondition.lost => 'Lost',
  };
}
