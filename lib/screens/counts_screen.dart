import 'package:flutter/material.dart';

import '../core/models/models.dart';
import '../core/sample_data.dart';
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Cycle Counts',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF17212F),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _openCreateCount,
            icon: const Icon(Icons.add_task),
            label: const Text('New Cycle Count'),
          ),
        ),
        const SizedBox(height: 16),
        for (final session in sampleCycleCountSessions) ...[
          _CycleCountCard(session: session, onTap: () => _openSession(session)),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Future<void> _openCreateCount() async {
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
}

class _CycleCountCard extends StatelessWidget {
  const _CycleCountCard({required this.session, required this.onTap});

  final CycleCountSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final assignedUser = _assignedUserName(session.assignedToUserId);
    final lineCount = sampleCycleCountLines
        .where((line) => line.sessionId == session.id)
        .length;

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
                  _StatusBadge(status: session.status),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoPill(
                    label: '$lineCount item${lineCount == 1 ? '' : 's'}',
                  ),
                  _InfoPill(
                    label: session.blindCount ? 'Blind count' : 'Visible count',
                  ),
                  if (assignedUser != null) _InfoPill(label: assignedUser),
                  if (session.dueAt != null)
                    _InfoPill(label: 'Due ${_formatDate(session.dueAt!)}'),
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

    for (final user in sampleUsers) {
      if (user.id == userId) {
        for (final person in samplePeople) {
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CycleCountStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1F8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFC9D7E6)),
      ),
      child: Text(
        _statusLabel(status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFF1E3A5F),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _statusLabel(CycleCountStatus status) {
    return switch (status) {
      CycleCountStatus.draft => 'Draft',
      CycleCountStatus.assigned => 'Assigned',
      CycleCountStatus.submitted => 'Submitted',
      CycleCountStatus.approved => 'Approved',
    };
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE1E6EC)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: const Color(0xFF394554)),
        ),
      ),
    );
  }
}
