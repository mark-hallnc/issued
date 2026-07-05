enum AssignmentTargetType { job, truck, department, jobBox, other }

class AssignmentTarget {
  const AssignmentTarget({
    required this.id,
    required this.name,
    required this.targetType,
    required this.description,
    required this.locationId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final AssignmentTargetType targetType;
  final String? description;
  final String? locationId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssignmentTarget copyWith({
    String? id,
    String? name,
    AssignmentTargetType? targetType,
    String? description,
    String? locationId,
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
  });

  final String id;
  final AssignableDestinationType type;
  final String displayName;
  final String? subtitle;
}

String assignmentTargetTypeLabel(AssignmentTargetType type) {
  return switch (type) {
    AssignmentTargetType.job => 'Job',
    AssignmentTargetType.truck => 'Truck',
    AssignmentTargetType.department => 'Department',
    AssignmentTargetType.jobBox => 'Job Box',
    AssignmentTargetType.other => 'Other',
  };
}
