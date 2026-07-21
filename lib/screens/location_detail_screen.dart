import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import '../widgets/issued_empty_state.dart';
import '../widgets/issued_metric_card.dart';
import '../widgets/issued_page_header.dart';
import '../widgets/issued_status_badge.dart';
import 'items_screen.dart';
import 'label_center_screen.dart';
import 'quick_issue_screen.dart';

class LocationDetailScreen extends StatelessWidget {
  const LocationDetailScreen({super.key, required this.locationId});

  final String locationId;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final location = store.findLocationById(locationId);
    if (location == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Location')),
        body: const Center(child: Text('Location not found.')),
      );
    }
    final summary = store.getLocationStockSummary(location.id);
    final items = store.getItemsAtLocation(location.id);
    final children = store.getChildLocations(location.id);
    final parent = location.parentLocationId == null
        ? null
        : store.findLocationById(location.parentLocationId!);
    final activity =
        store.transactions.where((transaction) {
            return transaction.fromLocationId == location.id ||
                transaction.toLocationId == location.id ||
                transaction.assignedToLocationId == location.id;
          }).toList()
          ..sort((left, right) => right.createdAt.compareTo(left.createdAt));

    return Scaffold(
      appBar: AppBar(title: const Text('Location')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          IssuedPageHeader(
            title: location.name,
            subtitle: parent == null
                ? 'Top-level location'
                : 'Inside ${parent.name}',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            _locationTypeIcon(location.type),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.resolveLocationPath(location.id),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            if ((location.code ?? '').trim().isNotEmpty)
                              Text(
                                'Code ${location.code}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      IssuedStatusBadge(
                        label: _locationTypeLabel(location.type),
                        icon: _locationTypeIcon(location.type),
                      ),
                      IssuedStatusBadge(
                        label: location.isActive ? 'Active' : 'Archived',
                        tone: location.isActive
                            ? IssuedStatusTone.success
                            : IssuedStatusTone.neutral,
                      ),
                    ],
                  ),
                  if ((location.description ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      location.description!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: IssuedMetricCard(
                  label: 'Items stored here',
                  value: '${summary.itemCount}',
                  icon: Icons.inventory_2_outlined,
                  tone: IssuedStatusTone.info,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: IssuedMetricCard(
                  label: 'Total quantity',
                  value: _format(summary.totalQuantity),
                  icon: Icons.numbers_outlined,
                  tone: IssuedStatusTone.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        ItemsScreen(initialLocationId: location.id),
                  ),
                ),
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('View stock'),
              ),
              if (store.permissions.canReceiveStock)
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => QuickIssueScreen(
                        initialSourceLocationId: location.id,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text('Receive stock here'),
                ),
              if (store.permissions.canTransferStock)
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => QuickIssueScreen(
                        initialSourceLocationId: location.id,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Transfer stock out'),
                ),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => LabelCenterScreen(
                      initialMode: LabelCenterMode.locations,
                      initialLocationIds: {location.id},
                    ),
                  ),
                ),
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Print label'),
              ),
            ],
          ),
          if (children.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Child locations',
              children: [
                for (final child in children)
                  ListTile(
                    title: Text(child.name),
                    subtitle: Text(store.resolveLocationPath(child.id)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            LocationDetailScreen(locationId: child.id),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Stock in this location',
            children: items.isEmpty
                ? const [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: IssuedEmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'No stock here yet',
                        message:
                            'Receive stock into this location or move items here.',
                      ),
                    ),
                  ]
                : [
                    for (final item in items.take(30))
                      ListTile(
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: Text(item.name),
                        subtitle: Text(
                          [
                            if ((item.sku ?? '').trim().isNotEmpty)
                              'SKU ${item.sku}',
                            if ((item.barcode ?? '').trim().isNotEmpty)
                              'Barcode ${item.barcode}',
                          ].join(' · '),
                        ),
                        trailing: _StockQuantity(
                          item: item,
                          quantity: _quantityAt(store, item.id, location.id),
                          store: store,
                        ),
                      ),
                  ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Recent activity',
            children: activity.isEmpty
                ? const [ListTile(title: Text('No recent activity.'))]
                : [
                    for (final transaction in activity.take(8))
                      ListTile(
                        title: Text(_transactionLabel(transaction)),
                        subtitle: Text(transaction.createdAt.toString()),
                      ),
                  ],
          ),
        ],
      ),
    );
  }

  double _quantityAt(AppStore store, String itemId, String locationId) {
    for (final balance in store.itemBalancesForItem(itemId)) {
      if (balance.locationId == locationId) {
        return balance.quantityOnHand;
      }
    }
    final item = store.itemById(itemId);
    return item?.locationId == locationId ? item?.quantityOnHand ?? 0 : 0;
  }

  String _transactionLabel(InventoryTransaction transaction) {
    return switch (transaction.transactionType) {
      InventoryTransactionType.receive => 'Receive',
      InventoryTransactionType.issue => 'Issue',
      InventoryTransactionType.checkout => 'Check Out',
      InventoryTransactionType.returnItem => 'Return',
      InventoryTransactionType.transfer => 'Transfer',
      InventoryTransactionType.adjustment => 'Adjustment',
      InventoryTransactionType.markLost => 'Lost',
      InventoryTransactionType.markDamaged => 'Damaged',
      InventoryTransactionType.cycleCountAdjustment => 'Cycle Count',
      InventoryTransactionType.correction => 'Correction',
    };
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _StockQuantity extends StatelessWidget {
  const _StockQuantity({
    required this.item,
    required this.quantity,
    required this.store,
  });

  final Item item;
  final double quantity;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          store.formatStockQuantity(item, quantity),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (quantity <= 0)
          const IssuedStatusBadge(label: 'Out', tone: IssuedStatusTone.error),
      ],
    );
  }
}

String _locationTypeLabel(String value) {
  return switch (value) {
    'stockroom' => 'Stockroom',
    'shelf' => 'Shelf',
    'bin' => 'Bin',
    'truck' => 'Truck',
    'jobBox' => 'Job Box',
    'warehouse' => 'Warehouse',
    'trailer' => 'Trailer',
    _ => value.isEmpty ? 'Other' : value,
  };
}

IconData _locationTypeIcon(String value) {
  return switch (value) {
    'warehouse' || 'stockroom' => Icons.warehouse_outlined,
    'shelf' => Icons.view_stream_outlined,
    'bin' => Icons.inventory_2_outlined,
    'jobBox' => Icons.handyman_outlined,
    'truck' => Icons.local_shipping_outlined,
    'trailer' => Icons.rv_hookup_outlined,
    _ => Icons.location_on_outlined,
  };
}

String _format(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2);
}
