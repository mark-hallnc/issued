import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import '../core/scanner/scan_parser.dart';
import 'add_item_screen.dart';
import 'checked_out_screen.dart';
import 'item_detail_screen.dart';
import 'items_screen.dart';
import 'label_center_screen.dart';
import 'location_detail_screen.dart';
import 'quick_issue_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final ScanResolver _resolver = const ScanResolver();
  bool _isHandlingCode = false;
  ResolvedScan? _resolvedScan;
  String? _lastRawValue;
  DateTime? _lastScanAt;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final resolved = _resolvedScan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
        actions: [
          TextButton(
            onPressed: _showManualEntryDialog,
            child: const Text('Manual', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF17212F),
            padding: const EdgeInsets.all(16),
            child: Text(
              resolved == null
                  ? 'Scan an item, location, assignment target, barcode, or SKU.'
                  : 'Scan paused. Review the result or scan again.',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          if (resolved == null)
            Expanded(
              child: MobileScanner(
                controller: _controller,
                onDetect: _handleCapture,
                errorBuilder: (context, error) {
                  return _ScannerError(message: error.errorCode.message);
                },
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [_ResultPanel(resolved: resolved, store: store)],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showManualEntryDialog,
                    icon: const Icon(Icons.keyboard),
                    label: const Text('Enter Code Manually'),
                  ),
                ),
                if (resolved != null) ...[
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _scanAgain,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scan Again'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleCapture(BarcodeCapture capture) {
    if (_isHandlingCode) {
      return;
    }

    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue?.trim();
      if (code == null || code.isEmpty || _isDuplicateScan(code)) {
        continue;
      }
      _handleCode(code);
      return;
    }
  }

  bool _isDuplicateScan(String rawValue) {
    final now = DateTime.now();
    final lastRawValue = _lastRawValue;
    final lastScanAt = _lastScanAt;
    if (lastRawValue == rawValue &&
        lastScanAt != null &&
        now.difference(lastScanAt) < const Duration(seconds: 2)) {
      return true;
    }
    _lastRawValue = rawValue;
    _lastScanAt = now;
    return false;
  }

  Future<void> _handleCode(String code) async {
    if (_isHandlingCode && _resolvedScan == null) {
      return;
    }

    setState(() {
      _isHandlingCode = true;
    });
    await _controller.stop();

    if (!mounted) {
      return;
    }

    final resolved = _resolver.resolveScan(code, AppStoreScope.of(context));
    setState(() {
      _resolvedScan = resolved;
    });
  }

  Future<void> _showManualEntryDialog() async {
    if (_isHandlingCode && _resolvedScan == null) {
      return;
    }

    final code = await showDialog<String>(
      context: context,
      builder: (context) => const _ManualEntryDialog(),
    );

    if (code == null || code.trim().isEmpty) {
      return;
    }

    await _handleCode(code.trim());
  }

  Future<void> _scanAgain() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _resolvedScan = null;
      _isHandlingCode = false;
    });
    await _controller.start();
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.resolved, required this.store});

  final ResolvedScan resolved;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return switch (resolved.resolutionType) {
      ScanResolutionType.item => _ItemScanPanel(
        item: resolved.item!,
        store: store,
      ),
      ScanResolutionType.location => _LocationScanPanel(
        location: resolved.location!,
        store: store,
      ),
      ScanResolutionType.assignmentTarget => _TargetScanPanel(
        target: resolved.assignmentTarget!,
        store: store,
      ),
      ScanResolutionType.multipleItems => _MultipleItemsPanel(
        items: resolved.itemMatches,
        store: store,
      ),
      ScanResolutionType.checkout => _CheckoutScanPanel(
        checkout: resolved.checkout!,
        store: store,
      ),
      ScanResolutionType.reorder => _ReorderScanPanel(
        reorder: resolved.reorder!,
        store: store,
      ),
      ScanResolutionType.malformed => _SimpleResultPanel(
        title: 'This Issued label could not be read.',
        rawValue: resolved.rawValue,
      ),
      ScanResolutionType.notFound => _NotFoundPanel(resolved: resolved),
    };
  }
}

class _ItemScanPanel extends StatelessWidget {
  const _ItemScanPanel({required this.item, required this.store});

