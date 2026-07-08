import '../models/cycle_count_models.dart';

class CloudCycleCount {
  const CloudCycleCount({
    required this.id,
    required this.workspaceId,
    required this.localCountId,
    required this.name,
    required this.status,
    required this.locationId,
    required this.locationName,
    required this.binId,
    required this.binName,
    required this.startedAt,
    required this.completedAt,
    required this.approvedAt,
    required this.countedByUserId,
    required this.countedByName,
    required this.countedByEmail,
    required this.approvedByUserId,
    required this.approvedByName,
    required this.approvedByEmail,
    required this.notes,
    required this.sourceDeviceId,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String workspaceId;
  final String localCountId;
  final String? name;
  final String status;
  final String? locationId;
  final String? locationName;
  final String? binId;
  final String? binName;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? approvedAt;
  final String? countedByUserId;
  final String? countedByName;
  final String? countedByEmail;
  final String? approvedByUserId;
  final String? approvedByName;
  final String? approvedByEmail;
  final String? notes;
  final String? sourceDeviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  factory CloudCycleCount.fromJson(Map<String, dynamic> json) {
    return CloudCycleCount(
      id: json['id']?.toString() ?? '',
      workspaceId: json['workspace_id']?.toString() ?? '',
      localCountId: json['local_count_id']?.toString() ?? '',
      name: json['name']?.toString(),
      status: json['status']?.toString() ?? '',
      locationId: json['location_id']?.toString(),
      locationName: json['location_name']?.toString(),
      binId: json['bin_id']?.toString(),
      binName: json['bin_name']?.toString(),
      startedAt: _nullableDate(json['started_at']),
      completedAt: _nullableDate(json['completed_at']),
      approvedAt: _nullableDate(json['approved_at']),
      countedByUserId: json['counted_by_user_id']?.toString(),
      countedByName: json['counted_by_name']?.toString(),
      countedByEmail: json['counted_by_email']?.toString(),
      approvedByUserId: json['approved_by_user_id']?.toString(),
      approvedByName: json['approved_by_name']?.toString(),
      approvedByEmail: json['approved_by_email']?.toString(),
      notes: json['notes']?.toString(),
      sourceDeviceId: json['source_device_id']?.toString(),
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
      deletedAt: _nullableDate(json['deleted_at']),
    );
  }

  factory CloudCycleCount.fromLocalCycleCount({
    required String workspaceId,
    required CycleCountSession session,
    String? Function(String? userId)? userNameFor,
    String? Function(String? userId)? userEmailFor,
  }) {
    final updatedAt =
        session.approvedAt ?? session.submittedAt ?? session.createdAt;
    return CloudCycleCount(
      id: '',
      workspaceId: workspaceId,
      localCountId: session.id,
      name: _emptyToNull(session.name),
      status: session.status.name,
      locationId: null,
      locationName: null,
      binId: null,
      binName: null,
      startedAt: session.createdAt,
      completedAt: session.submittedAt,
      approvedAt: session.approvedAt,
      countedByUserId: null,
      countedByName: userNameFor?.call(session.assignedToUserId),
      countedByEmail: userEmailFor?.call(session.assignedToUserId),
      approvedByUserId: null,
      approvedByName: null,
      approvedByEmail: null,
      notes: session.blindCount ? 'Blind count' : null,
      sourceDeviceId: null,
      createdAt: session.createdAt,
      updatedAt: updatedAt,
      deletedAt: null,
    );
  }

  Map<String, Object?> toUpsertJson() {
    return {
      'workspace_id': workspaceId,
      'local_count_id': localCountId,
      'name': name,
      'status': status,
      'location_id': locationId,
      'location_name': locationName,
      'bin_id': binId,
      'bin_name': binName,
      'started_at': startedAt?.toUtc().toIso8601String(),
      'completed_at': completedAt?.toUtc().toIso8601String(),
      'approved_at': approvedAt?.toUtc().toIso8601String(),
      'counted_by_user_id': countedByUserId,
      'counted_by_name': countedByName,
      'counted_by_email': countedByEmail,
      'approved_by_user_id': approvedByUserId,
      'approved_by_name': approvedByName,
      'approved_by_email': approvedByEmail,
      'notes': notes,
      'source_device_id': sourceDeviceId,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }
}

class CloudCycleCountLine {
  const CloudCycleCountLine({
    required this.id,
    required this.workspaceId,
    required this.workspaceCycleCountId,
    required this.workspaceItemId,
    required this.localCountLineId,
    required this.localCountId,
    required this.localItemId,
    required this.locationId,
    required this.locationName,
    required this.binId,
    required this.binName,
    required this.expectedQuantity,
    required this.countedQuantity,
    required this.varianceQuantity,
    required this.varianceValue,
    required this.status,
    required this.countedAt,
    required this.countedByUserId,
    required this.countedByName,
    required this.countedByEmail,
    required this.notes,
    required this.sourceDeviceId,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String workspaceId;
  final String? workspaceCycleCountId;
  final String? workspaceItemId;
  final String localCountLineId;
  final String localCountId;
  final String localItemId;
  final String? locationId;
  final String? locationName;
  final String? binId;
  final String? binName;
  final double? expectedQuantity;
  final double countedQuantity;
  final double? varianceQuantity;
  final double? varianceValue;
  final String? status;
  final DateTime? countedAt;
  final String? countedByUserId;
  final String? countedByName;
  final String? countedByEmail;
  final String? notes;
  final String? sourceDeviceId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  factory CloudCycleCountLine.fromJson(Map<String, dynamic> json) {
    return CloudCycleCountLine(
      id: json['id']?.toString() ?? '',
      workspaceId: json['workspace_id']?.toString() ?? '',
      workspaceCycleCountId: json['workspace_cycle_count_id']?.toString(),
      workspaceItemId: json['workspace_item_id']?.toString(),
      localCountLineId: json['local_count_line_id']?.toString() ?? '',
      localCountId: json['local_count_id']?.toString() ?? '',
      localItemId: json['local_item_id']?.toString() ?? '',
      locationId: json['location_id']?.toString(),
      locationName: json['location_name']?.toString(),
      binId: json['bin_id']?.toString(),
      binName: json['bin_name']?.toString(),
      expectedQuantity: _double(json['expected_quantity']),
      countedQuantity: _double(json['counted_quantity']) ?? 0,
      varianceQuantity: _double(json['variance_quantity']),
      varianceValue: _double(json['variance_value']),
      status: json['status']?.toString(),
      countedAt: _nullableDate(json['counted_at']),
      countedByUserId: json['counted_by_user_id']?.toString(),
      countedByName: json['counted_by_name']?.toString(),
      countedByEmail: json['counted_by_email']?.toString(),
      notes: json['notes']?.toString(),
      sourceDeviceId: json['source_device_id']?.toString(),
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
      deletedAt: _nullableDate(json['deleted_at']),
    );
  }

  factory CloudCycleCountLine.fromLocalCycleCountLine({
    required String workspaceId,
    required CycleCountLine line,
    required CycleCountSession? session,
    String? workspaceCycleCountId,
    String? workspaceItemId,
    String? Function(String locationId)? locationNameFor,
    String? Function(String? userId)? userNameFor,
    String? Function(String? userId)? userEmailFor,
    double? Function(CycleCountLine line)? varianceValueFor,
  }) {
    final countedAt = session?.submittedAt ?? session?.approvedAt;
    return CloudCycleCountLine(
      id: '',
      workspaceId: workspaceId,
      workspaceCycleCountId: workspaceCycleCountId,
      workspaceItemId: workspaceItemId,
      localCountLineId: line.id,
      localCountId: line.sessionId,
      localItemId: line.itemId,
      locationId: _emptyToNull(line.locationId),
      locationName: locationNameFor?.call(line.locationId),
      binId: null,
      binName: null,
      expectedQuantity: line.expectedQuantity,
      countedQuantity: line.countedQuantity ?? 0,
      varianceQuantity: line.varianceQuantity,
      varianceValue: varianceValueFor?.call(line),
      status: session?.status.name,
      countedAt: countedAt,
      countedByUserId: null,
      countedByName: userNameFor?.call(session?.assignedToUserId),
      countedByEmail: userEmailFor?.call(session?.assignedToUserId),
      notes: _emptyToNull(line.notes),
      sourceDeviceId: null,
      createdAt: session?.createdAt ?? DateTime.now(),
      updatedAt: session?.approvedAt ?? session?.submittedAt ?? DateTime.now(),
      deletedAt: null,
    );
  }

  Map<String, Object?> toUpsertJson() {
    return {
      'workspace_id': workspaceId,
      'workspace_cycle_count_id': workspaceCycleCountId,
      'workspace_item_id': workspaceItemId,
      'local_count_line_id': localCountLineId,
      'local_count_id': localCountId,
      'local_item_id': localItemId,
      'location_id': locationId,
      'location_name': locationName,
      'bin_id': binId,
      'bin_name': binName,
      'expected_quantity': expectedQuantity,
      'counted_quantity': countedQuantity,
      'variance_quantity': varianceQuantity,
      'variance_value': varianceValue,
      'status': status,
      'counted_at': countedAt?.toUtc().toIso8601String(),
      'counted_by_user_id': countedByUserId,
      'counted_by_name': countedByName,
      'counted_by_email': countedByEmail,
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
