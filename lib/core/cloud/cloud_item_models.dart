import '../models/inventory_models.dart';

class CloudWorkspaceItem {
  const CloudWorkspaceItem({
    required this.id,
    required this.workspaceId,
    required this.localItemId,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.description,
    required this.category,
    required this.unit,
    required this.reorderPoint,
    required this.reorderQuantity,
    required this.unitCost,
    required this.isActive,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String workspaceId;
  final String? localItemId;
  final String name;
  final String? sku;
  final String? barcode;
  final String? description;
  final String? category;
  final String? unit;
  final double? reorderPoint;
  final double? reorderQuantity;
  final double? unitCost;
  final bool isActive;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CloudWorkspaceItem.fromJson(Map<String, dynamic> json) {
    return CloudWorkspaceItem(
      id: json['id']?.toString() ?? '',
      workspaceId: json['workspace_id']?.toString() ?? '',
      localItemId: json['local_item_id']?.toString(),
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString(),
      barcode: json['barcode']?.toString(),
      description: json['description']?.toString(),
      category: json['category']?.toString(),
      unit: json['unit']?.toString(),
      reorderPoint: _double(json['reorder_point']),
      reorderQuantity: _double(json['reorder_quantity']),
      unitCost: _double(json['unit_cost']),
      isActive: json['is_active'] == true,
      deletedAt: _nullableDate(json['deleted_at']),
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
    );
  }

  factory CloudWorkspaceItem.fromLocalItem({
    required String workspaceId,
    required Item item,
    String? unit,
  }) {
    return CloudWorkspaceItem(
      id: '',
      workspaceId: workspaceId,
      localItemId: item.id,
      name: item.name,
      sku: _emptyToNull(item.sku),
      barcode: _emptyToNull(item.barcode),
      description: _emptyToNull(item.description),
      category: _emptyToNull(item.category),
      unit: _emptyToNull(unit ?? item.unitOfMeasureId),
      reorderPoint: item.minimumQuantity > 0 ? item.minimumQuantity : null,
      reorderQuantity: null,
      unitCost: item.unitCost,
      isActive: item.isActive,
      deletedAt: null,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  Map<String, Object?> toUpsertJson({String? userId}) {
    return {
      'workspace_id': workspaceId,
      'local_item_id': localItemId,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'description': description,
      'category': category,
      'unit': unit,
      'reorder_point': reorderPoint,
      'reorder_quantity': reorderQuantity,
      'unit_cost': unitCost,
      'is_active': isActive,
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      ?'created_by': userId,
      ?'updated_by': userId,
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
