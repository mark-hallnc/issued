import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/cloud/sync_reconciliation_models.dart';
import 'sync_conflicts_screen.dart';
import 'sync_queue_screen.dart';

class SyncHealthScreen extends StatefulWidget {
  const SyncHealthScreen({super.key});

  @override
  State<SyncHealthScreen> createState() => _SyncHealthScreenState();
}

class _SyncHealthScreenState extends State<SyncHealthScreen> {
  late Future<SyncReconciliationSummary> _summaryFuture;
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) {
      return;
    }
    _didLoad = true;
    _summaryFuture = AppStoreScope.of(context).refreshSyncReconciliation();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sync Health')),
      body: FutureBuilder<SyncReconciliationSummary>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          final summary = snapshot.data ?? store.syncReconciliationSummary;
          if (snapshot.connectionState == ConnectionState.waiting &&
              summary == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!store.isCloudWorkspaceActive || summary == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Sign in and select a workspace to view cloud sync health.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SummaryCard(summary: summary, store: store),
                const SizedBox(height: 12),
                _ActionCard(onRefresh: _refresh, onPullLatest: _pullLatest),
                if (store.latestSyncUserError != null ||
                    store.recentSyncErrors.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SyncErrorDiagnosticsCard(onRefresh: _refresh),
                ],
                const SizedBox(height: 12),
                for (final entity in summary.entities) ...[
                  _EntityCard(entity: entity),
                  const SizedBox(height: 8),
                ],
                if (summary.messages.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Notes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final message in summary.messages)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(message),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _refresh() async {
    final future = AppStoreScope.of(context).refreshSyncReconciliation();
    setState(() {
      _summaryFuture = future;
    });
    await future;
  }

  Future<void> _pullLatest() async {
    final store = AppStoreScope.of(context);
    final result = await store.pullCloudChangesNow();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Account data refreshed.')),
    );
    await _refresh();
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.store});

  final SyncReconciliationSummary summary;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_statusIcon(summary.overallStatus)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    syncHealthStatusLabelFor(summary.overallStatus),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _MetricLine(
              label: 'Workspace',
              value:
                  summary.workspaceName ?? store.activeWorkspace?.name ?? '-',
            ),
            _MetricLine(
              label: 'Last checked',
              value: _formatDate(summary.checkedAt),
            ),
            _MetricLine(
              label: 'Last successful sync',
              value: _formatDate(store.cloudSyncSummary.lastSuccessfulSyncAt),
            ),
            _MetricLine(
              label: 'Local records',
              value: summary.totalLocalCount.toString(),
            ),
            _MetricLine(
              label: 'Cloud records',
              value: summary.totalCloudCount.toString(),
            ),
            _MetricLine(
              label: 'Pending uploads',
              value: summary.totalPending.toString(),
            ),
            _MetricLine(
              label: 'Failed uploads',
              value: summary.totalFailed.toString(),
            ),
            _MetricLine(
              label: 'Conflicts',
              value: summary.totalConflicts.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.onRefresh, required this.onPullLatest});

  final Future<void> Function() onRefresh;
  final Future<void> Function() onPullLatest;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
            OutlinedButton.icon(
              onPressed: onPullLatest,
              icon: const Icon(Icons.cloud_download_outlined),
              label: const Text('Pull latest from account'),
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  _runAction(context, () => store.syncNow(), after: onRefresh),
              icon: const Icon(Icons.sync),
              label: const Text('Sync now'),
            ),
            OutlinedButton.icon(
              onPressed: store.failedSyncUploadCount > 0
                  ? () => _runAction(
                      context,
                      () => store.retryFailedUploadsNow(),
                      after: onRefresh,
                    )
                  : null,
              icon: const Icon(Icons.replay_outlined),
              label: const Text('Retry failed'),
            ),
            OutlinedButton.icon(
              onPressed: store.recentSyncErrors.isEmpty
                  ? null
                  : () {
                      store.clearSyncDiagnostics();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sync diagnostics cleared.'),
                        ),
                      );
                    },
              icon: const Icon(Icons.cleaning_services_outlined),
              label: const Text('Clear diagnostics'),
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
              label: const Text('View queue'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const SyncConflictsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.report_problem_outlined),
              label: const Text('View conflicts'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntityCard extends StatelessWidget {
  const _EntityCard({required this.entity});

  final SyncEntityReconciliation entity;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_statusIcon(entity.status), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    syncEntityLabel(entity.entityType),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(syncHealthStatusLabelFor(entity.status)),
              ],
            ),
            const SizedBox(height: 8),
            _MetricLine(label: 'Local', value: _countLabel(entity.localCount)),
            _MetricLine(label: 'Cloud', value: _countLabel(entity.cloudCount)),
            _MetricLine(
              label: 'Pending',
              value: entity.pendingUploadCount.toString(),
            ),
            _MetricLine(
              label: 'Failed',
              value: entity.failedUploadCount.toString(),
            ),
            _MetricLine(
              label: 'Conflicts',
              value: entity.conflictCount.toString(),
            ),
            _MetricLine(
              label: 'Last local change',
              value: _formatDate(entity.lastLocalChangeAt),
            ),
            _MetricLine(
              label: 'Last cloud change',
              value: _formatDate(entity.lastCloudChangeAt),
            ),
            const SizedBox(height: 6),
            Text(entity.message),
          ],
        ),
      ),
    );
  }
}

