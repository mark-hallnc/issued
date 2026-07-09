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

enum _ReorderListFilter {
  needed,
  awaitingReceipt,
  partiallyReceived,
  received,
  cancelled,
  all,
}

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
  const ReorderListScreen({super.key})
    : _initialFilter = _ReorderListFilter.needed;

  const ReorderListScreen.needed({super.key})
    : _initialFilter = _ReorderListFilter.needed;

  const ReorderListScreen.awaitingReceipt({super.key})
    : _initialFilter = _ReorderListFilter.awaitingReceipt;

  final _ReorderListFilter _initialFilter;

  @override
  State<ReorderListScreen> createState() => _ReorderListScreenState();
}

class _ReorderListScreenState extends State<ReorderListScreen> {
  late _ReorderListFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget._initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final requests = switch (_filter) {
      _ReorderListFilter.needed => store.pendingReorderRequests,
      _ReorderListFilter.awaitingReceipt => store.awaitingReceiptReorders,
      _ReorderListFilter.partiallyReceived =>
        store.reorderRequests
            .where(
              (request) => request.status == ReorderStatus.partiallyReceived,
            )
            .toList(),
      _ReorderListFilter.received =>
        store.reorderRequests
            .where((request) => request.status == ReorderStatus.received)
            .toList(),
      _ReorderListFilter.cancelled =>
        store.reorderRequests.where((request) => request.isCancelled).toList(),
      _ReorderListFilter.all => store.reorderRequests.toList(),
    }..sort((left, right) => right.createdAt.compareTo(left.createdAt));

    return Scaffold(
      appBar: AppBar(title: const Text('Reorder List')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Needed',
                  selected: _filter == _ReorderListFilter.needed,
                  onSelected: () => _setFilter(_ReorderListFilter.needed),
                ),
                _FilterChip(
                  label: 'Awaiting Receipt',
                  selected: _filter == _ReorderListFilter.awaitingReceipt,
                  onSelected: () =>
                      _setFilter(_ReorderListFilter.awaitingReceipt),
                ),
                _FilterChip(
                  label: 'Partially Received',
                  selected: _filter == _ReorderListFilter.partiallyReceived,
                  onSelected: () =>
                      _setFilter(_ReorderListFilter.partiallyReceived),
                ),
                _FilterChip(
                  label: 'Received',
                  selected: _filter == _ReorderListFilter.received,
                  onSelected: () => _setFilter(_ReorderListFilter.received),
                ),
                _FilterChip(
                  label: 'Cancelled',
                  selected: _filter == _ReorderListFilter.cancelled,
                  onSelected: () => _setFilter(_ReorderListFilter.cancelled),
                ),
                _FilterChip(
                  label: 'All',
                  selected: _filter == _ReorderListFilter.all,
                  onSelected: () => _setFilter(_ReorderListFilter.all),
                ),
              ],
            ),
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
    final suggestedQuantity = store.getReorderSuggestedQuantity(item);
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
        request.status == ReorderStatus.ordered ||
        request.status == ReorderStatus.partiallyReceived;

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
              'Requested: ${_formatQuantity(request.requestedQuantity)} ${unit?.abbreviation ?? ''}',
            ),
            Text(
              'Received: ${_formatQuantity(request.receivedQuantity)} ${unit?.abbreviation ?? ''}',
            ),
            Text(
              'Remaining: ${_formatQuantity(request.remainingQuantity)} ${unit?.abbreviation ?? ''}',
            ),
            if (item != null &&
                _purchaseEquivalentText(
                      store,
                      item,
                      request.requestedQuantity,
                    ) !=
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
            if (_destinationText(store, request) != null)
              Text(_destinationText(store, request)!),
            if ((request.orderNumber ?? '').trim().isNotEmpty)
              Text('Order Number: ${request.orderNumber}'),
            Text('Status: ${reorderStatusLabel(request.status)}'),
            Text('Created: ${_formatDate(request.createdAt)}'),
            if (request.orderedAt != null)
              Text('Ordered: ${_formatDate(request.orderedAt!)}'),
            if (request.receivedAt != null)
              Text('Received: ${_formatDate(request.receivedAt!)}'),
            if (request.cancelledAt != null)
              Text('Cancelled: ${_formatDate(request.cancelledAt!)}'),
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
    _showMessage(context, 'This item already has an open reorder request.');
    return;
  }

  final result = await _showQuantityNotesDialog(
    context,
    title: 'Add to Reorder',
    quantityLabel: 'Requested quantity',
    initialQuantity: store.getReorderSuggestedQuantity(item),
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
    initialQuantity: request.remainingQuantity > 0
        ? request.remainingQuantity
        : request.requestedQuantity,
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

  return showDialog<_QuantityNotesResult>(
    context: context,
    builder: (context) => _QuantityNotesDialog(
      store: store,
      title: title,
      quantityLabel: quantityLabel,
      initialQuantity: initialQuantity,
      item: item,
      allowPurchaseMode: allowPurchaseMode,
    ),
  );
}

