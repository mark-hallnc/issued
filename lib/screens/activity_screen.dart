import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import 'item_detail_screen.dart';

enum ActivityFilter {
  all,
  receive,
  issue,
  checkout,
  returnItem,
  transfer,
  adjustments,
  lostDamaged,
  cycleCounts,
}

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, this.itemId});

  final String? itemId;

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final _searchController = TextEditingController();
  ActivityFilter _filter = ActivityFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final transactions = _filteredTransactions(store);

    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search activity',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter == ActivityFilter.all,
                  onSelected: () => _setFilter(ActivityFilter.all),
                ),
                _FilterChip(
                  label: 'Receive',
                  selected: _filter == ActivityFilter.receive,
                  onSelected: () => _setFilter(ActivityFilter.receive),
                ),
                _FilterChip(
                  label: 'Issue',
                  selected: _filter == ActivityFilter.issue,
                  onSelected: () => _setFilter(ActivityFilter.issue),
                ),
                _FilterChip(
                  label: 'Check Out',
                  selected: _filter == ActivityFilter.checkout,
                  onSelected: () => _setFilter(ActivityFilter.checkout),
                ),
                _FilterChip(
                  label: 'Return',
                  selected: _filter == ActivityFilter.returnItem,
                  onSelected: () => _setFilter(ActivityFilter.returnItem),
                ),
                _FilterChip(
                  label: 'Transfer',
                  selected: _filter == ActivityFilter.transfer,
                  onSelected: () => _setFilter(ActivityFilter.transfer),
                ),
                _FilterChip(
                  label: 'Adjustments',
                  selected: _filter == ActivityFilter.adjustments,
                  onSelected: () => _setFilter(ActivityFilter.adjustments),
                ),
                _FilterChip(
                  label: 'Lost/Damaged',
                  selected: _filter == ActivityFilter.lostDamaged,
                  onSelected: () => _setFilter(ActivityFilter.lostDamaged),
                ),
                _FilterChip(
                  label: 'Cycle Counts',
                  selected: _filter == ActivityFilter.cycleCounts,
                  onSelected: () => _setFilter(ActivityFilter.cycleCounts),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            const _ActivityEmptyState()
          else
            ..._groupedActivityCards(store, transactions),
        ],
      ),
    );
  }

  List<InventoryTransaction> _filteredTransactions(AppStore store) {
    final searchText = _searchController.text.trim().toLowerCase();
    final baseTransactions = widget.itemId == null
        ? store.recentTransactions(limit: store.transactions.length)
        : store.transactionsForItem(widget.itemId!);

    return baseTransactions.where((transaction) {
      if (!_matchesFilter(transaction)) {
        return false;
      }

      if (searchText.isEmpty) {
        return true;
      }

      final searchableText = [
        store.resolveItemName(transaction.itemId),
        transaction.notes,
        store.resolveAssignedTo(
          personId: transaction.assignedToPersonId,
          locationId: transaction.assignedToLocationId,
          targetId: transaction.assignedToTargetId,
          text: transaction.assignedToText,
        ),
        store.resolveLocationName(transaction.fromLocationId),
        store.resolveLocationName(transaction.toLocationId),
        store.resolveUserName(transaction.performedByUserId),
      ].whereType<String>().join(' ').toLowerCase();

      return searchableText.contains(searchText);
    }).toList();
  }

  bool _matchesFilter(InventoryTransaction transaction) {
    return switch (_filter) {
      ActivityFilter.all => true,
      ActivityFilter.receive =>
        transaction.transactionType == InventoryTransactionType.receive,
      ActivityFilter.issue =>
        transaction.transactionType == InventoryTransactionType.issue,
      ActivityFilter.checkout =>
        transaction.transactionType == InventoryTransactionType.checkout,
      ActivityFilter.returnItem =>
        transaction.transactionType == InventoryTransactionType.returnItem,
      ActivityFilter.transfer =>
        transaction.transactionType == InventoryTransactionType.transfer,
      ActivityFilter.adjustments =>
        transaction.transactionType == InventoryTransactionType.adjustment ||
            transaction.transactionType == InventoryTransactionType.correction,
      ActivityFilter.lostDamaged =>
        transaction.transactionType == InventoryTransactionType.markLost ||
            transaction.transactionType == InventoryTransactionType.markDamaged,
      ActivityFilter.cycleCounts =>
        transaction.transactionType ==
            InventoryTransactionType.cycleCountAdjustment,
    };
  }

  List<Widget> _groupedActivityCards(
    AppStore store,
    List<InventoryTransaction> transactions,
  ) {
    final widgets = <Widget>[];
    String? currentHeading;

    for (final transaction in transactions) {
      final heading = _dateHeading(transaction.createdAt);
      if (heading != currentHeading) {
        widgets.add(_DateHeading(label: heading));
        currentHeading = heading;
      }

      widgets.add(_ActivityCard(transaction: transaction, store: store));
      widgets.add(const SizedBox(height: 10));
    }

    return widgets;
  }

  void _setFilter(ActivityFilter filter) {
    setState(() {
      _filter = filter;
    });
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.transaction, required this.store});

  final InventoryTransaction transaction;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final itemName = store.resolveItemName(transaction.itemId);
    final unit = store.resolveUomAbbreviation(transaction.unitOfMeasureId);
    final quantity = _quantityText(transaction.quantityDelta, unit);
    final fromLocation = store.resolveLocationName(transaction.fromLocationId);
    final toLocation = store.resolveLocationName(transaction.toLocationId);
    final assignedTo = store.resolveAssignedTo(
      personId: transaction.assignedToPersonId,
      locationId: transaction.assignedToLocationId,
      targetId: transaction.assignedToTargetId,
      text: transaction.assignedToText,
    );
    final performedBy = store.resolveUserName(transaction.performedByUserId);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showActivityDetail(context, store, transaction),
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
                      _transactionLabel(transaction.transactionType),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF17212F),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    _formatTime(transaction.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF5C6672),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                itemName,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(quantity),
              if (fromLocation != null) Text('From: $fromLocation'),
              if (toLocation != null) Text('To: $toLocation'),
              if (assignedTo != null) Text('Assigned to: $assignedTo'),
              if (performedBy != null) Text('Performed by: $performedBy'),
              if (transaction.isReversed || transaction.isReversal) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    if (transaction.isReversed)
                      const Chip(label: Text('Reversed')),
                    if (transaction.isReversal)
                      const Chip(label: Text('Correction')),
                  ],
                ),
              ],
              if ((transaction.correctionReason ?? '').trim().isNotEmpty)
                Text('Correction Reason: ${transaction.correctionReason}'),
              if ((transaction.notes ?? '').trim().isNotEmpty)
                Text('Notes: ${transaction.notes}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityEmptyState extends StatelessWidget {
  const _ActivityEmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'No activity yet.',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Receipts, issues, checkouts, returns, adjustments, and cycle counts will appear here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateHeading extends StatelessWidget {
  const _DateHeading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: const Color(0xFF5C6672),
          fontWeight: FontWeight.w800,
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

void _showActivityDetail(
  BuildContext context,
  AppStore store,
  InventoryTransaction transaction,
) {
  final item = store.itemById(transaction.itemId);
  final reversal = store.getReversalForTransaction(transaction.id);
  final original = store.getOriginalTransactionForReversal(transaction.id);

  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(_transactionLabel(transaction.transactionType)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailLine(
                label: 'Item',
                value: store.resolveItemName(transaction.itemId),
              ),
              _DetailLine(
                label: 'Quantity',
                value: _quantityText(
                  transaction.quantityDelta,
                  store.resolveUomAbbreviation(transaction.unitOfMeasureId),
                ),
              ),
              _DetailLine(
                label: 'From',
                value: store.resolveLocationName(transaction.fromLocationId),
              ),
              _DetailLine(
                label: 'To',
                value: store.resolveLocationName(transaction.toLocationId),
              ),
              _DetailLine(
                label: 'Assigned To',
                value: store.resolveAssignedTo(
                  personId: transaction.assignedToPersonId,
                  locationId: transaction.assignedToLocationId,
                  targetId: transaction.assignedToTargetId,
                  text: transaction.assignedToText,
                ),
              ),
              _DetailLine(
                label: 'Performed by',
                value: store.resolveUserName(transaction.performedByUserId),
              ),
              _DetailLine(label: 'Notes', value: transaction.notes),
              _DetailLine(
                label: 'Correction Reason',
                value: transaction.correctionReason,
              ),
              _DetailLine(
                label: 'Reverses',
                value: transaction.reversesTransactionId,
              ),
              _DetailLine(
                label: 'Reversed By',
                value: transaction.reversedByTransactionId,
              ),
              _DetailLine(
                label: 'Corrected',
                value: transaction.correctedAt == null
                    ? null
                    : _formatDateTime(transaction.correctedAt!),
              ),
              _DetailLine(
                label: 'Created',
                value: _formatDateTime(transaction.createdAt),
              ),
              const SizedBox(height: 8),
              Text(
                transaction.id,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF5C6672)),
              ),
            ],
          ),
        ),
        actions: [
          if (original != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showActivityDetail(context, store, original);
              },
              child: const Text('View Original'),
            ),
          if (reversal != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showActivityDetail(context, store, reversal);
              },
              child: const Text('View Correction'),
            ),
          if (store.canReverseTransaction(transaction))
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showReverseTransactionDialog(context, store, transaction);
              },
              child: const Text('Reverse / Correct'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: item == null
                ? null
                : () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => ItemDetailScreen(item: item),
                      ),
                    );
                  },
            child: const Text('Open Item'),
          ),
        ],
      );
    },
  );
}

