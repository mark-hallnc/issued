import 'package:flutter/material.dart';

import '../core/cloud/sync_status_models.dart';

class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({
    super.key,
    required this.status,
    this.onOpenDiagnostics,
  });

  final SyncUserStatusSummary status;
  final VoidCallback? onOpenDiagnostics;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status.status);
    return ActionChip(
      avatar: Icon(_statusIcon(status.status), size: 18, color: color),
      label: Text(status.label, overflow: TextOverflow.ellipsis),
      onPressed: () {
        if (status.canOpenDiagnostics && onOpenDiagnostics != null) {
          onOpenDiagnostics!();
          return;
        }
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sync status'),
            content: Text(status.detail ?? status.label),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      side: BorderSide(color: color.withAlpha(89)),
      backgroundColor: color.withAlpha(20),
    );
  }
}

IconData _statusIcon(SyncUserStatus status) {
  return switch (status) {
    SyncUserStatus.disabled => Icons.cloud_off_outlined,
    SyncUserStatus.signedOut => Icons.account_circle_outlined,
    SyncUserStatus.noWorkspace => Icons.business_outlined,
    SyncUserStatus.setupRequired => Icons.tune_outlined,
    SyncUserStatus.offlineOrFailed => Icons.cloud_off_outlined,
    SyncUserStatus.syncing => Icons.sync,
    SyncUserStatus.pendingChanges => Icons.schedule_outlined,
    SyncUserStatus.synced => Icons.cloud_done_outlined,
    SyncUserStatus.conflictsNeedReview => Icons.report_problem_outlined,
  };
}

Color _statusColor(SyncUserStatus status) {
  return switch (status) {
    SyncUserStatus.synced => const Color(0xFF067647),
    SyncUserStatus.syncing => const Color(0xFF175CD3),
    SyncUserStatus.pendingChanges ||
    SyncUserStatus.setupRequired => const Color(0xFFB54708),
    SyncUserStatus.offlineOrFailed ||
    SyncUserStatus.conflictsNeedReview => const Color(0xFFB42318),
    _ => const Color(0xFF475467),
  };
}
