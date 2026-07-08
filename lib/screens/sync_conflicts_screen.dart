import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/cloud/sync_conflict_resolution_models.dart';
import '../core/models/models.dart';

class SyncConflictsScreen extends StatefulWidget {
  const SyncConflictsScreen({super.key});

  @override
  State<SyncConflictsScreen> createState() => _SyncConflictsScreenState();
}

class _SyncConflictsScreenState extends State<SyncConflictsScreen> {
  bool _isResolving = false;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final conflicts = store.getSyncMergeConflicts();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Review'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isResolving
                ? null
                : () {
                    setState(() {});
                  },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: conflicts.isEmpty
          ? const Center(child: Text('No sync conflicts need review.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: conflicts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final conflict = conflicts[index];
                return _ConflictCard(
                  conflict: conflict,
                  canViewCosts: store.permissions.canViewCosts,
                  canResolveData:
                      store.permissions.isAdmin || store.permissions.isManager,
                  isResolving: _isResolving,
                  onResolve: (action) => _resolve(conflict, action),
                );
              },
            ),
      floatingActionButton: conflicts.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _isResolving
                  ? null
                  : () async {
                      final result = await store
                          .retrySyncAfterConflictResolution();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result.message ?? 'Sync retry complete.',
                            ),
                          ),
                        );
                        setState(() {});
                      }
                    },
              icon: const Icon(Icons.sync),
              label: const Text('Sync again'),
            ),
    );
  }

  Future<void> _resolve(
    SyncMergeConflict conflict,
    SyncConflictResolutionAction action,
  ) async {
    final confirmed = await _confirmAction(context, conflict, action);
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _isResolving = true);
    final store = AppStoreScope.of(context);
    final result = await store.resolveSyncConflict(conflict, action);
    if (!mounted) {
      return;
    }
    setState(() => _isResolving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Conflict updated.')),
    );
  }
}

class _ConflictCard extends StatelessWidget {
  const _ConflictCard({
    required this.conflict,
    required this.canViewCosts,
    required this.canResolveData,
    required this.isResolving,
    required this.onResolve,
  });

  final SyncMergeConflict conflict;
  final bool canViewCosts;
  final bool canResolveData;
  final bool isResolving;
  final ValueChanged<SyncConflictResolutionAction> onResolve;

