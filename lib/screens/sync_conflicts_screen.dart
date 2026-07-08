import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';

class SyncConflictsScreen extends StatelessWidget {
  const SyncConflictsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final conflicts = store.getSyncMergeConflicts();
    return Scaffold(
      appBar: AppBar(title: const Text('Sync Review')),
      body: conflicts.isEmpty
          ? const Center(child: Text('No sync conflicts need review.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: conflicts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final conflict = conflicts[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.report_problem_outlined),
                    title: Text(_entityLabel(conflict.entityType)),
                    subtitle: Text(
                      [
                        conflict.message,
                        if (conflict.localId != null)
                          'Local: ${conflict.localId}',
                        if (conflict.cloudId != null)
                          'Cloud: ${conflict.cloudId}',
                        if (conflict.field != null) 'Field: ${conflict.field}',
                        _formatDate(conflict.createdAt),
                      ].join('\n'),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: conflicts.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                store.clearSyncMergeConflicts();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear reviewed'),
            ),
    );
  }
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

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.month}/${local.day}/${local.year} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}
