import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(store.resolveLocationPath(location.id)),
                  if ((location.code ?? '').trim().isNotEmpty)
                    Text('Code: ${location.code}'),
                  Text('Type: ${_locationTypeLabel(location.type)}'),
                  if ((location.description ?? '').trim().isNotEmpty)
                    Text(location.description!),
                  if (!location.isActive) const Chip(label: Text('Archived')),
                  const SizedBox(height: 12),
                  Text('${summary.itemCount} items stocked here'),
                  Text('${summary.positiveBalanceCount} positive balances'),
                  Text(
                    'Total quantity count: ${_format(summary.totalQuantity)}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        ItemsScreen(initialLocationId: location.id),
                  ),
                ),
                child: const Text('View Stock'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        QuickIssueScreen(initialSourceLocationId: location.id),
                  ),
                ),
                child: const Text('Receive Stock to Location'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        QuickIssueScreen(initialSourceLocationId: location.id),
                  ),
                ),
                child: const Text('Transfer Stock Out'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => LabelCenterScreen(
                      initialMode: LabelCenterMode.locations,
                      initialLocationIds: {location.id},
                    ),
                  ),
                ),
                child: const Text('Print Label'),
              ),
            ],
          ),
          if (children.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Child Locations',
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
            title: 'Stock at this location',
            children: items.isEmpty
                ? const [ListTile(title: Text('No stock here.'))]
                : [
                    for (final item in items.take(30))
                      ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          store.formatStockQuantity(
                            item,
                            _quantityAt(store, item.id, location.id),
                          ),
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
          ListTile(title: Text(title)),
          ...children,
        ],
      ),
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

String _format(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2);
}
