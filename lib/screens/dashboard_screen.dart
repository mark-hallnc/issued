import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import '../core/permissions/app_permissions.dart';
import 'activity_screen.dart';
import 'add_item_screen.dart';
import 'backup_restore_screen.dart';
import 'checked_out_screen.dart';
import 'counts_screen.dart';
import 'csv_import_screen.dart';
import 'data_health_screen.dart';
import 'low_stock_screen.dart';
import 'plan_screens.dart';
import 'quick_issue_screen.dart';
import 'scanner_screen.dart';
import 'settings_detail_screens.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final summary = store.getDashboardSummary();
    final textTheme = Theme.of(context).textTheme;
    final limitWarnings = store.getLimitWarnings().take(2).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Needs Attention',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF17212F),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _signedInText(store),
          style: textTheme.bodyLarge?.copyWith(color: const Color(0xFF5C6672)),
        ),
        const SizedBox(height: 12),
        if (limitWarnings.isNotEmpty)
          for (final warning in limitWarnings) ...[
            _LimitWarningCard(warning: warning),
            const SizedBox(height: 10),
          ],
        if (summary.totalActiveItems == 0)
          _EmptyInventoryActions(store: store)
        else ...[
          if (!summary.hasAttentionItems)
            const _HealthyCard(message: 'Everything looks good.'),
          _QuickActionsSection(store: store),
          _InventoryAlertsSection(summary: summary),
          _CheckoutSection(summary: summary),
          _ReorderSection(summary: summary),
          _CycleCountSection(summary: summary),
          _DataHealthSection(summary: summary),
          _RecentActivitySection(summary: summary, store: store),
        ],
      ],
    );
  }

  String _signedInText(AppStore store) {
    final name = store.currentPerson?.displayName ?? 'Local user';
    return 'Signed in as $name - ${roleLabel(store.currentRole)}';
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      if (store.permissions.canIssueItems)
        _ActionCard(
          label: 'Quick Issue',
          icon: Icons.flash_on_outlined,
          onTap: () => _push(context, const QuickIssueScreen()),
        ),
      if (store.permissions.canPerformInventoryActions ||
          store.permissions.canManageItems)
        _ActionCard(
          label: 'Scan Item',
          icon: Icons.qr_code_scanner,
          onTap: () => _push(context, const ScannerScreen()),
        ),
      if (store.permissions.canManageItems)
        _ActionCard(
          label: 'Add Item',
          icon: Icons.add_box_outlined,
          onTap: () => _push(context, const AddItemScreen()),
        ),
      if (store.permissions.canReceiveStock)
        _ActionCard(
          label: 'Receive Stock',
          icon: Icons.inventory_outlined,
          onTap: () => _push(context, const LowStockScreen()),
        ),
      if (store.permissions.canImportExport)
        _ActionCard(
          label: 'Export Backup',
          icon: Icons.backup_outlined,
          onTap: () => _push(context, const BackupRestoreScreen()),
        ),
    ];
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }
    return _Section(
      title: 'Quick Actions',
      children: [Wrap(spacing: 10, runSpacing: 10, children: actions)],
    );
  }
}

class _InventoryAlertsSection extends StatelessWidget {
  const _InventoryAlertsSection({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Inventory Alerts',
      children: [
        _SummaryGrid(
          children: [
            _SummaryCard(
              title: 'Low Stock Items',
              value: summary.lowStockCount,
              icon: Icons.warning_amber_outlined,
              onTap: () => _push(context, const LowStockScreen()),
            ),
            _SummaryCard(
              title: 'Out of Stock Items',
              value: summary.outOfStockCount,
              icon: Icons.remove_shopping_cart_outlined,
              onTap: () => _push(context, const LowStockScreen()),
            ),
            _SummaryCard(
              title: 'Negative Stock',
              value: summary.negativeStockCount,
              icon: Icons.error_outline,
              emphasize: summary.negativeStockCount > 0,
              onTap: () => _push(context, const DataHealthScreen()),
            ),
            _SummaryCard(
              title: 'Missing Balances',
              value: summary.missingLocationBalanceCount,
              icon: Icons.location_off_outlined,
              emphasize: summary.missingLocationBalanceCount > 0,
              onTap: () => _push(context, const DataHealthScreen()),
            ),
            _SummaryCard(
              title: 'Missing Setup Data',
              value: summary.missingSetupDataCount,
              icon: Icons.rule_folder_outlined,
              emphasize: summary.missingSetupDataCount > 0,
              onTap: () => _push(context, const DataHealthScreen()),
            ),
          ],
        ),
      ],
    );
  }
}

