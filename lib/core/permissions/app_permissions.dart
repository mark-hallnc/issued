import '../models/models.dart';

class AppPermissions {
  const AppPermissions(this.role);

  final UserRole role;

  bool get isAdmin => role == UserRole.admin;
  bool get isManager => role == UserRole.manager;
  bool get isWorker => role == UserRole.worker;

  bool get canManageUsers => isAdmin;
  bool get canManageSettings => isAdmin || isManager;
  bool get canManageItems => isAdmin || isManager;
  bool get canArchiveItems => canManageItems;
  bool get canPerformInventoryActions => isAdmin || isManager || isWorker;
  bool get canIssueItems => canPerformInventoryActions;
  bool get canReceiveStock => isAdmin || isManager;
  bool get canTransferStock => isAdmin || isManager;
  bool get canAdjustQuantity => isAdmin || isManager;
  bool get canManageCycleCounts => isAdmin || isManager;
  bool get canApproveCycleCounts => isAdmin || isManager;
  bool get canImportExport => isAdmin || isManager;
  bool get canViewCosts => isAdmin || isManager;
  bool get canManagePlan => isAdmin;
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
