enum CloudAdoptionState {
  notNeeded,
  needsDecision,
  localOnlySelected,
  uploadSelected,
  startFreshSelected,
  completed,
  blocked,
  error,
}

enum CloudAdoptionChoice {
  uploadLocalData,
  keepLocalOnly,
  startFreshCloud,
  cancel,
}

class CloudAdoptionSummary {
  const CloudAdoptionSummary({
    required this.state,
    required this.workspaceId,
    this.workspaceName,
    required this.localItemCount,
    required this.localBalanceCount,
    required this.localTransactionCount,
    required this.localCheckoutCount,
    required this.localSupplierCount,
    required this.localPurchasingCount,
    required this.localCycleCountCount,
    required this.cloudItemCount,
    required this.cloudBalanceCount,
    required this.cloudTransactionCount,
    required this.cloudCheckoutCount,
    required this.cloudSupplierCount,
    required this.cloudPurchasingCount,
    required this.cloudCycleCountCount,
    required this.hasLocalBusinessData,
    required this.hasCloudBusinessData,
    required this.message,
    this.completedChoice,
    this.completedAt,
  });

  final CloudAdoptionState state;
  final String workspaceId;
  final String? workspaceName;
  final int localItemCount;
  final int localBalanceCount;
  final int localTransactionCount;
  final int localCheckoutCount;
  final int localSupplierCount;
  final int localPurchasingCount;
  final int localCycleCountCount;
  final int cloudItemCount;
  final int cloudBalanceCount;
  final int cloudTransactionCount;
  final int cloudCheckoutCount;
  final int cloudSupplierCount;
  final int cloudPurchasingCount;
  final int cloudCycleCountCount;
  final bool hasLocalBusinessData;
  final bool hasCloudBusinessData;
  final String message;
  final CloudAdoptionChoice? completedChoice;
  final DateTime? completedAt;

  int get totalLocalBusinessCount =>
      localItemCount +
      localBalanceCount +
      localTransactionCount +
      localCheckoutCount +
      localSupplierCount +
      localPurchasingCount +
      localCycleCountCount;

  int get totalCloudBusinessCount =>
      cloudItemCount +
      cloudBalanceCount +
      cloudTransactionCount +
      cloudCheckoutCount +
      cloudSupplierCount +
      cloudPurchasingCount +
      cloudCycleCountCount;

  bool get shouldProtectExistingLocalData =>
      completedChoice == CloudAdoptionChoice.startFreshCloud ||
      completedChoice == CloudAdoptionChoice.keepLocalOnly;
}