  final Item item;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final unit = store.getStockUom(item);
    final primaryLocation = store.primaryLocationForItem(item.id);
    final openCheckouts = store.openCheckoutRecordsForItem(item.id);
    final archived = !item.isActive;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelTitle(
              title: 'Item Found',
              icon: Icons.inventory_2_outlined,
              badge: archived ? 'Archived' : null,
            ),
            const SizedBox(height: 8),
            Text(item.name, style: Theme.of(context).textTheme.titleLarge),
            Text(_itemTypeLabel(item.itemType)),
            Text(
              'Total: ${store.formatStockQuantity(item, item.quantityOnHand)}',
            ),
            if (unit != null) Text('UOM: ${unit.abbreviation}'),
            Text(
              'Location: ${primaryLocation?.name ?? store.resolveLocationName(item.locationId) ?? 'Unknown'}',
            ),
            if ((item.sku ?? '').trim().isNotEmpty) Text('SKU: ${item.sku}'),
            if ((item.barcode ?? '').trim().isNotEmpty)
              Text('Barcode: ${item.barcode}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => _openQuickIssue(context, itemId: item.id),
                  icon: const Icon(Icons.flash_on_outlined),
                  label: const Text('Quick Actions'),
                ),
                if (!archived && store.permissions.canIssueItems)
                  OutlinedButton(
                    onPressed: () => _openQuickIssue(context, itemId: item.id),
                    child: Text(
                      item.itemType == ItemType.consumable
                          ? 'Issue'
                          : 'Check Out',
                    ),
                  ),
                if (!archived && openCheckouts.isNotEmpty)
                  OutlinedButton(
                    onPressed: () => _openQuickIssue(context, itemId: item.id),
                    child: const Text('Return'),
                  ),
                if (!archived && store.permissions.canReceiveStock)
                  OutlinedButton(
                    onPressed: () => _openQuickIssue(context, itemId: item.id),
                    child: const Text('Receive'),
                  ),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => ItemDetailScreen(item: item),
                    ),
                  ),
                  child: const Text('View Detail'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationScanPanel extends StatelessWidget {
  const _LocationScanPanel({required this.location, required this.store});

  final Location location;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final itemsAtLocation = store.items.where((item) {
      if (!item.isActive) {
        return false;
      }
      return item.locationId == location.id ||
          store
              .itemBalancesForItem(item.id)
              .any((balance) => balance.locationId == location.id);
    }).toList();
    final totalStock = itemsAtLocation.fold<double>(0, (sum, item) {
      final locationBalances = store
          .itemBalancesForItem(item.id)
          .where((balance) => balance.locationId == location.id)
          .toList();
      if (locationBalances.isEmpty && item.locationId == location.id) {
        return sum + item.quantityOnHand;
      }
      return sum +
          locationBalances.fold<double>(
            0,
            (balanceSum, balance) => balanceSum + balance.quantityOnHand,
          );
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelTitle(
              title: 'Location Found',
              icon: Icons.location_on_outlined,
              badge: location.isActive ? null : 'Archived',
            ),
            const SizedBox(height: 8),
            Text(location.name, style: Theme.of(context).textTheme.titleLarge),
            Text('Type: ${location.type}'),
            Text('${itemsAtLocation.length} active items'),
            Text('Total stock quantity: ${_formatQuantity(totalStock)}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          LocationDetailScreen(locationId: location.id),
                    ),
                  ),
                  child: const Text('View Detail'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          ItemsScreen(initialLocationId: location.id),
                    ),
                  ),
                  child: const Text('View Items at Location'),
                ),
                OutlinedButton(
                  onPressed: () =>
                      _openQuickIssue(context, sourceLocationId: location.id),
                  child: const Text('Receive Stock to This Location'),
                ),
                OutlinedButton(
                  onPressed: () =>
                      _openQuickIssue(context, sourceLocationId: location.id),
                  child: const Text('Transfer From This Location'),
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
                  child: const Text('Print Location Label'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetScanPanel extends StatelessWidget {
  const _TargetScanPanel({required this.target, required this.store});

  final AssignmentTarget target;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final openCheckouts = store.checkoutRecords
        .where(
          (record) => record.isOpen && record.assignedToTargetId == target.id,
        )
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelTitle(
              title: 'Target Found',
              icon: Icons.assignment_ind_outlined,
              badge: target.isActive ? null : 'Archived',
            ),
            const SizedBox(height: 8),
            Text(target.name, style: Theme.of(context).textTheme.titleLarge),
            Text(assignmentTargetTypeLabel(target.targetType)),
            if ((target.code ?? '').trim().isNotEmpty)
              Text('Code: ${target.code}'),
            Text('$openCheckouts open checkouts'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          CheckedOutScreen(initialTargetId: target.id),
                    ),
                  ),
                  child: const Text('View Open Checkouts for Target'),
                ),
                OutlinedButton(
                  onPressed: () =>
                      _openQuickIssue(context, assignmentTargetId: target.id),
                  child: const Text('Issue to This Target'),
                ),
                OutlinedButton(
                  onPressed: () =>
                      _openQuickIssue(context, assignmentTargetId: target.id),
                  child: const Text('Check Out to This Target'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MultipleItemsPanel extends StatelessWidget {
  const _MultipleItemsPanel({required this.items, required this.store});

  final List<Item> items;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.warning_amber_outlined),
            title: Text('Multiple active items match this code.'),
          ),
          for (final item in items)
            ListTile(
              title: Text(item.name),
              subtitle: Text(
                [
                  if ((item.sku ?? '').trim().isNotEmpty) 'SKU ${item.sku}',
                  if ((item.barcode ?? '').trim().isNotEmpty)
                    'Barcode ${item.barcode}',
                  store.resolveLocationName(item.locationId),
                  store.formatStockQuantity(item, item.quantityOnHand),
                ].whereType<String>().join(' - '),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => ItemDetailScreen(item: item),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CheckoutScanPanel extends StatelessWidget {
  const _CheckoutScanPanel({required this.checkout, required this.store});

  final CheckoutRecord checkout;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final item = store.itemById(checkout.itemId);
    return _SimpleResultPanel(
      title: 'Checkout Found',
      rawValue: checkout.id,
      message: item == null
          ? 'This checkout references ${checkout.itemId}.'
          : 'Checkout for ${item.name}.',
      action: item == null
          ? null
          : OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => ItemDetailScreen(item: item),
                ),
              ),
              child: const Text('View Item Detail'),
            ),
    );
  }
}

class _ReorderScanPanel extends StatelessWidget {
  const _ReorderScanPanel({required this.reorder, required this.store});

  final ReorderRequest reorder;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final item = store.itemById(reorder.itemId);
    return _SimpleResultPanel(
      title: 'Reorder Found',
      rawValue: reorder.id,
      message: item == null
          ? 'This reorder references ${reorder.itemId}.'
          : 'Reorder for ${item.name}.',
      action: item == null
          ? null
          : OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => ItemDetailScreen(item: item),
                ),
              ),
              child: const Text('View Item Detail'),
            ),
    );
  }
}

