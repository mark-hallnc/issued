import 'sync_models.dart';

enum SyncConflictResolutionAction {
  keepLocal,
  useCloud,
  markReviewed,
  retry,
  unsupported,
}

enum SyncConflictSeverity { info, warning, dangerous }

class SyncConflictResolutionResult {
  const SyncConflictResolutionResult({
    required this.success,
    required this.action,
    required this.entityType,
    this.localId,
    this.cloudId,
    required this.message,
    required this.requiresSyncRetry,
    this.error,
  });

  const SyncConflictResolutionResult.failure({
    required this.action,
    required this.entityType,
    this.localId,
    this.cloudId,
    required this.message,
    this.error,
  }) : success = false,
       requiresSyncRetry = false;

  final bool success;
  final SyncConflictResolutionAction action;
  final CloudSyncEntity entityType;
  final String? localId;
  final String? cloudId;
  final String message;
  final bool requiresSyncRetry;
  final Object? error;
}

bool isSafeAutoApplyAction(
  CloudSyncEntity entity,
  SyncConflictResolutionAction action,
) {
  if (action == SyncConflictResolutionAction.markReviewed ||
      action == SyncConflictResolutionAction.retry) {
    return true;
  }
  return switch (entity) {
    CloudSyncEntity.item || CloudSyncEntity.supplier => true,
    CloudSyncEntity.transaction =>
      action == SyncConflictResolutionAction.keepLocal,
    CloudSyncEntity.purchaseOrder ||
    CloudSyncEntity.checkout ||
    CloudSyncEntity.count ||
    CloudSyncEntity.countLine =>
      action == SyncConflictResolutionAction.keepLocal,
    _ => false,
  };
}

bool isDestructiveAction(
  CloudSyncEntity entity,
  SyncConflictResolutionAction action,
) {
  if (action == SyncConflictResolutionAction.useCloud) {
    return entity != CloudSyncEntity.item && entity != CloudSyncEntity.supplier;
  }
  return entity == CloudSyncEntity.inventoryBalance ||
      entity == CloudSyncEntity.transaction;
}
