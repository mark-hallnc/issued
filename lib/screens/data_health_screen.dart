import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_store.dart';
import '../core/backup/backup_service.dart';
import '../core/data_health/data_health_service.dart';
import '../core/models/models.dart';
import 'sync_health_screen.dart';

class DataHealthScreen extends StatefulWidget {
  const DataHealthScreen({super.key});

  @override
  State<DataHealthScreen> createState() => _DataHealthScreenState();
}

class _DataHealthScreenState extends State<DataHealthScreen> {
  DataHealthReport? _report;
  bool _isRunning = false;
  bool _isRepairing = false;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final canRun = _canRunHealthCheck(store);
    final canRepair = _canRepairHealthIssues(store);
    final report = _report;

    return Scaffold(
      appBar: AppBar(title: const Text('Data Health')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Check local inventory data for missing links, quantity mismatches, and setup issues.',
          ),
          const SizedBox(height: 8),
          const Text('Export a backup before running repairs.'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: canRun && !_isRunning ? _runHealthCheck : null,
                icon: const Icon(Icons.health_and_safety_outlined),
                label: Text(_isRunning ? 'Checking...' : 'Run Health Check'),
              ),
              OutlinedButton.icon(
                onPressed: () => _exportBackup(context),
                icon: const Icon(Icons.download),
                label: const Text('Export Backup'),
              ),
              if (store.isCloudWorkspaceActive)
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const SyncHealthScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.cloud_sync_outlined),
                  label: const Text('Cloud Sync Health'),
                ),
              if (report != null &&
                  report.issues.any((issue) => issue.canRepair))
                OutlinedButton.icon(
                  onPressed: canRepair && !_isRepairing
                      ? () => _repairAllSafeIssues(context)
                      : null,
                  icon: const Icon(Icons.build_outlined),
                  label: Text(
                    _isRepairing ? 'Repairing...' : 'Repair Safe Issues',
                  ),
                ),
            ],
          ),
          if (!canRun) ...[
            const SizedBox(height: 12),
            const _InfoCard(
              message: 'Your current role does not allow this action.',
            ),
          ],
          const SizedBox(height: 16),
          if (report == null)
            const _InfoCard(message: 'Run a health check to review local data.')
          else
            _ReportSummary(report: report),
          if (report != null) ...[
            const SizedBox(height: 12),
            if (report.isHealthy)
              const _InfoCard(message: 'No data health issues found.')
            else
              for (final issue in report.issues) ...[
                _IssueCard(
                  issue: issue,
                  affectedName: _affectedName(store, issue),
                  canRepair: canRepair && issue.canRepair,
                  onRepair: () => _repairIssue(context, issue),
                ),
                const SizedBox(height: 8),
              ],
          ],
        ],
      ),
    );
  }

  bool _canRunHealthCheck(AppStore store) {
    return store.currentRole == UserRole.admin ||
        store.currentRole == UserRole.manager;
  }

  bool _canRepairHealthIssues(AppStore store) {
    return store.currentRole == UserRole.admin ||
        (store.currentRole == UserRole.manager &&
            store.permissions.canManageSettings &&
            store.permissions.canManageItems);
  }

  Future<void> _runHealthCheck() async {
    setState(() {
      _isRunning = true;
    });
    final report = AppStoreScope.of(context).runDataHealthCheck();
    if (!mounted) {
      return;
    }
    setState(() {
      _report = report;
      _isRunning = false;
    });
  }

  Future<void> _repairIssue(BuildContext context, DataHealthIssue issue) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Repair Issue?'),
        content: Text('${issue.description}\n\nExport a backup first.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Repair'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    final store = AppStoreScope.of(context);
    final repaired = await store.repairDataHealthIssue(issue.id);
    if (!context.mounted) {
      return;
    }
    _showMessage(context, repaired ? 'Repair complete.' : 'Could not repair.');
    setState(() {
      _report = store.runDataHealthCheck();
    });
  }

  Future<void> _repairAllSafeIssues(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Repair Safe Issues?'),
        content: const Text(
          'This will apply safe repairs. Export a backup first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Repair Safe Issues'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    setState(() {
      _isRepairing = true;
    });
    final store = AppStoreScope.of(context);
    final repairedCount = await store.repairAllSafeDataHealthIssues();
    if (!context.mounted) {
      return;
    }
    setState(() {
      _isRepairing = false;
      _report = store.runDataHealthCheck();
    });
    _showMessage(context, 'Repaired $repairedCount issue(s).');
  }

  Future<void> _exportBackup(BuildContext context) async {
    try {
      final store = AppStoreScope.of(context);
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

  String _affectedName(AppStore store, DataHealthIssue issue) {
    final id = issue.affectedRecordId;
    if (id == null) {
      return issue.affectedRecordType;
    }
    return switch (issue.affectedRecordType) {
      'item' => store.resolveItemName(id),
      'itemLocationBalance' => 'Balance $id',
      'inventoryTransaction' => 'Activity $id',
      'checkoutRecord' => 'Checkout $id',
      'reorderRequest' => 'Reorder $id',
      'cycleCountLine' => 'Count line $id',
      'customFieldValue' => 'Custom field value $id',
      _ => id,
    };
  }

  String _backupFilename() {
    final now = DateTime.now();
    final date =
        '${now.year}${_two(now.month)}${_two(now.day)}_${_two(now.hour)}${_two(now.minute)}';
    return 'issued_backup_$date.json';
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ReportSummary extends StatelessWidget {
  const _ReportSummary({required this.report});

  final DataHealthReport report;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.isHealthy ? 'Healthy' : 'Issues found',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _CountChip(label: 'Errors', count: report.errorCount),
                _CountChip(label: 'Warnings', count: report.warningCount),
                _CountChip(label: 'Info', count: report.infoCount),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({
    required this.issue,
    required this.affectedName,
    required this.canRepair,
    required this.onRepair,
  });

  final DataHealthIssue issue;
  final String affectedName;
  final bool canRepair;
  final VoidCallback onRepair;

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(issue.severity);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_severityIcon(issue.severity), color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issue.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(affectedName),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(issue.description),
            if (issue.canRepair) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: canRepair ? onRepair : null,
                  icon: const Icon(Icons.build_outlined),
                  label: const Text('Repair'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _severityIcon(DataHealthSeverity severity) {
    return switch (severity) {
      DataHealthSeverity.error => Icons.error_outline,
      DataHealthSeverity.warning => Icons.warning_amber_outlined,
      DataHealthSeverity.info => Icons.info_outline,
    };
  }

  Color _severityColor(DataHealthSeverity severity) {
    return switch (severity) {
      DataHealthSeverity.error => Colors.red,
      DataHealthSeverity.warning => Colors.orange,
      DataHealthSeverity.info => Colors.blueGrey,
    };
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $count'));
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: Text(message)),
    );
  }
}
