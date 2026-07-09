enum SyncQaCheckStatus {
  notStarted,
  ready,
  running,
  passed,
  warning,
  failed,
  skipped,
}

enum SyncQaCheckCategory {
  setup,
  auth,
  workspace,
  permissions,
  catalog,
  inventory,
  checkout,
  purchasing,
  counts,
  offline,
  conflicts,
  diagnostics,
}

class SyncQaCheck {
  const SyncQaCheck({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.expectedResult,
    required this.status,
    this.details,
    this.lastRunAt,
    this.manualSteps = const [],
    this.troubleshooting = const [],
  });

  final String id;
  final SyncQaCheckCategory category;
  final String title;
  final String description;
  final String expectedResult;
  final SyncQaCheckStatus status;
  final String? details;
  final DateTime? lastRunAt;
  final List<String> manualSteps;
  final List<String> troubleshooting;

  SyncQaCheck copyWith({
    SyncQaCheckStatus? status,
    String? details,
    bool clearDetails = false,
    DateTime? lastRunAt,
  }) {
    return SyncQaCheck(
      id: id,
      category: category,
      title: title,
      description: description,
      expectedResult: expectedResult,
      status: status ?? this.status,
      details: clearDetails ? null : details ?? this.details,
      lastRunAt: lastRunAt ?? this.lastRunAt,
      manualSteps: manualSteps,
      troubleshooting: troubleshooting,
    );
  }
}

class SyncQaSession {
  const SyncQaSession({
    required this.workspaceId,
    this.workspaceName,
    required this.startedAt,
    required this.updatedAt,
    required this.checks,
  });

  final String workspaceId;
  final String? workspaceName;
  final DateTime startedAt;
  final DateTime updatedAt;
  final List<SyncQaCheck> checks;

  int get passedCount => _count(SyncQaCheckStatus.passed);
  int get warningCount => _count(SyncQaCheckStatus.warning);
  int get failedCount => _count(SyncQaCheckStatus.failed);
  int get skippedCount => _count(SyncQaCheckStatus.skipped);
  int get totalCount => checks.length;

  int _count(SyncQaCheckStatus status) {
    return checks.where((check) => check.status == status).length;
  }

  SyncQaSession copyWith({
    String? workspaceId,
    String? workspaceName,
    DateTime? updatedAt,
    List<SyncQaCheck>? checks,
  }) {
    return SyncQaSession(
      workspaceId: workspaceId ?? this.workspaceId,
      workspaceName: workspaceName ?? this.workspaceName,
      startedAt: startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      checks: checks ?? this.checks,
    );
  }
}

String syncQaCheckStatusLabel(SyncQaCheckStatus status) {
  return switch (status) {
    SyncQaCheckStatus.notStarted => 'Not started',
    SyncQaCheckStatus.ready => 'Ready',
    SyncQaCheckStatus.running => 'Running',
    SyncQaCheckStatus.passed => 'Passed',
    SyncQaCheckStatus.warning => 'Warning',
    SyncQaCheckStatus.failed => 'Failed',
    SyncQaCheckStatus.skipped => 'Skipped',
  };
}

String syncQaCheckCategoryLabel(SyncQaCheckCategory category) {
  return switch (category) {
    SyncQaCheckCategory.setup => 'Setup',
    SyncQaCheckCategory.auth => 'Auth',
    SyncQaCheckCategory.workspace => 'Workspace',
    SyncQaCheckCategory.permissions => 'Permissions',
    SyncQaCheckCategory.catalog => 'Catalog',
    SyncQaCheckCategory.inventory => 'Inventory',
    SyncQaCheckCategory.checkout => 'Checkouts',
    SyncQaCheckCategory.purchasing => 'Purchasing',
    SyncQaCheckCategory.counts => 'Cycle counts',
    SyncQaCheckCategory.offline => 'Offline',
    SyncQaCheckCategory.conflicts => 'Conflicts',
    SyncQaCheckCategory.diagnostics => 'Diagnostics',
  };
}