void _showReverseTransactionDialog(
  BuildContext context,
  AppStore store,
  InventoryTransaction transaction,
) {
  final reasonController = TextEditingController();
  String? errorText;

  showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Reverse Transaction'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_transactionLabel(transaction.transactionType)),
                  Text(store.resolveItemName(transaction.itemId)),
                  Text(
                    _quantityText(
                      transaction.quantityDelta,
                      store.resolveUomAbbreviation(transaction.unitOfMeasureId),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This will not delete history. It will create a correction transaction.',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _correctionPreview(store, transaction),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      labelText: 'Correction Reason',
                      errorText: errorText,
                    ),
                    minLines: 2,
                    maxLines: 4,
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
                  final reason = reasonController.text.trim();
                  if (reason.length < 3) {
                    setDialogState(() {
                      errorText = 'Enter a reason.';
                    });
                    return;
                  }
                  final result = store.reverseInventoryTransaction(
                    transaction.id,
                    reason,
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message ?? 'Correction created.'),
                    ),
                  );
                },
                child: const Text('Create Correction'),
              ),
            ],
          );
        },
      );
    },
  ).whenComplete(reasonController.dispose);
}

String _correctionPreview(AppStore store, InventoryTransaction transaction) {
  final unit = store.resolveUomAbbreviation(transaction.unitOfMeasureId);
  final quantity = _formatQuantity(transaction.quantityDelta.abs());
  switch (transaction.transactionType) {
    case InventoryTransactionType.receive:
      return '${store.resolveLocationName(transaction.toLocationId) ?? 'Destination'} will decrease by $quantity $unit.';
    case InventoryTransactionType.issue ||
        InventoryTransactionType.markLost ||
        InventoryTransactionType.markDamaged:
      return '${store.resolveLocationName(transaction.fromLocationId) ?? 'Source'} will increase by $quantity $unit.';
    case InventoryTransactionType.transfer:
      return '${store.resolveLocationName(transaction.toLocationId) ?? 'Destination'} will decrease by $quantity $unit. ${store.resolveLocationName(transaction.fromLocationId) ?? 'Source'} will increase by $quantity $unit.';
    case InventoryTransactionType.adjustment ||
        InventoryTransactionType.cycleCountAdjustment:
      if (transaction.quantityDelta > 0) {
        return '${store.resolveLocationName(transaction.toLocationId) ?? 'Location'} will decrease by $quantity $unit.';
      }
      return '${store.resolveLocationName(transaction.fromLocationId) ?? 'Location'} will increase by $quantity $unit.';
    case InventoryTransactionType.checkout ||
        InventoryTransactionType.returnItem:
      return 'Correct this from the checkout record.';
    case InventoryTransactionType.correction:
      return 'Correction transactions cannot be reversed.';
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF5C6672),
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(value!),
        ],
      ),
    );
  }
}

