import 'package:flutter/material.dart';

import 'import_export_screen.dart';
import 'settings_detail_screens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _settingsRows = <_SettingsRow>[
    _SettingsRow(
      title: 'Company',
      icon: Icons.business_outlined,
      screen: CompanySettingsScreen(),
    ),
    _SettingsRow(
      title: 'Users & Roles',
      icon: Icons.group_outlined,
      screen: UsersRolesSettingsScreen(),
    ),
    _SettingsRow(
      title: 'Locations',
      icon: Icons.location_on_outlined,
      screen: LocationsSettingsScreen(),
    ),
    _SettingsRow(
      title: 'Units of Measure',
      icon: Icons.straighten_outlined,
      screen: UnitsOfMeasureSettingsScreen(),
    ),
    _SettingsRow(
      title: 'Custom Fields',
      icon: Icons.tune_outlined,
      screen: CustomFieldsSettingsScreen(),
    ),
    _SettingsRow(
      title: 'Plan & Usage',
      icon: Icons.query_stats_outlined,
      screen: PlanUsageSettingsScreen(),
    ),
    _SettingsRow(
      title: 'Import & Export',
      icon: Icons.import_export,
      screen: ImportExportScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _settingsRows.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final row = _settingsRows[index];

        return Card(
          child: ListTile(
            leading: Icon(row.icon, color: const Color(0xFF1E3A5F)),
            title: Text(row.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (context) => row.screen));
            },
          ),
        );
      },
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
