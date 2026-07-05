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
    final canRestoreBackup = _canRestoreBackup(store);

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
              const Text(
                'Open your Issued backup JSON file, copy its contents, and paste it here.',
              ),
              const SizedBox(height: 8),
              const Text('File-based restore will be added later.'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: canRestoreBackup
                    ? () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RestoreBackupScreen(),
                        ),
                      )
                    : () => _showPermissionDenied(context),
                icon: const Icon(Icons.content_paste),
                label: const Text('Restore from Pasted Backup'),
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

  bool _canRestoreBackup(AppStore store) {
    return store.currentRole == UserRole.admin ||
        (store.currentRole == UserRole.manager &&
            store.permissions.canImportExport &&
            store.permissions.canManageSettings);
  }

  void _showPermissionDenied(BuildContext context) {
    _showMessage(context, 'Your current role does not allow this action.');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class RestoreBackupScreen extends StatefulWidget {
  const RestoreBackupScreen({super.key});

  @override
  State<RestoreBackupScreen> createState() => _RestoreBackupScreenState();
}

class _RestoreBackupScreenState extends State<RestoreBackupScreen> {
  final _jsonController = TextEditingController();
  BackupValidationResult? _validation;
  List<String> _previewWarnings = const [];

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  void _validateBackup() {
    final text = _jsonController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _validation = const BackupValidationResult(
          isValid: false,
          message: 'Paste backup JSON first.',
          errors: ['Paste backup JSON first.'],
        );
        _previewWarnings = const [];
      });
      return;
    }

    final service = const BackupService();
    final validation = service.validateBackupJson(text);
    final parsedBackup = validation.isValid
        ? service.parseBackupData(text)
        : null;
    final parseWarnings = parsedBackup?.warnings ?? const <String>[];

    setState(() {
      _validation = validation;
      _previewWarnings = [...validation.warnings, ...parseWarnings];
    });

    if (!validation.isValid) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RestorePreviewScreen(
          backupJson: text,
          validation: validation,
          warnings: _previewWarnings,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final validation = _validation;

    return Scaffold(
      appBar: AppBar(title: const Text('Pasted Backup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Paste the full contents of an Issued JSON backup file.'),
          const SizedBox(height: 12),
          TextField(
            controller: _jsonController,
            minLines: 12,
            maxLines: 18,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Backup JSON',
              alignLabelWithHint: true,
            ),
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _validateBackup,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Validate Backup'),
              ),
            ],
          ),
          if (validation != null) ...[
            const SizedBox(height: 16),
            _ValidationResultCard(
              validation: validation,
              warnings: _previewWarnings,
            ),
          ],
        ],
      ),
    );
  }
}

class RestorePreviewScreen extends StatelessWidget {
  const RestorePreviewScreen({
    required this.backupJson,
    required this.validation,
    required this.warnings,
    super.key,
  });

  final String backupJson;
  final BackupValidationResult validation;
  final List<String> warnings;

  Future<void> _exportCurrentBackupFirst(BuildContext context) async {
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
        _showMessage(context, 'Current backup exported.');
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'Could not export current backup.');
      }
    }
  }

  Future<void> _restoreBackup(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _RestoreConfirmationDialog(),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    final store = AppStoreScope.of(context);
    final result = await store.restoreFromBackupJson(backupJson);
    if (!context.mounted) {
      return;
    }

    if (!result.isValid) {
      _showMessage(context, result.message);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
    messenger.showSnackBar(const SnackBar(content: Text('Backup restored.')));
  }

  @override
  Widget build(BuildContext context) {
    final counts = validation.counts;
    final createdAt = validation.createdAt;

    return Scaffold(
      appBar: AppBar(title: const Text('Restore Preview')),
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
                    validation.companyName ?? 'Issued workspace',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Backup version: ${validation.backupVersion ?? '-'}'),
                  if (createdAt != null)
                    Text('Created: ${_formatDate(createdAt)}'),
                  const Divider(height: 24),
                  _CountLine(label: 'Items', value: counts.items),
                  _CountLine(label: 'Locations', value: counts.locations),
                  _CountLine(
                    label: 'People and users',
                    value: counts.people + counts.users,
                  ),
                  _CountLine(label: 'Transactions', value: counts.transactions),
                  _CountLine(label: 'Cycle counts', value: counts.cycleCounts),
                  _CountLine(label: 'Balances', value: counts.balances),
                  _CountLine(label: 'Checkouts', value: counts.checkouts),
                  _CountLine(
                    label: 'Reorder requests',
                    value: counts.reorderRequests,
                  ),
                  _CountLine(
                    label: 'Custom fields',
                    value: counts.customFields,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _WarningCard(
            message:
                'Restoring will replace the local data on this device. Export a backup first if you want to keep the current data.',
          ),
          const SizedBox(height: 12),
          const _WarningCard(
            message:
                'Photo file paths are restored, but image files may not exist on this device unless they were copied separately.',
          ),
          if (warnings.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ValidationWarningsCard(warnings: warnings),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              OutlinedButton.icon(
                onPressed: () => _exportCurrentBackupFirst(context),
                icon: const Icon(Icons.download),
                label: const Text('Export Current Backup First'),
              ),
              FilledButton.icon(
                onPressed: () => _restoreBackup(context),
                icon: const Icon(Icons.restore),
                label: const Text('Restore Backup'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _backupFilename() {
    final now = DateTime.now();
    final date =
        '${now.year}${_two(now.month)}${_two(now.day)}_${_two(now.hour)}${_two(now.minute)}';
    return 'issued_backup_$date.json';
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.year}-${_two(local.month)}-${_two(local.day)} ${_two(local.hour)}:${_two(local.minute)}';
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _RestoreConfirmationDialog extends StatefulWidget {
  const _RestoreConfirmationDialog();

  @override
  State<_RestoreConfirmationDialog> createState() =>
      _RestoreConfirmationDialogState();
}

class _RestoreConfirmationDialogState
    extends State<_RestoreConfirmationDialog> {
  final _controller = TextEditingController();
  bool _showError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_controller.text.trim() == 'RESTORE') {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _showError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Replace Local Data?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Are you sure? This will replace the local Issued data on this device.',
          ),
          const SizedBox(height: 12),
          const Text('Type RESTORE to continue.'),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorText: _showError ? 'Type RESTORE exactly.' : null,
            ),
            onSubmitted: (_) => _confirm(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _confirm, child: const Text('Replace Data')),
      ],
    );
  }
}

class _ValidationResultCard extends StatelessWidget {
  const _ValidationResultCard({
    required this.validation,
    required this.warnings,
  });

  final BackupValidationResult validation;
  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    final color = validation.isValid ? Colors.green : Colors.red;
    final messages = validation.isValid ? warnings : validation.errors;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  validation.isValid
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  color: color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    validation.message,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (messages.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final message in messages.take(5)) Text(message),
            ],
          ],
        ),
      ),
    );
  }
}

class _ValidationWarningsCard extends StatelessWidget {
  const _ValidationWarningsCard({required this.warnings});

  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Warnings',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final warning in warnings.take(8)) Text(warning),
          ],
        ),
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_outlined),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _CountLine extends StatelessWidget {
  const _CountLine({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
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
