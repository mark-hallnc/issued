class Plan {
  const Plan({
    required this.code,
    required this.name,
    required this.itemLimit,
    required this.userLimit,
    required this.locationLimit,
    required this.photoLimit,
    required this.labelExportLimit,
  });

  final String code;
  final String name;
  final int itemLimit;
  final int userLimit;
  final int locationLimit;
  final int photoLimit;
  final int labelExportLimit;

  Plan copyWith({
    String? code,
    String? name,
    int? itemLimit,
    int? userLimit,
    int? locationLimit,
    int? photoLimit,
    int? labelExportLimit,
  }) {
    return Plan(
      code: code ?? this.code,
      name: name ?? this.name,
      itemLimit: itemLimit ?? this.itemLimit,
      userLimit: userLimit ?? this.userLimit,
      locationLimit: locationLimit ?? this.locationLimit,
      photoLimit: photoLimit ?? this.photoLimit,
      labelExportLimit: labelExportLimit ?? this.labelExportLimit,
    );
  }
}

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
