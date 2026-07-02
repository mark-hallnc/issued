import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.item});

  final Item item;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late Item _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final unit = _unitById(store, _item.unitOfMeasureId);
    final location = _locationById(store, _item.locationId);
    final showReturnableActions =
        _item.itemType == ItemType.returnable ||
        _item.itemType == ItemType.asset;
    final checkedOutPerson = _checkedOutPerson(store);
    final recentTransactions = _recentTransactions(store);

    return Scaffold(
      appBar: AppBar(title: const Text('Item Detail')),
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
                    _item.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF17212F),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoPill(label: _itemTypeLabel(_item.itemType)),
                      _InfoPill(label: _item.isActive ? 'Active' : 'Inactive'),
                      if (checkedOutPerson != null)
                        _InfoPill(label: 'Checked out to $checkedOutPerson'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'On hand',
                    value:
                        '${_formatQuantity(_item.quantityOnHand)} ${unit?.abbreviation ?? ''}',
                  ),
                  _DetailRow(
                    label: 'Minimum',
                    value:
                        '${_formatQuantity(_item.minimumQuantity)} ${unit?.abbreviation ?? ''}',
                  ),
                  _DetailRow(
                    label: 'Location',
                    value: location?.name ?? 'Unknown location',
                  ),
                  _DetailRow(label: 'Category', value: _item.category),
                  if (_item.sku != null)
                    _DetailRow(label: 'SKU', value: _item.sku!),
                  if (_item.barcode != null)
                    _DetailRow(label: 'Barcode', value: _item.barcode!),
                  if (_item.supplier != null)
                    _DetailRow(label: 'Supplier', value: _item.supplier!),
                  if (_item.unitCost != null)
                    _DetailRow(
                      label: 'Unit cost',
                      value: '\$${_item.unitCost!.toStringAsFixed(2)}',
                    ),
                  _DetailRow(
                    label: 'Status',
                    value: checkedOutPerson == null
                        ? (_item.isActive ? 'Active' : 'Inactive')
                        : 'Checked out',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF17212F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _ActionButton(
                        label: 'Issue',
                        icon: Icons.call_made,
                        onPressed: _issueItem,
                      ),
                      _ActionButton(
                        label: 'Receive',
                        icon: Icons.add_box,
                        onPressed: _receiveStock,
                      ),
                      _ActionButton(
                        label: 'Transfer',
                        icon: Icons.swap_horiz,
                        onPressed: _transferItem,
                      ),
                      _ActionButton(
                        label: 'Adjust',
                        icon: Icons.tune,
                        onPressed: _adjustQuantity,
                      ),
                      if (showReturnableActions) ...[
                        _ActionButton(
                          label: 'Check Out',
                          icon: Icons.assignment_ind,
                          onPressed: _checkOutItem,
                        ),
                        _ActionButton(
                          label: 'Return',
                          icon: Icons.assignment_return,
                          onPressed: _returnItem,
                        ),
                        _ActionButton(
                          label: 'Mark Lost/Damaged',
                          icon: Icons.report_problem_outlined,
                          onPressed: _markLostOrDamaged,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF17212F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (recentTransactions.isEmpty)
                    Text(
                      'No activity yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5C6672),
                      ),
                    )
                  else
                    for (final transaction in recentTransactions)
                      _TransactionRow(transaction: transaction),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _receiveStock() async {
    final result = await _showQuantityNotesDialog(
      title: 'Receive Stock',
      quantityLabel: 'Quantity received',
    );

    if (result == null) {
      return;
    }

    _applyItemUpdate(
      _item.copyWith(
        quantityOnHand: _item.quantityOnHand + result.quantity,
        updatedAt: DateTime.now(),
      ),
    );
    _appendTransaction(
      InventoryTransactionType.receive,
      result.quantity,
      notes: result.notes,
      toLocationId: _item.locationId,
    );
  }

  Future<void> _issueItem() async {
    final store = AppStoreScope.of(context);
    final person = _defaultPerson(store);
    final result = await _showQuantityNotesDialog(
      title: _item.itemType == ItemType.consumable
          ? 'Issue Consumable'
          : 'Issue Item',
      quantityLabel: 'Quantity issued',
    );

    if (result == null) {
      return;
    }

    _applyItemUpdate(
      _item.copyWith(
        quantityOnHand: _item.quantityOnHand - result.quantity,
        updatedAt: DateTime.now(),
      ),
    );
    _appendTransaction(
      InventoryTransactionType.issue,
      -result.quantity,
      notes: result.notes,
      fromLocationId: _item.locationId,
      assignedToPersonId: person?.id,
    );
  }

  Future<void> _checkOutItem() async {
    final store = AppStoreScope.of(context);
    final person = _defaultPerson(store);
    final result = await _showQuantityNotesDialog(
      title: 'Check Out Item',
      quantityLabel: 'Quantity checked out',
      initialQuantity: 1,
      helperText: person == null
          ? null
          : 'Assigned to ${person.displayName} for this mock workflow.',
    );

    if (result == null) {
      return;
    }

    _applyItemUpdate(
      _item.copyWith(
        quantityOnHand: _item.quantityOnHand - result.quantity,
        updatedAt: DateTime.now(),
      ),
    );
    _appendTransaction(
      InventoryTransactionType.checkout,
      -result.quantity,
      notes: result.notes,
      fromLocationId: _item.locationId,
      assignedToPersonId: person?.id,
    );
  }

  Future<void> _returnItem() async {
    final result = await _showQuantityNotesDialog(
      title: 'Return Item',
      quantityLabel: 'Quantity returned',
      initialQuantity: 1,
    );

    if (result == null) {
      return;
    }

    _applyItemUpdate(
      _item.copyWith(
        quantityOnHand: _item.quantityOnHand + result.quantity,
        updatedAt: DateTime.now(),
      ),
    );
    _appendTransaction(
      InventoryTransactionType.returnItem,
      result.quantity,
      notes: result.notes,
      toLocationId: _item.locationId,
    );
  }

  Future<void> _transferItem() async {
    final result = await showDialog<_TransferResult>(
      context: context,
      builder: (context) => _TransferDialog(
        currentLocationId: _item.locationId,
        store: AppStoreScope.of(context),
      ),
    );

    if (result == null) {
      return;
    }

    final fromLocationId = _item.locationId;
    _applyItemUpdate(
      _item.copyWith(
        locationId: result.toLocationId,
        updatedAt: DateTime.now(),
      ),
    );
    _appendTransaction(
      InventoryTransactionType.transfer,
      0,
      notes: result.notes,
      fromLocationId: fromLocationId,
      toLocationId: result.toLocationId,
    );
  }

  Future<void> _adjustQuantity() async {
    final result = await _showQuantityNotesDialog(
      title: 'Set Quantity On Hand',
      quantityLabel: 'New quantity on hand',
      initialQuantity: _item.quantityOnHand,
    );

    if (result == null) {
      return;
    }

    final delta = result.quantity - _item.quantityOnHand;
    _applyItemUpdate(
      _item.copyWith(
        quantityOnHand: result.quantity,
        updatedAt: DateTime.now(),
      ),
    );
    _appendTransaction(
      InventoryTransactionType.adjustment,
      delta,
      notes: result.notes,
      toLocationId: _item.locationId,
    );
  }

  Future<void> _markLostOrDamaged() async {
    final result = await _showQuantityNotesDialog(
      title: 'Mark Lost/Damaged',
      quantityLabel: 'Quantity lost/damaged',
      initialQuantity: 1,
    );

    if (result == null) {
      return;
    }

    _applyItemUpdate(
      _item.copyWith(
        quantityOnHand: _item.quantityOnHand - result.quantity,
        updatedAt: DateTime.now(),
      ),
    );
    _appendTransaction(
      InventoryTransactionType.markDamaged,
      -result.quantity,
      notes: result.notes,
      fromLocationId: _item.locationId,
    );
  }

  Future<_QuantityNotesResult?> _showQuantityNotesDialog({
    required String title,
    required String quantityLabel,
    double initialQuantity = 1,
    String? helperText,
  }) {
    return showDialog<_QuantityNotesResult>(
      context: context,
      builder: (context) => _QuantityNotesDialog(
        title: title,
        quantityLabel: quantityLabel,
        initialQuantity: initialQuantity,
        helperText: helperText,
      ),
    );
  }

  void _applyItemUpdate(Item updatedItem) {
    final store = AppStoreScope.of(context);
    store.updateItem(updatedItem);

    setState(() {
      _item = updatedItem;
    });
  }

  void _appendTransaction(
    InventoryTransactionType type,
    double quantityDelta, {
    String? notes,
    String? fromLocationId,
    String? toLocationId,
    String? assignedToPersonId,
  }) {
    final store = AppStoreScope.of(context);
    store.addTransaction(
      InventoryTransaction(
        id: 'txn-${DateTime.now().microsecondsSinceEpoch}',
        itemId: _item.id,
        transactionType: type,
        quantityDelta: quantityDelta,
        unitOfMeasureId: _item.unitOfMeasureId,
        fromLocationId: fromLocationId,
        toLocationId: toLocationId,
        assignedToPersonId: assignedToPersonId,
        performedByUserId: store.users.isEmpty ? null : store.users.first.id,
        notes: notes,
        createdAt: DateTime.now(),
      ),
    );

    setState(() {});
  }

  List<InventoryTransaction> _recentTransactions(AppStore store) {
    final transactions = store.transactions
        .where((transaction) => transaction.itemId == _item.id)
        .toList();

    transactions.sort(
      (left, right) => right.createdAt.compareTo(left.createdAt),
    );
    return transactions.take(5).toList();
  }

  String? _checkedOutPerson(AppStore store) {
    for (final transaction in _recentTransactions(store)) {
      if (transaction.transactionType == InventoryTransactionType.checkout) {
        final personId = transaction.assignedToPersonId;
        if (personId == null) {
          return 'assigned person';
        }

        return _personById(store, personId)?.displayName ?? 'assigned person';
      }

      if (transaction.transactionType == InventoryTransactionType.returnItem ||
          transaction.transactionType == InventoryTransactionType.markLost ||
          transaction.transactionType == InventoryTransactionType.markDamaged) {
        return null;
      }
    }

    return null;
  }

  Person? _defaultPerson(AppStore store) {
    return store.people.isEmpty ? null : store.people.last;
  }

  Person? _personById(AppStore store, String personId) {
    for (final person in store.people) {
      if (person.id == personId) {
        return person;
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

  String _itemTypeLabel(ItemType type) {
    return switch (type) {
      ItemType.consumable => 'Consumable',
      ItemType.returnable => 'Returnable',
      ItemType.asset => 'Asset',
    };
  }
}

class _QuantityNotesDialog extends StatefulWidget {
  const _QuantityNotesDialog({
    required this.title,
    required this.quantityLabel,
    required this.initialQuantity,
    this.helperText,
  });

  final String title;
  final String quantityLabel;
  final double initialQuantity;
  final String? helperText;

  @override
  State<_QuantityNotesDialog> createState() => _QuantityNotesDialogState();
}

class _QuantityNotesDialogState extends State<_QuantityNotesDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: _formatQuantity(widget.initialQuantity),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: widget.quantityLabel,
                  helperText: widget.helperText,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _quantityValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes optional'),
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
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }

  String? _quantityValidator(String? value) {
    final quantity = double.tryParse(value?.trim() ?? '');

    if (quantity == null) {
      return 'Enter a valid number';
    }

    if (quantity < 0) {
      return 'Enter zero or greater';
    }

    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      _QuantityNotesResult(
        quantity: double.parse(_quantityController.text.trim()),
        notes: _emptyToNull(_notesController.text),
      ),
    );
  }
}

class _TransferDialog extends StatefulWidget {
  const _TransferDialog({required this.currentLocationId, required this.store});

  final String currentLocationId;
  final AppStore store;

  @override
  State<_TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<_TransferDialog> {
  final _notesController = TextEditingController();
  late String _toLocationId;

  @override
  void initState() {
    super.initState();
    _toLocationId = widget.store.locations
        .firstWhere(
          (location) => location.id != widget.currentLocationId,
          orElse: () => widget.store.locations.first,
        )
        .id;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fromLocation = widget.store.locations.firstWhere(
      (location) => location.id == widget.currentLocationId,
      orElse: () => widget.store.locations.first,
    );

    return AlertDialog(
      title: const Text('Transfer Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailRow(label: 'From', value: fromLocation.name),
            DropdownButtonFormField<String>(
              initialValue: _toLocationId,
              decoration: const InputDecoration(labelText: 'To location'),
              items: widget.store.locations
                  .map(
                    (location) => DropdownMenuItem(
                      value: location.id,
                      child: Text(location.name),
                    ),
                  )
                  .toList(),
              onChanged: (locationId) {
                if (locationId == null) {
                  return;
                }

                setState(() {
                  _toLocationId = locationId;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes optional'),
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
            Navigator.of(context).pop(
              _TransferResult(
                toLocationId: _toLocationId,
                notes: _emptyToNull(_notesController.text),
              ),
            );
          },
          child: const Text('Transfer'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5C6672),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF17212F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  final InventoryTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final quantityText = _formatQuantity(transaction.quantityDelta);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_transactionLabel(transaction.transactionType)} ($quantityText)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF17212F),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            transaction.notes?.isEmpty ?? true
                ? _formatDate(transaction.createdAt)
                : '${_formatDate(transaction.createdAt)} - ${transaction.notes}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF5C6672)),
          ),
        ],
      ),
    );
  }

  String _transactionLabel(InventoryTransactionType type) {
    return switch (type) {
      InventoryTransactionType.receive => 'Receive',
      InventoryTransactionType.issue => 'Issue',
      InventoryTransactionType.checkout => 'Check Out',
      InventoryTransactionType.returnItem => 'Return',
      InventoryTransactionType.transfer => 'Transfer',
      InventoryTransactionType.adjustment => 'Adjust',
      InventoryTransactionType.markLost => 'Lost',
      InventoryTransactionType.markDamaged => 'Lost/Damaged',
      InventoryTransactionType.cycleCountAdjustment => 'Cycle Count',
    };
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
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

class _QuantityNotesResult {
  const _QuantityNotesResult({required this.quantity, required this.notes});

  final double quantity;
  final String? notes;
}

class _TransferResult {
  const _TransferResult({required this.toLocationId, required this.notes});

  final String toLocationId;
  final String? notes;
}

String? _emptyToNull(String value) {
  final trimmedValue = value.trim();
  return trimmedValue.isEmpty ? null : trimmedValue;
}

String _formatDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}

String _formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toStringAsFixed(0);
  }

  return quantity.toStringAsFixed(2);
}
