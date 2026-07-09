import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_store.dart';
import '../core/cloud/sync_qa_models.dart';
import '../core/models/models.dart';

class SyncQaChecklistScreen extends StatefulWidget {
  const SyncQaChecklistScreen({super.key});

  @override
  State<SyncQaChecklistScreen> createState() => _SyncQaChecklistScreenState();
}

class _SyncQaChecklistScreenState extends State<SyncQaChecklistScreen> {
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    if (!store.canOpenSyncDiagnostics) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sync QA Checklist')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Sync QA is available to workspace admins and diagnostics users.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final session =
        store.syncQaSession ?? store.buildSyncQaChecklist(notify: false);
    final workspaceName =
        session.workspaceName ?? store.activeWorkspace?.name ?? 'No workspace';
    final role = store.currentCloudRole == null
        ? 'No cloud role'
        : cloudWorkspaceRoleLabel(store.currentCloudRole!);

    return Scaffold(
      appBar: AppBar(title: const Text('Sync QA Checklist')),
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
                    workspaceName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Role: $role'),
                  Text('Last sync: ${store.cloudSyncStatusLabel}'),
                  Text('Updated: ${_formatDate(session.updatedAt)}'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SummaryChip(
                        label: 'Passed',
                        count: session.passedCount,
                        color: const Color(0xFF047857),
                      ),
                      _SummaryChip(
                        label: 'Warnings',
                        count: session.warningCount,
                        color: const Color(0xFFB45309),
                      ),
                      _SummaryChip(
                        label: 'Failed',
                        count: session.failedCount,
                        color: const Color(0xFFB42318),
                      ),
                      _SummaryChip(
                        label: 'Skipped',
                        count: session.skippedCount,
                        color: const Color(0xFF475467),
                      ),
                      _SummaryChip(
                        label: 'Total',
                        count: session.totalCount,
                        color: const Color(0xFF1E3A5F),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _isRunning
                            ? null
                            : () async {
                                setState(() => _isRunning = true);
                                try {
                                  await store.runSyncQaAutomatedChecks();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Automated QA checks finished.',
                                        ),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _isRunning = false);
                                  }
                                }
                              },
                        icon: _isRunning
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(_isRunning ? 'Running...' : 'Run checks'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _isRunning
                            ? null
                            : () => store.resetSyncQaChecklist(),
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Reset checklist'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(
                              text: store.exportSyncQaChecklistText(),
                            ),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Checklist summary copied.'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy summary'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final category in SyncQaCheckCategory.values)
            _CategorySection(
              category: category,
              checks: session.checks
                  .where((check) => check.category == category)
                  .toList(),
              onStatusChanged: (check, status) {
                store.markSyncQaCheckStatus(
                  check.id,
                  status,
                  details: 'Marked ${syncQaCheckStatusLabel(status)} manually.',
                );
              },
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.year}-${_two(local.month)}-${_two(local.day)} '
        '${_two(local.hour)}:${_two(local.minute)}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.checks,
    required this.onStatusChanged,
  });

  final SyncQaCheckCategory category;
  final List<SyncQaCheck> checks;
  final void Function(SyncQaCheck check, SyncQaCheckStatus status)
  onStatusChanged;

  @override
  Widget build(BuildContext context) {
    if (checks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Text(
            syncQaCheckCategoryLabel(category),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        for (final check in checks)
          _QaCheckCard(check: check, onStatusChanged: onStatusChanged),
      ],
    );
  }
}

class _QaCheckCard extends StatelessWidget {
  const _QaCheckCard({required this.check, required this.onStatusChanged});

  final SyncQaCheck check;
  final void Function(SyncQaCheck check, SyncQaCheckStatus status)
  onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(check.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_statusIcon(check.status), color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        check.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 3),
                      Text(check.description),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  syncQaCheckStatusLabel(check.status),
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Expected: ${check.expectedResult}'),
            if (check.details != null && check.details!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                check.details!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
            if (check.manualSteps.isNotEmpty)
              _TextListExpansion(
                title: 'Manual steps',
                values: check.manualSteps,
              ),
            if (check.troubleshooting.isNotEmpty)
              _TextListExpansion(
                title: 'Troubleshooting',
                values: check.troubleshooting,
              ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () =>
                      onStatusChanged(check, SyncQaCheckStatus.passed),
                  child: const Text('Pass'),
                ),
                OutlinedButton(
                  onPressed: () =>
                      onStatusChanged(check, SyncQaCheckStatus.warning),
                  child: const Text('Warning'),
                ),
                OutlinedButton(
                  onPressed: () =>
                      onStatusChanged(check, SyncQaCheckStatus.failed),
                  child: const Text('Fail'),
                ),
                OutlinedButton(
                  onPressed: () =>
                      onStatusChanged(check, SyncQaCheckStatus.skipped),
                  child: const Text('Skip'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(SyncQaCheckStatus status) {
    return switch (status) {
      SyncQaCheckStatus.passed => const Color(0xFF047857),
      SyncQaCheckStatus.warning => const Color(0xFFB45309),
      SyncQaCheckStatus.failed => const Color(0xFFB42318),
      SyncQaCheckStatus.skipped => const Color(0xFF475467),
      SyncQaCheckStatus.running => const Color(0xFF1E3A5F),
      SyncQaCheckStatus.ready => const Color(0xFF1E3A5F),
      SyncQaCheckStatus.notStarted => const Color(0xFF667085),
    };
  }

  IconData _statusIcon(SyncQaCheckStatus status) {
    return switch (status) {
      SyncQaCheckStatus.passed => Icons.check_circle_outline,
      SyncQaCheckStatus.warning => Icons.warning_amber_outlined,
      SyncQaCheckStatus.failed => Icons.error_outline,
      SyncQaCheckStatus.skipped => Icons.remove_circle_outline,
      SyncQaCheckStatus.running => Icons.sync,
      SyncQaCheckStatus.ready => Icons.radio_button_unchecked,
      SyncQaCheckStatus.notStarted => Icons.radio_button_unchecked,
    };
  }
}

class _TextListExpansion extends StatelessWidget {
  const _TextListExpansion({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: Text(title),
      children: [
        for (final value in values)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('- $value'),
            ),
          ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.08).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha((255 * 0.35).round())),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}