class _NotFoundPanel extends StatelessWidget {
  const _NotFoundPanel({required this.resolved});

  final ResolvedScan resolved;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    return _SimpleResultPanel(
      title: 'No item, location, or target found for this code.',
      rawValue: resolved.rawValue,
      action: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const ItemsScreen(),
              ),
            ),
            child: const Text('Search Items'),
          ),
          if (store.permissions.canManageItems)
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<bool>(
                  builder: (context) =>
                      AddItemScreen(initialBarcode: resolved.rawValue.trim()),
                ),
              ),
              child: const Text('Add New Item'),
            ),
        ],
      ),
    );
  }
}

class _SimpleResultPanel extends StatelessWidget {
  const _SimpleResultPanel({
    required this.title,
    required this.rawValue,
    this.message,
    this.action,
  });

  final String title;
  final String rawValue;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectableText(rawValue),
            if (message != null) ...[const SizedBox(height: 8), Text(message!)],
            if (action != null) ...[const SizedBox(height: 12), action!],
          ],
        ),
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.title, required this.icon, this.badge});

  final String title;
  final IconData icon;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1E3A5F)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (badge != null) Chip(label: Text(badge!)),
      ],
    );
  }
}

class _ManualEntryDialog extends StatefulWidget {
  const _ManualEntryDialog();

  @override
  State<_ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<_ManualEntryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Code'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Barcode or QR value',
          border: OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Search')),
      ],
    );
  }

  void _submit() {
    Navigator.of(context).pop(_controller.text.trim());
  }
}

class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt_outlined, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Camera access is needed to scan item barcodes and QR labels.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _openQuickIssue(
  BuildContext context, {
  String? itemId,
  String? sourceLocationId,
  String? assignmentTargetId,
}) {
  final store = AppStoreScope.of(context);
  if (store.isLocked) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Unlock Issued to continue.')));
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => QuickIssueScreen(
        initialItemId: itemId,
        initialSourceLocationId: sourceLocationId,
        initialAssignmentTargetId: assignmentTargetId,
      ),
    ),
  );
}

String _itemTypeLabel(ItemType type) {
  return switch (type) {
    ItemType.consumable => 'Consumable',
    ItemType.returnable => 'Returnable',
    ItemType.asset => 'Asset',
  };
}

String _formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toStringAsFixed(0);
  }
  return quantity.toStringAsFixed(2);
}
