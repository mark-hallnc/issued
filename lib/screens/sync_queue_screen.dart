import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/cloud/sync_outbox_service.dart';

class SyncQueueScreen extends StatelessWidget {
  const SyncQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sync Queue')),
      body: FutureBuilder<List<SyncOutboxEntry>>(
        future: store.getSyncQueueEntries(),
        builder: (context, snapshot) {
          final entries = snapshot.data ?? const <SyncOutboxEntry>[];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (entries.isEmpty) {
            return const Center(child: Text('No queued sync changes.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                child: ListTile(
                  leading: Icon(_statusIcon(entry.status)),
                  title: Text('${entry.entity.name} ${entry.operation.name}'),
                  subtitle: Text(
                    [
                      entry.entityId,
                      'Status: ${entry.status.name}',
                      'Attempts: ${entry.attempts}',
                      if (entry.lastError != null) entry.lastError!,
                      _formatDate(entry.updatedAt),
                    ].join('\n'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

IconData _statusIcon(SyncOutboxStatus status) {
  return switch (status) {
    SyncOutboxStatus.pending => Icons.schedule,
    SyncOutboxStatus.syncing => Icons.sync,
    SyncOutboxStatus.failed => Icons.error_outline,
    SyncOutboxStatus.done => Icons.check_circle_outline,
    SyncOutboxStatus.skipped => Icons.skip_next_outlined,
  };
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  return '${local.month}/${local.day}/${local.year} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}
