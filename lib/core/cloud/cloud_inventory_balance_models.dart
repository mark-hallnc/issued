import '../models/item_location_balance_models.dart';

class CloudInventoryBalance {
  const CloudInventoryBalance({
    required this.id,
    required this.workspaceId,
    required this.workspaceItemId,
    required this.localItemId,
    required this.locationId,
    required this.locationName,
    required this.binId,
    required this.binName,
    required this.quantity,
    required this.reservedQuantity,
    required this.countedAt,
    required this.lastMovementAt,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String workspaceId;
  final String? workspaceItemId;
  final String localItemId;
  final String? locationId;
  final String? locationName;
  final String? binId;
  final String? binName;
  final double quantity;
  final double reservedQuantity;
  final DateTime? countedAt;
  final DateTime? lastMovementAt;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CloudInventoryBalance.fromJson(Map<String, dynamic> json) {
    return CloudInventoryBalance(
      id: json['id']?.toString() ?? '',
      workspaceId: json['workspace_id']?.toString() ?? '',
      workspaceItemId: json['workspace_item_id']?.toString(),
      localItemId: json['local_item_id']?.toString() ?? '',
      locationId: json['location_id']?.toString(),
      locationName: json['location_name']?.toString(),
      binId: json['bin_id']?.toString(),
      binName: json['bin_name']?.toString(),
      quantity: _double(json['quantity']) ?? 0,
      reservedQuantity: _double(json['reserved_quantity']) ?? 0,
      countedAt: _nullableDate(json['counted_at']),
      lastMovementAt: _nullableDate(json['last_movement_at']),
      deletedAt: _nullableDate(json['deleted_at']),
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
    );
  }

  factory CloudInventoryBalance.fromLocalBalance({
    required String workspaceId,
    required ItemLocationBalance balance,
    String? workspaceItemId,
    String? locationName,
  }) {
    return CloudInventoryBalance(
      id: '',
      workspaceId: workspaceId,
      workspaceItemId: workspaceItemId,
      localItemId: balance.itemId,
      locationId: balance.locationId,
      locationName: _emptyToNull(locationName),
      binId: null,
      binName: null,
      quantity: balance.quantityOnHand,
      reservedQuantity: 0,
      countedAt: null,
      lastMovementAt: balance.updatedAt,
      deletedAt: null,
      createdAt: balance.updatedAt,
      updatedAt: balance.updatedAt,
    );
  }

  String get stableKey => balanceStableKey(
    localItemId: localItemId,
    locationId: locationId,
    binId: binId,
  );

  Map<String, Object?> toUpsertJson({String? userId}) {
    return {
      'workspace_id': workspaceId,
      'workspace_item_id': workspaceItemId,
      'local_item_id': localItemId,
      'location_id': locationId,
      'location_name': locationName,
      'bin_id': binId,
      'bin_name': binName,
      'quantity': quantity,
      'reserved_quantity': reservedQuantity,
      'counted_at': countedAt?.toUtc().toIso8601String(),
      'last_movement_at': lastMovementAt?.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      ?'created_by': userId,
      ?'updated_by': userId,
    };
  }
}

String balanceStableKey({
  required String localItemId,
  String? locationId,
  String? binId,
}) {
  return [localItemId, locationId ?? '', binId ?? ''].join('|');
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
