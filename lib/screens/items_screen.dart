import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../core/app_store.dart';
import '../core/labels/label_service.dart';
import '../core/models/models.dart';
import '../widgets/issued_empty_state.dart';
import '../widgets/issued_page_header.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';
import 'plan_screens.dart';

enum _ItemFilter {
  all,
  lowStock,
  checkedOut,
  onReorder,
  consumable,
  returnable,
  asset,
  archived,
}

enum _ItemSort {
  defaultSort,
  nameAz,
  nameZa,
  quantityLowHigh,
  quantityHighLow,
  recentlyUpdated,
  lowStockFirst,
}

enum _StockStatusFilter { any, lowStock, inStock, zeroQuantity }

enum _ActiveStatusFilter { active, archived, all }

enum _PhotoFilter { any, hasPhoto, noPhoto }

enum _BarcodeFilter { any, hasBarcode, missingBarcode }

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key, this.initialLocationId});

  final String? initialLocationId;

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final _searchController = TextEditingController();
  _ItemFilter _selectedFilter = _ItemFilter.all;
  _ItemSort _sort = _ItemSort.defaultSort;
  ItemType? _advancedItemType;
  String? _locationId;
  String? _category;
  String? _supplier;
  _StockStatusFilter _stockStatus = _StockStatusFilter.any;
  _ActiveStatusFilter _activeStatus = _ActiveStatusFilter.active;
  _PhotoFilter _photoFilter = _PhotoFilter.any;
  _BarcodeFilter _barcodeFilter = _BarcodeFilter.any;

  @override
  void initState() {
    super.initState();
    _locationId = widget.initialLocationId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final permissions = store.permissions;
    final allItems = store.items;
    final visibleItems = _visibleItems(store);
    final exportableItems = visibleItems
        .where((item) => item.isActive)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const IssuedPageHeader(
          title: 'Items',
          subtitle: 'Manage inventory and stock levels',
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search items',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.close),
                  ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: permissions.canManageItems ? _openAddItem : null,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
              OutlinedButton.icon(
                onPressed: _openAdvancedFilters,
                icon: const Icon(Icons.filter_list),
                label: Text(_hasAdvancedFilters ? 'Filters On' : 'Filters'),
              ),
              PopupMenuButton<_ItemSort>(
                tooltip: 'Sort items',
                onSelected: (sort) => setState(() => _sort = sort),
                itemBuilder: (context) => [
                  for (final sort in _ItemSort.values)
                    PopupMenuItem<_ItemSort>(
                      value: sort,
                      child: Text(_sortLabel(sort)),
                    ),
                ],
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.sort),
                  label: Text(_sortLabel(_sort)),
                ),
              ),
              if (permissions.canImportExport)
                OutlinedButton.icon(
                  onPressed: exportableItems.isEmpty
                      ? null
                      : () => _exportLabels(store, exportableItems),
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('Export Labels'),
                ),
            ],
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
                label: 'Checked Out',
                selected: _selectedFilter == _ItemFilter.checkedOut,
                onSelected: () => _setFilter(_ItemFilter.checkedOut),
              ),
              _FilterChip(
                label: 'On Reorder',
                selected: _selectedFilter == _ItemFilter.onReorder,
                onSelected: () => _setFilter(_ItemFilter.onReorder),
              ),
              _FilterChip(
                label: 'Consumables',
                selected: _selectedFilter == _ItemFilter.consumable,
                onSelected: () => _setFilter(_ItemFilter.consumable),
              ),
              _FilterChip(
                label: 'Returnables',
                selected: _selectedFilter == _ItemFilter.returnable,
                onSelected: () => _setFilter(_ItemFilter.returnable),
              ),
              _FilterChip(
                label: 'Assets',
                selected: _selectedFilter == _ItemFilter.asset,
                onSelected: () => _setFilter(_ItemFilter.asset),
              ),
              _FilterChip(
                label: 'Archived',
                selected: _selectedFilter == _ItemFilter.archived,
                onSelected: () => _setFilter(_ItemFilter.archived),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ResultSummary(
          itemCount: visibleItems.length,
          lowStockCount: visibleItems.where(store.isItemLowStock).length,
          summaryParts: _summaryParts(store),
        ),
        const SizedBox(height: 12),
        if (allItems.isEmpty)
          IssuedEmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No items yet',
            message: 'Add your first item to start tracking inventory.',
            actionLabel: permissions.canManageItems ? 'Add item' : null,
            onAction: permissions.canManageItems ? _openAddItem : null,
          )
        else if (visibleItems.isEmpty)
          const IssuedEmptyState(
            icon: Icons.search_off_outlined,
            title: 'No matching items',
            message: 'Try clearing search or filters.',
          )
        else
          for (final item in visibleItems) ...[
            _ItemCard(
              item: item,
              store: store,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }

  List<Item> _visibleItems(AppStore store) {
    final query = _searchController.text.trim().toLowerCase();
    final items = store.items.where((item) {
      return _matchesQuickFilter(store, item) &&
          _matchesAdvancedFilters(store, item) &&
          _matchesSearch(store, item, query);
    }).toList();

    _sortItems(store, items);
    return items;
  }

  bool _matchesQuickFilter(AppStore store, Item item) {
    return switch (_selectedFilter) {
      _ItemFilter.all => _matchesDefaultActiveStatus(item),
      _ItemFilter.lowStock =>
        _matchesDefaultActiveStatus(item) && store.isItemLowStock(item),
      _ItemFilter.checkedOut =>
        _matchesDefaultActiveStatus(item) && store.isItemCheckedOut(item.id),
      _ItemFilter.onReorder =>
        _matchesDefaultActiveStatus(item) &&
            store.isItemOnActiveReorder(item.id),
      _ItemFilter.consumable =>
        _matchesDefaultActiveStatus(item) &&
            item.itemType == ItemType.consumable,
      _ItemFilter.returnable =>
        _matchesDefaultActiveStatus(item) &&
            item.itemType == ItemType.returnable,
      _ItemFilter.asset =>
        _matchesDefaultActiveStatus(item) && item.itemType == ItemType.asset,
      _ItemFilter.archived => !item.isActive,
    };
  }

  bool _matchesDefaultActiveStatus(Item item) {
    if (_activeStatus == _ActiveStatusFilter.all) {
      return true;
    }
    if (_activeStatus == _ActiveStatusFilter.archived) {
      return !item.isActive;
    }
    return item.isActive;
  }

  bool _matchesAdvancedFilters(AppStore store, Item item) {
    if (_advancedItemType != null && item.itemType != _advancedItemType) {
      return false;
    }
    if (_locationId != null && !_itemHasLocation(store, item, _locationId!)) {
      return false;
    }
    if (_category != null && item.category != _category) {
      return false;
    }
    if (_supplier != null && item.supplier != _supplier) {
      return false;
    }

    final hasPhoto = (item.photoPath ?? '').trim().isNotEmpty;
    if (_photoFilter == _PhotoFilter.hasPhoto && !hasPhoto) {
      return false;
    }
    if (_photoFilter == _PhotoFilter.noPhoto && hasPhoto) {
      return false;
    }

    final hasBarcode = (item.barcode ?? '').trim().isNotEmpty;
    if (_barcodeFilter == _BarcodeFilter.hasBarcode && !hasBarcode) {
      return false;
    }
    if (_barcodeFilter == _BarcodeFilter.missingBarcode && hasBarcode) {
      return false;
    }

    return switch (_stockStatus) {
      _StockStatusFilter.any => true,
      _StockStatusFilter.lowStock => store.isItemLowStock(item),
      _StockStatusFilter.inStock => item.isActive && item.quantityOnHand > 0,
      _StockStatusFilter.zeroQuantity => item.quantityOnHand == 0,
    };
  }

  bool _matchesSearch(AppStore store, Item item, String query) {
    if (query.isEmpty) {
      return true;
    }

    final customFieldText = store.customFieldValues
        .where((value) => value.entityId == item.id)
        .map((value) {
          return [
            value.textValue,
            value.numberValue?.toString(),
            value.selectedOption,
            value.booleanValue == null
                ? null
                : value.booleanValue!
                ? 'yes'
                : 'no',
            value.dateValue?.toIso8601String(),
          ].whereType<String>().join(' ');
        })
        .join(' ');

    final searchableText = [
      item.name,
      item.description,
      item.category,
      item.sku,
      item.barcode,
      item.supplier,
      _itemLocationSearchText(store, item),
      store.resolveUomAbbreviation(item.unitOfMeasureId),
      _unitName(store, item.unitOfMeasureId),
      _itemTypeLabel(item.itemType),
      customFieldText,
    ].whereType<String>().join(' ').toLowerCase();

    return searchableText.contains(query);
  }

  void _sortItems(AppStore store, List<Item> items) {
    int activeLowName(Item left, Item right) {
      final activeCompare = _boolRank(
        right.isActive,
      ).compareTo(_boolRank(left.isActive));
      if (activeCompare != 0) {
        return activeCompare;
      }

      final lowCompare = _boolRank(
        store.isItemLowStock(right),
      ).compareTo(_boolRank(store.isItemLowStock(left)));
      if (lowCompare != 0) {
        return lowCompare;
      }

      return left.name.toLowerCase().compareTo(right.name.toLowerCase());
    }

    items.sort((left, right) {
      return switch (_sort) {
        _ItemSort.defaultSort => activeLowName(left, right),
        _ItemSort.nameAz => left.name.toLowerCase().compareTo(
          right.name.toLowerCase(),
        ),
        _ItemSort.nameZa => right.name.toLowerCase().compareTo(
          left.name.toLowerCase(),
        ),
        _ItemSort.quantityLowHigh => left.quantityOnHand.compareTo(
          right.quantityOnHand,
        ),
        _ItemSort.quantityHighLow => right.quantityOnHand.compareTo(
          left.quantityOnHand,
        ),
        _ItemSort.recentlyUpdated => right.updatedAt.compareTo(left.updatedAt),
        _ItemSort.lowStockFirst => _boolRank(
          store.isItemLowStock(right),
        ).compareTo(_boolRank(store.isItemLowStock(left))),
      };
    });
  }

  int _boolRank(bool value) {
    return value ? 1 : 0;
  }

  List<String> _summaryParts(AppStore store) {
    final parts = <String>[];
    if (_activeStatus == _ActiveStatusFilter.archived ||
        _selectedFilter == _ItemFilter.archived) {
      parts.add('Showing archived items');
    }
    if (_locationId != null) {
      parts.add('Filtered by ${store.resolveLocationName(_locationId)}');
    }
    if (_category != null) {
      parts.add('Category $_category');
    }
    if (_supplier != null) {
      parts.add('Supplier $_supplier');
    }
    return parts;
  }

  bool get _hasAdvancedFilters {
    return _advancedItemType != null ||
        _locationId != null ||
        _category != null ||
        _supplier != null ||
        _stockStatus != _StockStatusFilter.any ||
        _activeStatus != _ActiveStatusFilter.active ||
        _photoFilter != _PhotoFilter.any ||
        _barcodeFilter != _BarcodeFilter.any;
  }

  void _setFilter(_ItemFilter filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == _ItemFilter.archived) {
        _activeStatus = _ActiveStatusFilter.archived;
      } else if (_activeStatus == _ActiveStatusFilter.archived) {
        _activeStatus = _ActiveStatusFilter.active;
      }
    });
  }

  Future<void> _openAdvancedFilters() async {
    final store = AppStoreScope.of(context);
    final result = await showModalBottomSheet<_AdvancedFilterResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AdvancedFilterSheet(
        store: store,
        itemType: _advancedItemType,
        locationId: _locationId,
        category: _category,
        supplier: _supplier,
        stockStatus: _stockStatus,
        activeStatus: _activeStatus,
        photoFilter: _photoFilter,
        barcodeFilter: _barcodeFilter,
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _advancedItemType = result.itemType;
      _locationId = result.locationId;
      _category = result.category;
      _supplier = result.supplier;
      _stockStatus = result.stockStatus;
      _activeStatus = result.activeStatus;
      _photoFilter = result.photoFilter;
      _barcodeFilter = result.barcodeFilter;
      _selectedFilter = result.activeStatus == _ActiveStatusFilter.archived
          ? _ItemFilter.archived
          : _selectedFilter == _ItemFilter.archived
          ? _ItemFilter.all
          : _selectedFilter;
    });
  }

  Future<void> _openAddItem() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canManageItems) {
      _showPermissionDenied();
      return;
    }

    if (!store.canAddItem) {
      await _showItemLimitReached(store);
      return;
    }

    final itemAdded = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (context) => const AddItemScreen()),
    );

    if (!mounted) {
      return;
    }

    if (itemAdded == true) {
      setState(() {
        _selectedFilter = _ItemFilter.all;
        _activeStatus = _ActiveStatusFilter.active;
      });
    }
  }

  Future<void> _exportLabels(AppStore store, List<Item> items) async {
    if (!store.permissions.canImportExport) {
      _showPermissionDenied();
      return;
    }

    if (!store.canExportLabel) {
      await _showLabelLimitReached(store);
      return;
    }

    final labels = items.map((item) => _labelItem(store, item)).toList();
    final didExport = await Printing.layoutPdf(
      name: 'issued_labels.pdf',
      onLayout: (_) => buildBatchLabelsPdf(labels),
    );

    if (didExport && mounted) {
      store.recordLabelExport();
    }
  }

  void _showPermissionDenied() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your current role does not allow this action.'),
      ),
    );
  }

  Future<void> _showItemLimitReached(AppStore store) async {
    final action = await showPlanLimitDialog(
      context,
      title: 'Item limit reached',
      message:
          'Your ${store.currentPlan.name} plan includes up to ${store.currentPlan.itemLimit} active items.',
      recommendedPlanCode: store.getLimitWarningForItems()?.recommendedPlanCode,
      showArchiveItems: true,
    );

    if (!mounted) {
      return;
    }

    switch (action) {
      case PlanLimitDialogAction.archiveItems:
        setState(() {
          _selectedFilter = _ItemFilter.archived;
          _activeStatus = _ActiveStatusFilter.archived;
        });
      case PlanLimitDialogAction.upgrade:
        await openComparePlans(
          context,
          recommendedPlanCode: store
              .getLimitWarningForItems()
              ?.recommendedPlanCode,
        );
      case PlanLimitDialogAction.cancel || null:
        return;
    }
  }

  Future<void> _showLabelLimitReached(AppStore store) async {
    final action = await showPlanLimitDialog(
      context,
      title: 'Label export limit reached',
      message:
          'Your ${store.currentPlan.name} plan includes ${store.currentPlan.labelExportLimit} label exports per month.',
      recommendedPlanCode: store
          .getLimitWarningForLabels()
          ?.recommendedPlanCode,
    );

    if (!mounted || action != PlanLimitDialogAction.upgrade) {
      return;
    }

    await openComparePlans(
      context,
      recommendedPlanCode: store
          .getLimitWarningForLabels()
          ?.recommendedPlanCode,
    );
  }

  LabelItem _labelItem(AppStore store, Item item) {
    final locationName = store.resolveLocationName(item.locationId);

    return LabelItem(
      item: item,
      codeValue: itemQrValue(item),
      itemType: _itemTypeLabel(item.itemType),
      quantityText:
          '${_formatQuantity(item.quantityOnHand)} ${store.resolveUomAbbreviation(item.unitOfMeasureId)}'
              .trim(),
      locationName: locationName,
    );
  }
}

