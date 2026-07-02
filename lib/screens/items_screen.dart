import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';

enum _ItemFilter { all, lowStock, consumable, returnable, asset }

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  _ItemFilter _selectedFilter = _ItemFilter.all;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final visibleItems = store.items.where(_matchesSelectedFilter).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          enabled: false,
          decoration: InputDecoration(
            hintText: 'Search items',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE1E6EC)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE1E6EC)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _openAddItem,
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                selected: _selectedFilter == _ItemFilter.all,
                onSelected: () => _setFilter(_ItemFilter.all),
              ),
              _FilterChip(
                label: 'Low Stock',
                selected: _selectedFilter == _ItemFilter.lowStock,
                onSelected: () => _setFilter(_ItemFilter.lowStock),
              ),
              _FilterChip(
                label: 'Consumable',
                selected: _selectedFilter == _ItemFilter.consumable,
                onSelected: () => _setFilter(_ItemFilter.consumable),
              ),
              _FilterChip(
                label: 'Returnable',
                selected: _selectedFilter == _ItemFilter.returnable,
                onSelected: () => _setFilter(_ItemFilter.returnable),
              ),
              _FilterChip(
                label: 'Asset',
                selected: _selectedFilter == _ItemFilter.asset,
                onSelected: () => _setFilter(_ItemFilter.asset),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final item in visibleItems) ...[
          _ItemCard(item: item, store: store, onChanged: () => setState(() {})),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  bool _matchesSelectedFilter(Item item) {
    return switch (_selectedFilter) {
      _ItemFilter.all => true,
      _ItemFilter.lowStock => item.quantityOnHand <= item.minimumQuantity,
      _ItemFilter.consumable => item.itemType == ItemType.consumable,
      _ItemFilter.returnable => item.itemType == ItemType.returnable,
      _ItemFilter.asset => item.itemType == ItemType.asset,
    };
  }

  void _setFilter(_ItemFilter filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  Future<void> _openAddItem() async {
    final itemAdded = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (context) => const AddItemScreen()),
    );

    if (!mounted) {
      return;
    }

    if (itemAdded == true) {
      setState(() {
        _selectedFilter = _ItemFilter.all;
      });
    }
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

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.store,
    required this.onChanged,
  });

  final Item item;
  final AppStore store;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isLowStock = item.quantityOnHand <= item.minimumQuantity;
    final unit = _unitById(item.unitOfMeasureId);
    final location = _locationById(item.locationId);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => ItemDetailScreen(item: item),
            ),
          );
          onChanged();
        },
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
                      item.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF17212F),
                      ),
                    ),
                  ),
                  if (isLowStock) const _LowStockBadge(),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoPill(label: _itemTypeLabel(item.itemType)),
                  _InfoPill(
                    label:
                        '${_formatQuantity(item.quantityOnHand)} ${unit?.abbreviation ?? ''}',
                  ),
                  _InfoPill(label: location?.name ?? 'Unknown location'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  UnitOfMeasure? _unitById(String unitId) {
    for (final unit in store.unitsOfMeasure) {
      if (unit.id == unitId) {
        return unit;
      }
    }

    return null;
  }

  Location? _locationById(String locationId) {
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

  String _formatQuantity(double quantity) {
    if (quantity == quantity.roundToDouble()) {
      return quantity.toStringAsFixed(0);
    }

    return quantity.toStringAsFixed(2);
  }
}

class _LowStockBadge extends StatelessWidget {
  const _LowStockBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFC46B)),
      ),
      child: Text(
        'Low',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFF7A4B00),
          fontWeight: FontWeight.w700,
        ),
      ),
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
