import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../core/app_store.dart';
import '../core/labels/label_service.dart';
import '../core/models/models.dart';

enum LabelCenterMode { items, locations, targets }

class LabelCenterScreen extends StatefulWidget {
  const LabelCenterScreen({
    super.key,
    this.initialMode = LabelCenterMode.items,
    this.initialItemIds = const {},
    this.initialLocationIds = const {},
  });

  final LabelCenterMode initialMode;
  final Set<String> initialItemIds;
  final Set<String> initialLocationIds;

  @override
  State<LabelCenterScreen> createState() => _LabelCenterScreenState();
}

class _LabelCenterScreenState extends State<LabelCenterScreen> {
  late LabelCenterMode _mode = widget.initialMode;
  late final Set<String> _selectedItemIds = Set.of(widget.initialItemIds);
  late final Set<String> _selectedLocationIds = Set.of(
    widget.initialLocationIds,
  );
  final Set<String> _selectedTargetIds = {};
  final _searchController = TextEditingController();
  LabelTemplate _template = LabelTemplate.small;
  int _copies = 1;
  AssignmentTargetType? _targetTypeFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final records = _selectedRecords(store);
    final pages = estimateLabelPages(
      recordCount: records.length,
      copies: _copies,
      template: _template,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Label Center')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<LabelCenterMode>(
            segments: [
              const ButtonSegment(
                value: LabelCenterMode.items,
                label: Text('Item Labels'),
                icon: Icon(Icons.inventory_2_outlined),
              ),
              const ButtonSegment(
                value: LabelCenterMode.locations,
                label: Text('Location Labels'),
                icon: Icon(Icons.location_on_outlined),
              ),
              if (store.assignmentTargets.isNotEmpty)
                const ButtonSegment(
                  value: LabelCenterMode.targets,
                  label: Text('Target Labels'),
                  icon: Icon(Icons.assignment_ind_outlined),
                ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) {
              setState(() => _mode = selection.first);
            },
          ),
          const SizedBox(height: 12),
          _TemplateAndCopies(
            template: _template,
            copies: _copies,
            onTemplateChanged: (value) => setState(() => _template = value),
            onCopiesChanged: (value) => setState(() => _copies = value),
          ),
          const SizedBox(height: 12),
          _QuickActions(
            mode: _mode,
            onSelectAll: () => _selectAll(store),
            onClear: () => setState(_clearCurrentSelection),
            onLowStock: _mode == LabelCenterMode.items
                ? () => _selectItems(store.getLowStockItems())
                : null,
            onCheckedOutCapable: _mode == LabelCenterMode.items
                ? () => _selectItems(
                    store.items.where(
                      (item) =>
                          item.isActive &&
                          (item.itemType == ItemType.returnable ||
                              item.itemType == ItemType.asset),
                    ),
                  )
                : null,
            onRecentlyAdded: _mode == LabelCenterMode.items
                ? () => _selectItems(_recentItems(store))
                : null,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_mode == LabelCenterMode.targets) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<AssignmentTargetType?>(
              initialValue: _targetTypeFilter,
              decoration: const InputDecoration(
                labelText: 'Target type',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('All targets')),
                for (final type in AssignmentTargetType.values)
                  DropdownMenuItem(
                    value: type,
                    child: Text(assignmentTargetTypeLabel(type)),
                  ),
              ],
              onChanged: (value) => setState(() => _targetTypeFilter = value),
            ),
          ],
          const SizedBox(height: 12),
          _SelectionList(
            mode: _mode,
            store: store,
            searchText: _searchController.text,
            targetTypeFilter: _targetTypeFilter,
            selectedItemIds: _selectedItemIds,
            selectedLocationIds: _selectedLocationIds,
            selectedTargetIds: _selectedTargetIds,
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 12),
          _PreviewCard(
            selectedCount: records.length,
            copies: _copies,
            totalLabels: records.length * _copies,
            templateName: labelTemplateSpec(_template).name,
            pages: pages,
            canGenerate: records.isNotEmpty,
            onGenerate: () => _generatePdf(store, records),
          ),
        ],
      ),
    );
  }

  void _selectAll(AppStore store) {
    setState(() {
      switch (_mode) {
        case LabelCenterMode.items:
          _selectedItemIds.addAll(
            store.items.where((item) => item.isActive).map((item) => item.id),
          );
        case LabelCenterMode.locations:
          _selectedLocationIds.addAll(
            store.locations
                .where((location) => location.isActive)
                .map((location) => location.id),
          );
        case LabelCenterMode.targets:
          _selectedTargetIds.addAll(
            store.assignmentTargets
                .where(
                  (target) =>
                      target.isActive &&
                      (_targetTypeFilter == null ||
                          target.targetType == _targetTypeFilter),
                )
                .map((target) => target.id),
          );
      }
    });
  }

  void _selectItems(Iterable<Item> items) {
    setState(() {
      _selectedItemIds.addAll(
        items.where((item) => item.isActive).map((item) => item.id),
      );
    });
  }

  void _clearCurrentSelection() {
    switch (_mode) {
      case LabelCenterMode.items:
        _selectedItemIds.clear();
      case LabelCenterMode.locations:
        _selectedLocationIds.clear();
      case LabelCenterMode.targets:
        _selectedTargetIds.clear();
    }
  }

  List<Item> _recentItems(AppStore store) {
    final items = store.items.where((item) => item.isActive).toList()
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return items.take(20).toList();
  }

  List<LabelRecord> _selectedRecords(AppStore store) {
    return switch (_mode) {
      LabelCenterMode.items =>
        store.items
            .where(
              (item) => item.isActive && _selectedItemIds.contains(item.id),
            )
            .map((item) => _itemRecord(store, item))
            .toList(),
      LabelCenterMode.locations =>
        store.locations
            .where(
              (location) =>
                  location.isActive &&
                  _selectedLocationIds.contains(location.id),
            )
            .map((location) => _locationRecord(store, location))
            .toList(),
      LabelCenterMode.targets =>
        store.assignmentTargets
            .where(
              (target) =>
                  target.isActive && _selectedTargetIds.contains(target.id),
            )
            .map((target) => _targetRecord(store, target))
            .toList(),
    };
  }

  Future<void> _generatePdf(AppStore store, List<LabelRecord> records) async {
    if (!store.permissions.canImportExport) {
      _showMessage('Your current role does not allow this action.');
      return;
    }
    if (!store.canExportLabel) {
      _showMessage('You have reached your label export limit for this plan.');
      return;
    }
    try {
      final name = labelBatchFileName(_fileTypeName);
      final didPrint = await Printing.layoutPdf(
        name: name,
        onLayout: (_) => buildLabelBatchPdf(
          records: records,
          template: _template,
          copies: _copies,
        ),
      );
      if (didPrint && mounted) {
        store.recordLabelExport();
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Could not generate label PDF.');
      }
    }
  }

  String get _fileTypeName {
    return switch (_mode) {
      LabelCenterMode.items => 'item',
      LabelCenterMode.locations => 'location',
      LabelCenterMode.targets => 'target',
    };
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TemplateAndCopies extends StatelessWidget {
  const _TemplateAndCopies({
    required this.template,
    required this.copies,
    required this.onTemplateChanged,
    required this.onCopiesChanged,
  });

  final LabelTemplate template;
  final int copies;
  final ValueChanged<LabelTemplate> onTemplateChanged;
  final ValueChanged<int> onCopiesChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<LabelTemplate>(
            initialValue: template,
            decoration: const InputDecoration(
              labelText: 'Template',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final spec in labelTemplates)
                DropdownMenuItem(
                  value: spec.template,
                  child: Text(spec.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                onTemplateChanged(value);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 106,
          child: DropdownButtonFormField<int>(
            initialValue: copies,
            decoration: const InputDecoration(
              labelText: 'Copies',
              border: OutlineInputBorder(),
            ),
            items: [
              for (var value = 1; value <= 10; value++)
                DropdownMenuItem(value: value, child: Text('$value')),
            ],
            onChanged: (value) {
              if (value != null) {
                onCopiesChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.mode,
    required this.onSelectAll,
    required this.onClear,
    this.onLowStock,
    this.onCheckedOutCapable,
    this.onRecentlyAdded,
  });

  final LabelCenterMode mode;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;
  final VoidCallback? onLowStock;
  final VoidCallback? onCheckedOutCapable;
  final VoidCallback? onRecentlyAdded;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ActionChip(label: const Text('Select all'), onPressed: onSelectAll),
        if (onLowStock != null)
          ActionChip(label: const Text('Low stock'), onPressed: onLowStock),
        if (onCheckedOutCapable != null)
          ActionChip(
            label: const Text('Assets/returnables'),
            onPressed: onCheckedOutCapable,
          ),
        if (onRecentlyAdded != null)
          ActionChip(
            label: const Text('Recently added'),
            onPressed: onRecentlyAdded,
          ),
        ActionChip(label: const Text('Clear'), onPressed: onClear),
      ],
    );
  }
}

class _SelectionList extends StatelessWidget {
  const _SelectionList({
    required this.mode,
    required this.store,
    required this.searchText,
    required this.targetTypeFilter,
    required this.selectedItemIds,
    required this.selectedLocationIds,
    required this.selectedTargetIds,
    required this.onChanged,
  });

  final LabelCenterMode mode;
  final AppStore store;
  final String searchText;
  final AssignmentTargetType? targetTypeFilter;
  final Set<String> selectedItemIds;
  final Set<String> selectedLocationIds;
  final Set<String> selectedTargetIds;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final query = searchText.trim().toLowerCase();
    final tiles = switch (mode) {
      LabelCenterMode.items => _itemTiles(query),
      LabelCenterMode.locations => _locationTiles(query),
      LabelCenterMode.targets => _targetTiles(query),
    };
    if (tiles.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No label records found.'),
        ),
      );
    }
    return Column(children: tiles.take(80).toList());
  }

  List<Widget> _itemTiles(String query) {
    final items = store.items.where((item) {
      if (!item.isActive) {
        return false;
      }
      final haystack = [
        item.name,
        item.category,
        item.sku,
        item.barcode,
        store.resolveLocationName(item.locationId),
      ].whereType<String>().join(' ').toLowerCase();
      return query.isEmpty || haystack.contains(query);
    }).toList()..sort((left, right) => left.name.compareTo(right.name));

    return [
      for (final item in items)
        CheckboxListTile(
          value: selectedItemIds.contains(item.id),
          title: Text(item.name),
          subtitle: Text(
            [
                  item.category,
                  store.resolveLocationName(item.locationId),
                  if ((item.sku ?? '').isNotEmpty) 'SKU ${item.sku}',
                ]
                .whereType<String>()
                .where((value) => value.isNotEmpty)
                .join(' - '),
          ),
          onChanged: (checked) {
            checked == true
                ? selectedItemIds.add(item.id)
                : selectedItemIds.remove(item.id);
            onChanged();
          },
        ),
    ];
  }

  List<Widget> _locationTiles(String query) {
    final locations = store.locations.where((location) {
      if (!location.isActive) {
        return false;
      }
      return query.isEmpty || location.name.toLowerCase().contains(query);
    }).toList()..sort((left, right) => left.name.compareTo(right.name));

    return [
      for (final location in locations)
        CheckboxListTile(
          value: selectedLocationIds.contains(location.id),
          title: Text(location.name),
          subtitle: Text(location.type),
          onChanged: (checked) {
            checked == true
                ? selectedLocationIds.add(location.id)
                : selectedLocationIds.remove(location.id);
            onChanged();
          },
        ),
    ];
  }

  List<Widget> _targetTiles(String query) {
    final targets = store.assignmentTargets.where((target) {
      if (!target.isActive) {
        return false;
      }
      if (targetTypeFilter != null && target.targetType != targetTypeFilter) {
        return false;
      }
      final haystack = [
        target.name,
        target.code,
        assignmentTargetTypeLabel(target.targetType),
      ].whereType<String>().join(' ').toLowerCase();
      return query.isEmpty || haystack.contains(query);
    }).toList()..sort((left, right) => left.name.compareTo(right.name));

    return [
      for (final target in targets)
        CheckboxListTile(
          value: selectedTargetIds.contains(target.id),
          title: Text(target.name),
          subtitle: Text(
            [
              assignmentTargetTypeLabel(target.targetType),
              if ((target.code ?? '').isNotEmpty) 'Code ${target.code}',
            ].join(' - '),
          ),
          onChanged: (checked) {
            checked == true
                ? selectedTargetIds.add(target.id)
                : selectedTargetIds.remove(target.id);
            onChanged();
          },
        ),
    ];
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.selectedCount,
    required this.copies,
    required this.totalLabels,
    required this.templateName,
    required this.pages,
    required this.canGenerate,
    required this.onGenerate,
  });

  final int selectedCount;
  final int copies;
  final int totalLabels;
  final String templateName;
  final int pages;
  final bool canGenerate;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Selected records: $selectedCount'),
            Text('Copies per record: $copies'),
            Text('Total labels: $totalLabels'),
            Text('Template: $templateName'),
            Text('Estimated pages: $pages'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: canGenerate ? onGenerate : null,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Generate PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

LabelRecord _itemRecord(AppStore store, Item item) {
  final unit = store.getStockUom(item);
  final locationName = store.resolveLocationName(item.locationId);
  return LabelRecord(
    title: item.name,
    subtitle: _itemTypeLabel(item.itemType),
    detail: locationName,
    footer: [
      if ((item.sku ?? '').trim().isNotEmpty) 'SKU: ${item.sku!.trim()}',
      if ((item.barcode ?? '').trim().isNotEmpty)
        'Barcode: ${item.barcode!.trim()}',
      if (unit != null) 'UOM: ${unit.abbreviation}',
    ].join('  '),
    payload: itemQrValue(item),
    kind: 'Item',
  );
}

LabelRecord _locationRecord(AppStore store, Location location) {
  return LabelRecord(
    title: store.resolveLocationPath(location.id),
    subtitle: location.type,
    footer: (location.code ?? '').trim().isEmpty
        ? null
        : 'Code: ${location.code}',
    payload: locationQrValue(location),
    kind: 'Location',
  );
}

LabelRecord _targetRecord(AppStore store, AssignmentTarget target) {
  return LabelRecord(
    title: target.name,
    subtitle: assignmentTargetTypeLabel(target.targetType),
    detail: store.resolveLocationName(target.locationId),
    footer: (target.code ?? '').trim().isEmpty ? null : 'Code: ${target.code}',
    payload: assignmentTargetQrValue(target),
    kind: 'Target',
  );
}

String _itemTypeLabel(ItemType type) {
  return switch (type) {
    ItemType.consumable => 'Consumable',
    ItemType.returnable => 'Returnable',
    ItemType.asset => 'Asset',
  };
}