class _CheckoutSection extends StatelessWidget {
  const _CheckoutSection({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Checkouts',
      children: [
        _SummaryGrid(
          children: [
            _SummaryCard(
              title: 'Currently Checked Out',
              value: summary.checkedOutCount,
              icon: Icons.assignment_return_outlined,
              onTap: () => _push(context, const CheckedOutScreen()),
            ),
            _SummaryCard(
              title: 'Overdue Checkouts',
              value: summary.overdueCheckoutCount,
              icon: Icons.event_busy_outlined,
              emphasize: summary.overdueCheckoutCount > 0,
              onTap: () => _push(context, const CheckedOutScreen()),
            ),
            _SummaryCard(
              title: 'Due Soon Checkouts',
              value: summary.dueSoonCheckoutCount,
              icon: Icons.event_available_outlined,
              onTap: () => _push(context, const CheckedOutScreen()),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReorderSection extends StatelessWidget {
  const _ReorderSection({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Reorders',
      children: [
        _SummaryGrid(
          children: [
            _SummaryCard(
              title: 'Pending Reorders',
              value: summary.pendingReorderCount,
              icon: Icons.list_alt_outlined,
              onTap: () => _push(context, const ReorderListScreen()),
            ),
            _SummaryCard(
              title: 'Awaiting Receipt',
              value: summary.orderedReorderCount,
              icon: Icons.local_shipping_outlined,
              onTap: () => _push(context, const ReorderListScreen()),
            ),
            _SummaryCard(
              title: 'Low Stock Without Reorder',
              value: summary.lowStockWithoutReorderCount,
              icon: Icons.add_task_outlined,
              onTap: () => _push(context, const LowStockScreen()),
            ),
          ],
        ),
      ],
    );
  }
}

class _CycleCountSection extends StatelessWidget {
  const _CycleCountSection({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Cycle Counts',
      children: [
        _SummaryGrid(
          children: [
            _SummaryCard(
              title: 'Draft Counts',
              value: summary.draftCycleCountCount,
              icon: Icons.fact_check_outlined,
              onTap: () => _push(context, const CountsScreen()),
            ),
            _SummaryCard(
              title: 'Needs Approval',
              value: summary.submittedCycleCountCount,
              icon: Icons.approval_outlined,
              emphasize: summary.submittedCycleCountCount > 0,
              onTap: () => _push(context, const CountsScreen()),
            ),
            _SummaryCard(
              title: 'Counts with Variance',
              value: summary.cycleCountVarianceCount,
              icon: Icons.compare_arrows,
              onTap: () => _push(context, const CountsScreen()),
            ),
          ],
        ),
      ],
    );
  }
}

class _DataHealthSection extends StatelessWidget {
  const _DataHealthSection({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final errors = summary.dataHealthErrorCount;
    final warnings = summary.dataHealthWarningCount;
    final message = errors == null && warnings == null
        ? 'Run a check when you want a deeper data review.'
        : '$errors errors, $warnings warnings';
    return _Section(
      title: 'Data Health',
      children: [
        _AlertCard(
          icon: Icons.health_and_safety_outlined,
          title: errors == null && warnings == null
              ? 'Healthy state unknown'
              : 'Data Health',
          message: message,
          actionLabel: 'Run Data Health Check',
          onTap: () => _push(context, const DataHealthScreen()),
        ),
      ],
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({required this.summary, required this.store});

  final DashboardSummary summary;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Recent Activity',
      children: [
        Card(
          child: Column(
            children: [
              if (summary.recentTransactions.isEmpty)
                const ListTile(title: Text('No recent activity.'))
              else
                for (final transaction in summary.recentTransactions)
                  _RecentActivityTile(transaction: transaction, store: store),
              ListTile(
                title: const Text('View all activity'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _push(context, const ActivityScreen()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyInventoryActions extends StatelessWidget {
  const _EmptyInventoryActions({required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Quick Actions',
      children: [
        const _HealthyCard(
          message: 'No items yet. Add or import your first items.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (store.permissions.canManageItems)
              _ActionCard(
                label: 'Add First Item',
                icon: Icons.add_box_outlined,
                onTap: () => _push(context, const AddItemScreen()),
              ),
            if (store.permissions.canImportExport)
              _ActionCard(
                label: 'Import CSV',
                icon: Icons.upload_file,
                onTap: () => _push(context, const CsvImportScreen()),
              ),
            if (store.permissions.canManageSettings)
              _ActionCard(
                label: 'Create Location',
                icon: Icons.add_location_alt_outlined,
                onTap: () => _push(context, const LocationsSettingsScreen()),
              ),
            if (store.permissions.canImportExport)
              _ActionCard(
                label: 'Export CSV Template',
                icon: Icons.description_outlined,
                onTap: () => _push(context, const CsvImportScreen()),
              ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF17212F),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.45,
      children: children,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    this.emphasize = false,
    this.onTap,
  });

  final String title;
  final int value;
  final IconData icon;
  final bool emphasize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = emphasize ? const Color(0xFFB54708) : const Color(0xFF1E3A5F);
    return Card(
      color: emphasize ? const Color(0xFFFFF3E0) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const Spacer(),
              Text(
                value.toString(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1E3A5F)),
        title: Text(title),
        subtitle: Text(message),
        trailing: TextButton(onPressed: onTap, child: Text(actionLabel)),
      ),
    );
  }
}

class _HealthyCard extends StatelessWidget {
  const _HealthyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _RecentActivityTile extends StatelessWidget {
  const _RecentActivityTile({required this.transaction, required this.store});

  final InventoryTransaction transaction;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final itemName = store.itemById(transaction.itemId)?.name ?? 'Unknown item';
    final userName =
        store.resolveUserName(transaction.performedByUserId) ?? 'Unknown user';
    return ListTile(
      leading: const Icon(Icons.history_outlined),
      title: Text(itemName),
      subtitle: Text(
        '${_transactionLabel(transaction.transactionType)} - ${_formatQuantity(transaction.quantityDelta)}'
        '\n$userName - ${_formatDateTime(transaction.createdAt)}',
      ),
      isThreeLine: true,
      onTap: () => _push(context, const ActivityScreen()),
    );
  }
}

class _LimitWarningCard extends StatelessWidget {
  const _LimitWarningCard({required this.warning});

  final PlanLimitWarning warning;

  @override
  Widget build(BuildContext context) {
    final isReached = warning.severity == PlanLimitSeverity.reached;
    final canManagePlan = AppStoreScope.of(context).permissions.canManagePlan;

    return Card(
      color: isReached ? const Color(0xFFFFF3E0) : const Color(0xFFEAF2FF),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              warning.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF17212F),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () =>
                      _push(context, const PlanUsageSettingsScreen()),
                  child: const Text('View Plan'),
                ),
                if (canManagePlan)
                  FilledButton(
                    onPressed: () => openComparePlans(
                      context,
                      recommendedPlanCode: warning.recommendedPlanCode,
                    ),
                    child: const Text('Upgrade'),
                  )
                else
                  const OutlinedButton(
                    onPressed: null,
                    child: Text('Ask an admin to upgrade'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _push(BuildContext context, Widget screen) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (context) => screen));
}

String _transactionLabel(InventoryTransactionType type) {
  return switch (type) {
    InventoryTransactionType.receive => 'Receive',
    InventoryTransactionType.issue => 'Issue',
    InventoryTransactionType.checkout => 'Check Out',
    InventoryTransactionType.returnItem => 'Return',
    InventoryTransactionType.transfer => 'Transfer',
    InventoryTransactionType.adjustment => 'Adjustment',
    InventoryTransactionType.markLost => 'Lost',
    InventoryTransactionType.markDamaged => 'Damaged',
    InventoryTransactionType.cycleCountAdjustment => 'Cycle Count',
  };
}

String _formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toStringAsFixed(0);
  }
  return quantity.toStringAsFixed(2);
}

String _formatDateTime(DateTime value) {
  final hour = value.hour > 12
      ? value.hour - 12
      : value.hour == 0
      ? 12
      : value.hour;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  return '${value.month}/${value.day}/${value.year} $hour:$minute $suffix';
}