class _QuantityNotesDialog extends StatefulWidget {
  const _QuantityNotesDialog({
    required this.store,
    required this.title,
    required this.quantityLabel,
    required this.initialQuantity,
    this.item,
    this.allowPurchaseMode = false,
  });

  final AppStore store;
  final String title;
  final String quantityLabel;
  final double initialQuantity;
  final Item? item;
  final bool allowPurchaseMode;

  @override
  State<_QuantityNotesDialog> createState() => _QuantityNotesDialogState();
}

class _QuantityNotesDialogState extends State<_QuantityNotesDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;
  late bool _receiveByPurchase;

  Item? get _purchaseItem {
    final item = widget.item;
    if (!widget.allowPurchaseMode ||
        item == null ||
        !widget.store.hasPurchaseConversion(item)) {
      return null;
    }
    return item;
  }

  @override
  void initState() {
    super.initState();
    final purchaseItem = _purchaseItem;
    _receiveByPurchase = purchaseItem != null;
    final initialText = purchaseItem != null
        ? _formatQuantity(
            widget.initialQuantity /
                purchaseItem.purchaseToStockConversionFactor!,
          )
        : _formatQuantity(widget.initialQuantity);
    _quantityController = TextEditingController(text: initialText);
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final purchaseItem = _purchaseItem;
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: _receiveByPurchase && purchaseItem != null
                      ? 'Received quantity '
                            '(${store.getPurchaseUom(purchaseItem)?.abbreviation ?? 'purchase UOM'})'
                      : widget.quantityLabel,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final quantity = double.tryParse(value?.trim() ?? '');
                  if (quantity == null || quantity <= 0) {
                    return 'Enter a quantity greater than 0.';
                  }
                  if (_receiveByPurchase && purchaseItem != null) {
                    return store.validatePurchaseReceiveQuantity(
                      purchaseItem,
                      quantity,
                    );
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
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
                  selected: {_receiveByPurchase},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _receiveByPurchase = selection.first;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'This will add '
                    '${store.formatStockQuantity(purchaseItem, _stockQuantity())}.',
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  double _enteredQuantity() {
    return double.tryParse(_quantityController.text.trim()) ?? 0;
  }

  double _stockQuantity() {
    final purchaseItem = _purchaseItem;
    if (_receiveByPurchase && purchaseItem != null) {
      return widget.store.convertPurchaseToStock(
        purchaseItem,
        _enteredQuantity(),
      );
    }
    return _enteredQuantity();
  }

  String? _combinedNotes() {
    final purchaseItem = _purchaseItem;
    final notes = _notesController.text.trim();
    if (!_receiveByPurchase || purchaseItem == null) {
      return notes.isEmpty ? null : notes;
    }
    final conversionNote =
        'Received ${widget.store.formatPurchaseQuantity(purchaseItem, _enteredQuantity())} = '
        '${widget.store.formatStockQuantity(purchaseItem, _stockQuantity())}.';
    return notes.isEmpty ? conversionNote : '$conversionNote $notes';
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      _QuantityNotesResult(quantity: _stockQuantity(), notes: _combinedNotes()),
    );
  }
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
        ? 'Reorder cancelled.'
        : 'Could not cancel this reorder.',
  );
}

void _openReorderList(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (context) => const ReorderListScreen()),
  );
}

String? _purchaseEquivalentText(
  AppStore store,
  Item item,
  double stockQuantity,
) {
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

String? _destinationText(AppStore store, ReorderRequest request) {
  final locationId = request.destinationLocationId;
  if (locationId == null) {
    return null;
  }
  final location = _locationById(store, locationId);
  return 'Destination: ${location?.name ?? 'Unknown location'}';
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
