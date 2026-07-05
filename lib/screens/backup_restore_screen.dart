import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_store.dart';
import '../core/backup/backup_service.dart';
import '../core/models/models.dart';

class BackupRestoreScreen extends StatelessWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final canExportBackup = _canExportBackup(store);

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Backup',
            children: [
              const Text(
                'Export a complete local backup of your Issued workspace.',
              ),
              const SizedBox(height: 8),
              const Text(
                'This backup includes inventory records and local photo paths. Photo file bundling will be added later.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: canExportBackup
                    ? () => _confirmAndExport(context)
                    : () => _showPermissionDenied(context),
                icon: const Icon(Icons.download),
                label: const Text('Export Backup'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Restore',
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.restore_outlined),
                title: const Text('Restore from backup'),
                subtitle: const Text(
                  'Restore will be added after safe file selection support is re-enabled.',
                ),
                enabled: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndExport(BuildContext context) async {
    final store = AppStoreScope.of(context);
    if (!_canExportBackup(store)) {
      _showPermissionDenied(context);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will export your local Issued data as a JSON backup file.',
            ),
            const SizedBox(height: 12),
            Text('Items: ${store.items.length}'),
            Text('Locations: ${store.locations.length}'),
            Text('Transactions: ${store.transactions.length}'),
            Text('Cycle counts: ${store.cycleCountSessions.length}'),
            Text('Checkouts: ${store.checkoutRecords.length}'),
            Text('Reorder requests: ${store.reorderRequests.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Export'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await _exportBackup(context);
  }

  Future<void> _exportBackup(BuildContext context) async {
    final store = AppStoreScope.of(context);
    try {
      final backupJson = const BackupService().exportBackupJson(store);
      final directory = await getTemporaryDirectory();
      final filename = _backupFilename();
      final file = File('${directory.path}${Platform.pathSeparator}$filename');
      await file.writeAsString(backupJson, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          fileNameOverrides: [filename],
        ),
      );
      if (context.mounted) {
        _showMessage(context, 'Backup exported.');
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'Could not export backup.');
      }
    }
  }

  String _backupFilename() {
    final now = DateTime.now();
    final date =
        '${now.year}${_two(now.month)}${_two(now.day)}_${_two(now.hour)}${_two(now.minute)}';
    return 'issued_backup_$date.json';
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  bool _canExportBackup(AppStore store) {
    return store.currentRole == UserRole.admin ||
        (store.currentRole == UserRole.manager &&
            store.permissions.canImportExport);
  }

  void _showPermissionDenied(BuildContext context) {
    _showMessage(context, 'Your current role does not allow this action.');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF17212F),
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
