import '../models/reorder_models.dart';

class CloudPurchaseOrder {
  const CloudPurchaseOrder({
    required this.id,
    required this.workspaceId,
    required this.workspaceItemId,
    required this.workspaceSupplierId,
    required this.localPurchaseOrderId,
    required this.localItemId,
    required this.localSupplierId,
    required this.supplierName,
    required this.orderNumber,
    required this.status,
    required this.quantityOrdered,
    required this.quantityReceived,
    required this.unitCost,
    required this.totalCost,
    required this.orderedAt,
    required this.expectedAt,
    required this.receivedAt,
    required this.createdByUserId,
    required this.updatedByUserId,
    required this.notes,
    required this.sourceDeviceId,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String workspaceId;
  final String? workspaceItemId;
  final String? workspaceSupplierId;
  final String localPurchaseOrderId;
  final String? localItemId;
  final String? localSupplierId;
  final String? supplierName;
  final String? orderNumber;
  final String status;
  final double quantityOrdered;
  final double quantityReceived;
  final double? unitCost;
  final double? totalCost;
  final DateTime? orderedAt;
  final DateTime? expectedAt;
  final DateTime? receivedAt;
  final String? createdByUserId;
  final String? updatedByUserId;
  final String? notes;
  final String? sourceDeviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  factory CloudPurchaseOrder.fromJson(Map<String, dynamic> json) {
    return CloudPurchaseOrder(
      id: json['id']?.toString() ?? '',
      workspaceId: json['workspace_id']?.toString() ?? '',
      workspaceItemId: json['workspace_item_id']?.toString(),
      workspaceSupplierId: json['workspace_supplier_id']?.toString(),
      localPurchaseOrderId: json['local_purchase_order_id']?.toString() ?? '',
      localItemId: json['local_item_id']?.toString(),
      localSupplierId: json['local_supplier_id']?.toString(),
      supplierName: json['supplier_name']?.toString(),
      orderNumber: json['order_number']?.toString(),
      status: json['status']?.toString() ?? '',
      quantityOrdered: _double(json['quantity_ordered']) ?? 0,
      quantityReceived: _double(json['quantity_received']) ?? 0,
      unitCost: _double(json['unit_cost']),
      totalCost: _double(json['total_cost']),
      orderedAt: _nullableDate(json['ordered_at']),
      expectedAt: _nullableDate(json['expected_at']),
      receivedAt: _nullableDate(json['received_at']),
      createdByUserId: json['created_by_user_id']?.toString(),
      updatedByUserId: json['updated_by_user_id']?.toString(),
      notes: json['notes']?.toString(),
      sourceDeviceId: json['source_device_id']?.toString(),
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
      deletedAt: _nullableDate(json['deleted_at']),
    );
  }

  factory CloudPurchaseOrder.fromLocalReorder({
    required String workspaceId,
    required ReorderRequest reorder,
    String? workspaceItemId,
    String? workspaceSupplierId,
    required bool includeCosts,
  }) {
    final totalCost = includeCosts ? reorder.expectedCost : null;
    final unitCost = totalCost == null || reorder.requestedQuantity == 0
        ? null
        : totalCost / reorder.requestedQuantity;
    final updatedAt =
        reorder.receivedAt ??
        reorder.cancelledAt ??
        reorder.orderedAt ??
        reorder.createdAt;
    return CloudPurchaseOrder(
      id: '',
      workspaceId: workspaceId,
      workspaceItemId: workspaceItemId,
      workspaceSupplierId: workspaceSupplierId,
      localPurchaseOrderId: reorder.id,
      localItemId: reorder.itemId,
      localSupplierId: reorder.supplierId,
      supplierName: _emptyToNull(reorder.supplier),
      orderNumber: _emptyToNull(reorder.orderNumber),
      status: reorder.status.name,
      quantityOrdered: reorder.purchaseQuantity ?? reorder.requestedQuantity,
      quantityReceived: reorder.receivedQuantity,
      unitCost: unitCost,
      totalCost: totalCost,
      orderedAt: reorder.orderedAt,
      expectedAt: null,
      receivedAt: reorder.receivedAt,
      createdByUserId: null,
      updatedByUserId: null,
      notes: _emptyToNull(reorder.notes),
      sourceDeviceId: null,
      createdAt: reorder.createdAt,
      updatedAt: updatedAt,
      deletedAt: reorder.isCancelled ? reorder.cancelledAt : null,
    );
  }

  Map<String, Object?> toUpsertJson() {
    return {
      'workspace_id': workspaceId,
      'workspace_item_id': workspaceItemId,
      'workspace_supplier_id': workspaceSupplierId,
      'local_purchase_order_id': localPurchaseOrderId,
      'local_item_id': localItemId,
      'local_supplier_id': localSupplierId,
      'supplier_name': supplierName,
      'order_number': orderNumber,
      'status': status,
      'quantity_ordered': quantityOrdered,
      'quantity_received': quantityReceived,
      'unit_cost': unitCost,
      'total_cost': totalCost,
      'ordered_at': orderedAt?.toUtc().toIso8601String(),
      'expected_at': expectedAt?.toUtc().toIso8601String(),
      'received_at': receivedAt?.toUtc().toIso8601String(),
      'created_by_user_id': createdByUserId,
      'updated_by_user_id': updatedByUserId,
      'notes': notes,
      'source_device_id': sourceDeviceId,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }
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
