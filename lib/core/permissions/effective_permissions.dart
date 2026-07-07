import '../models/models.dart';
import 'app_permissions.dart';

UserRole localRoleForCloudWorkspaceRole(CloudWorkspaceRole role) {
  return switch (role) {
    CloudWorkspaceRole.owner || CloudWorkspaceRole.admin => UserRole.admin,
    CloudWorkspaceRole.manager => UserRole.manager,
    CloudWorkspaceRole.worker => UserRole.worker,
    CloudWorkspaceRole.viewOnly => UserRole.viewOnly,
  };
}

AppPermissions effectivePermissionsForRole(UserRole role) {
  return AppPermissions(role);
}

String effectiveRoleLabel({
  required UserRole localRole,
  required CloudWorkspaceRole? cloudRole,
  required bool isCloudWorkspaceMode,
}) {
  if (isCloudWorkspaceMode && cloudRole != null) {
    return cloudWorkspaceRoleLabel(cloudRole);
  }
  return roleLabel(localRole);
}
