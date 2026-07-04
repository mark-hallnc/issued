class Company {
  const Company({
    required this.id,
    required this.name,
    required this.industry,
    required this.createdAt,
    required this.updatedAt,
    required this.setupCompleted,
  });

  final String id;
  final String name;
  final String? industry;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool setupCompleted;

  Company copyWith({
    String? id,
    String? name,
    String? industry,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? setupCompleted,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      industry: industry ?? this.industry,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      setupCompleted: setupCompleted ?? this.setupCompleted,
    );
  }
}
