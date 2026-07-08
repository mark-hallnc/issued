import 'sync_models.dart';

enum SyncHealthStatus {
  healthy,
  pending,
  failed,
  conflict,
  mismatch,
  unsupported,
  unknown,
}

class SyncEntityReconciliation {
  const SyncEntityReconciliation({
    required this.entityType,
    required this.localCount,
    required this.cloudCount,
    required this.pendingUploadCount,
    required this.failedUploadCount,
    required this.conflictCount,
    this.lastLocalChangeAt,
    this.lastCloudChangeAt,
    required this.status,
    required this.message,
  });

  final CloudSyncEntity entityType;
  final int? localCount;
  final int? cloudCount;
  final int pendingUploadCount;
  final int failedUploadCount;
  final int conflictCount;
  final DateTime? lastLocalChangeAt;
  final DateTime? lastCloudChangeAt;
  final SyncHealthStatus status;
  final String message;
}

class SyncReconciliationSummary {
  const SyncReconciliationSummary({
    required this.workspaceId,
    this.workspaceName,
    required this.checkedAt,
    required this.overallStatus,
    required this.entities,
    this.messages = const [],
  });

  final String workspaceId;
  final String? workspaceName;
  final DateTime checkedAt;
  final SyncHealthStatus overallStatus;
  final List<SyncEntityReconciliation> entities;
  final List<String> messages;

  int get totalLocalCount =>
      entities.fold(0, (total, entity) => total + (entity.localCount ?? 0));

  int get totalCloudCount =>
      entities.fold(0, (total, entity) => total + (entity.cloudCount ?? 0));

  int get totalPending =>
      entities.fold(0, (total, entity) => total + entity.pendingUploadCount);

  int get totalFailed =>
      entities.fold(0, (total, entity) => total + entity.failedUploadCount);

  int get totalConflicts =>
      entities.fold(0, (total, entity) => total + entity.conflictCount);
}

String syncHealthStatusLabelFor(SyncHealthStatus status) {
  return switch (status) {
    SyncHealthStatus.healthy => 'Healthy',
    SyncHealthStatus.pending => 'Pending',
    SyncHealthStatus.failed => 'Failed',
    SyncHealthStatus.conflict => 'Needs review',
    SyncHealthStatus.mismatch => 'Count mismatch',
    SyncHealthStatus.unsupported => 'Unsupported',
    SyncHealthStatus.unknown => 'Unknown',
  };
}

String syncEntityLabel(CloudSyncEntity entity) {
  return switch (entity) {
    CloudSyncEntity.item => 'Items',
    CloudSyncEntity.inventoryBalance => 'Balances',
    CloudSyncEntity.transaction => 'Transactions',
    CloudSyncEntity.checkout => 'Checkouts',
    CloudSyncEntity.supplier => 'Suppliers',
    CloudSyncEntity.location => 'Locations',
    CloudSyncEntity.purchaseOrder => 'Purchasing',
    CloudSyncEntity.count => 'Cycle Counts',
    CloudSyncEntity.countLine => 'Count Lines',
    CloudSyncEntity.user => 'Users',
    CloudSyncEntity.settings => 'Settings',
  };
}
