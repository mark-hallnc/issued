import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import '../widgets/issued_empty_state.dart';
import '../widgets/issued_metric_card.dart';
import '../widgets/issued_page_header.dart';
import '../widgets/issued_status_badge.dart';
import 'create_cycle_count_screen.dart';
import 'cycle_count_detail_screen.dart';

class CountsScreen extends StatefulWidget {
  const CountsScreen({super.key});

  @override
  State<CountsScreen> createState() => _CountsScreenState();
}

class _CountsScreenState extends State<CountsScreen> {
  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final canCreateCounts = store.permissions.canManageCycleCounts;
    final sessions = store.cycleCountSessions;
    final openCount = sessions
        .where(
          (session) =>
              session.status == CycleCountStatus.draft ||
              session.status == CycleCountStatus.assigned,
        )
        .length;
    final submittedCount = sessions
        .where((session) => session.status == CycleCountStatus.submitted)
        .length;
    final approvedCount = sessions
        .where((session) => session.status == CycleCountStatus.approved)
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        IssuedPageHeader(
          title: 'Cycle Counts',
          subtitle:
              'Plan counts, record variances, and keep inventory accurate.',
          action: canCreateCounts
              ? FilledButton.icon(
                  onPressed: _openCreateCount,
                  icon: const Icon(Icons.add_task),
                  label: const Text('New cycle count'),
                )
              : null,
        ),
        if (sessions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: IssuedMetricCard(
                  label: 'Open counts',
                  value: '$openCount',
                  icon: Icons.pending_actions_outlined,
                  tone: IssuedStatusTone.info,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: IssuedMetricCard(
                  label: 'Submitted',
                  value: '$submittedCount',
                  icon: Icons.send_outlined,
                  tone: IssuedStatusTone.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          IssuedMetricCard(
            label: 'Approved counts',
            value: '$approvedCount',
            icon: Icons.verified_outlined,
            tone: IssuedStatusTone.success,
          ),
          const SizedBox(height: 16),
        ],
        if (sessions.isEmpty)
          IssuedEmptyState(
            icon: Icons.fact_check_outlined,
            title: 'No cycle counts yet',
            message:
                'Create a cycle count to verify stock and catch inventory variances.',
            actionLabel: canCreateCounts ? 'New cycle count' : null,
            onAction: canCreateCounts ? _openCreateCount : null,
          ),
        for (final session in sessions) ...[
          _CycleCountCard(
            session: session,
            store: store,
            onTap: () => _openSession(session),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Future<void> _openCreateCount() async {
    if (!AppStoreScope.of(context).permissions.canManageCycleCounts) {
      _showPermissionDenied();
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const CreateCycleCountScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _openSession(CycleCountSession session) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CycleCountDetailScreen(session: session),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _showPermissionDenied() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your current role does not allow this action.'),
      ),
    );
  }
}

class _CycleCountCard extends StatelessWidget {
  const _CycleCountCard({
    required this.session,
    required this.store,
    required this.onTap,
  });

  final CycleCountSession session;
  final AppStore store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final assignedUser = _assignedUserName(session.assignedToUserId);
    final lineCount = store.cycleCountLines
        .where((line) => line.sessionId == session.id)
        .length;
    final isOverdue =
        session.dueAt != null &&
        session.dueAt!.isBefore(DateTime.now()) &&
        session.status != CycleCountStatus.approved;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      session.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF17212F),
                      ),
                    ),
                  ),
                  IssuedStatusBadge(
                    label: _statusLabel(session.status),
                    tone: _statusTone(session.status),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  IssuedStatusBadge(
                    label: '$lineCount item${lineCount == 1 ? '' : 's'}',
                  ),
                  IssuedStatusBadge(
                    label: session.blindCount ? 'Blind count' : 'Visible count',
                    icon: session.blindCount
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  if (assignedUser != null)
                    IssuedStatusBadge(
                      label: assignedUser,
                      icon: Icons.person_outline,
                    ),
                  if (session.dueAt != null)
                    IssuedStatusBadge(
                      label: 'Due ${_formatDate(session.dueAt!)}',
                      icon: Icons.event_outlined,
                    ),
                  if (isOverdue)
                    const IssuedStatusBadge(
                      label: 'Overdue',
                      icon: Icons.warning_amber_outlined,
                      tone: IssuedStatusTone.warning,
                    ),
                  IssuedStatusBadge(
                    label: 'Created ${_formatDate(session.createdAt)}',
                    icon: Icons.calendar_today_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _assignedUserName(String? userId) {
    if (userId == null) {
      return null;
    }

    for (final user in store.users) {
      if (user.id == userId) {
        for (final person in store.people) {
          if (person.id == user.personId) {
            return person.displayName;
          }
        }
      }
    }

    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

String _statusLabel(CycleCountStatus status) {
  return switch (status) {
    CycleCountStatus.draft => 'Draft',
    CycleCountStatus.assigned => 'Assigned',
    CycleCountStatus.submitted => 'Submitted',
    CycleCountStatus.approved => 'Approved',
  };
}

IssuedStatusTone _statusTone(CycleCountStatus status) {
  return switch (status) {
    CycleCountStatus.draft => IssuedStatusTone.neutral,
    CycleCountStatus.assigned => IssuedStatusTone.info,
    CycleCountStatus.submitted => IssuedStatusTone.warning,
    CycleCountStatus.approved => IssuedStatusTone.success,
  };
}
