import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import 'item_detail_screen.dart';

enum _CheckedOutFilter {
  all,
  overdue,
  byPerson,
  byLocation,
  byTarget,
  assets,
  returnables,
}

class CheckedOutScreen extends StatefulWidget {
  const CheckedOutScreen({super.key});

  @override
  State<CheckedOutScreen> createState() => _CheckedOutScreenState();
}

class _CheckedOutScreenState extends State<CheckedOutScreen> {
  _CheckedOutFilter _filter = _CheckedOutFilter.all;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final records = store.openCheckoutRecords.where((record) {
      final item = _itemById(store, record.itemId);
      return switch (_filter) {
        _CheckedOutFilter.all => true,
        _CheckedOutFilter.overdue => _isOverdue(record),
        _CheckedOutFilter.byPerson => record.assignedToPersonId != null,
        _CheckedOutFilter.byLocation => record.assignedToLocationId != null,
        _CheckedOutFilter.byTarget => record.assignedToTargetId != null,
        _CheckedOutFilter.assets => item?.itemType == ItemType.asset,
        _CheckedOutFilter.returnables => item?.itemType == ItemType.returnable,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Checked Out')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter == _CheckedOutFilter.all,
                  onSelected: () => _setFilter(_CheckedOutFilter.all),
                ),
                _FilterChip(
                  label: 'Overdue',
                  selected: _filter == _CheckedOutFilter.overdue,
                  onSelected: () => _setFilter(_CheckedOutFilter.overdue),
                ),
                _FilterChip(
                  label: 'By Person',
                  selected: _filter == _CheckedOutFilter.byPerson,
                  onSelected: () => _setFilter(_CheckedOutFilter.byPerson),
                ),
                _FilterChip(
                  label: 'By Location',
                  selected: _filter == _CheckedOutFilter.byLocation,
                  onSelected: () => _setFilter(_CheckedOutFilter.byLocation),
                ),
                _FilterChip(
                  label: 'By Target',
                  selected: _filter == _CheckedOutFilter.byTarget,
                  onSelected: () => _setFilter(_CheckedOutFilter.byTarget),
                ),
                _FilterChip(
                  label: 'Assets',
                  selected: _filter == _CheckedOutFilter.assets,
                  onSelected: () => _setFilter(_CheckedOutFilter.assets),
                ),
                _FilterChip(
                  label: 'Returnables',
                  selected: _filter == _CheckedOutFilter.returnables,
                  onSelected: () => _setFilter(_CheckedOutFilter.returnables),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (records.isEmpty)
            const _EmptyState(message: 'Nothing is currently checked out.'),
          for (final record in records) ...[
            _CheckoutRecordCard(record: record),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  void _setFilter(_CheckedOutFilter filter) {
    setState(() {
      _filter = filter;
    });
  }
}

class _CheckoutRecordCard extends StatelessWidget {
  const _CheckoutRecordCard({required this.record});

  final CheckoutRecord record;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final item = _itemById(store, record.itemId);
    final unit = _unitById(store, record.unitOfMeasureId);
    final assignedTo = _assignedToText(store, record);
    final overdue = _isOverdue(record);
    final canReturn = store.permissions.canIssueItems;
    final canMarkLostDamaged = store.permissions.canAdjustQuantity;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item?.name ?? 'Unknown item',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF17212F),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (overdue)
                  const Chip(
                    label: Text('Overdue'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Quantity: ${_formatQuantity(record.quantity)} ${unit?.abbreviation ?? ''}',
            ),
            Text('Assigned to: $assignedTo'),
            Text('Checked out: ${_formatDate(record.checkedOutAt)}'),
            if (record.dueAt != null)
              Text('Due: ${_formatDate(record.dueAt!)}'),
            if ((record.notes ?? '').trim().isNotEmpty)
              Text('Notes: ${record.notes}'),
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
                FilledButton(
                  onPressed: canReturn
                      ? () => _showReturnDialog(context, record)
                      : null,
                  child: const Text('Return'),
                ),
                OutlinedButton(
                  onPressed: canMarkLostDamaged
                      ? () => _markLost(context, record.id)
                      : null,
                  child: const Text('Mark Lost'),
                ),
                OutlinedButton(
                  onPressed: canMarkLostDamaged
                      ? () => _markDamaged(context, record.id)
                      : null,
                  child: const Text('Mark Damaged'),
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

Future<void> _showReturnDialog(
  BuildContext context,
  CheckoutRecord record,
) async {
  final store = AppStoreScope.of(context);
  if (!store.permissions.canIssueItems) {
    _showPermissionDenied(context);
    return;
  }

  final result = await _showQuantityNotesDialog(
    context,
    title: 'Return Checked Out Item',
    quantityLabel: 'Quantity returned',
    initialQuantity: record.quantity,
  );
  if (result == null || !context.mounted) {
    return;
  }

  if (result.quantity != record.quantity) {
    _showMessage(context, 'Partial returns are not supported yet.');
    return;
  }

  Location? returnLocation = store.primaryLocationForItem(record.itemId);
  if (returnLocation == null) {
    for (final location in store.locations) {
      if (location.isActive) {
        returnLocation = location;
        break;
      }
    }
  }
  if (returnLocation == null) {
    _showMessage(context, 'Create a location before returning stock.');
    return;
  }

  final returned = store.returnCheckout(
    checkoutRecordId: record.id,
    returnedQuantity: result.quantity,
    returnToLocationId: returnLocation.id,
    notes: result.notes,
  );
  _showMessage(context, returned ? 'Item returned.' : 'Could not return item.');
}

Future<_QuantityNotesResult?> _showQuantityNotesDialog(
  BuildContext context, {
  required String title,
  required String quantityLabel,
  required double initialQuantity,
}) {
  final formKey = GlobalKey<FormState>();
  final quantityController = TextEditingController(
    text: _formatQuantity(initialQuantity),
  );
  final notesController = TextEditingController();

  return showDialog<_QuantityNotesResult>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(labelText: quantityLabel),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final quantity = double.tryParse(value?.trim() ?? '');
                  if (quantity == null || quantity <= 0) {
                    return 'Enter a quantity greater than 0.';
                  }

                  return null;
                },
              ),
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

              final notes = notesController.text.trim();
              Navigator.of(context).pop(
                _QuantityNotesResult(
                  quantity: double.parse(quantityController.text.trim()),
                  notes: notes.isEmpty ? null : notes,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  ).whenComplete(() {
    quantityController.dispose();
    notesController.dispose();
  });
}

void _markLost(BuildContext context, String checkoutRecordId) {
  final store = AppStoreScope.of(context);
  if (!store.permissions.canAdjustQuantity) {
    _showPermissionDenied(context);
    return;
  }

  _showMessage(
    context,
    store.markCheckoutLost(checkoutRecordId, null)
        ? 'Marked lost.'
        : 'Could not update this checkout.',
  );
}

void _markDamaged(BuildContext context, String checkoutRecordId) {
  final store = AppStoreScope.of(context);
  if (!store.permissions.canAdjustQuantity) {
    _showPermissionDenied(context);
    return;
  }

  _showMessage(
    context,
    store.markCheckoutDamaged(checkoutRecordId, null)
        ? 'Marked damaged.'
        : 'Could not update this checkout.',
  );
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

bool _isOverdue(CheckoutRecord record) {
  final dueAt = record.dueAt;
  if (dueAt == null) {
    return false;
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return dueAt.isBefore(today);
}

String _assignedToText(AppStore store, CheckoutRecord record) {
  final parts = <String>[];
  final personId = record.assignedToPersonId;
  if (personId != null) {
    parts.add(_personById(store, personId)?.displayName ?? 'Unknown person');
  }

  final locationId = record.assignedToLocationId;
  if (locationId != null) {
    parts.add(_locationById(store, locationId)?.name ?? 'Unknown location');
  }

  final targetId = record.assignedToTargetId;
  if (targetId != null) {
    parts.add(store.resolveAssignmentTargetName(targetId) ?? 'Unknown target');
  }

  final assignedText = record.assignedToText?.trim();
  if (assignedText != null && assignedText.isNotEmpty) {
    parts.add(assignedText);
  }

  return parts.isEmpty ? 'Unassigned' : parts.join(' / ');
}

Item? _itemById(AppStore store, String itemId) {
  for (final item in store.items) {
    if (item.id == itemId) {
      return item;
    }
  }

  return null;
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

String _formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toStringAsFixed(0);
  }

  return quantity.toStringAsFixed(2);
}

String _formatDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}