String _transactionLabel(InventoryTransactionType type) {
  return switch (type) {
    InventoryTransactionType.receive => 'Received',
    InventoryTransactionType.issue => 'Issued',
    InventoryTransactionType.checkout => 'Checked Out',
    InventoryTransactionType.returnItem => 'Returned',
    InventoryTransactionType.transfer => 'Transferred',
    InventoryTransactionType.adjustment => 'Adjusted',
    InventoryTransactionType.markLost => 'Marked Lost',
    InventoryTransactionType.markDamaged => 'Marked Damaged',
    InventoryTransactionType.cycleCountAdjustment => 'Cycle Count Adjustment',
    InventoryTransactionType.correction => 'Correction',
  };
}

String _quantityText(double quantity, String unit) {
  return '${_formatQuantity(quantity)} $unit'.trim();
}

String _formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toStringAsFixed(0);
  }

  return quantity.toStringAsFixed(2);
}

String _dateHeading(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final transactionDate = DateTime(date.year, date.month, date.day);
  final yesterday = today.subtract(const Duration(days: 1));

  if (transactionDate == today) {
    return 'Today';
  }
  if (transactionDate == yesterday) {
    return 'Yesterday';
  }

  return _formatDate(date);
}

String _formatDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}

String _formatTime(DateTime date) {
  final hour = date.hour == 0
      ? 12
      : date.hour > 12
      ? date.hour - 12
      : date.hour;
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

String _formatDateTime(DateTime date) {
  return '${_formatDate(date)} ${_formatTime(date)}';
}
