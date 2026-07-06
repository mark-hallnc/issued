enum AssignmentTargetType { job, truck, department, jobBox, workOrder, other }

class AssignmentTarget {
  const AssignmentTarget({
    required this.id,
    required this.name,
    required this.targetType,
    required this.code,
    required this.description,
    required this.locationId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final AssignmentTargetType targetType;
  final String? code;
  final String? description;
  final String? locationId;
  String? get relatedLocationId => locationId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssignmentTarget copyWith({
    String? id,
    String? name,
    AssignmentTargetType? targetType,
    String? code,
    String? description,
    String? locationId,
    bool clearCode = false,
    bool clearDescription = false,
    bool clearLocationId = false,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssignmentTarget(
      id: id ?? this.id,
      name: name ?? this.name,
      targetType: targetType ?? this.targetType,
      code: clearCode ? null : code ?? this.code,
      description: clearDescription ? null : description ?? this.description,
      locationId: clearLocationId ? null : locationId ?? this.locationId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum AssignableDestinationType { person, location, assignmentTarget, freeText }

class AssignableDestination {
  const AssignableDestination({
    required this.id,
    required this.type,
    required this.displayName,
    required this.subtitle,
    this.targetType,
  });

  final String id;
  final AssignableDestinationType type;
  final String displayName;
  final String? subtitle;
  final AssignmentTargetType? targetType;
}

String assignmentTargetTypeLabel(AssignmentTargetType type) {
  return switch (type) {
    AssignmentTargetType.job => 'Job',
    AssignmentTargetType.truck => 'Truck',
    AssignmentTargetType.department => 'Department',
    AssignmentTargetType.jobBox => 'Job Box',
    AssignmentTargetType.workOrder => 'Work Order',
    AssignmentTargetType.other => 'Other',
  };
}
