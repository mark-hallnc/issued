import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';

enum PlanLimitDialogAction { archiveItems, upgrade, cancel }

Future<PlanLimitDialogAction?> showPlanLimitDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? recommendedPlanCode,
  bool showArchiveItems = false,
}) {
  return showDialog<PlanLimitDialogAction>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(PlanLimitDialogAction.cancel),
          child: const Text('Cancel'),
        ),
        if (showArchiveItems)
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(PlanLimitDialogAction.archiveItems),
            child: const Text('Archive Items'),
          ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(PlanLimitDialogAction.upgrade),
          child: const Text('Upgrade'),
        ),
      ],
    ),
  );
}

Future<void> openComparePlans(
  BuildContext context, {
  String? recommendedPlanCode,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) =>
          ComparePlansScreen(recommendedPlanCode: recommendedPlanCode),
    ),
  );
}

class ComparePlansScreen extends StatelessWidget {
  const ComparePlansScreen({super.key, this.recommendedPlanCode});

  final String? recommendedPlanCode;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Compare Plans')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final plan in store.availablePlans) ...[
            _PlanCard(
              plan: plan,
              isCurrent: plan.code == store.currentPlan.code,
              isRecommended: plan.code == recommendedPlanCode,
              onSelected: () => _selectPlan(context, store, plan),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  void _selectPlan(BuildContext context, AppStore store, Plan plan) {
    if (!store.permissions.canManagePlan) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your current role does not allow this action.'),
        ),
      );
      return;
    }

    if (plan.code == store.currentPlan.code) {
      return;
    }

    store.setCurrentPlanForTesting(plan.code);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Billing is not connected yet. Plan changed for this organization.',
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isCurrent,
    required this.isRecommended,
    required this.onSelected,
  });

  final Plan plan;
  final bool isCurrent;
  final bool isRecommended;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final color = isRecommended
        ? const Color(0xFFEAF2FF)
        : Theme.of(context).cardColor;

    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRecommended
              ? const Color(0xFF1E3A5F)
              : const Color(0xFFE1E6EC),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF17212F),
                    ),
                  ),
                ),
                Text(
                  _priceForPlan(plan.code),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (isRecommended) ...[
              const SizedBox(height: 8),
              const _PlanBadge(label: 'Recommended'),
            ],
            const SizedBox(height: 14),
            _PlanRow(label: 'Items', value: '${plan.itemLimit}'),
            _PlanRow(label: 'Users', value: '${plan.userLimit}'),
            _PlanRow(label: 'Locations', value: '${plan.locationLimit}'),
            _PlanRow(
              label: 'Label exports',
              value: '${plan.labelExportLimit}/mo',
            ),
            _PlanRow(
              label: 'CSV import',
              value: plan.csvImportEnabled ? 'Yes' : 'No',
            ),
            _PlanRow(
              label: 'Advanced reports',
              value: _advancedReportsLabel(plan),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: isCurrent
                  ? OutlinedButton(
                      onPressed: null,
                      child: const Text('Current Plan'),
                    )
                  : FilledButton(
                      onPressed: onSelected,
                      child: Text('Select ${plan.name}'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _advancedReportsLabel(Plan plan) {
    if (plan.code == 'starter') {
      return 'Basic only';
    }

    return plan.advancedReportsEnabled ? 'Yes' : 'No';
  }

  String _priceForPlan(String planCode) {
    return switch (planCode) {
      'starter' => r'$19/mo',
      'shop' => r'$49/mo',
      'pro' => r'$99/mo',
      _ => r'$0',
    };
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF5C6672)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF17212F),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
