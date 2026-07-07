import '../models/models.dart';

class AppPermissions {
  const AppPermissions(this.role);

  final UserRole role;

  bool get isAdmin => role == UserRole.admin;
  bool get isManager => role == UserRole.manager;
  bool get isWorker => role == UserRole.worker;
  bool get isViewOnly => role == UserRole.viewOnly;

  bool get canViewInventory => true;
  bool get canCreateItems => isAdmin || isManager;
  bool get canEditItems => isAdmin || isManager;
  bool get canDeleteItems => isAdmin || isManager;
  bool get canManageUsers => isAdmin;
  bool get canManageSettings => isAdmin || isManager;
  bool get canManageItems => canCreateItems || canEditItems;
  bool get canArchiveItems => canManageItems;
  bool get canPerformInventoryActions => isAdmin || isManager || isWorker;
  bool get canIssueItems => canPerformInventoryActions;
  bool get canReturnItems => canPerformInventoryActions;
  bool get canManageCheckouts => isAdmin || isManager;
  bool get canReceiveStock => isAdmin || isManager;
  bool get canTransferStock => isAdmin || isManager;
  bool get canAdjustQuantity => isAdmin || isManager;
  bool get canAdjustInventory => canAdjustQuantity;
  bool get canManageCycleCounts => isAdmin || isManager;
  bool get canApproveCycleCounts => isAdmin || isManager;
  bool get canRunCounts => canManageCycleCounts;
  bool get canImportExport => isAdmin || isManager;
  bool get canViewReports => true;
  bool get canExportReports => canImportExport;
  bool get canViewCosts => isAdmin || isManager;
  bool get canEditCosts => canViewCosts;
  bool get canManagePlan => isAdmin;
  bool get canManageSuppliers => isAdmin || isManager;
  bool get canManagePurchasing => isAdmin || isManager;
  bool get canManageMembers => isAdmin;
  bool get canInviteMembers => isAdmin;
  bool get canChangeMemberRoles => isAdmin;
  bool get canDisableMembers => isAdmin;
  bool get canManageWorkspaceSettings => isAdmin;
  bool get canClearLocalData => isAdmin;
}

String roleLabel(UserRole role) {
  return switch (role) {
    UserRole.admin => 'Admin',
    UserRole.manager => 'Manager',
    UserRole.worker => 'Worker',
    UserRole.viewOnly => 'View-only',
  };
}

void showPermissionDeniedMessage(void Function(String message) showMessage) {
  showMessage('Your current role does not allow this action.');
}