  @override
  Widget build(BuildContext context) {
    final actions = _actionsFor(conflict, canResolveData: canResolveData);
    final hideValues = !canViewCosts && _isCostSensitiveConflict(conflict);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_severityIcon(conflict.severity)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _entityLabel(conflict.entityType),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(_severityLabel(conflict.severity)),
              ],
            ),
            const SizedBox(height: 8),
            Text(conflict.message),
            const SizedBox(height: 8),
            if (conflict.field != null) _Line('Field', conflict.field!),
            if (conflict.localId != null) _Line('Local', conflict.localId!),
            if (conflict.cloudId != null) _Line('Cloud', conflict.cloudId!),
            if (!hideValues && conflict.localValue != null)
              _Line('Local value', conflict.localValue!),
            if (hideValues && conflict.localValue != null)
              const _Line('Local value', 'Hidden by role'),
            if (!hideValues && conflict.cloudValue != null)
              _Line('Cloud value', conflict.cloudValue!),
            if (hideValues && conflict.cloudValue != null)
              const _Line('Cloud value', 'Hidden by role'),
            _Line('Created', _formatDate(conflict.createdAt)),
            if (conflict.severity == SyncConflictSeverity.dangerous) ...[
              const SizedBox(height: 8),
              const Text(
                'Automatic overwrite is unsafe for this conflict. Review the underlying workflow records before changing quantities or history.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final action in actions)
                  OutlinedButton.icon(
                    onPressed: isResolving ? null : () => onResolve(action),
                    icon: Icon(_actionIcon(action)),
                    label: Text(_actionLabel(action)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

List<SyncConflictResolutionAction> _actionsFor(
  SyncMergeConflict conflict, {
  required bool canResolveData,
}) {
  final actions = <SyncConflictResolutionAction>[
    SyncConflictResolutionAction.markReviewed,
    SyncConflictResolutionAction.retry,
  ];
  if (!canResolveData) {
    return actions;
  }
  if (isSafeAutoApplyAction(
    conflict.entityType,
    SyncConflictResolutionAction.keepLocal,
  )) {
    actions.insert(0, SyncConflictResolutionAction.keepLocal);
  }
  if (isSafeAutoApplyAction(
    conflict.entityType,
    SyncConflictResolutionAction.useCloud,
  )) {
    actions.insert(1, SyncConflictResolutionAction.useCloud);
  }
  return actions;
}

bool _isCostSensitiveConflict(SyncMergeConflict conflict) {
  final field = conflict.field?.toLowerCase() ?? '';
  final message = conflict.message.toLowerCase();
  const sensitiveTerms = [
    'cost',
    'price',
    'value',
    'amount',
    'minimum_order',
    'variance_value',
    'unit_cost',
    'total_cost',
  ];
  return sensitiveTerms.any(
    (term) => field.contains(term) || message.contains(term),
  );
}

Future<bool?> _confirmAction(
  BuildContext context,
  SyncMergeConflict conflict,
  SyncConflictResolutionAction action,
) {
  if (action == SyncConflictResolutionAction.markReviewed ||
      action == SyncConflictResolutionAction.retry) {
    return Future.value(true);
  }
  final destructive = isDestructiveAction(conflict.entityType, action);
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(_actionLabel(action)),
      content: Text(
        destructive
            ? 'This action can affect workflow state. Continue only after reviewing the related records.'
            : 'Apply this resolution for ${_entityLabel(conflict.entityType)}?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Continue'),
        ),
      ],
    ),
  );
}

String _entityLabel(CloudSyncEntity entity) {
  return switch (entity) {
    CloudSyncEntity.item => 'Item',
    CloudSyncEntity.inventoryBalance => 'Inventory balance',
    CloudSyncEntity.transaction => 'Transaction',
    CloudSyncEntity.checkout => 'Checkout',
    CloudSyncEntity.supplier => 'Supplier',
    CloudSyncEntity.location => 'Location',
    CloudSyncEntity.purchaseOrder => 'Purchasing',
    CloudSyncEntity.count => 'Cycle count',
    CloudSyncEntity.countLine => 'Cycle count line',
    CloudSyncEntity.user => 'User',
    CloudSyncEntity.settings => 'Settings',
  };
}

String _actionLabel(SyncConflictResolutionAction action) {
  return switch (action) {
    SyncConflictResolutionAction.keepLocal => 'Keep local',
    SyncConflictResolutionAction.useCloud => 'Use cloud',
    SyncConflictResolutionAction.markReviewed => 'Mark reviewed',
    SyncConflictResolutionAction.retry => 'Retry',
    SyncConflictResolutionAction.unsupported => 'Unsupported',
  };
}

IconData _actionIcon(SyncConflictResolutionAction action) {
  return switch (action) {
    SyncConflictResolutionAction.keepLocal => Icons.cloud_upload_outlined,
    SyncConflictResolutionAction.useCloud => Icons.cloud_download_outlined,
    SyncConflictResolutionAction.markReviewed => Icons.done_outline,
    SyncConflictResolutionAction.retry => Icons.refresh,
    SyncConflictResolutionAction.unsupported => Icons.block,
  };
}

IconData _severityIcon(SyncConflictSeverity severity) {
  return switch (severity) {
    SyncConflictSeverity.info => Icons.info_outline,
    SyncConflictSeverity.warning => Icons.report_problem_outlined,
    SyncConflictSeverity.dangerous => Icons.warning_amber_outlined,
  };
}

String _severityLabel(SyncConflictSeverity severity) {
  return switch (severity) {
    SyncConflictSeverity.info => 'Info',
    SyncConflictSeverity.warning => 'Review needed',
    SyncConflictSeverity.dangerous => 'Dangerous',
  };
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.month}/${local.day}/${local.year} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}
