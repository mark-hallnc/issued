enum CheckoutStatus { checkedOut, returned, lost, damaged }

class CheckoutRecord {
  const CheckoutRecord({
    required this.id,
    required this.itemId,
    required this.assignedToPersonId,
    required this.assignedToLocationId,
    required this.assignedToText,
    required this.quantity,
    required this.unitOfMeasureId,
    required this.status,
    required this.checkedOutAt,
    required this.dueAt,
    required this.returnedAt,
    required this.checkedOutByUserId,
    required this.returnedByUserId,
    required this.notes,
  });

  final String id;
  final String itemId;
  final String? assignedToPersonId;
  final String? assignedToLocationId;
  final String? assignedToText;
  final double quantity;
  final String unitOfMeasureId;
  final CheckoutStatus status;
  final DateTime checkedOutAt;
  final DateTime? dueAt;
  final DateTime? returnedAt;
  final String? checkedOutByUserId;
  final String? returnedByUserId;
  final String? notes;

  CheckoutRecord copyWith({
    String? id,
    String? itemId,
    String? assignedToPersonId,
    String? assignedToLocationId,
    String? assignedToText,
    double? quantity,
    String? unitOfMeasureId,
    CheckoutStatus? status,
    DateTime? checkedOutAt,
    DateTime? dueAt,
    DateTime? returnedAt,
    String? checkedOutByUserId,
    String? returnedByUserId,
    String? notes,
  }) {
    return CheckoutRecord(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      assignedToPersonId: assignedToPersonId ?? this.assignedToPersonId,
      assignedToLocationId: assignedToLocationId ?? this.assignedToLocationId,
      assignedToText: assignedToText ?? this.assignedToText,
      quantity: quantity ?? this.quantity,
      unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
      status: status ?? this.status,
      checkedOutAt: checkedOutAt ?? this.checkedOutAt,
      dueAt: dueAt ?? this.dueAt,
      returnedAt: returnedAt ?? this.returnedAt,
      checkedOutByUserId: checkedOutByUserId ?? this.checkedOutByUserId,
      returnedByUserId: returnedByUserId ?? this.returnedByUserId,
      notes: notes ?? this.notes,
    );
  }
}

String checkoutStatusLabel(CheckoutStatus status) {
  return switch (status) {
    CheckoutStatus.checkedOut => 'Checked Out',
    CheckoutStatus.returned => 'Returned',
    CheckoutStatus.lost => 'Lost',
    CheckoutStatus.damaged => 'Damaged',
  };
}
