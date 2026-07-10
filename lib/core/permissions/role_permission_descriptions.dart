import '../models/models.dart';
import 'app_permissions.dart';
import 'effective_permissions.dart';

class RolePermissionActionDescription {
  const RolePermissionActionDescription({
    required this.title,
    required this.description,
    required this.allowed,
    required this.category,
  });

  final String title;
  final String description;
  final bool allowed;
  final String category;
}

class RolePermissionDescription {
  const RolePermissionDescription({
    required this.roleLabel,
    required this.roleKey,
    required this.summary,
    required this.actions,
  });

  final String roleLabel;
  final String roleKey;
  final String summary;
  final List<RolePermissionActionDescription> actions;
}

class RolePermissionCategory {
  static const accountUsers = 'Account & users';
  static const inventory = 'Inventory';
  static const locations = 'Locations';
  static const stockMovement = 'Stock movement';
  static const purchasing = 'Purchasing';
  static const checkouts = 'Checkouts';
  static const counts = 'Counts';
  static const reportsExports = 'Reports & exports';
  static const settingsTools = 'Settings & tools';
  static const costs = 'Costs';

  static const ordered = [
    accountUsers,
    inventory,
    locations,
    stockMovement,
    purchasing,
    checkouts,
    counts,
    reportsExports,
    settingsTools,
    costs,
  ];
}

List<RolePermissionDescription> buildRolePermissionDescriptions() {
  const roles = [
    CloudWorkspaceRole.owner,
    CloudWorkspaceRole.admin,
    CloudWorkspaceRole.manager,
    CloudWorkspaceRole.worker,
    CloudWorkspaceRole.viewOnly,
  ];

  return [
    for (final role in roles)
      _descriptionForCloudRole(
        role,
        AppPermissions(localRoleForCloudWorkspaceRole(role)),
      ),
  ];
}

RolePermissionDescription _descriptionForCloudRole(
  CloudWorkspaceRole role,
  AppPermissions permissions,
) {
  return RolePermissionDescription(
    roleLabel: cloudWorkspaceRoleLabel(role),
    roleKey: role.name,
    summary: _summaryForCloudRole(role),
    actions: _actionsForPermissions(role, permissions),
  );
}

String _summaryForCloudRole(CloudWorkspaceRole role) {
  return switch (role) {
    CloudWorkspaceRole.owner =>
      'Can manage the organization and has owner protections.',
    CloudWorkspaceRole.admin =>
      'Can manage most organization settings and users, with owner-only protections still applying.',
    CloudWorkspaceRole.manager =>
      'Can run day-to-day inventory work, including items, locations, receiving, counts, and purchasing.',
    CloudWorkspaceRole.worker =>
      'Can view inventory and perform basic stock movement such as issuing and returning items.',
    CloudWorkspaceRole.viewOnly =>
      'Can view inventory and reports without making changes.',
  };
}

List<RolePermissionActionDescription> _actionsForPermissions(
  CloudWorkspaceRole role,
  AppPermissions permissions,
) {
  final isOwner = role == CloudWorkspaceRole.owner;
  return [
    _action(
      category: RolePermissionCategory.accountUsers,
      title: 'Invite and manage users',
      description: isOwner
          ? 'Can invite users, change roles, disable members, and manage owner-protected actions.'
          : 'Can invite users, change roles, and disable members when owner protections allow it.',
      allowed: permissions.canManageUsers,
    ),
    _action(
      category: RolePermissionCategory.accountUsers,
      title: 'Manage plan',
      description: 'Can choose the organization plan.',
      allowed: permissions.canManagePlan,
    ),
    _action(
      category: RolePermissionCategory.inventory,
      title: 'View inventory',
      description: 'Can see inventory items and quantities.',
      allowed: permissions.canViewInventory,
    ),
    _action(
      category: RolePermissionCategory.inventory,
      title: 'Add and edit items',
      description: 'Can create inventory items and edit item details.',
      allowed: permissions.canManageItems,
    ),
    _action(
      category: RolePermissionCategory.inventory,
      title: 'Archive items',
      description: 'Can archive active inventory items.',
      allowed: permissions.canArchiveItems,
    ),
    _action(
      category: RolePermissionCategory.locations,
      title: 'Manage locations and units',
      description:
          'Can manage organization settings, including locations, units of measure, and custom fields.',
      allowed: permissions.canManageSettings,
    ),
    _action(
      category: RolePermissionCategory.stockMovement,
      title: 'Issue and return stock',
      description: 'Can issue items out and return them.',
      allowed: permissions.canIssueItems && permissions.canReturnItems,
    ),
    _action(
      category: RolePermissionCategory.stockMovement,
      title: 'Receive stock',
      description: 'Can receive stock into a location.',
      allowed: permissions.canReceiveStock,
    ),
    _action(
      category: RolePermissionCategory.stockMovement,
      title: 'Transfer and adjust quantities',
      description: 'Can transfer stock and make quantity adjustments.',
      allowed:
          permissions.canTransferStock && permissions.canAdjustQuantity,
    ),
    _action(
      category: RolePermissionCategory.purchasing,
      title: 'Manage suppliers and purchasing',
      description: 'Can manage suppliers, reorder requests, and purchasing records.',
      allowed:
          permissions.canManageSuppliers && permissions.canManagePurchasing,
    ),
    _action(
      category: RolePermissionCategory.checkouts,
      title: 'Manage checkouts',
      description: 'Can check items out, return them, and manage checkout records.',
      allowed: permissions.canManageCheckouts,
    ),
    _action(
      category: RolePermissionCategory.counts,
      title: 'Run cycle counts',
      description: 'Can create, run, and approve cycle counts.',
      allowed:
          permissions.canManageCycleCounts && permissions.canApproveCycleCounts,
    ),
    _action(
      category: RolePermissionCategory.reportsExports,
      title: 'View reports',
      description: 'Can open reports.',
      allowed: permissions.canViewReports,
    ),
    _action(
      category: RolePermissionCategory.reportsExports,
      title: 'Export data and labels',
      description: 'Can import, export, and print labels.',
      allowed: permissions.canImportExport && permissions.canExportReports,
    ),
    _action(
      category: RolePermissionCategory.settingsTools,
      title: 'Use backup and data tools',
      description: 'Can use backup, restore, import, export, and data health tools.',
      allowed:
          permissions.canImportExport && permissions.canManageSettings,
    ),
    _action(
      category: RolePermissionCategory.settingsTools,
      title: 'Clear device data',
      description: 'Can clear local data from this device in developer tools.',
      allowed: permissions.canClearLocalData,
    ),
    _action(
      category: RolePermissionCategory.costs,
      title: 'View costs and inventory value',
      description: 'Can see item costs, inventory value, and cost-sensitive reports.',
      allowed: permissions.canViewCosts,
    ),
  ];
}

RolePermissionActionDescription _action({
  required String category,
  required String title,
  required String description,
  required bool allowed,
}) {
  return RolePermissionActionDescription(
    title: title,
    description: description,
    allowed: allowed,
    category: category,
  );
}
