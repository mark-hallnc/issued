import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_store.dart';
import '../core/backup/backup_service.dart';
import '../core/csv/inventory_csv_service.dart'
    hide CsvImportPreview, CsvImportRow, CsvDuplicateMode;
import '../core/import_export/csv_import_service.dart';
import '../core/models/models.dart';

class CsvImportScreen extends StatefulWidget {
  const CsvImportScreen({super.key});

  @override
  State<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends State<CsvImportScreen> {
  final _csvController = TextEditingController();
  final _service = const CsvImportService();
  var _createMissingLocations = true;
  var _createMissingUoms = true;
  var _updateExistingItems = true;
  var _importStartingQuantities = true;
  CsvImportPreview? _preview;
  var _isImporting = false;

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canImportExport) {
      return Scaffold(
        appBar: AppBar(title: const Text('Paste CSV Import')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Your current role does not allow this action.'),
            ),
          ),
        ),
      );
    }

    final preview = _preview;
    return Scaffold(
      appBar: AppBar(title: const Text('Paste CSV Import')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _IntroCard(
            onExportTemplate: _exportTemplate,
            onExportBackup: _exportBackup,
          ),
          const SizedBox(height: 12),
          _OptionsCard(
            createMissingLocations: _createMissingLocations,
            createMissingUoms: _createMissingUoms,
            updateExistingItems: _updateExistingItems,
            importStartingQuantities: _importStartingQuantities,
            onCreateMissingLocationsChanged: (value) =>
                _setOption(() => _createMissingLocations = value),
            onCreateMissingUomsChanged: (value) =>
                _setOption(() => _createMissingUoms = value),
            onUpdateExistingItemsChanged: (value) =>
                _setOption(() => _updateExistingItems = value),
            onImportStartingQuantitiesChanged: (value) =>
                _setOption(() => _importStartingQuantities = value),
          ),
          const SizedBox(height: 12),
          if (preview == null)
            _editCsvCard()
          else
            _previewCards(store, preview),
        ],
      ),
    );
  }

  Widget _editCsvCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _csvController,
              decoration: const InputDecoration(
                labelText: 'Paste CSV',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              minLines: 12,
              maxLines: 18,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clear,
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _loadPreview,
                    child: const Text('Load Preview'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewCards(AppStore store, CsvImportPreview preview) {
    if (preview.fatalError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MessageCard(message: preview.fatalError!, isError: true),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _backToEdit,
            child: const Text('Back/Edit CSV'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PreviewSummaryCard(preview: preview),
        if (preview.unknownHeaders.isNotEmpty) ...[
          const SizedBox(height: 12),
          _MessageCard(
            message:
                'Unknown columns ignored: ${preview.unknownHeaders.join(', ')}',
            isError: false,
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _backToEdit,
                child: const Text('Back/Edit CSV'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: preview.validCount == 0 || _isImporting
                    ? null
                    : () => _confirmImport(store),
                child: Text(
                  _isImporting ? 'Importing...' : 'Import Valid Rows',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final row in preview.rows) ...[
          _PreviewRowCard(row: row),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  void _setOption(VoidCallback update) {
    setState(() {
      update();
      _preview = null;
    });
  }

  void _loadPreview() {
    final store = AppStoreScope.of(context);
    setState(() {
      _preview = _service.preview(_csvController.text, store, _options);
    });
  }

  void _clear() {
    setState(() {
      _csvController.clear();
      _preview = null;
    });
  }

  void _backToEdit() {
    setState(() {
      _preview = null;
    });
  }

  CsvImportOptions get _options {
    return CsvImportOptions(
      createMissingLocations: _createMissingLocations,
      createMissingUoms: _createMissingUoms,
      updateExistingItems: _updateExistingItems,
      importStartingQuantities: _importStartingQuantities,
    );
  }

  Future<void> _confirmImport(AppStore store) async {
    final preview = _service.preview(_csvController.text, store, _options);
    setState(() {
      _preview = preview;
    });
    if (preview.fatalError != null || preview.validCount == 0) {
      return;
    }

    final limitMessage = _planLimitMessage(store, preview);
    if (limitMessage != null) {
      _showMessage(limitMessage);
      return;
    }

    final updateCount = preview.rows
        .where((row) => row.canImport && row.action == CsvImportAction.update)
        .length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import CSV'),
        content: Text(
          [
            'Import ${preview.validCount} valid rows? This may create or update items.',
            if (updateCount > 0) '$updateCount existing items will be updated.',
          ].join('\n\n'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isImporting = true;
    });
    final result = _applyImport(store, preview);
    if (!mounted) {
      return;
    }
    setState(() {
      _isImporting = false;
      _preview = null;
      _csvController.clear();
    });
    _showMessage('Imported ${result.importedRows} rows from CSV.');
  }

  _ImportResult _applyImport(AppStore store, CsvImportPreview preview) {
    var importedRows = 0;
    var sequence = 0;
    for (final row in preview.rows) {
      if (!row.canImport) {
        continue;
      }
      final imported = switch (row.action) {
        CsvImportAction.create => _createItem(store, row, sequence),
        CsvImportAction.update => _updateItem(store, row, sequence),
        CsvImportAction.skip => false,
      };
      if (imported) {
        importedRows++;
      }
      sequence++;
    }
    return _ImportResult(importedRows: importedRows);
  }

  bool _createItem(AppStore store, CsvImportRowPreview row, int sequence) {
    final now = DateTime.now();
    final parsed = row.parsedItem;
    final unit = _resolveUnit(store, parsed, sequence);
    final location = _resolveLocation(store, parsed.location, sequence);
    if (unit == null || location == null || parsed.name == null) {
      return false;
    }

    final balances = _balancesForImport(store, parsed, location);
    final initialQuantity = _importStartingQuantities
        ? balances.firstOrNull?.quantity ?? parsed.quantity ?? 0
        : 0.0;
    final item = Item(
      id: 'item-import-${now.microsecondsSinceEpoch}-$sequence',
      name: parsed.name!,
      description: parsed.description ?? '',
      itemType: parsed.itemType ?? ItemType.consumable,
      category: parsed.category ?? '',
      locationId: location.id,
      quantityOnHand: initialQuantity,
      minimumQuantity: parsed.minimumQuantity ?? 0,
      unitOfMeasureId: unit.id,
      purchaseUnitOfMeasureId: _resolvePurchaseUnitId(store, parsed, sequence),
      purchaseToStockConversionFactor: parsed.purchaseToStockConversionFactor,
      purchaseUnitLabel: parsed.purchaseUnitOfMeasure,
      barcode: parsed.barcode,
      sku: parsed.sku,
      supplier: parsed.supplier,
      unitCost: parsed.unitCost,
      photoPath: null,
      isActive: true,
      allowFractionalQuantity:
          parsed.allowFractionalQuantity ?? unit.allowsDecimal,
      createdAt: now,
      updatedAt: now,
    );

    final customValues = _customFieldValues(store, item, parsed);
    final addResult = store.addItemWithInitialBalance(
      item,
      location.id,
      initialTransactionNotes: 'Created by CSV import',
    );
    if (!addResult.success) {
      return false;
    }
    for (final value in customValues) {
      store.setCustomFieldValue(value);
    }
    if (_importStartingQuantities && balances.length > 1) {
      for (final balance in balances.skip(1)) {
        final balanceLocation = _resolveLocation(
          store,
          balance.locationName,
          sequence,
        );
        if (balanceLocation == null) {
          continue;
        }
        store.setItemLocationBalance(
          item.id,
          balanceLocation.id,
          balance.quantity,
        );
        _addImportTransaction(
          store,
          item: item.copyWith(quantityOnHand: balance.quantity),
          quantityDelta: balance.quantity,
          toLocationId: balanceLocation.id,
          notes: 'Created by CSV import',
          sequence: sequence,
        );
      }
    }
    return true;
  }

  bool _updateItem(AppStore store, CsvImportRowPreview row, int sequence) {
    final existing = store.itemById(row.existingItemId ?? '');
    if (existing == null) {
      return false;
    }
    final parsed = row.parsedItem;
    final unit = parsed.unitOfMeasure == null
        ? null
        : _resolveUnit(store, parsed, sequence);
    final location = parsed.location == null
        ? null
        : _resolveLocation(store, parsed.location, sequence);
    final purchaseUnitId = parsed.purchaseUnitOfMeasure == null
        ? existing.purchaseUnitOfMeasureId
        : _resolvePurchaseUnitId(store, parsed, sequence);
    final updated = existing.copyWith(
      name: parsed.name ?? existing.name,
      description: parsed.hasColumn('description')
          ? parsed.description ?? ''
          : existing.description,
      itemType: parsed.itemType ?? existing.itemType,
      category: parsed.hasColumn('category')
          ? parsed.category ?? ''
          : existing.category,
      minimumQuantity: parsed.minimumQuantity ?? existing.minimumQuantity,
      unitOfMeasureId: unit?.id ?? existing.unitOfMeasureId,
      locationId: location?.id ?? existing.locationId,
      purchaseUnitOfMeasureId: purchaseUnitId,
      purchaseToStockConversionFactor:
          parsed.purchaseToStockConversionFactor ??
          existing.purchaseToStockConversionFactor,
      purchaseUnitLabel:
          parsed.purchaseUnitOfMeasure ?? existing.purchaseUnitLabel,
      barcode: parsed.hasColumn('barcode') ? parsed.barcode : existing.barcode,
      sku: parsed.hasColumn('sku') ? parsed.sku : existing.sku,
      supplier: parsed.hasColumn('supplier')
          ? parsed.supplier
          : existing.supplier,
      unitCost: parsed.hasColumn('unit_cost')
          ? parsed.unitCost
          : existing.unitCost,
      allowFractionalQuantity:
          parsed.allowFractionalQuantity ?? existing.allowFractionalQuantity,
      updatedAt: DateTime.now(),
    );
    final saved = store.updateItemDetails(
      updated,
      customFieldValues: _customFieldValues(store, updated, parsed),
      activityNote: 'Updated by CSV import',
    );
    if (!saved) {
      return false;
    }
    if (_importStartingQuantities) {
      _applyQuantityUpdates(store, updated, parsed, sequence);
    }
    return true;
  }

  void _applyQuantityUpdates(
    AppStore store,
    Item item,
    CsvParsedItem parsed,
    int sequence,
  ) {
    final balances = _balancesForImport(
      store,
      parsed,
      findImportLocation(store, parsed.location) ??
          store.primaryLocationForItem(item.id) ??
          store.locations.first,
    );
    if (balances.isEmpty && parsed.quantity == null) {
      return;
    }
    for (final balance in balances) {
      final location = _resolveLocation(store, balance.locationName, sequence);
      if (location == null) {
        continue;
      }
      final oldQuantity = _quantityAt(store, item.id, location.id);
      if (oldQuantity == balance.quantity) {
        continue;
      }
      store.setItemLocationBalance(item.id, location.id, balance.quantity);
      _addImportTransaction(
        store,
        item: item,
        quantityDelta: balance.quantity - oldQuantity,
        toLocationId: location.id,
        notes:
            'CSV import quantity set from ${_formatQuantity(oldQuantity)} to ${_formatQuantity(balance.quantity)}',
        sequence: sequence,
      );
    }
  }

  List<CsvLocationBalance> _balancesForImport(
    AppStore store,
    CsvParsedItem parsed,
    Location fallbackLocation,
  ) {
    if (parsed.locationBalances.isNotEmpty) {
      return parsed.locationBalances;
    }
    if (parsed.quantity == null) {
      return const [];
    }
    return [
      CsvLocationBalance(
        locationName: parsed.location ?? fallbackLocation.name,
        quantity: parsed.quantity!,
      ),
    ];
  }

  UnitOfMeasure? _resolveUnit(
    AppStore store,
    CsvParsedItem parsed,
    int sequence,
  ) {
    final existing = findImportUnit(store, parsed.unitOfMeasure);
    if (existing != null) {
      return existing;
    }
    if (parsed.unitOfMeasure == null) {
      return findImportUnit(store, 'Each') ?? store.unitsOfMeasure.firstOrNull;
    }
    if (!_createMissingUoms) {
      return null;
    }
    final name = parsed.unitOfMeasure!;
    final allowsDecimal =
        parsed.allowFractionalQuantity == true ||
        (parsed.quantity != null &&
            parsed.quantity != parsed.quantity!.roundToDouble());
    final unit = UnitOfMeasure(
      id: 'uom-import-${DateTime.now().microsecondsSinceEpoch}-$sequence',
      name: name,
      abbreviation: name,
      allowsDecimal: allowsDecimal,
      isActive: true,
    );
    return store.addUnitOfMeasure(unit).success ? unit : null;
  }

  String? _resolvePurchaseUnitId(
    AppStore store,
    CsvParsedItem parsed,
    int sequence,
  ) {
    final value = parsed.purchaseUnitOfMeasure;
    if (value == null) {
      return null;
    }
    final existing = findImportUnit(store, value);
    if (existing != null) {
      return existing.id;
    }
    if (!_createMissingUoms) {
      return null;
    }
    final unit = UnitOfMeasure(
      id: 'uom-import-purchase-${DateTime.now().microsecondsSinceEpoch}-$sequence',
      name: value,
      abbreviation: value,
      allowsDecimal: true,
      isActive: true,
    );
    return store.addUnitOfMeasure(unit).success ? unit.id : null;
  }

  Location? _resolveLocation(AppStore store, String? name, int sequence) {
    final existing = findImportLocation(store, name);
    if (existing != null) {
      return existing;
    }
    if (name == null || name.trim().isEmpty) {
      return store.locations.where((location) => location.isActive).firstOrNull;
    }
    if (!_createMissingLocations) {
      return null;
    }
    final location = Location(
      id: 'loc-import-${DateTime.now().microsecondsSinceEpoch}-$sequence',
      name: name,
      type: 'Imported',
      parentLocationId: null,
      isActive: true,
    );
    return store.addLocation(location).success ? location : null;
  }

  List<CustomFieldValue> _customFieldValues(
    AppStore store,
    Item item,
    CsvParsedItem parsed,
  ) {
    final values = <CustomFieldValue>[];
    for (final field in store.activeCustomFieldsForItem(item)) {
      final raw = parsed.customValues['custom_${csvImportSlug(field.name)}'];
      if (raw == null || raw.trim().isEmpty) {
        continue;
      }
      final value = buildCustomFieldValue(
        field: field,
        itemId: item.id,
        rawValue: raw,
      );
      if (value != null) {
        values.add(value);
      }
    }
    return values;
  }

  double _quantityAt(AppStore store, String itemId, String locationId) {
    for (final balance in store.itemBalancesForItem(itemId)) {
      if (balance.locationId == locationId) {
        return balance.quantityOnHand;
      }
    }
    return 0;
  }

  void _addImportTransaction(
    AppStore store, {
    required Item item,
    required double quantityDelta,
    required String toLocationId,
    required String notes,
    required int sequence,
  }) {
    store.addTransaction(
      InventoryTransaction(
        id: 'txn-csv-import-${DateTime.now().microsecondsSinceEpoch}-$sequence',
        itemId: item.id,
        transactionType: quantityDelta >= 0
            ? InventoryTransactionType.receive
            : InventoryTransactionType.adjustment,
        quantityDelta: quantityDelta,
        unitOfMeasureId: item.unitOfMeasureId,
        fromLocationId: null,
        toLocationId: toLocationId,
        assignedToPersonId: null,
        assignedToTargetId: null,
        assignedToText: null,
        performedByUserId: store.currentUser?.id,
        notes: notes,
        createdAt: DateTime.now(),
      ),
    );
  }

  String? _planLimitMessage(AppStore store, CsvImportPreview preview) {
    final createCount = preview.rows
        .where((row) => row.canImport && row.action == CsvImportAction.create)
        .length;
    final remainingItems =
        store.currentPlan.itemLimit - store.currentUsage.activeItemCount;
    if (createCount > remainingItems) {
      return 'This import would exceed your current item limit.';
    }
    final newLocations = <String>{};
    for (final row in preview.rows.where((row) => row.canImport)) {
      for (final name in [
        row.parsedItem.location,
        for (final balance in row.parsedItem.locationBalances)
          balance.locationName,
      ].whereType<String>()) {
        if (findImportLocation(store, name) == null) {
          newLocations.add(name.trim().toLowerCase());
        }
      }
    }
    final remainingLocations =
        store.currentPlan.locationLimit - store.currentUsage.locationCount;
    if (newLocations.length > remainingLocations) {
      return 'This import would exceed your current location limit.';
    }
    return null;
  }

  Future<void> _exportTemplate() async {
    await _shareTextFile(
      filename: 'issued_import_template.csv',
      text: buildImportTemplateCsv(
        AppStoreScope.of(context).customFieldDefinitions
            .where(
              (field) =>
                  field.isActive &&
                  field.entityType == CustomFieldEntityType.item,
            )
            .toList(),
      ),
      mimeType: 'text/csv',
      successMessage: 'CSV template exported.',
      failureMessage: 'Could not export the CSV template.',
    );
  }

  Future<void> _exportBackup() async {
    final backupJson = const BackupService().exportBackupJson(
      AppStoreScope.of(context),
    );
    await _shareTextFile(
      filename: _backupFilename(),
      text: backupJson,
      mimeType: 'application/json',
      successMessage: 'Backup exported.',
      failureMessage: 'Could not export backup.',
    );
  }

  Future<void> _shareTextFile({
    required String filename,
    required String text,
    required String mimeType,
    required String successMessage,
    required String failureMessage,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}${Platform.pathSeparator}$filename');
      await file.writeAsString(text, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: mimeType)],
          fileNameOverrides: [filename],
        ),
      );
      if (mounted) {
        _showMessage(successMessage);
      }
    } catch (_) {
      if (mounted) {
        _showMessage(failureMessage);
      }
    }
  }

  String _backupFilename() {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    return 'issued_backup_$date.json';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({
    required this.onExportTemplate,
    required this.onExportBackup,
  });

  final VoidCallback onExportTemplate;
  final VoidCallback onExportBackup;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Paste CSV text from Excel, Google Sheets, or a text file. The first row must contain column names.',
            ),
            const SizedBox(height: 8),
            const Text('Export a backup before importing large CSV files.'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onExportTemplate,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Export CSV Template'),
                ),
                OutlinedButton.icon(
                  onPressed: onExportBackup,
                  icon: const Icon(Icons.backup_outlined),
                  label: const Text('Export Backup'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionsCard extends StatelessWidget {
  const _OptionsCard({
    required this.createMissingLocations,
    required this.createMissingUoms,
    required this.updateExistingItems,
    required this.importStartingQuantities,
    required this.onCreateMissingLocationsChanged,
    required this.onCreateMissingUomsChanged,
    required this.onUpdateExistingItemsChanged,
    required this.onImportStartingQuantitiesChanged,
  });

  final bool createMissingLocations;
  final bool createMissingUoms;
  final bool updateExistingItems;
  final bool importStartingQuantities;
  final ValueChanged<bool> onCreateMissingLocationsChanged;
  final ValueChanged<bool> onCreateMissingUomsChanged;
  final ValueChanged<bool> onUpdateExistingItemsChanged;
  final ValueChanged<bool> onImportStartingQuantitiesChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Create missing locations'),
            value: createMissingLocations,
            onChanged: onCreateMissingLocationsChanged,
          ),
          SwitchListTile(
            title: const Text('Create missing units'),
            value: createMissingUoms,
            onChanged: onCreateMissingUomsChanged,
          ),
          SwitchListTile(
            title: const Text('Update existing items'),
            value: updateExistingItems,
            onChanged: onUpdateExistingItemsChanged,
          ),
          SwitchListTile(
            title: const Text('Import starting quantities'),
            value: importStartingQuantities,
            onChanged: onImportStartingQuantitiesChanged,
          ),
        ],
      ),
    );
  }
}

class _PreviewSummaryCard extends StatelessWidget {
  const _PreviewSummaryCard({required this.preview});

  final CsvImportPreview preview;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _CountText(label: 'Rows', value: preview.rows.length),
            _CountText(label: 'Creates', value: preview.createCount),
            _CountText(label: 'Updates', value: preview.updateCount),
            _CountText(
              label: 'Skips/errors',
              value: preview.skipCount + preview.errorCount,
            ),
            _CountText(label: 'Warnings', value: preview.warningCount),
          ],
        ),
      ),
    );
  }
}

class _CountText extends StatelessWidget {
  const _CountText({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Text('$label: $value');
  }
}

class _PreviewRowCard extends StatelessWidget {
  const _PreviewRowCard({required this.row});

  final CsvImportRowPreview row;

  @override
  Widget build(BuildContext context) {
    final hasErrors = row.errors.isNotEmpty;
    return Card(
      color: hasErrors ? const Color(0xFFFFF3E0) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Row ${row.rowNumber}: ${row.parsedItem.name ?? 'Unnamed item'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(_actionLabel(row.action)),
            for (final error in row.errors)
              Text('Error: $error', style: const TextStyle(color: Colors.red)),
            for (final warning in row.warnings) Text('Warning: $warning'),
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

class _ImportResult {
  const _ImportResult({required this.importedRows});

  final int importedRows;
}

String _actionLabel(CsvImportAction action) {
  return switch (action) {
    CsvImportAction.create => 'Create',
    CsvImportAction.update => 'Update',
    CsvImportAction.skip => 'Skip',
  };
}

String _formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toStringAsFixed(0);
  }
  return quantity.toStringAsFixed(2);
}
