class Plan {
  const Plan({
    required this.code,
    required this.name,
    required this.itemLimit,
    required this.userLimit,
    required this.locationLimit,
    required this.photoLimit,
    required this.labelExportLimit,
    required this.csvImportEnabled,
    required this.advancedReportsEnabled,
  });

  final String code;
  final String name;
  final int itemLimit;
  final int userLimit;
  final int locationLimit;
  final int photoLimit;
  final int labelExportLimit;
  final bool csvImportEnabled;
  final bool advancedReportsEnabled;

  Plan copyWith({
    String? code,
    String? name,
    int? itemLimit,
    int? userLimit,
    int? locationLimit,
    int? photoLimit,
    int? labelExportLimit,
    bool? csvImportEnabled,
    bool? advancedReportsEnabled,
  }) {
    return Plan(
      code: code ?? this.code,
      name: name ?? this.name,
      itemLimit: itemLimit ?? this.itemLimit,
      userLimit: userLimit ?? this.userLimit,
      locationLimit: locationLimit ?? this.locationLimit,
      photoLimit: photoLimit ?? this.photoLimit,
      labelExportLimit: labelExportLimit ?? this.labelExportLimit,
      csvImportEnabled: csvImportEnabled ?? this.csvImportEnabled,
      advancedReportsEnabled:
          advancedReportsEnabled ?? this.advancedReportsEnabled,
    );
  }
}

class PlanLimitWarning {
  const PlanLimitWarning({
    required this.kind,
    required this.message,
    required this.severity,
    required this.recommendedPlanCode,
  });

  final PlanLimitKind kind;
  final String message;
  final PlanLimitSeverity severity;
  final String? recommendedPlanCode;
}

enum PlanLimitKind { items, users, locations, photos, labels }

enum PlanLimitSeverity { approaching, nearlyFull, reached }

class CompanyUsage {
  const CompanyUsage({
    required this.activeItemCount,
    required this.userCount,
    required this.locationCount,
    required this.photoCount,
    required this.labelExportCount,
  });

  final int activeItemCount;
  final int userCount;
  final int locationCount;
  final int photoCount;
  final int labelExportCount;

  CompanyUsage copyWith({
    int? activeItemCount,
    int? userCount,
    int? locationCount,
    int? photoCount,
    int? labelExportCount,
  }) {
    return CompanyUsage(
      activeItemCount: activeItemCount ?? this.activeItemCount,
      userCount: userCount ?? this.userCount,
      locationCount: locationCount ?? this.locationCount,
      photoCount: photoCount ?? this.photoCount,
      labelExportCount: labelExportCount ?? this.labelExportCount,
    );
  }
}
