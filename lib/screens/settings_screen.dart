import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/permissions/app_permissions.dart';
import 'assignment_targets_screen.dart';
import 'backup_restore_screen.dart';
import 'cloud_login_screen.dart';
import 'data_health_screen.dart';
import 'import_export_screen.dart';
import 'label_center_screen.dart';
import 'reports_screen.dart';
import 'settings_detail_screens.dart';
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
            onPressed: store.isCloudSignedIn
                ? () async {
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
                  Text(roleLabel(store.currentRole)),
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
