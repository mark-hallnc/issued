import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import 'item_detail_screen.dart';

enum _LowStockFilter {
  all,
  consumables,
  returnablesAssets,
  hasSupplier,
  alreadyOnReorder,
}

enum _ReorderListFilter { needed, ordered, history }

class LowStockScreen extends StatefulWidget {
  const LowStockScreen({super.key});

  @override
  State<LowStockScreen> createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  _LowStockFilter _filter = _LowStockFilter.all;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final items = store.getLowStockItems().where((item) {
      return switch (_filter) {
        _LowStockFilter.all => true,
        _LowStockFilter.consumables => item.itemType == ItemType.consumable,
        _LowStockFilter.returnablesAssets =>
          item.itemType == ItemType.returnable ||
              item.itemType == ItemType.asset,
        _LowStockFilter.hasSupplier => (item.supplier ?? '').trim().isNotEmpty,
        _LowStockFilter.alreadyOnReorder =>
          store.getActiveReorderForItem(item.id) != null,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Stock'),
        actions: [
          TextButton.icon(
            onPressed: () => _openReorderList(context),
            icon: const Icon(Icons.list_alt),
            label: const Text('Reorder List'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter == _LowStockFilter.all,
                  onSelected: () => _setFilter(_LowStockFilter.all),
                ),
                _FilterChip(
                  label: 'Consumables',
                  selected: _filter == _LowStockFilter.consumables,
                  onSelected: () => _setFilter(_LowStockFilter.consumables),
                ),
                _FilterChip(
                  label: 'Returnables & Assets',
                  selected: _filter == _LowStockFilter.returnablesAssets,
                  onSelected: () =>
                      _setFilter(_LowStockFilter.returnablesAssets),
                ),
                _FilterChip(
                  label: 'Has Supplier',
                  selected: _filter == _LowStockFilter.hasSupplier,
                  onSelected: () => _setFilter(_LowStockFilter.hasSupplier),
                ),
                _FilterChip(
                  label: 'Already on Reorder',
                  selected: _filter == _LowStockFilter.alreadyOnReorder,
                  onSelected: () =>
                      _setFilter(_LowStockFilter.alreadyOnReorder),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const _EmptyState(message: 'Nothing needs restocking right now.'),
          for (final item in items) ...[
            _LowStockItemCard(item: item),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  void _setFilter(_LowStockFilter filter) {
    setState(() {
      _filter = filter;
    });
  }
}

class ReorderListScreen extends StatefulWidget {
  const ReorderListScreen({super.key});

  @override
  State<ReorderListScreen> createState() => _ReorderListScreenState();
}

class _ReorderListScreenState extends State<ReorderListScreen> {
  _ReorderListFilter _filter = _ReorderListFilter.needed;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final requests =
        store.reorderRequests.where((request) {
          return switch (_filter) {
            _ReorderListFilter.needed => request.status == ReorderStatus.needed,
            _ReorderListFilter.ordered =>
              request.status == ReorderStatus.ordered,
            _ReorderListFilter.history =>
              request.status == ReorderStatus.received ||
                  request.status == ReorderStatus.canceled,
          };
        }).toList()..sort(
          (left, right) => right.createdAt.compareTo(left.createdAt),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Reorder List')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _FilterChip(
                label: 'Needed',
                selected: _filter == _ReorderListFilter.needed,
                onSelected: () => _setFilter(_ReorderListFilter.needed),
              ),
              _FilterChip(
                label: 'Ordered',
                selected: _filter == _ReorderListFilter.ordered,
                onSelected: () => _setFilter(_ReorderListFilter.ordered),
              ),
              _FilterChip(
                label: 'History',
                selected: _filter == _ReorderListFilter.history,
                onSelected: () => _setFilter(_ReorderListFilter.history),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (requests.isEmpty)
            const _EmptyState(message: 'No reorder requests to show.'),
          for (final request in requests) ...[
            _ReorderRequestCard(request: request),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  void _setFilter(_ReorderListFilter filter) {
    setState(() {
      _filter = filter;
    });
  }
}

class _LowStockItemCard extends StatelessWidget {
  const _LowStockItemCard({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final theme = Theme.of(context);
    final unit = _unitById(store, item.unitOfMeasureId);
    final location = _locationById(store, item.locationId);
    final activeReorder = store.getActiveReorderForItem(item.id);
    final suggestedQuantity = store.getSuggestedReorderQuantity(item);
    final canManageReorders = store.canManageReorders;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF17212F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'On hand: ${_formatQuantity(item.quantityOnHand)} ${unit?.abbreviation ?? ''}',
            ),
            Text(
              'Minimum: ${_formatQuantity(item.minimumQuantity)} ${unit?.abbreviation ?? ''}',
            ),
            Text('Location: ${location?.name ?? 'Unknown'}'),
            if ((item.supplier ?? '').trim().isNotEmpty)
              Text('Supplier: ${item.supplier}'),
            Text(
              'Suggested reorder: ${_formatQuantity(suggestedQuantity)} ${unit?.abbreviation ?? ''}',
            ),
            if (_purchaseEquivalentText(store, item, suggestedQuantity) != null)
              Text(_purchaseEquivalentText(store, item, suggestedQuantity)!),
            if (activeReorder != null) ...[
              const SizedBox(height: 8),
              Chip(label: Text(reorderStatusLabel(activeReorder.status))),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => _openItem(context, item),
                  child: const Text('Open Item'),
                ),
                if (activeReorder == null)
                  FilledButton(
                    onPressed: canManageReorders
                        ? () => _showAddToReorderDialog(context, item)
                        : null,
                    child: const Text('Add to Reorder'),
                  )
                else
                  OutlinedButton(
                    onPressed: () => _openReorderList(context),
                    child: const Text('Open Reorder List'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReorderRequestCard extends StatelessWidget {
  const _ReorderRequestCard({required this.request});

  final ReorderRequest request;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final item = _itemById(store, request.itemId);
    final unit = _unitById(store, request.unitOfMeasureId);
    final canManageReorders = store.canManageReorders;
    final canReceiveReorders = store.canReceiveReorders;
    final canMutate =
        request.status == ReorderStatus.needed ||
        request.status == ReorderStatus.ordered;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item?.name ?? 'Unknown item',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF17212F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Quantity: ${_formatQuantity(request.requestedQuantity)} ${unit?.abbreviation ?? ''}',
            ),
            if (item != null &&
                _purchaseEquivalentText(store, item, request.requestedQuantity) !=
                    null)
              Text(
                _purchaseEquivalentText(
                  store,
                  item,
                  request.requestedQuantity,
                )!,
              ),
            if ((request.supplier ?? '').trim().isNotEmpty)
              Text('Supplier: ${request.supplier}'),
            Text('Status: ${reorderStatusLabel(request.status)}'),
            Text('Created: ${_formatDate(request.createdAt)}'),
            if (request.orderedAt != null)
              Text('Ordered: ${_formatDate(request.orderedAt!)}'),
            if (request.receivedAt != null)
              Text('Received: ${_formatDate(request.receivedAt!)}'),
            if ((request.notes ?? '').trim().isNotEmpty)
              Text('Notes: ${request.notes}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: item == null
                      ? null
                      : () => _openItem(context, item),
                  child: const Text('Open Item'),
                ),
                if (request.status == ReorderStatus.needed)
                  FilledButton(
                    onPressed: canManageReorders
                        ? () => _markOrdered(context, request.id)
                        : null,
                    child: const Text('Mark Ordered'),
                  ),
                if (canMutate)
                  FilledButton.tonal(
                    onPressed: canReceiveReorders
                        ? () => _showReceiveDialog(context, request)
                        : null,
                    child: const Text('Receive'),
                  ),
                if (canMutate)
                  OutlinedButton(
                    onPressed: canManageReorders
                        ? () => _cancelReorder(context, request.id)
                        : null,
                    child: const Text('Cancel'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text(message)),
      ),
    );
  }
}

class _QuantityNotesResult {
  const _QuantityNotesResult({required this.quantity, required this.notes});

  final double quantity;
  final String? notes;
}

Future<void> _showAddToReorderDialog(BuildContext context, Item item) async {
  final store = AppStoreScope.of(context);
  if (!store.canManageReorders) {
    _showPermissionDenied(context);
    return;
  }

  if (store.getActiveReorderForItem(item.id) != null) {
    _showMessage(context, 'This item is already on the reorder list.');
    return;
  }

  final result = await _showQuantityNotesDialog(
    context,
    title: 'Add to Reorder',
    quantityLabel: 'Requested quantity',
    initialQuantity: store.getSuggestedReorderQuantity(item),
  );
  if (result == null || !context.mounted) {
    return;
  }

  final created = store.createReorderRequest(
    item.id,
    result.quantity,
    result.notes,
  );
  _showMessage(
    context,
    created
        ? 'Added to reorder list.'
        : 'This item is already on the reorder list.',
  );
}

Future<void> _showReceiveDialog(
  BuildContext context,
  ReorderRequest request,
) async {
  final store = AppStoreScope.of(context);
  if (!store.canReceiveReorders) {
    _showPermissionDenied(context);
    return;
  }

  final result = await _showQuantityNotesDialog(
    context,
    title: 'Receive Reorder',
    quantityLabel: 'Received quantity',
    initialQuantity: request.requestedQuantity,
    item: store.itemById(request.itemId),
    allowPurchaseMode: true,
  );
  if (result == null || !context.mounted) {
    return;
  }

  final received = store.receiveReorder(
    request.id,
    result.quantity,
    result.notes,
  );
  _showMessage(
    context,
    received ? 'Reorder received.' : 'Could not receive this reorder.',
  );
}

Future<_QuantityNotesResult?> _showQuantityNotesDialog(
  BuildContext context, {
  required String title,
  required String quantityLabel,
  required double initialQuantity,
  Item? item,
  bool allowPurchaseMode = false,
}) {
  final store = AppStoreScope.of(context);
  final canUsePurchase =
      allowPurchaseMode && item != null && store.hasPurchaseConversion(item);
  final purchaseItem = canUsePurchase ? item! : null;
  var receiveByPurchase = canUsePurchase;
  final initialText = purchaseItem != null
      ? _formatQuantity(
          initialQuantity / purchaseItem.purchaseToStockConversionFactor!,
        )
      : _formatQuantity(initialQuantity);
  final formKey = GlobalKey<FormState>();
  final quantityController = TextEditingController(text: initialText);
  final notesController = TextEditingController();

  return showDialog<_QuantityNotesResult>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          double enteredQuantity() {
            return double.tryParse(quantityController.text.trim()) ?? 0;
          }

          double stockQuantity() {
            if (receiveByPurchase && purchaseItem != null) {
              return store.convertPurchaseToStock(
                purchaseItem,
                enteredQuantity(),
              );
            }
            return enteredQuantity();
          }

          String? combinedNotes() {
            final notes = notesController.text.trim();
            if (!receiveByPurchase || purchaseItem == null) {
              return notes.isEmpty ? null : notes;
            }
            final conversionNote =
                'Received ${store.formatPurchaseQuantity(purchaseItem, enteredQuantity())} = '
                '${store.formatStockQuantity(purchaseItem, stockQuantity())}.';
            return notes.isEmpty ? conversionNote : '$conversionNote $notes';
          }

          return AlertDialog(
            title: Text(title),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      labelText: receiveByPurchase && purchaseItem != null
                          ? 'Received quantity '
                                '(${store.getPurchaseUom(purchaseItem)?.abbreviation ?? 'purchase UOM'})'
                          : quantityLabel,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      final quantity = double.tryParse(value?.trim() ?? '');
                      if (quantity == null || quantity <= 0) {
                        return 'Enter a quantity greater than 0.';
                      }
                      if (receiveByPurchase && purchaseItem != null) {
                        return store.validatePurchaseReceiveQuantity(
                          purchaseItem,
                          quantity,
                        );
                      }
                      return null;
                    },
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  if (purchaseItem != null) ...[
                    const SizedBox(height: 8),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment<bool>(
                          value: false,
                          label: Text(
                            'Receive by '
                            '${store.getStockUom(purchaseItem)?.abbreviation ?? 'stock'}',
                          ),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          label: Text(
                            'Receive by '
                            '${store.getPurchaseUom(purchaseItem)?.abbreviation ?? 'purchase'}',
                          ),
                        ),
                      ],
                      selected: {receiveByPurchase},
                      onSelectionChanged: (selection) {
                        setDialogState(() {
                          receiveByPurchase = selection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'This will add ${store.formatStockQuantity(purchaseItem, stockQuantity())}.',
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }

                  Navigator.of(context).pop(
                    _QuantityNotesResult(
                      quantity: stockQuantity(),
                      notes: combinedNotes(),
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  ).whenComplete(() {
    quantityController.dispose();
    notesController.dispose();
  });
}

void _markOrdered(BuildContext context, String reorderId) {
  final store = AppStoreScope.of(context);
  if (!store.canManageReorders) {
    _showPermissionDenied(context);
    return;
  }

  _showMessage(
    context,
    store.markReorderOrdered(reorderId)
        ? 'Reorder marked ordered.'
        : 'Could not update this reorder.',
  );
}

void _cancelReorder(BuildContext context, String reorderId) {
  final store = AppStoreScope.of(context);
  if (!store.canManageReorders) {
    _showPermissionDenied(context);
    return;
  }

  _showMessage(
    context,
    store.cancelReorder(reorderId)
        ? 'Reorder canceled.'
        : 'Could not cancel this reorder.',
  );
}

void _openReorderList(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (context) => const ReorderListScreen()),
  );
}

String? _purchaseEquivalentText(AppStore store, Item item, double stockQuantity) {
  if (!store.hasPurchaseConversion(item)) {
    return null;
  }
  final factor = item.purchaseToStockConversionFactor!;
  final purchaseQuantity = stockQuantity / factor;
  return 'Equivalent: ${store.formatPurchaseQuantity(item, purchaseQuantity)}';
}

void _openItem(BuildContext context, Item item) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (context) => ItemDetailScreen(item: item)),
  );
}

void _showPermissionDenied(BuildContext context) {
  _showMessage(context, 'Your current role does not allow this action.');
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Item? _itemById(AppStore store, String itemId) {
  for (final item in store.items) {
    if (item.id == itemId) {
      return item;
    }
  }

  return null;
}

UnitOfMeasure? _unitById(AppStore store, String unitId) {
  for (final unit in store.unitsOfMeasure) {
    if (unit.id == unitId) {
      return unit;
    }
  }

  return null;
}

Location? _locationById(AppStore store, String locationId) {
  for (final location in store.locations) {
    if (location.id == locationId) {
      return location;
    }
  }

  return null;
}

String _formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toStringAsFixed(0);
  }

  return quantity.toStringAsFixed(2);
}

String _formatDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}
