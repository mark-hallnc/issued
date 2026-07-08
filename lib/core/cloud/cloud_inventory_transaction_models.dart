import '../models/inventory_models.dart';

class CloudInventoryTransaction {
  const CloudInventoryTransaction({
    required this.id,
    required this.workspaceId,
    required this.workspaceItemId,
    required this.localTransactionId,
    required this.localItemId,
    required this.transactionType,
    required this.quantityDelta,
    required this.quantityBefore,
    required this.quantityAfter,
    required this.locationId,
    required this.locationName,
    required this.binId,
    required this.binName,
    required this.relatedCheckoutId,
    required this.relatedPurchaseOrderId,
    required this.relatedCountId,
    required this.assignmentType,
    required this.assignmentId,
    required this.assignmentLabel,
    required this.reason,
    required this.notes,
    required this.performedByUserId,
    required this.performedByName,
    required this.performedByEmail,
    required this.sourceDeviceId,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String workspaceId;
  final String? workspaceItemId;
  final String localTransactionId;
  final String localItemId;
  final String transactionType;
  final double quantityDelta;
  final double? quantityBefore;
  final double? quantityAfter;
  final String? locationId;
  final String? locationName;
  final String? binId;
  final String? binName;
  final String? relatedCheckoutId;
  final String? relatedPurchaseOrderId;
  final String? relatedCountId;
  final String? assignmentType;
  final String? assignmentId;
  final String? assignmentLabel;
  final String? reason;
  final String? notes;
  final String? performedByUserId;
  final String? performedByName;
  final String? performedByEmail;
  final String? sourceDeviceId;
  final DateTime occurredAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  factory CloudInventoryTransaction.fromJson(Map<String, dynamic> json) {
    return CloudInventoryTransaction(
      id: json['id']?.toString() ?? '',
      workspaceId: json['workspace_id']?.toString() ?? '',
      workspaceItemId: json['workspace_item_id']?.toString(),
      localTransactionId: json['local_transaction_id']?.toString() ?? '',
      localItemId: json['local_item_id']?.toString() ?? '',
      transactionType: json['transaction_type']?.toString() ?? '',
      quantityDelta: _double(json['quantity_delta']) ?? 0,
      quantityBefore: _double(json['quantity_before']),
      quantityAfter: _double(json['quantity_after']),
      locationId: json['location_id']?.toString(),
      locationName: json['location_name']?.toString(),
      binId: json['bin_id']?.toString(),
      binName: json['bin_name']?.toString(),
      relatedCheckoutId: json['related_checkout_id']?.toString(),
      relatedPurchaseOrderId: json['related_purchase_order_id']?.toString(),
      relatedCountId: json['related_count_id']?.toString(),
      assignmentType: json['assignment_type']?.toString(),
      assignmentId: json['assignment_id']?.toString(),
      assignmentLabel: json['assignment_label']?.toString(),
      reason: json['reason']?.toString(),
      notes: json['notes']?.toString(),
      performedByUserId: json['performed_by_user_id']?.toString(),
      performedByName: json['performed_by_name']?.toString(),
      performedByEmail: json['performed_by_email']?.toString(),
      sourceDeviceId: json['source_device_id']?.toString(),
      occurredAt: _date(json['occurred_at']),
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
      deletedAt: _nullableDate(json['deleted_at']),
    );
  }

  factory CloudInventoryTransaction.fromLocalTransaction({
    required String workspaceId,
    required InventoryTransaction transaction,
    String? workspaceItemId,
    String? Function(String? locationId)? locationNameForId,
    String? Function(InventoryTransaction transaction)? assignmentLabelFor,
    String? Function(String? userId)? performedByNameFor,
    String? Function(String? userId)? performedByEmailFor,
  }) {
    final locationId = _primaryLocationId(transaction);
    final assignment = _assignment(transaction, assignmentLabelFor);
    return CloudInventoryTransaction(
      id: '',
      workspaceId: workspaceId,
      workspaceItemId: workspaceItemId,
      localTransactionId: transaction.id,
      localItemId: transaction.itemId,
      transactionType: transaction.transactionType.name,
      quantityDelta: transaction.quantityDelta,
      quantityBefore: null,
      quantityAfter: null,
      locationId: locationId,
      locationName: _emptyToNull(locationNameForId?.call(locationId)),
      binId: null,
      binName: null,
      relatedCheckoutId: null,
      relatedPurchaseOrderId: null,
      relatedCountId: null,
      assignmentType: assignment.type,
      assignmentId: assignment.id,
      assignmentLabel: assignment.label,
      reason: _emptyToNull(transaction.correctionReason),
      notes: _emptyToNull(transaction.notes),
      performedByUserId: null,
      performedByName: _emptyToNull(
        performedByNameFor?.call(transaction.performedByUserId),
      ),
      performedByEmail: _emptyToNull(
        performedByEmailFor?.call(transaction.performedByUserId),
      ),
      sourceDeviceId: null,
      occurredAt: transaction.createdAt,
      createdAt: transaction.createdAt,
      updatedAt: transaction.correctedAt ?? transaction.createdAt,
      deletedAt: null,
    );
  }

  Map<String, Object?> toUpsertJson() {
    return {
      'workspace_id': workspaceId,
      'workspace_item_id': workspaceItemId,
      'local_transaction_id': localTransactionId,
      'local_item_id': localItemId,
      'transaction_type': transactionType,
      'quantity_delta': quantityDelta,
      'quantity_before': quantityBefore,
      'quantity_after': quantityAfter,
      'location_id': locationId,
      'location_name': locationName,
      'bin_id': binId,
      'bin_name': binName,
      'related_checkout_id': relatedCheckoutId,
      'related_purchase_order_id': relatedPurchaseOrderId,
      'related_count_id': relatedCountId,
      'assignment_type': assignmentType,
      'assignment_id': assignmentId,
      'assignment_label': assignmentLabel,
      'reason': reason,
      'notes': notes,
      'performed_by_user_id': performedByUserId,
      'performed_by_name': performedByName,
      'performed_by_email': performedByEmail,
      'source_device_id': sourceDeviceId,
      'occurred_at': occurredAt.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }
}

({String? type, String? id, String? label}) _assignment(
  InventoryTransaction transaction,
  String? Function(InventoryTransaction transaction)? assignmentLabelFor,
) {
  if (transaction.assignedToPersonId != null) {
    return (
      type: 'person',
      id: transaction.assignedToPersonId,
      label: _emptyToNull(assignmentLabelFor?.call(transaction)),
    );
  }
  if (transaction.assignedToLocationId != null) {
    return (
      type: 'location',
      id: transaction.assignedToLocationId,
      label: _emptyToNull(assignmentLabelFor?.call(transaction)),
    );
  }
  if (transaction.assignedToTargetId != null) {
    return (
      type: 'target',
      id: transaction.assignedToTargetId,
      label: _emptyToNull(assignmentLabelFor?.call(transaction)),
    );
  }
  return (
    type: null,
    id: null,
    label: _emptyToNull(transaction.assignedToText),
  );
}

String? _primaryLocationId(InventoryTransaction transaction) {
  if (transaction.quantityDelta < 0) {
    return transaction.fromLocationId ?? transaction.toLocationId;
  }
  return transaction.toLocationId ?? transaction.fromLocationId;
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
