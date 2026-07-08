enum SyncUserStatus {
  disabled,
  signedOut,
  noWorkspace,
  setupRequired,
  offlineOrFailed,
  syncing,
  pendingChanges,
  synced,
  conflictsNeedReview,
}

class SyncUserStatusSummary {
  const SyncUserStatusSummary({
    required this.status,
    required this.label,
    this.detail,
    required this.pendingCount,
    required this.failedCount,
    required this.conflictCount,
    this.lastSyncedAt,
    required this.canOpenDiagnostics,
  });

  final SyncUserStatus status;
  final String label;
  final String? detail;
  final int pendingCount;
  final int failedCount;
  final int conflictCount;
  final DateTime? lastSyncedAt;
  final bool canOpenDiagnostics;
}
