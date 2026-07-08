enum CloudSyncStatus { disabled, ready, syncing, offline, error, needsSetup }

enum CloudSyncDirection { upload, download, both }

enum CloudSyncEntity {
  item,
  inventoryBalance,
  transaction,
  checkout,
  supplier,
  location,
  purchaseOrder,
  count,
  countLine,
  user,
  settings,
}

enum CloudSyncOperation { create, update, delete }

class CloudSyncSummary {
  const CloudSyncSummary({
    required this.status,
    this.lastSyncAt,
    this.lastSuccessfulSyncAt,
    required this.pendingUploadCount,
    required this.pendingDownloadCount,
    this.lastError,
    this.activeWorkspaceId,
    this.activeWorkspaceName,
    required this.isCloudEnabled,
    required this.isWorkspaceSelected,
  });

  factory CloudSyncSummary.disabled() {
    return const CloudSyncSummary(
      status: CloudSyncStatus.disabled,
      pendingUploadCount: 0,
      pendingDownloadCount: 0,
      isCloudEnabled: false,
      isWorkspaceSelected: false,
    );
  }

  final CloudSyncStatus status;
  final DateTime? lastSyncAt;
  final DateTime? lastSuccessfulSyncAt;
  final int pendingUploadCount;
  final int pendingDownloadCount;
  final String? lastError;
  final String? activeWorkspaceId;
  final String? activeWorkspaceName;
  final bool isCloudEnabled;
  final bool isWorkspaceSelected;

  CloudSyncSummary copyWith({
    CloudSyncStatus? status,
    DateTime? lastSyncAt,
    DateTime? lastSuccessfulSyncAt,
    int? pendingUploadCount,
    int? pendingDownloadCount,
    String? lastError,
    bool clearLastError = false,
    String? activeWorkspaceId,
    String? activeWorkspaceName,
    bool clearWorkspace = false,
    bool? isCloudEnabled,
    bool? isWorkspaceSelected,
  }) {
    return CloudSyncSummary(
      status: status ?? this.status,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastSuccessfulSyncAt: lastSuccessfulSyncAt ?? this.lastSuccessfulSyncAt,
      pendingUploadCount: pendingUploadCount ?? this.pendingUploadCount,
      pendingDownloadCount: pendingDownloadCount ?? this.pendingDownloadCount,
      lastError: clearLastError ? null : lastError ?? this.lastError,
      activeWorkspaceId: clearWorkspace
          ? null
          : activeWorkspaceId ?? this.activeWorkspaceId,
      activeWorkspaceName: clearWorkspace
          ? null
          : activeWorkspaceName ?? this.activeWorkspaceName,
      isCloudEnabled: isCloudEnabled ?? this.isCloudEnabled,
      isWorkspaceSelected: isWorkspaceSelected ?? this.isWorkspaceSelected,
    );
  }
}

class CloudSyncResult {
  const CloudSyncResult({
    required this.success,
    required this.message,
    required this.uploadedCount,
    required this.downloadedCount,
    required this.skippedCount,
    this.error,
  });

  const CloudSyncResult.success({
    required this.message,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.skippedCount = 0,
  }) : success = true,
       error = null;

  const CloudSyncResult.failure({
    required this.message,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.skippedCount = 0,
    this.error,
  }) : success = false;

  final bool success;
  final String message;
  final int uploadedCount;
  final int downloadedCount;
  final int skippedCount;
  final Object? error;
}

String cloudSyncStatusLabel(CloudSyncStatus status) {
  return switch (status) {
    CloudSyncStatus.disabled => 'Disabled',
    CloudSyncStatus.ready => 'Ready',
    CloudSyncStatus.syncing => 'Syncing',
    CloudSyncStatus.offline => 'Offline',
    CloudSyncStatus.error => 'Error',
    CloudSyncStatus.needsSetup => 'Needs setup',
  };
}