class _SyncErrorDiagnosticsCard extends StatelessWidget {
  const _SyncErrorDiagnosticsCard({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final latest = store.latestSyncUserError;
    final recent = store.recentSyncErrors.take(5).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.manage_search_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Diagnostics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if (latest != null) ...[
              const SizedBox(height: 10),
              Text(
                latest.title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(latest.message),
              if (latest.recoveryActionLabel != null)
                Text('Recovery: ${latest.recoveryActionLabel}'),
            ],
            if (recent.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final error in recent) ...[
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(error.title),
                  subtitle: Text(_formatDate(error.createdAt)),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SelectableText(
                        error.technicalDetails ?? error.message,
                      ),
                    ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: latest?.canRetry == true
                      ? () => _runAction(
                          context,
                          () => store.syncNow(),
                          after: onRefresh,
                        )
                      : null,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
                OutlinedButton.icon(
                  onPressed: store.failedSyncUploadCount > 0
                      ? () => _runAction(
                          context,
                          () => store.retryFailedUploadsNow(),
                          after: onRefresh,
                        )
                      : null,
                  icon: const Icon(Icons.replay_outlined),
                  label: const Text('Retry failed'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _runAction(
  BuildContext context,
  Future<AppActionResult> Function() action, {
  Future<void> Function()? after,
}) async {
  final store = AppStoreScope.of(context);
  AppActionResult result;
  try {
    result = await action();
  } catch (error, stackTrace) {
    result = store.friendlySyncFailure(
      error,
      stackTrace: stackTrace,
      context: 'Sync diagnostics action',
    );
  }
  if (!context.mounted) {
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result.message ?? 'Sync action complete.')),
  );
  await after?.call();
}

IconData _statusIcon(SyncHealthStatus status) {
  return switch (status) {
    SyncHealthStatus.healthy => Icons.check_circle_outline,
    SyncHealthStatus.pending => Icons.schedule,
    SyncHealthStatus.failed => Icons.error_outline,
    SyncHealthStatus.conflict => Icons.report_problem_outlined,
    SyncHealthStatus.mismatch => Icons.compare_arrows,
    SyncHealthStatus.unsupported => Icons.block,
    SyncHealthStatus.unknown => Icons.help_outline,
  };
}

String _countLabel(int? value) => value?.toString() ?? 'Unknown';

String _formatDate(DateTime? value) {
  if (value == null) {
    return 'Never';
  }
  final local = value.toLocal();
  return '${local.month}/${local.day}/${local.year} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}
