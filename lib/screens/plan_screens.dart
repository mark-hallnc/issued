import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import '../widgets/issued_page_header.dart';

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

class ComparePlansScreen extends StatefulWidget {
  const ComparePlansScreen({super.key, this.recommendedPlanCode});

  final String? recommendedPlanCode;

  @override
  State<ComparePlansScreen> createState() => _ComparePlansScreenState();
}

class _ComparePlansScreenState extends State<ComparePlansScreen> {
  String? _selectedPlanCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedPlanCode ??= AppStoreScope.of(context).currentPlan.code;
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final plans = store.availablePlans;
    if (plans.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Compare plans')),
        body: const Center(child: Text('Plan options are unavailable right now.')),
      );
    }
    final activePlan = store.currentPlan;
    final selectedPlan = plans.firstWhere(
      (plan) => plan.code == _selectedPlanCode,
      orElse: () => activePlan,
    );
    final canManagePlan = store.permissions.canManagePlan;

    return Scaffold(
      appBar: AppBar(title: const Text('Compare plans')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const IssuedPageHeader(
            title: 'Compare plans',
            subtitle:
                'Choose the plan that fits how your organization manages inventory.',
          ),
          const SizedBox(height: 18),
          if (store.currentUsage.userCount >= activePlan.userLimit) ...[
            _PlanNotice(
              message:
                  '${activePlan.name} includes ${activePlan.userLimit} ${activePlan.userLimit == 1 ? 'user' : 'users'}. Choose a plan with more users to invite more people.',
            ),
            const SizedBox(height: 14),
          ],
          for (final plan in plans) ...[
            _PlanCard(
              plan: plan,
              isCurrent: plan.code == activePlan.code,
              isSelected: plan.code == selectedPlan.code,
              isRecommended:
                  plan.code == widget.recommendedPlanCode ||
                  (widget.recommendedPlanCode == null && plan.code == 'pro'),
              onSelected: () => setState(() => _selectedPlanCode = plan.code),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 6),
          _SelectedPlanSummary(
            plan: selectedPlan,
            isCurrent: selectedPlan.code == activePlan.code,
          ),
          const SizedBox(height: 14),
          if (!canManagePlan)
            const _PlanNotice(
              message: 'Only an owner or admin can change the plan.',
            ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: !canManagePlan || selectedPlan.code == activePlan.code
                ? null
                : () => _confirmSelection(store, selectedPlan),
            child: Text(
              selectedPlan.code == activePlan.code
                  ? 'Current plan'
                  : '${_isHigherPlan(plans, activePlan, selectedPlan) ? 'Select' : 'Switch to'} ${selectedPlan.name} for testing',
            ),
          ),
        ],
      ),
    );
  }

  bool _isHigherPlan(List<Plan> plans, Plan active, Plan selected) {
    return plans.indexWhere((plan) => plan.code == selected.code) >
        plans.indexWhere((plan) => plan.code == active.code);
  }

  Future<void> _confirmSelection(
    AppStore store,
    Plan selectedPlan,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Switch to ${selectedPlan.name}?'),
        content: const Text(
          'This updates the plan for this organization during testing. Billing is not connected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Switch plan'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    store.setCurrentPlanForTesting(selectedPlan.code);
    setState(() => _selectedPlanCode = selectedPlan.code);
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
    required this.isSelected,
    required this.isRecommended,
    required this.onSelected,
  });

  final Plan plan;
  final bool isCurrent;
  final bool isSelected;
  final bool isRecommended;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      color: isSelected ? colors.primaryContainer.withAlpha(105) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isSelected ? colors.primary : const Color(0xFFE7ECF2),
          width: isSelected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSelected,
        child: Padding(
          padding: const EdgeInsets.all(18),
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
                if (isSelected) ...[
                  const SizedBox(width: 10),
                  Icon(Icons.check_circle, color: colors.primary),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _valueStatement(plan),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            if (isCurrent || isRecommended) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (isCurrent) const _PlanBadge(label: 'Current plan'),
                  if (isRecommended)
                    _PlanBadge(
                      label: plan.code == 'pro'
                          ? 'Most flexible'
                          : 'Recommended',
                      muted: true,
                    ),
                ],
              ),
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
            const SizedBox(height: 10),
            Text(
              isSelected ? 'Selected for comparison' : 'Tap to compare',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected ? colors.primary : const Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  String _valueStatement(Plan plan) {
    return switch (plan.code) {
      'free' => 'Good for trying Issued on your own.',
      'starter' => 'More room for a small operation.',
      'shop' => 'Built for growing inventory teams.',
      'pro' => 'For teams that need shared access and fewer limits.',
      _ => 'Inventory limits sized for your organization.',
    };
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

class _SelectedPlanSummary extends StatelessWidget {
  const _SelectedPlanSummary({required this.plan, required this.isCurrent});

  final Plan plan;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(70),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected plan',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              plan.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SummaryChip(label: '${plan.userLimit} users'),
                _SummaryChip(label: '${plan.itemLimit} items'),
                _SummaryChip(label: '${plan.locationLimit} locations'),
                _SummaryChip(
                  label: plan.advancedReportsEnabled
                      ? 'Advanced reports'
                      : 'Standard reports',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isCurrent
                  ? 'Your organization is currently on this plan.'
                  : 'Switching to this plan will update limits for this organization.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.check, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _PlanNotice extends StatelessWidget {
  const _PlanNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.primaryContainer.withAlpha(80),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: colors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
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
  const _PlanBadge({required this.label, this.muted = false});

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: muted
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: muted
                ? Theme.of(context).colorScheme.primary
                : Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
