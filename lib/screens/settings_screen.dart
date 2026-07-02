import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _settingsRows = [
    ('Company', Icons.business_outlined),
    ('Users & Roles', Icons.group_outlined),
    ('Locations', Icons.location_on_outlined),
    ('Units of Measure', Icons.straighten_outlined),
    ('Custom Fields', Icons.tune_outlined),
    ('Plan & Usage', Icons.query_stats_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _settingsRows.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final (title, icon) = _settingsRows[index];

        return Card(
          child: ListTile(
            leading: Icon(icon, color: const Color(0xFF1E3A5F)),
            title: Text(title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        );
      },
    );
  }
}
