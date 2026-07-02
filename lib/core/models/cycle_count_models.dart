enum CycleCountStatus { draft, assigned, submitted, approved }

class CycleCountSession {
  const CycleCountSession({
    required this.id,
    required this.name,
    required this.status,
    required this.assignedToUserId,
    required this.blindCount,
    required this.dueAt,
    required this.createdAt,
    required this.submittedAt,
    required this.approvedAt,
  });

  final String id;
  final String name;
  final CycleCountStatus status;
  final String? assignedToUserId;
  final bool blindCount;
  final DateTime? dueAt;
  final DateTime createdAt;
  final DateTime? submittedAt;
  final DateTime? approvedAt;

  CycleCountSession copyWith({
    String? id,
    String? name,
    CycleCountStatus? status,
    String? assignedToUserId,
    bool? blindCount,
    DateTime? dueAt,
    DateTime? createdAt,
    DateTime? submittedAt,
    DateTime? approvedAt,
  }) {
    return CycleCountSession(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      blindCount: blindCount ?? this.blindCount,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt ?? this.createdAt,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}

class CycleCountLine {
  const CycleCountLine({
    required this.id,
    required this.sessionId,
    required this.itemId,
    required this.locationId,
    required this.expectedQuantity,
    required this.countedQuantity,
    required this.varianceQuantity,
    required this.unitOfMeasureId,
    required this.notes,
  });

  final String id;
  final String sessionId;
  final String itemId;
  final String locationId;
  final double expectedQuantity;
  final double? countedQuantity;
  final double? varianceQuantity;
  final String unitOfMeasureId;
  final String? notes;

  CycleCountLine copyWith({
    String? id,
    String? sessionId,
    String? itemId,
    String? locationId,
    double? expectedQuantity,
    double? countedQuantity,
    double? varianceQuantity,
    String? unitOfMeasureId,
    String? notes,
  }) {
    return CycleCountLine(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      itemId: itemId ?? this.itemId,
      locationId: locationId ?? this.locationId,
      expectedQuantity: expectedQuantity ?? this.expectedQuantity,
      countedQuantity: countedQuantity ?? this.countedQuantity,
      varianceQuantity: varianceQuantity ?? this.varianceQuantity,
      unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
      notes: notes ?? this.notes,
    );
  }
}