class _AdvancedFilterResult {
  const _AdvancedFilterResult({
    required this.itemType,
    required this.locationId,
    required this.category,
    required this.supplier,
    required this.stockStatus,
    required this.activeStatus,
    required this.photoFilter,
    required this.barcodeFilter,
  });

  final ItemType? itemType;
  final String? locationId;
  final String? category;
  final String? supplier;
  final _StockStatusFilter stockStatus;
  final _ActiveStatusFilter activeStatus;
  final _PhotoFilter photoFilter;
  final _BarcodeFilter barcodeFilter;
}

class _AdvancedFilterSheet extends StatefulWidget {
  const _AdvancedFilterSheet({
    required this.store,
    required this.itemType,
    required this.locationId,
    required this.category,
    required this.supplier,
    required this.stockStatus,
    required this.activeStatus,
    required this.photoFilter,
    required this.barcodeFilter,
  });

  final AppStore store;
  final ItemType? itemType;
  final String? locationId;
  final String? category;
  final String? supplier;
  final _StockStatusFilter stockStatus;
  final _ActiveStatusFilter activeStatus;
  final _PhotoFilter photoFilter;
  final _BarcodeFilter barcodeFilter;

  @override
  State<_AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends State<_AdvancedFilterSheet> {
  late ItemType? _itemType = widget.itemType;
  late String? _locationId = widget.locationId;
  late String? _category = widget.category;
  late String? _supplier = widget.supplier;
  late _StockStatusFilter _stockStatus = widget.stockStatus;
  late _ActiveStatusFilter _activeStatus = widget.activeStatus;
  late _PhotoFilter _photoFilter = widget.photoFilter;
  late _BarcodeFilter _barcodeFilter = widget.barcodeFilter;

  @override
  Widget build(BuildContext context) {
    final categories =
        widget.store.items
            .map((item) => item.category.trim())
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final suppliers =
        widget.store.items
            .map((item) => item.supplier?.trim())
            .whereType<String>()
            .where((supplier) => supplier.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final locations =
        widget.store.locations.where((location) => location.isActive).toList()
          ..sort((left, right) => left.name.compareTo(right.name));

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filters',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              _Dropdown<ItemType?>(
                label: 'Item type',
                value: _itemType,
                items: [
                  const DropdownMenuItem<ItemType?>(
                    value: null,
                    child: Text('Any'),
                  ),
                  for (final type in ItemType.values)
                    DropdownMenuItem<ItemType?>(
                      value: type,
                      child: Text(_itemTypeLabel(type)),
                    ),
                ],
                onChanged: (value) => setState(() => _itemType = value),
              ),
              _Dropdown<String?>(
                label: 'Location',
                value: _locationId,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Any'),
                  ),
                  for (final location in locations)
                    DropdownMenuItem<String?>(
                      value: location.id,
                      child: Text(location.name),
                    ),
                ],
                onChanged: (value) => setState(() => _locationId = value),
              ),
              _Dropdown<String?>(
                label: 'Category',
                value: _category,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Any'),
                  ),
                  for (final category in categories)
                    DropdownMenuItem<String?>(
                      value: category,
                      child: Text(category),
                    ),
                ],
                onChanged: (value) => setState(() => _category = value),
              ),
              _Dropdown<String?>(
                label: 'Supplier',
                value: _supplier,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Any'),
                  ),
                  for (final supplier in suppliers)
                    DropdownMenuItem<String?>(
                      value: supplier,
                      child: Text(supplier),
                    ),
                ],
                onChanged: (value) => setState(() => _supplier = value),
              ),
              _Dropdown<_StockStatusFilter>(
                label: 'Stock status',
                value: _stockStatus,
                items: [
                  for (final value in _StockStatusFilter.values)
                    DropdownMenuItem<_StockStatusFilter>(
                      value: value,
                      child: Text(_stockStatusLabel(value)),
                    ),
                ],
                onChanged: (value) => setState(() => _stockStatus = value!),
              ),
              _Dropdown<_ActiveStatusFilter>(
                label: 'Active status',
                value: _activeStatus,
                items: [
                  for (final value in _ActiveStatusFilter.values)
                    DropdownMenuItem<_ActiveStatusFilter>(
                      value: value,
                      child: Text(_activeStatusLabel(value)),
                    ),
                ],
                onChanged: (value) => setState(() => _activeStatus = value!),
              ),
              _Dropdown<_PhotoFilter>(
                label: 'Has photo',
                value: _photoFilter,
                items: [
                  for (final value in _PhotoFilter.values)
                    DropdownMenuItem<_PhotoFilter>(
                      value: value,
                      child: Text(_photoFilterLabel(value)),
                    ),
                ],
                onChanged: (value) => setState(() => _photoFilter = value!),
              ),
              _Dropdown<_BarcodeFilter>(
                label: 'Has barcode',
                value: _barcodeFilter,
                items: [
                  for (final value in _BarcodeFilter.values)
                    DropdownMenuItem<_BarcodeFilter>(
                      value: value,
                      child: Text(_barcodeFilterLabel(value)),
                    ),
                ],
                onChanged: (value) => setState(() => _barcodeFilter = value!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clear,
                      child: const Text('Clear Filters'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _apply,
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clear() {
    Navigator.of(context).pop(
      const _AdvancedFilterResult(
        itemType: null,
        locationId: null,
        category: null,
        supplier: null,
        stockStatus: _StockStatusFilter.any,
        activeStatus: _ActiveStatusFilter.active,
        photoFilter: _PhotoFilter.any,
        barcodeFilter: _BarcodeFilter.any,
      ),
    );
  }

  void _apply() {
    Navigator.of(context).pop(
      _AdvancedFilterResult(
        itemType: _itemType,
        locationId: _locationId,
        category: _category,
        supplier: _supplier,
        stockStatus: _stockStatus,
        activeStatus: _activeStatus,
        photoFilter: _photoFilter,
        barcodeFilter: _barcodeFilter,
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary({
    required this.itemCount,
    required this.lowStockCount,
    required this.summaryParts,
  });

  final int itemCount;
  final int lowStockCount;
  final List<String> summaryParts;

  @override
  Widget build(BuildContext context) {
    final pieces = [
      '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
      if (lowStockCount > 0) '$lowStockCount low stock',
      ...summaryParts,
    ];

    return Text(
      pieces.join('  •  '),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: const Color(0xFF5C6672),
        fontWeight: FontWeight.w700,
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
    final isLowStock = store.isItemLowStock(item);
    final isCheckedOut = store.isItemCheckedOut(item.id);
    final isOnReorder = store.isItemOnActiveReorder(item.id);
    final unit = store.resolveUomAbbreviation(item.unitOfMeasureId);
    final location = _itemLocationSummary(store, item);

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
                  if (isLowStock) const _StatusBadge(label: 'Low'),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoPill(label: _itemTypeLabel(item.itemType)),
                  _InfoPill(
                    label: '${_formatQuantity(item.quantityOnHand)} $unit'
                        .trim(),
                  ),
                  _InfoPill(label: location),
                  if (item.category.trim().isNotEmpty)
                    _InfoPill(label: item.category),
                  if (isCheckedOut) const _StatusBadge(label: 'Checked Out'),
                  if (isOnReorder) const _StatusBadge(label: 'On Reorder'),
                  if (!item.isActive) const _StatusBadge(label: 'Archived'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

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
        label,
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

bool _itemHasLocation(AppStore store, Item item, String locationId) {
  if (item.locationId == locationId) {
    return true;
  }
  return store
      .itemBalancesForItem(item.id)
      .any((balance) => balance.locationId == locationId);
}

String _itemLocationSearchText(AppStore store, Item item) {
  final names = <String>{
    if (store.resolveLocationName(item.locationId) != null)
      store.resolveLocationName(item.locationId)!,
    for (final balance in store.itemBalancesForItem(item.id))
      if (store.resolveLocationName(balance.locationId) != null)
        store.resolveLocationName(balance.locationId)!,
  };
  return names.join(' ');
}

String _itemLocationSummary(AppStore store, Item item) {
  final positiveBalances = store
      .itemBalancesForItem(item.id)
      .where((balance) => balance.quantityOnHand > 0)
      .toList();
  if (positiveBalances.length == 1) {
    return store.resolveLocationName(positiveBalances.first.locationId) ??
        'Unknown location';
  }
  if (positiveBalances.length > 1) {
    return '${positiveBalances.length} locations';
  }
  return store.resolveLocationName(item.locationId) ?? 'Unknown location';
}

String _sortLabel(_ItemSort sort) {
  return switch (sort) {
    _ItemSort.defaultSort => 'Default',
    _ItemSort.nameAz => 'Name A-Z',
    _ItemSort.nameZa => 'Name Z-A',
    _ItemSort.quantityLowHigh => 'Quantity low to high',
    _ItemSort.quantityHighLow => 'Quantity high to low',
    _ItemSort.recentlyUpdated => 'Recently updated',
    _ItemSort.lowStockFirst => 'Low stock first',
  };
}

String _stockStatusLabel(_StockStatusFilter status) {
  return switch (status) {
    _StockStatusFilter.any => 'Any',
    _StockStatusFilter.lowStock => 'Low stock',
    _StockStatusFilter.inStock => 'In stock',
    _StockStatusFilter.zeroQuantity => 'Zero quantity',
  };
}

String _activeStatusLabel(_ActiveStatusFilter status) {
  return switch (status) {
    _ActiveStatusFilter.active => 'Active',
    _ActiveStatusFilter.archived => 'Archived',
    _ActiveStatusFilter.all => 'All',
  };
}

String _photoFilterLabel(_PhotoFilter filter) {
  return switch (filter) {
    _PhotoFilter.any => 'Any',
    _PhotoFilter.hasPhoto => 'Has photo',
    _PhotoFilter.noPhoto => 'No photo',
  };
}

String _barcodeFilterLabel(_BarcodeFilter filter) {
  return switch (filter) {
    _BarcodeFilter.any => 'Any',
    _BarcodeFilter.hasBarcode => 'Has barcode',
    _BarcodeFilter.missingBarcode => 'Missing barcode',
  };
}

String _itemTypeLabel(ItemType type) {
  return switch (type) {
    ItemType.consumable => 'Consumable',
    ItemType.returnable => 'Returnable',
    ItemType.asset => 'Asset',
  };
}

String? _unitName(AppStore store, String unitId) {
  for (final unit in store.unitsOfMeasure) {
    if (unit.id == unitId) {
      return unit.name;
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
