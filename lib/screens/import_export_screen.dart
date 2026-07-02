import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_store.dart';
import '../core/csv/inventory_csv_service.dart';
import '../core/models/models.dart';
import 'plan_screens.dart';

class ImportExportScreen extends StatelessWidget {
  const ImportExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import & Export')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Export',
            children: [
              _ActionTile(
                icon: Icons.inventory_2_outlined,
                title: 'Export Active Items',
                onTap: () => _shareCsv(
                  context,
                  filename: _datedFilename('issued_items'),
                  csvText: buildItemsCsv(
                    AppStoreScope.of(context),
                    includeArchived: false,
                  ),
                ),
              ),
              _ActionTile(
                icon: Icons.archive_outlined,
                title: 'Export All Items',
                onTap: () => _shareCsv(
                  context,
                  filename: _datedFilename('issued_items_all'),
                  csvText: buildItemsCsv(
                    AppStoreScope.of(context),
                    includeArchived: true,
                  ),
                ),
              ),
              _ActionTile(
                icon: Icons.history_outlined,
                title: 'Export Activity',
                onTap: () => _shareCsv(
                  context,
                  filename: _datedFilename('issued_activity'),
                  csvText: buildActivityCsv(AppStoreScope.of(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Import',
            children: [
              _ActionTile(
                icon: Icons.upload_file,
                title: 'Import Items from CSV',
                onTap: () => _startImport(context),
              ),
              _ActionTile(
                icon: Icons.description_outlined,
                title: 'Download Sample CSV Template',
                onTap: () => _shareCsv(
                  context,
                  filename: 'issued_import_template.csv',
                  csvText: buildImportTemplateCsv(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _startImport(BuildContext context) async {
    final store = AppStoreScope.of(context);
    if (!store.currentPlan.csvImportEnabled) {
      final action = await showPlanLimitDialog(
        context,
        title: 'CSV import needs an upgrade',
        message: 'CSV import is not included in the Free plan.',
        recommendedPlanCode: 'starter',
      );

      if (context.mounted && action == PlanLimitDialogAction.upgrade) {
        await openComparePlans(context, recommendedPlanCode: 'starter');
      }
      return;
    }

    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'Could not open the file picker.');
      }
      return;
    }

    if (result == null || result.files.isEmpty) {
      return;
    }

    final pickedFile = result.files.single;
    final bytes = pickedFile.bytes;
    if (bytes == null) {
      if (context.mounted) {
        _showMessage(context, 'Could not read that CSV file.');
      }
      return;
    }

    CsvImportPreview preview;
    try {
      preview = parseItemsCsv(utf8.decode(bytes, allowMalformed: true), store);
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'That file could not be parsed as CSV.');
      }
      return;
    }

    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ImportPreviewScreen(preview: preview),
      ),
    );
  }

  Future<void> _shareCsv(
    BuildContext context, {
    required String filename,
    required String csvText,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}${Platform.pathSeparator}$filename');
      await file.writeAsString(csvText, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv')],
          fileNameOverrides: [filename],
        ),
      );
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'Could not share the CSV file.');
      }
    }
  }

  String _datedFilename(String prefix) {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    return '${prefix}_$date.csv';
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class ImportPreviewScreen extends StatefulWidget {
  const ImportPreviewScreen({super.key, required this.preview});

  final CsvImportPreview preview;

  @override
  State<ImportPreviewScreen> createState() => _ImportPreviewScreenState();
}

class _ImportPreviewScreenState extends State<ImportPreviewScreen> {
  CsvDuplicateMode _duplicateMode = CsvDuplicateMode.skip;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    final preview = widget.preview;

    return Scaffold(
      appBar: AppBar(title: const Text('Import Preview')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed:
                preview.fatalError != null ||
                    preview.validRowCount == 0 ||
                    _isImporting
                ? null
                : _importRows,
            icon: const Icon(Icons.check),
            label: Text(_isImporting ? 'Importing...' : 'Import Items'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (preview.fatalError != null)
            _MessageCard(message: preview.fatalError!, isError: true)
          else ...[
            _SummaryCard(
              validRows: preview.validRowCount,
              issueRows: preview.issueRowCount,
            ),
            if (preview.validRowCount == 0) ...[
              const SizedBox(height: 12),
              const _MessageCard(
                message: 'No valid item rows are ready to import.',
                isError: true,
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Duplicate handling',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<CsvDuplicateMode>(
              initialValue: _duplicateMode,
              decoration: const InputDecoration(
                labelText: 'Duplicates',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: CsvDuplicateMode.skip,
                  child: Text('Skip duplicates'),
                ),
                DropdownMenuItem(
                  value: CsvDuplicateMode.update,
                  child: Text('Update existing items'),
                ),
                DropdownMenuItem(
                  value: CsvDuplicateMode.createNew,
                  child: Text('Import duplicates as new items'),
                ),
              ],
              onChanged: _setDuplicateMode,
            ),
            const SizedBox(height: 12),
            Text(
              'First 10 rows',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final row in preview.rows.take(10)) ...[
              _ImportRowTile(row: row),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }

  void _setDuplicateMode(CsvDuplicateMode? mode) {
    if (mode == null) {
      return;
    }

    setState(() {
      _duplicateMode = mode;
    });
  }

  Future<void> _importRows() async {
    final store = AppStoreScope.of(context);
    final newItemCount = newActiveItemCountForMode(
      widget.preview,
      _duplicateMode,
    );
    final remainingItemSlots =
        store.currentPlan.itemLimit - store.currentUsage.activeItemCount;
    if (newItemCount > remainingItemSlots) {
      await _showImportLimitDialog(
        title: 'Item limit reached',
        message:
            'This import would create $newItemCount active items, but your ${store.currentPlan.name} plan has $remainingItemSlots item slots available.',
        recommendedPlanCode: store
            .getLimitWarningForItems()
            ?.recommendedPlanCode,
      );
      return;
    }

    final newLocations = newLocationNamesForImport(widget.preview, store);
    final remainingLocationSlots =
        store.currentPlan.locationLimit - store.currentUsage.locationCount;
    if (newLocations.length > remainingLocationSlots) {
      await _showImportLimitDialog(
        title: 'Location limit reached',
        message:
            'This import would create ${newLocations.length} locations, but your ${store.currentPlan.name} plan has $remainingLocationSlots location slots available.',
        recommendedPlanCode: store
            .getLimitWarningForLocations()
            ?.recommendedPlanCode,
      );
      return;
    }

    setState(() {
      _isImporting = true;
    });

    final importedCount = _applyImport(store);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Imported $importedCount items from CSV.')),
    );
  }

  Future<void> _showImportLimitDialog({
    required String title,
    required String message,
    String? recommendedPlanCode,
  }) async {
    final action = await showPlanLimitDialog(
      context,
      title: title,
      message: message,
      recommendedPlanCode: recommendedPlanCode,
      showArchiveItems: true,
    );

    if (!mounted || action != PlanLimitDialogAction.upgrade) {
      return;
    }

    await openComparePlans(context, recommendedPlanCode: recommendedPlanCode);
  }

  int _applyImport(AppStore store) {
    var importedCount = 0;
    var index = 0;
    final now = DateTime.now();

    for (final row in widget.preview.rows) {
      if (!row.isValid) {
        continue;
      }

      final duplicate = _itemById(store, row.duplicateItemId);
      if (duplicate != null && _duplicateMode == CsvDuplicateMode.skip) {
        continue;
      }

      final unit = _resolveUnit(store, row, now, index);
      final location = _resolveLocation(store, row, now, index);

      if (duplicate != null && _duplicateMode == CsvDuplicateMode.update) {
        final updatedUnitId =
            row.unitOfMeasureName == null &&
                row.unitOfMeasureAbbreviation == null
            ? duplicate.unitOfMeasureId
            : unit.id;
        final updatedLocationId = row.locationName == null
            ? duplicate.locationId
            : location.id;
        final updatedItem = duplicate.copyWith(
          name: row.name,
          description: row.description ?? duplicate.description,
          itemType: row.itemType,
          category: row.category ?? duplicate.category,
          quantityOnHand: row.quantityProvided
              ? row.quantityOnHand
              : duplicate.quantityOnHand,
          minimumQuantity: row.minimumProvided
              ? row.minimumQuantity
              : duplicate.minimumQuantity,
          unitOfMeasureId: updatedUnitId,
          locationId: updatedLocationId,
          barcode: row.barcode ?? duplicate.barcode,
          sku: row.sku ?? duplicate.sku,
          supplier: row.supplier ?? duplicate.supplier,
          unitCost: row.unitCostProvided ? row.unitCost : duplicate.unitCost,
          allowFractionalQuantity: row.allowFractionalQuantityProvided
              ? row.allowFractionalQuantity
              : duplicate.allowFractionalQuantity,
          updatedAt: now,
        );
        store.updateItem(updatedItem);
        if (row.quantityProvided &&
            row.quantityOnHand != duplicate.quantityOnHand) {
          _addImportTransaction(
            store,
            item: updatedItem,
            quantity: row.quantityOnHand - duplicate.quantityOnHand,
            type: InventoryTransactionType.adjustment,
            now: now,
            index: index,
          );
        }
        importedCount++;
      } else {
        final item = Item(
          id: 'item-import-${now.microsecondsSinceEpoch}-$index',
          name: row.name,
          description: row.description ?? '',
          itemType: row.itemType,
          category: row.category ?? '',
          locationId: location.id,
          quantityOnHand: row.quantityOnHand,
          minimumQuantity: row.minimumQuantity,
          unitOfMeasureId: unit.id,
          barcode: row.barcode,
          sku: row.sku,
          supplier: row.supplier,
          unitCost: row.unitCost,
          photoPath: null,
          isActive: true,
          allowFractionalQuantity: row.allowFractionalQuantity,
          createdAt: now,
          updatedAt: now,
        );
        store.addItem(item);
        if (item.quantityOnHand != 0) {
          _addImportTransaction(
            store,
            item: item,
            quantity: item.quantityOnHand,
            type: InventoryTransactionType.receive,
            now: now,
            index: index,
          );
        }
        importedCount++;
      }

      index++;
    }

    return importedCount;
  }

  UnitOfMeasure _resolveUnit(
    AppStore store,
    CsvImportRow row,
    DateTime now,
    int index,
  ) {
    final matchingUnit = store.unitsOfMeasure.cast<UnitOfMeasure?>().firstWhere(
      (unit) {
        if (unit == null) {
          return false;
        }

        return _matches(row.unitOfMeasureName, unit.name) ||
            _matches(row.unitOfMeasureAbbreviation, unit.abbreviation);
      },
      orElse: () => null,
    );
    if (matchingUnit != null) {
      return matchingUnit;
    }

    final defaultUnit = store.unitsOfMeasure.cast<UnitOfMeasure?>().firstWhere(
      (unit) =>
          unit != null &&
          (_matches('Each', unit.name) || _matches('ea', unit.abbreviation)),
      orElse: () => null,
    );
    if (row.unitOfMeasureName == null &&
        row.unitOfMeasureAbbreviation == null &&
        defaultUnit != null) {
      return defaultUnit;
    }

    final name =
        row.unitOfMeasureName ?? row.unitOfMeasureAbbreviation ?? 'Each';
    final abbreviation =
        row.unitOfMeasureAbbreviation ?? row.unitOfMeasureName ?? 'ea';
    final unit = UnitOfMeasure(
      id: 'uom-import-${now.microsecondsSinceEpoch}-$index',
      name: name,
      abbreviation: abbreviation,
      allowsDecimal: row.allowFractionalQuantity,
      isActive: true,
    );
    store.addUnitOfMeasure(unit);
    return unit;
  }

  Location _resolveLocation(
    AppStore store,
    CsvImportRow row,
    DateTime now,
    int index,
  ) {
    final matchingLocation = store.locations.cast<Location?>().firstWhere(
      (location) =>
          location != null &&
          location.isActive &&
          _matches(row.locationName, location.name),
      orElse: () => null,
    );
    if (matchingLocation != null) {
      return matchingLocation;
    }

    final activeLocation = store.locations.cast<Location?>().firstWhere(
      (location) => location != null && location.isActive,
      orElse: () => null,
    );
    if (row.locationName == null && activeLocation != null) {
      return activeLocation;
    }

    final location = Location(
      id: 'loc-import-${now.microsecondsSinceEpoch}-$index',
      name: row.locationName ?? 'Imported',
      type: 'imported',
      parentLocationId: null,
      isActive: true,
    );
    store.addLocation(location);
    return location;
  }

  void _addImportTransaction(
    AppStore store, {
    required Item item,
    required double quantity,
    required InventoryTransactionType type,
    required DateTime now,
    required int index,
  }) {
    store.addTransaction(
      InventoryTransaction(
        id: 'txn-import-${now.microsecondsSinceEpoch}-$index-${item.id}',
        itemId: item.id,
        transactionType: type,
        quantityDelta: quantity,
        unitOfMeasureId: item.unitOfMeasureId,
        fromLocationId: null,
        toLocationId: item.locationId,
        assignedToPersonId: null,
        performedByUserId: store.users.isEmpty ? null : store.users.first.id,
        notes: 'Imported from CSV',
        createdAt: now,
      ),
    );
  }

  Item? _itemById(AppStore store, String? itemId) {
    if (itemId == null) {
      return null;
    }

    return store.items.cast<Item?>().firstWhere(
      (item) => item != null && item.id == itemId,
      orElse: () => null,
    );
  }

  bool _matches(String? left, String right) {
    return left != null &&
        left.trim().toLowerCase() == right.trim().toLowerCase();
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF17212F),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1E3A5F)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.validRows, required this.issueRows});

  final int validRows;
  final int issueRows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$validRows valid rows',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text('$issueRows rows have warnings or errors.'),
          ],
        ),
      ),
    );
  }
}

class _ImportRowTile extends StatelessWidget {
  const _ImportRowTile({required this.row});

  final CsvImportRow row;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(row.name.isEmpty ? 'Row ${row.rowNumber}' : row.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${row.itemType.name} - Qty ${row.quantityOnHand}'),
            for (final message in row.messages) Text(message),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isError ? const Color(0xFFFFF3E0) : null,
      child: Padding(padding: const EdgeInsets.all(16), child: Text(message)),
    );
  }
}
