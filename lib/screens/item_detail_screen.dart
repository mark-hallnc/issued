import 'package:flutter/material.dart';

import '../core/models/models.dart';
import '../core/sample_data.dart';

class ItemDetailScreen extends StatelessWidget {
  const ItemDetailScreen({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final unit = _unitById(item.unitOfMeasureId);
    final location = _locationById(item.locationId);
    final showReturnableActions =
        item.itemType == ItemType.returnable || item.itemType == ItemType.asset;

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
                    item.name,
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
                      _InfoPill(label: _itemTypeLabel(item.itemType)),
                      _InfoPill(label: item.isActive ? 'Active' : 'Inactive'),
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
                        '${_formatQuantity(item.quantityOnHand)} ${unit?.abbreviation ?? ''}',
                  ),
                  _DetailRow(
                    label: 'Minimum',
                    value:
                        '${_formatQuantity(item.minimumQuantity)} ${unit?.abbreviation ?? ''}',
                  ),
                  _DetailRow(
                    label: 'Location',
                    value: location?.name ?? 'Unknown location',
                  ),
                  _DetailRow(label: 'Category', value: item.category),
                  if (item.sku != null)
                    _DetailRow(label: 'SKU', value: item.sku!),
                  if (item.barcode != null)
                    _DetailRow(label: 'Barcode', value: item.barcode!),
                  if (item.supplier != null)
                    _DetailRow(label: 'Supplier', value: item.supplier!),
                  if (item.unitCost != null)
                    _DetailRow(
                      label: 'Unit cost',
                      value: '\$${item.unitCost!.toStringAsFixed(2)}',
                    ),
                  _DetailRow(
                    label: 'Status',
                    value: item.isActive ? 'Active' : 'Inactive',
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
                      _ActionButton(label: 'Issue', icon: Icons.call_made),
                      _ActionButton(label: 'Receive', icon: Icons.add_box),
                      _ActionButton(label: 'Transfer', icon: Icons.swap_horiz),
                      _ActionButton(label: 'Adjust', icon: Icons.tune),
                      if (showReturnableActions) ...[
                        _ActionButton(
                          label: 'Check Out',
                          icon: Icons.assignment_ind,
                        ),
                        _ActionButton(
                          label: 'Return',
                          icon: Icons.assignment_return,
                        ),
                        _ActionButton(
                          label: 'Mark Lost/Damaged',
                          icon: Icons.report_problem_outlined,
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
                  Text(
                    'Recent issue, receive, transfer, and adjustment activity will appear here.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5C6672),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  UnitOfMeasure? _unitById(String unitId) {
    for (final unit in sampleUnitsOfMeasure) {
      if (unit.id == unitId) {
        return unit;
      }
    }

    return null;
  }

  Location? _locationById(String locationId) {
    for (final location in sampleLocations) {
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

  String _formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toStringAsFixed(0);
    }

    return quantity.toStringAsFixed(2);
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$label action coming later')));
      },
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
