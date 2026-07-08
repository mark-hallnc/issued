import '../models/checkout_models.dart';

class CloudCheckout {
  const CloudCheckout({
    required this.id,
    required this.workspaceId,
    required this.workspaceItemId,
    required this.localCheckoutId,
    required this.localItemId,
    required this.quantity,
    required this.quantityReturned,
    required this.status,
    required this.checkedOutToType,
    required this.checkedOutToId,
    required this.checkedOutToLabel,
    required this.personId,
    required this.personName,
    required this.assignmentType,
    required this.assignmentId,
    required this.assignmentLabel,
    required this.dueAt,
    required this.checkedOutAt,
    required this.returnedAt,
    required this.checkedOutByUserId,
    required this.checkedOutByName,
    required this.checkedOutByEmail,
    required this.returnedByUserId,
    required this.returnedByName,
    required this.returnedByEmail,
    required this.notes,
    required this.sourceDeviceId,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String workspaceId;
  final String? workspaceItemId;
  final String localCheckoutId;
  final String localItemId;
  final double quantity;
  final double quantityReturned;
  final String status;
  final String? checkedOutToType;
  final String? checkedOutToId;
  final String? checkedOutToLabel;
  final String? personId;
  final String? personName;
  final String? assignmentType;
  final String? assignmentId;
  final String? assignmentLabel;
  final DateTime? dueAt;
  final DateTime checkedOutAt;
  final DateTime? returnedAt;
  final String? checkedOutByUserId;
  final String? checkedOutByName;
  final String? checkedOutByEmail;
  final String? returnedByUserId;
  final String? returnedByName;
  final String? returnedByEmail;
  final String? notes;
  final String? sourceDeviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  factory CloudCheckout.fromJson(Map<String, dynamic> json) {
    return CloudCheckout(
      id: json['id']?.toString() ?? '',
      workspaceId: json['workspace_id']?.toString() ?? '',
      workspaceItemId: json['workspace_item_id']?.toString(),
      localCheckoutId: json['local_checkout_id']?.toString() ?? '',
      localItemId: json['local_item_id']?.toString() ?? '',
      quantity: _double(json['quantity']) ?? 0,
      quantityReturned: _double(json['quantity_returned']) ?? 0,
      status: json['status']?.toString() ?? '',
      checkedOutToType: json['checked_out_to_type']?.toString(),
      checkedOutToId: json['checked_out_to_id']?.toString(),
      checkedOutToLabel: json['checked_out_to_label']?.toString(),
      personId: json['person_id']?.toString(),
      personName: json['person_name']?.toString(),
      assignmentType: json['assignment_type']?.toString(),
      assignmentId: json['assignment_id']?.toString(),
      assignmentLabel: json['assignment_label']?.toString(),
      dueAt: _nullableDate(json['due_at']),
      checkedOutAt: _date(json['checked_out_at']),
      returnedAt: _nullableDate(json['returned_at']),
      checkedOutByUserId: json['checked_out_by_user_id']?.toString(),
      checkedOutByName: json['checked_out_by_name']?.toString(),
      checkedOutByEmail: json['checked_out_by_email']?.toString(),
      returnedByUserId: json['returned_by_user_id']?.toString(),
      returnedByName: json['returned_by_name']?.toString(),
      returnedByEmail: json['returned_by_email']?.toString(),
      notes: json['notes']?.toString(),
      sourceDeviceId: json['source_device_id']?.toString(),
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
      deletedAt: _nullableDate(json['deleted_at']),
    );
  }

  factory CloudCheckout.fromLocalCheckout({
    required String workspaceId,
    required CheckoutRecord checkout,
    String? workspaceItemId,
    String? Function(CheckoutRecord checkout)? checkedOutToLabelFor,
    String? Function(String? personId)? personNameFor,
    String? Function(String? userId)? userNameFor,
    String? Function(String? userId)? userEmailFor,
  }) {
    final target = _checkoutTarget(checkout, checkedOutToLabelFor);
    final notes =
        [
              checkout.notes,
              checkout.returnNotes == null
                  ? null
                  : 'Return: ${checkout.returnNotes}',
              checkout.conditionOnReturn == null
                  ? null
                  : 'Condition: ${checkout.conditionOnReturn!.name}',
            ]
            .whereType<String>()
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .join('\n');
    return CloudCheckout(
      id: '',
      workspaceId: workspaceId,
      workspaceItemId: workspaceItemId,
      localCheckoutId: checkout.id,
      localItemId: checkout.itemId,
      quantity: checkout.quantity,
      quantityReturned: checkout.quantityReturned,
      status: checkout.status.name,
      checkedOutToType: target.type,
      checkedOutToId: target.id,
      checkedOutToLabel: target.label,
      personId: checkout.assignedToPersonId,
      personName: _emptyToNull(
        personNameFor?.call(checkout.assignedToPersonId),
      ),
      assignmentType: target.type == 'person' ? null : target.type,
      assignmentId: target.type == 'person' ? null : target.id,
      assignmentLabel: target.type == 'person' ? null : target.label,
      dueAt: checkout.dueAt,
      checkedOutAt: checkout.checkedOutAt,
      returnedAt: checkout.returnedAt,
      checkedOutByUserId: null,
      checkedOutByName: _emptyToNull(
        userNameFor?.call(checkout.checkedOutByUserId),
      ),
      checkedOutByEmail: _emptyToNull(
        userEmailFor?.call(checkout.checkedOutByUserId),
      ),
      returnedByUserId: null,
      returnedByName: _emptyToNull(
        userNameFor?.call(checkout.returnedByUserId),
      ),
      returnedByEmail: _emptyToNull(
        userEmailFor?.call(checkout.returnedByUserId),
      ),
      notes: _emptyToNull(notes),
      sourceDeviceId: null,
      createdAt: checkout.checkedOutAt,
      updatedAt: checkout.returnedAt ?? checkout.checkedOutAt,
      deletedAt: null,
    );
  }

  Map<String, Object?> toUpsertJson() {
    return {
      'workspace_id': workspaceId,
      'workspace_item_id': workspaceItemId,
      'local_checkout_id': localCheckoutId,
      'local_item_id': localItemId,
      'quantity': quantity,
      'quantity_returned': quantityReturned,
      'status': status,
      'checked_out_to_type': checkedOutToType,
      'checked_out_to_id': checkedOutToId,
      'checked_out_to_label': checkedOutToLabel,
      'person_id': personId,
      'person_name': personName,
      'assignment_type': assignmentType,
      'assignment_id': assignmentId,
      'assignment_label': assignmentLabel,
      'due_at': dueAt?.toUtc().toIso8601String(),
      'checked_out_at': checkedOutAt.toUtc().toIso8601String(),
      'returned_at': returnedAt?.toUtc().toIso8601String(),
      'checked_out_by_user_id': checkedOutByUserId,
      'checked_out_by_name': checkedOutByName,
      'checked_out_by_email': checkedOutByEmail,
      'returned_by_user_id': returnedByUserId,
      'returned_by_name': returnedByName,
      'returned_by_email': returnedByEmail,
      'notes': notes,
      'source_device_id': sourceDeviceId,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }
}

({String? type, String? id, String? label}) _checkoutTarget(
  CheckoutRecord checkout,
  String? Function(CheckoutRecord checkout)? checkedOutToLabelFor,
) {
  final label = _emptyToNull(checkedOutToLabelFor?.call(checkout));
  if (checkout.assignedToPersonId != null) {
    return (type: 'person', id: checkout.assignedToPersonId, label: label);
  }
  if (checkout.assignedToLocationId != null) {
    return (type: 'location', id: checkout.assignedToLocationId, label: label);
  }
  if (checkout.assignedToTargetId != null) {
    return (type: 'target', id: checkout.assignedToTargetId, label: label);
  }
  return (
    type: checkout.assignedToText == null ? null : 'text',
    id: null,
    label: label ?? _emptyToNull(checkout.assignedToText),
  );
}

DateTime _date(Object? value) {
  if (value is DateTime) {
    return value;
  }
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
}

DateTime? _nullableDate(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.tryParse(value.toString());
}

double? _double(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '');
}

String? _emptyToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
