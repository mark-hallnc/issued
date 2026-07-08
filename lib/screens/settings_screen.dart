import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import 'assignment_targets_screen.dart';
import 'backup_restore_screen.dart';
import 'cloud_login_screen.dart';
import 'data_health_screen.dart';
import 'import_export_screen.dart';
import 'label_center_screen.dart';
import 'reports_screen.dart';
import 'settings_detail_screens.dart';
import 'sync_conflicts_screen.dart';
import 'sync_queue_screen.dart';
import 'workspace_members_screen.dart';
import 'workspace_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final permissions = store.permissions;
    final rows = [
      if (permissions.canManageSettings)
        const _SettingsRow(
          title: 'Company',
          icon: Icons.business_outlined,
          screen: CompanySettingsScreen(),
        ),
      if (permissions.canManageUsers)
        const _SettingsRow(
          title: 'Users & Roles',
          icon: Icons.group_outlined,
          screen: UsersRolesSettingsScreen(),
        ),
      const _SettingsRow(
        title: 'Cloud Account / Workspace',
        icon: Icons.cloud_outlined,
        screen: CloudAccountSettingsScreen(),
      ),
      if (permissions.canManageSettings)
        const _SettingsRow(
          title: 'Locations',
          icon: Icons.location_on_outlined,
          screen: LocationsSettingsScreen(),
        ),
      if (permissions.canManageSettings)
        const _SettingsRow(
          title: 'Units of Measure',
          icon: Icons.straighten_outlined,
          screen: UnitsOfMeasureSettingsScreen(),
        ),
      if (permissions.canManageSettings)
        const _SettingsRow(
          title: 'Custom Fields',
          icon: Icons.tune_outlined,
          screen: CustomFieldsSettingsScreen(),
        ),
      if (permissions.isAdmin || permissions.isManager)
        const _SettingsRow(
          title: 'Assignment Targets',
          icon: Icons.assignment_ind_outlined,
          screen: AssignmentTargetsScreen(),
        ),
      if (permissions.isAdmin || permissions.isManager)
        const _SettingsRow(
          title: 'Plan & Usage',
          icon: Icons.query_stats_outlined,
          screen: PlanUsageSettingsScreen(),
        ),
      const _SettingsRow(
        title: 'Reports',
        icon: Icons.assessment_outlined,
        screen: ReportsScreen(),
      ),
      if (permissions.canImportExport)
        const _SettingsRow(
          title: 'Label Center',
          icon: Icons.qr_code_2,
          screen: LabelCenterScreen(),
        ),
      if (permissions.isAdmin || permissions.isManager)
        const _SettingsRow(
          title: 'Backup & Restore',
          icon: Icons.backup_outlined,
          screen: BackupRestoreScreen(),
        ),
      if (permissions.isAdmin || permissions.isManager)
        const _SettingsRow(
          title: 'Data Health',
          icon: Icons.health_and_safety_outlined,
          screen: DataHealthScreen(),
        ),
      if (permissions.canImportExport)
        const _SettingsRow(
          title: 'Import & Export',
          icon: Icons.import_export,
          screen: ImportExportScreen(),
        ),
      if (kDebugMode && permissions.canClearLocalData)
        const _SettingsRow(
          title: 'Developer Tools',
          icon: Icons.developer_mode_outlined,
          screen: DeveloperToolsSettingsScreen(),
        ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CurrentUserCard(store: store),
        const SizedBox(height: 12),
        if (rows.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Settings are read-only for your current role.'),
            ),
          )
        else
          for (final row in rows) ...[
            Card(
              child: ListTile(
                leading: Icon(row.icon, color: const Color(0xFF1E3A5F)),
                title: Text(row.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (context) => row.screen),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class DeveloperToolsSettingsScreen extends StatelessWidget {
  const DeveloperToolsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canClearLocalData) {
      return Scaffold(
        appBar: AppBar(title: const Text('Developer Tools')),
        body: const Center(
          child: Text(
            'You do not have permission to do that in this workspace.',
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Developer Tools')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Development cleanup',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'These debug-only actions affect this device only. Cloud workspaces will not be deleted.',
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => _confirmAndRun(
                      context,
                      title: 'Clear local test data?',
                      message:
                          'This removes local test inventory and activity from this device only. It does not delete cloud workspaces.',
                      action: store.clearLocalInventoryTestDataForDevelopment,
                    ),
                    child: const Text('Clear local test data'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: store.isCloudSignedIn
                        ? () => _confirmAndRun(
                            context,
                            title: 'Sign out cloud account?',
                            message:
                                'This signs out of the cloud account on this device. Local app data stays on this device.',
                            action: store.signOutCloud,
                          )
                        : null,
                    child: const Text('Sign out cloud account'),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => _confirmAndRun(
                      context,
                      title: 'Clear local data and sign out?',
                      message:
                          'This removes local app data from this device and signs out of the cloud account. It does not delete your Supabase project or workspace.',
                      action: store.clearLocalDataAndSignOutForDevelopment,
                    ),
                    child: const Text('Clear local data and sign out'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => _confirmAndRun(
                      context,
                      title: 'Reset app onboarding?',
                      message:
                          'This shows onboarding again. Inventory data is not deleted.',
                      action: () async {
                        await store.resetOnboardingForTesting();
                        return const AppActionResult.success(
                          message: 'Onboarding reset.',
                        );
                      },
                    ),
                    child: const Text('Reset app onboarding state'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndRun(
    BuildContext context, {
    required String title,
    required String message,
    required Future<AppActionResult> Function() action,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final result = await action();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Development action complete.')),
    );
  }
}

class CloudAccountSettingsScreen extends StatelessWidget {
  const CloudAccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final cloudEmail = store.currentCloudUser?.email;
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CloudStatusLine(
                    label: 'Cloud configured',
                    value: store.isCloudConfigured ? 'Yes' : 'No',
                  ),
                  _CloudStatusLine(
                    label: 'Signed in',
                    value: cloudEmail ?? 'No',
                  ),
                  _CloudStatusLine(
                    label: 'Active workspace',
                    value: store.activeWorkspace?.name ?? 'None',
                  ),
                  _CloudStatusLine(
                    label: 'Cloud role',
                    value: store.currentCloudRole == null
                        ? 'None'
                        : cloudWorkspaceRoleLabel(store.currentCloudRole!),
                  ),
                  _CloudStatusLine(
                    label: 'Mode',
                    value: store.cloudModeEnabled
                        ? 'Cloud workspace'
                        : 'Local-Only Mode',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cloud Sync',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _CloudStatusLine(
                    label: 'Status',
                    value: store.cloudSyncStatusLabel,
                  ),
                  _CloudStatusLine(
                    label: 'Active workspace',
                    value:
                        store.cloudSyncSummary.activeWorkspaceName ??
                        store.activeWorkspace?.name ??
                        'None',
                  ),
                  _CloudStatusLine(
                    label: 'Last sync',
                    value: _formatCloudSyncDate(
                      store.cloudSyncSummary.lastSuccessfulSyncAt,
                    ),
                  ),
                  _CloudStatusLine(
                    label: 'Last pull',
                    value: _formatCloudSyncDate(store.lastCloudPullAt),
                  ),
                  _CloudStatusLine(
                    label: 'Last push',
                    value: _formatCloudSyncDate(store.lastCloudPushAt),
                  ),
                  _CloudStatusLine(
                    label: 'Pending local changes',
                    value: store.cloudSyncSummary.pendingUploadCount.toString(),
                  ),
                  _CloudStatusLine(
                    label: 'Conflicts',
                    value: store.syncConflictCount.toString(),
                  ),
                  _CloudStatusLine(
                    label: 'Failed uploads',
                    value: store.failedSyncUploadCount.toString(),
                  ),
                  const _CloudStatusLine(
                    label: 'Auto sync',
                    value: 'Enabled while signed in',
                  ),
                  const _CloudStatusLine(
                    label: 'Item catalog',
                    value: 'Enabled',
                  ),
                  const _CloudStatusLine(
                    label: 'Quantities/balances',
                    value: 'Enabled',
                  ),
                  const _CloudStatusLine(
                    label: 'Transaction history',
                    value: 'Enabled',
                  ),
                  const _CloudStatusLine(label: 'Checkouts', value: 'Enabled'),
                  const _CloudStatusLine(label: 'Suppliers', value: 'Enabled'),
                  const _CloudStatusLine(
                    label: 'Purchasing/reorders',
                    value: 'Enabled',
                  ),
                  const _CloudStatusLine(
                    label: 'Cycle counts',
                    value: 'Enabled',
                  ),
                  if (store.cloudSyncSummary.lastError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      store.cloudSyncSummary.lastError!,
                      style: const TextStyle(
                        color: Color(0xFFB42318),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Text(
                    'Safe two-way sync is enabled for item and supplier metadata. Workflow records are downloaded for status and staged until conflict review is finished. Background sync is not enabled yet.',
                  ),
                  if (store.hasSyncConflicts) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7E6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF79009)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sync needs review',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${store.syncConflictCount} records were skipped because local and cloud data both changed.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (store.failedSyncUploadCount > 0) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Some changes could not be synced. They will retry automatically.',
                      style: TextStyle(
                        color: Color(0xFFB42318),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: store.isCloudSignedIn
                            ? () async {
                                final result = await store.syncNow();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.message ?? 'Sync checked.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.sync),
                        label: const Text('Sync now'),
                      ),
                      OutlinedButton.icon(
                        onPressed: store.isCloudSignedIn
                            ? () async {
                                final result = await store.syncTwoWayNow();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.message ??
                                            'Two-way sync checked.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.sync_alt),
                        label: const Text('Two-way sync now'),
                      ),
                      OutlinedButton.icon(
                        onPressed: store.isCloudSignedIn
                            ? () async {
                                final result = await store
                                    .pullCloudChangesNow();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.message ??
                                            'Cloud changes pulled.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.cloud_download_outlined),
                        label: const Text('Pull cloud changes'),
                      ),
                      if (store.hasSyncConflicts)
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    const SyncConflictsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.report_problem_outlined),
                          label: const Text('View conflicts'),
                        ),
                      if (store.hasSyncConflicts)
                        OutlinedButton.icon(
                          onPressed: store.clearSyncMergeConflicts,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Clear reviewed conflicts'),
                        ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const SyncQueueScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt_outlined),
                        label: const Text('View sync queue'),
                      ),
                      OutlinedButton.icon(
                        onPressed: store.failedSyncUploadCount > 0
                            ? () async {
                                final result = await store
                                    .retryFailedUploadsNow();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.message ??
                                            'Failed uploads queued.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry failed uploads'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final result = await store
                              .clearCompletedSyncQueueNow();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result.message ??
                                      'Completed sync history cleared.',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.cleaning_services_outlined),
                        label: const Text('Clear completed queue'),
                      ),
                      OutlinedButton.icon(
                        onPressed: store.isCloudSignedIn
                            ? () async {
                                final result = await store.syncItemCatalogNow();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.message ?? 'Catalog synced.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.inventory_2_outlined),
                        label: const Text('Sync item catalog now'),
                      ),
                      OutlinedButton.icon(
                        onPressed: store.isCloudSignedIn
                            ? () async {
                                final result = await store
                                    .syncInventoryBalancesNow();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.message ?? 'Balances synced.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.warehouse_outlined),
                        label: const Text('Sync balances'),
                      ),
                      OutlinedButton.icon(
                        onPressed: store.isCloudSignedIn
                            ? () async {
                                final result = await store
                                    .syncInventoryTransactionsNow();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.message ??
                                            'Transaction history synced.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: const Text('Sync transaction history'),
                      ),
                      OutlinedButton.icon(
                        onPressed: store.isCloudSignedIn
                            ? () async {
                                final result = await store.syncCheckoutsNow();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.message ?? 'Checkouts synced.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.assignment_return_outlined),
                        label: const Text('Sync checkouts'),
                      ),
                      OutlinedButton.icon(
                        onPressed: store.isCloudSignedIn
                            ? () async {
                                final result = await store.syncPurchasingNow();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.message ??
                                            'Purchasing records synced.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: const Text('Sync purchasing'),
                      ),
                      OutlinedButton.icon(
                        onPressed: store.isCloudSignedIn
                            ? () async {
                                final result = await store.syncCycleCountsNow();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.message ??
                                            'Cycle counts synced.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        icon: const Icon(Icons.fact_check_outlined),
                        label: const Text('Sync cycle counts'),
                      ),
                      if (store.cloudSyncSummary.lastError != null)
                        OutlinedButton.icon(
                          onPressed: store.clearCloudSyncError,
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear error'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const CloudLoginScreen(),
                ),
              );
            },
            child: Text(store.isCloudSignedIn ? 'Reconnect Cloud' : 'Sign In'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: store.isCloudSignedIn
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const WorkspaceSelectionScreen(),
                      ),
                    );
                  }
                : null,
            child: const Text('Select Workspace'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: store.activeWorkspace == null
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const WorkspaceMembersScreen(),
                      ),
                    );
                  },
            child: const Text('Members / Invites'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: store.isCloudSignedIn
                ? () async {
                    if (store.cloudSyncSummary.pendingUploadCount > 0 ||
                        store.failedSyncUploadCount > 0) {
                      final shouldSignOut = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Unsynced changes'),
                          content: const Text(
                            'This device has unsynced changes. They will stay on this device, but they cannot upload while signed out.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Sign out'),
                            ),
                          ],
                        ),
                      );
                      if (shouldSignOut != true) {
                        return;
                      }
                    }
                    final result = await store.signOutCloud();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result.message ?? 'Signed out.'),
                        ),
                      );
                    }
                  }
                : null,
            child: const Text('Sign Out'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: store.disableCloudModeAndUseLocalOnly,
            child: const Text('Use Local-Only Mode'),
          ),
        ],
      ),
    );
  }
}

String _formatCloudSyncDate(DateTime? value) {
  if (value == null) {
    return 'Never';
  }
  final local = value.toLocal();
  final hour = local.hour > 12
      ? local.hour - 12
      : local.hour == 0
      ? 12
      : local.hour;
  final minute = local.minute.toString().padLeft(2, '0');
  final suffix = local.hour >= 12 ? 'PM' : 'AM';
  return '${local.month}/${local.day}/${local.year} $hour:$minute $suffix';
}

class _CloudStatusLine extends StatelessWidget {
  const _CloudStatusLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _CurrentUserCard extends StatelessWidget {
  const _CurrentUserCard({required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final personName = store.currentPerson?.displayName ?? 'Local User';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.account_circle_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(personName),
                  Text(store.currentEffectiveRoleLabel),
                ],
              ),
            ),
            TextButton(
              onPressed: () => store.lockSession(clearCurrentUser: true),
              child: const Text('Switch User'),
            ),
            IconButton(
              tooltip: 'Lock',
              onPressed: () => store.lockSession(),
              icon: const Icon(Icons.lock_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow {
  const _SettingsRow({
    required this.title,
    required this.icon,
    required this.screen,
  });

  final String title;
  final IconData icon;
  final Widget screen;
}
