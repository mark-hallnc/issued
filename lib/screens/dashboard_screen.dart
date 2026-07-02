import 'package:flutter/material.dart';

import '../core/models/models.dart';
import '../core/sample_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lowStockCount = sampleItems
        .where(
          (item) =>
              item.isActive && item.quantityOnHand <= item.minimumQuantity,
        )
        .length;
    final checkedOutCount = sampleTransactions.where((transaction) {
      final item = _itemById(transaction.itemId);

      return item?.itemType == ItemType.returnable &&
          transaction.transactionType == InventoryTransactionType.checkout &&
          transaction.assignedToPersonId != null;
    }).length;
    final activeCycleCountCount = sampleCycleCountSessions
        .where((session) => session.status != CycleCountStatus.approved)
        .length;
    final recentTransactionCount = sampleTransactions.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Issued',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF17212F),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tool crib and shop inventory',
          style: textTheme.bodyLarge?.copyWith(color: const Color(0xFF5C6672)),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.28,
          children: [
            _DashboardCard(
              title: 'Low Stock',
              count: lowStockCount.toString(),
              icon: Icons.warning_amber_outlined,
            ),
            _DashboardCard(
              title: 'Checked Out',
              count: checkedOutCount.toString(),
              icon: Icons.assignment_return_outlined,
            ),
            _DashboardCard(
              title: 'Cycle Counts',
              count: activeCycleCountCount.toString(),
              icon: Icons.fact_check_outlined,
            ),
            _DashboardCard(
              title: 'Recent Activity',
              count: recentTransactionCount.toString(),
              icon: Icons.history_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Item? _itemById(String itemId) {
    for (final item in sampleItems) {
      if (item.id == itemId) {
        return item;
      }
    }

    return null;
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.count,
    required this.icon,
  });

  final String title;
  final String count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF1E3A5F)),
            const Spacer(),
            Text(
              count,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF17212F),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                color: const Color(0xFF5C6672),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
