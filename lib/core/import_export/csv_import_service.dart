import 'package:csv/csv.dart';

import '../app_store.dart';
import '../models/models.dart';

enum CsvImportAction { create, update, skip }

class CsvImportOptions {
  const CsvImportOptions({
    required this.createMissingLocations,
    required this.createMissingUoms,
    required this.updateExistingItems,
    required this.importStartingQuantities,
  });

  final bool createMissingLocations;
  final bool createMissingUoms;
  final bool updateExistingItems;
  final bool importStartingQuantities;
}

class CsvImportPreview {
  const CsvImportPreview({
    required this.rows,
    required this.fatalError,
    required this.unknownHeaders,
  });

  final List<CsvImportRowPreview> rows;
  final String? fatalError;
  final List<String> unknownHeaders;

  int get validCount => rows.where((row) => row.errors.isEmpty).length;
  int get warningCount => rows.where((row) => row.warnings.isNotEmpty).length;
  int get errorCount => rows.where((row) => row.errors.isNotEmpty).length;
  int get createCount =>
      rows.where((row) => row.action == CsvImportAction.create).length;
  int get updateCount =>
      rows.where((row) => row.action == CsvImportAction.update).length;
  int get skipCount =>
      rows.where((row) => row.action == CsvImportAction.skip).length;
}

class CsvImportRowPreview {
  const CsvImportRowPreview({
    required this.rowNumber,
    required this.rawValues,
    required this.parsedItem,
    required this.action,
    required this.existingItemId,
    required this.errors,
    required this.warnings,
  });

  final int rowNumber;
  final Map<String, String> rawValues;
  final CsvParsedItem parsedItem;
  final CsvImportAction action;
  final String? existingItemId;
  final List<String> errors;
  final List<String> warnings;

  bool get canImport => errors.isEmpty && action != CsvImportAction.skip;
}

class CsvParsedItem {
  const CsvParsedItem({
    required this.providedColumns,
    required this.customValues,
    required this.locationBalances,
    this.name,
    this.description,
    this.itemType,
    this.category,
    this.quantity,
    this.minimumQuantity,
    this.unitOfMeasure,
    this.location,
    this.barcode,
    this.sku,
    this.supplier,
    this.unitCost,
    this.allowFractionalQuantity,
    this.purchaseUnitOfMeasure,
    this.purchaseToStockConversionFactor,
    this.notes,
  });

  final Set<String> providedColumns;
  final String? name;
  final String? description;
  final ItemType? itemType;
  final String? category;
  final double? quantity;
  final double? minimumQuantity;
  final String? unitOfMeasure;
  final String? location;
  final String? barcode;
  final String? sku;
  final String? supplier;
  final double? unitCost;
  final bool? allowFractionalQuantity;
  final String? purchaseUnitOfMeasure;
  final double? purchaseToStockConversionFactor;
  final String? notes;
  final Map<String, String> customValues;
  final List<CsvLocationBalance> locationBalances;

  bool hasColumn(String column) => providedColumns.contains(column);
}

class CsvLocationBalance {
  const CsvLocationBalance({
    required this.locationName,
    required this.quantity,
  });

  final String locationName;
  final double quantity;
}

class CsvImportService {
  const CsvImportService();

  CsvImportPreview preview(
    String csvText,
    AppStore store,
    CsvImportOptions options,
  ) {
    if (csvText.trim().isEmpty) {
      return const CsvImportPreview(
        rows: [],
        fatalError: 'Paste CSV text before loading a preview.',
        unknownHeaders: [],
      );
    }

    final List<List<dynamic>> table;
    try {
      table = const CsvDecoder(
        dynamicTyping: false,
      ).convert(csvText.replaceAll('\r\n', '\n').replaceAll('\r', '\n'));
    } catch (_) {
      return const CsvImportPreview(
        rows: [],
        fatalError: 'The pasted CSV could not be read.',
        unknownHeaders: [],
      );
    }

    if (table.isEmpty ||
        table.first.every((value) => value.toString().trim().isEmpty)) {
      return const CsvImportPreview(
        rows: [],
        fatalError: 'The first row must contain column names.',
        unknownHeaders: [],
      );
    }

    final headerResult = _normalizeHeaders(table.first);
    if (headerResult.error != null) {
      return CsvImportPreview(
        rows: const [],
        fatalError: headerResult.error,
        unknownHeaders: const [],
      );
    }
    if (!headerResult.headers.contains('name')) {
      return const CsvImportPreview(
        rows: [],
        fatalError: 'The CSV must include a name column.',
        unknownHeaders: [],
      );
    }

    final duplicateValues = _duplicateCsvValues(table, headerResult.headers);
    final rows = <CsvImportRowPreview>[];
    for (var index = 1; index < table.length; index++) {
      final values = table[index];
      if (values.every((value) => value.toString().trim().isEmpty)) {
        continue;
      }
      rows.add(
        _previewRow(
          rowNumber: index + 1,
          headers: headerResult.headers,
          values: values,
          store: store,
          options: options,
          duplicateCsvValues: duplicateValues,
        ),
      );
    }

    if (rows.isEmpty) {
      return CsvImportPreview(
        rows: const [],
        fatalError: 'No item rows were found in the CSV.',
        unknownHeaders: headerResult.unknownHeaders,
      );
    }

    return CsvImportPreview(
      rows: rows,
      fatalError: null,
      unknownHeaders: headerResult.unknownHeaders,
    );
  }

  CsvImportRowPreview _previewRow({
    required int rowNumber,
    required List<String> headers,
    required List<dynamic> values,
    required AppStore store,
    required CsvImportOptions options,
    required Set<String> duplicateCsvValues,
  }) {
    final rawValues = <String, String>{};
    final providedColumns = <String>{};
    for (var index = 0; index < headers.length; index++) {
      final header = headers[index];
      if (header.isEmpty) {
        continue;
      }
      final value = index < values.length
          ? values[index].toString().trim()
          : '';
      rawValues[header] = value;
      if (value.isNotEmpty) {
        providedColumns.add(header);
      }
    }

    final errors = <String>[];
    final warnings = <String>[];
    if (values.length > headers.length) {
      warnings.add('Extra cells at the end of this row were ignored.');
    }

    final name = _value(rawValues, 'name');
    if (name == null) {
      errors.add('Name is required.');
    }

    final itemTypeText = _value(rawValues, 'item_type');
    final itemType = _parseItemType(itemTypeText, errors, warnings);
    final quantity = _parseNumber(
      _value(rawValues, 'quantity'),
      'quantity',
      errors,
    );
    final minimumQuantity = _parseNumber(
      _value(rawValues, 'minimum_quantity'),
      'minimum quantity',
      errors,
    );
    final unitCost = _parseNumber(
      _value(rawValues, 'unit_cost'),
      'unit cost',
      errors,
    );
    final purchaseFactor = _parseNumber(
      _value(rawValues, 'purchase_to_stock_conversion_factor'),
      'purchase conversion factor',
      errors,
    );
    final allowFractional = _parseBool(
      _value(rawValues, 'allow_fractional_quantity'),
      errors,
    );
    final unitText = _value(rawValues, 'unit_of_measure');
    final locationText = _value(rawValues, 'location');
    final purchaseUnitText = _value(rawValues, 'purchase_unit_of_measure');
    final customValues = _customValues(rawValues);
    final balances = _parseLocationBalances(
      _value(rawValues, 'location_balances'),
      errors,
      warnings,
    );

    if (quantity != null && quantity < 0) {
      errors.add('Quantity cannot be negative.');
    }
    if (minimumQuantity != null && minimumQuantity < 0) {
      errors.add('Minimum quantity cannot be negative.');
    }
    if (unitCost != null && unitCost < 0) {
      errors.add('Unit cost cannot be negative.');
    }
    if (purchaseFactor != null && purchaseFactor <= 0) {
      errors.add('Purchase conversion factor must be greater than 0.');
    }

    final unit = _findUnit(store, unitText);
    if (unitText != null && unit == null) {
      if (options.createMissingUoms) {
        warnings.add('Unit "$unitText" will be created.');
      } else {
        errors.add('Unit "$unitText" does not exist.');
      }
    }

    if (quantity != null &&
        unit != null &&
        !unit.allowsDecimal &&
        !_isWhole(quantity)) {
      errors.add('Quantity must be a whole number for ${unit.abbreviation}.');
    }
    if (quantity != null && allowFractional == false && !_isWhole(quantity)) {
      errors.add('Quantity must be a whole number.');
    }

    final location = _findLocation(store, locationText);
    if (locationText != null && location == null) {
      if (options.createMissingLocations) {
        warnings.add('Location "$locationText" will be created.');
      } else {
        errors.add('Location "$locationText" does not exist.');
      }
    }

    for (final balance in balances) {
      if (_findLocation(store, balance.locationName) == null &&
          !options.createMissingLocations) {
        errors.add('Location "${balance.locationName}" does not exist.');
      }
      if (balance.quantity < 0) {
        errors.add('Location balance cannot be negative.');
      }
    }

    final purchaseUnit = _findUnit(store, purchaseUnitText);
    if (purchaseUnitText != null &&
        purchaseUnit == null &&
        !options.createMissingUoms) {
      errors.add('Purchase unit "$purchaseUnitText" does not exist.');
    }
    if (purchaseUnitText != null &&
        unitText != null &&
        _normalize(purchaseUnitText) != _normalize(unitText) &&
        purchaseFactor == null) {
      errors.add(
        'Purchase conversion factor is required when purchase unit differs.',
      );
    }

    final barcode = _value(rawValues, 'barcode');
    final sku = _value(rawValues, 'sku');
    if (barcode != null &&
        duplicateCsvValues.contains('barcode:${_normalize(barcode)}')) {
      errors.add('Duplicate barcode "$barcode" appears in the CSV.');
    }
    if (sku != null && duplicateCsvValues.contains('sku:${_normalize(sku)}')) {
      errors.add('Duplicate SKU "$sku" appears in the CSV.');
    }

    final match = _findExistingMatch(
      store,
      barcode: barcode,
      sku: sku,
      name: name,
      category: _value(rawValues, 'category'),
      errors: errors,
    );
    var action = CsvImportAction.create;
    if (match != null) {
      if (options.updateExistingItems) {
        action = CsvImportAction.update;
        if ((barcode == null || barcode.isEmpty) &&
            (sku == null || sku.isEmpty)) {
          warnings.add('Matched existing item by name and category.');
        }
      } else {
        action = CsvImportAction.skip;
        warnings.add('Existing item will be skipped because updates are off.');
      }
    }

    final parsed = CsvParsedItem(
      providedColumns: providedColumns,
      name: name,
      description: _value(rawValues, 'description'),
      itemType: itemType,
      category: _value(rawValues, 'category'),
      quantity: quantity,
      minimumQuantity: minimumQuantity,
      unitOfMeasure: unitText,
      location: locationText,
      barcode: barcode,
      sku: sku,
      supplier: _value(rawValues, 'supplier'),
      unitCost: unitCost,
      allowFractionalQuantity: allowFractional,
      purchaseUnitOfMeasure: purchaseUnitText,
      purchaseToStockConversionFactor: purchaseFactor,
      notes: _value(rawValues, 'notes'),
      customValues: customValues,
      locationBalances: balances,
    );

    _validateCustomFields(store, parsed, errors);

    return CsvImportRowPreview(
      rowNumber: rowNumber,
      rawValues: rawValues,
      parsedItem: parsed,
      action: errors.isEmpty ? action : CsvImportAction.skip,
      existingItemId: match?.id,
      errors: errors,
      warnings: warnings,
    );
  }
}

_HeaderResult _normalizeHeaders(List<dynamic> row) {
  final headers = <String>[];
  final seen = <String>{};
  final unknown = <String>[];
  for (final value in row) {
    final raw = value.toString().trim();
    final normalized = _headerAliases[_slug(raw)] ?? _slug(raw);
    if (normalized.isEmpty) {
      headers.add('');
      continue;
    }
    if (!seen.add(normalized)) {
      return _HeaderResult(
        headers: const [],
        unknownHeaders: const [],
        error: 'Duplicate column "$raw" found.',
      );
    }
    headers.add(normalized);
    if (!_supportedHeaders.contains(normalized) &&
        !normalized.startsWith('custom_')) {
      unknown.add(raw);
    }
  }
  return _HeaderResult(headers: headers, unknownHeaders: unknown, error: null);
}

Set<String> _duplicateCsvValues(
  List<List<dynamic>> table,
  List<String> headers,
) {
  final seen = <String>{};
  final duplicates = <String>{};
  for (var index = 1; index < table.length; index++) {
    final values = table[index];
    for (final header in ['barcode', 'sku']) {
      final value = _cell(headers, values, header);
      if (value == null) {
        continue;
      }
      final key = '$header:${_normalize(value)}';
      if (!seen.add(key)) {
        duplicates.add(key);
      }
    }
  }
  return duplicates;
}

Item? _findExistingMatch(
  AppStore store, {
  required String? barcode,
  required String? sku,
  required String? name,
  required String? category,
  required List<String> errors,
}) {
  final activeItems = store.items.where((item) => item.isActive).toList();
  if (barcode != null) {
    final matches = activeItems
        .where((item) => _normalize(item.barcode ?? '') == _normalize(barcode))
        .toList();
    if (matches.length > 1) {
      errors.add('Barcode "$barcode" matches multiple active items.');
      return null;
    }
    if (matches.length == 1) {
      return matches.first;
    }
  }
  if (sku != null) {
    final matches = activeItems
        .where((item) => _normalize(item.sku ?? '') == _normalize(sku))
        .toList();
    if (matches.length > 1) {
      errors.add('SKU "$sku" matches multiple active items.');
      return null;
    }
    if (matches.length == 1) {
      return matches.first;
    }
  }
  if (name != null) {
    final normalizedCategory = _normalize(category ?? '');
    final matches = activeItems
        .where(
          (item) =>
              _normalize(item.name) == _normalize(name) &&
              _normalize(item.category) == normalizedCategory,
        )
        .toList();
    if (matches.length == 1) {
      return matches.first;
    }
  }
  return null;
}

void _validateCustomFields(
  AppStore store,
  CsvParsedItem parsed,
  List<String> errors,
) {
  final synthetic = Item(
    id: 'csv-preview',
    name: parsed.name ?? '',
    description: parsed.description ?? '',
    itemType: parsed.itemType ?? ItemType.consumable,
    category: parsed.category ?? '',
    locationId: '',
    quantityOnHand: parsed.quantity ?? 0,
    minimumQuantity: parsed.minimumQuantity ?? 0,
    unitOfMeasureId: '',
    purchaseUnitOfMeasureId: null,
    purchaseToStockConversionFactor: null,
    purchaseUnitLabel: null,
    barcode: parsed.barcode,
    sku: parsed.sku,
    supplier: parsed.supplier,
    unitCost: parsed.unitCost,
    photoPath: null,
    isActive: true,
    allowFractionalQuantity: parsed.allowFractionalQuantity ?? false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  for (final field in store.activeCustomFieldsForItem(synthetic)) {
    final key = 'custom_${_slug(field.name)}';
    final value = parsed.customValues[key];
    if (field.isRequired && (value == null || value.trim().isEmpty)) {
      errors.add('Custom field "${field.name}" is required.');
    }
    if (value != null && value.trim().isNotEmpty) {
      _parseCustomFieldValue(field, value, errors);
    }
  }
}

CustomFieldValue? buildCustomFieldValue({
  required CustomFieldDefinition field,
  required String itemId,
  required String rawValue,
}) {
  final id = 'cfv-${field.id}-$itemId';
  final value = rawValue.trim();
  return switch (field.fieldType) {
    CustomFieldType.text => CustomFieldValue(
      id: id,
      definitionId: field.id,
      entityId: itemId,
      textValue: value,
      numberValue: null,
      dateValue: null,
      booleanValue: null,
      selectedOption: null,
    ),
    CustomFieldType.number => CustomFieldValue(
      id: id,
      definitionId: field.id,
      entityId: itemId,
      textValue: null,
      numberValue: double.tryParse(value),
      dateValue: null,
      booleanValue: null,
      selectedOption: null,
    ),
    CustomFieldType.date => CustomFieldValue(
      id: id,
      definitionId: field.id,
      entityId: itemId,
      textValue: null,
      numberValue: null,
      dateValue: DateTime.tryParse(value),
      booleanValue: null,
      selectedOption: null,
    ),
    CustomFieldType.boolean => CustomFieldValue(
      id: id,
      definitionId: field.id,
      entityId: itemId,
      textValue: null,
      numberValue: null,
      dateValue: null,
      booleanValue: _parseBoolValue(value),
      selectedOption: null,
    ),
    CustomFieldType.select => CustomFieldValue(
      id: id,
      definitionId: field.id,
      entityId: itemId,
      textValue: null,
      numberValue: null,
      dateValue: null,
      booleanValue: null,
      selectedOption: value,
    ),
  };
}

void _parseCustomFieldValue(
  CustomFieldDefinition field,
  String value,
  List<String> errors,
) {
  switch (field.fieldType) {
    case CustomFieldType.text:
      return;
    case CustomFieldType.number:
      if (double.tryParse(value) == null) {
        errors.add('Custom field "${field.name}" must be a number.');
      }
    case CustomFieldType.date:
      if (DateTime.tryParse(value) == null) {
        errors.add('Custom field "${field.name}" must be a date.');
      }
    case CustomFieldType.boolean:
      if (_parseBoolValue(value) == null) {
        errors.add('Custom field "${field.name}" must be yes or no.');
      }
    case CustomFieldType.select:
      if (field.options.isNotEmpty &&
          !field.options.any(
            (option) => _normalize(option) == _normalize(value),
          )) {
        errors.add('Custom field "${field.name}" must match an option.');
      }
  }
}

List<CsvLocationBalance> _parseLocationBalances(
  String? value,
  List<String> errors,
  List<String> warnings,
) {
  if (value == null || value.trim().isEmpty) {
    return const [];
  }
  final balances = <CsvLocationBalance>[];
  for (final part in value.split(';')) {
    final pieces = part.split(':');
    if (pieces.length < 2) {
      warnings.add('Could not read one location balance entry.');
      continue;
    }
    final location = pieces.first.trim();
    final quantityText = pieces
        .sublist(1)
        .join(':')
        .trim()
        .split(RegExp(r'\s+'))
        .first;
    final quantity = double.tryParse(quantityText);
    if (location.isEmpty || quantity == null) {
      errors.add('Location balances must look like "Main Stockroom: 12 ea".');
      continue;
    }
    balances.add(
      CsvLocationBalance(locationName: location, quantity: quantity),
    );
  }
  return balances;
}

Map<String, String> _customValues(Map<String, String> rawValues) {
  return {
    for (final entry in rawValues.entries)
      if (entry.key.startsWith('custom_') && entry.value.trim().isNotEmpty)
        entry.key: entry.value.trim(),
  };
}

ItemType _parseItemType(
  String? value,
  List<String> errors,
  List<String> warnings,
) {
  if (value == null || value.trim().isEmpty) {
    warnings.add('Blank item type defaulted to consumable.');
    return ItemType.consumable;
  }
  return switch (_normalize(value)) {
    'consumable' => ItemType.consumable,
    'returnable' => ItemType.returnable,
    'asset' => ItemType.asset,
    _ => () {
      errors.add('Item type must be consumable, returnable, or asset.');
      return ItemType.consumable;
    }(),
  };
}

double? _parseNumber(String? value, String label, List<String> errors) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final parsed = double.tryParse(value.trim());
  if (parsed == null) {
    errors.add('$label must be numeric.');
  }
  return parsed;
}

bool? _parseBool(String? value, List<String> errors) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final parsed = _parseBoolValue(value);
  if (parsed == null) {
    errors.add('Allow fractional quantity must be yes or no.');
  }
  return parsed;
}

bool? _parseBoolValue(String value) {
  return switch (_normalize(value)) {
    'true' || 'yes' || 'y' || '1' => true,
    'false' || 'no' || 'n' || '0' => false,
    _ => null,
  };
}

String? _value(Map<String, String> values, String header) {
  final value = values[header]?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }
  return value;
}

String? _cell(List<String> headers, List<dynamic> values, String header) {
  final index = headers.indexOf(header);
  if (index == -1 || index >= values.length) {
    return null;
  }
  final text = values[index].toString().trim();
  return text.isEmpty ? null : text;
}

UnitOfMeasure? findImportUnit(AppStore store, String? value) =>
    _findUnit(store, value);

Location? findImportLocation(AppStore store, String? value) =>
    _findLocation(store, value);

UnitOfMeasure? _findUnit(AppStore store, String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return store.unitsOfMeasure.cast<UnitOfMeasure?>().firstWhere(
    (unit) =>
        unit != null &&
        (_normalize(unit.name) == _normalize(value) ||
            _normalize(unit.abbreviation) == _normalize(value)),
    orElse: () => null,
  );
}

Location? _findLocation(AppStore store, String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return store.locations.cast<Location?>().firstWhere(
    (location) =>
        location != null &&
        location.isActive &&
        _normalize(location.name) == _normalize(value),
    orElse: () => null,
  );
}

bool _isWhole(double value) => value == value.roundToDouble();

String _normalize(String value) => value.trim().toLowerCase();

String csvImportSlug(String value) => _slug(value);

String _slug(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}

const _supportedHeaders = {
  'name',
  'description',
  'item_type',
  'category',
  'quantity',
  'minimum_quantity',
  'unit_of_measure',
  'location',
  'barcode',
  'sku',
  'supplier',
  'unit_cost',
  'allow_fractional_quantity',
  'purchase_unit_of_measure',
  'purchase_to_stock_conversion_factor',
  'notes',
  'location_balances',
};

const _headerAliases = {
  'item_name': 'name',
  'qty': 'quantity',
  'quantity_on_hand': 'quantity',
  'min_qty': 'minimum_quantity',
  'minimum': 'minimum_quantity',
  'uom': 'unit_of_measure',
  'unit': 'unit_of_measure',
  'unit_of_measure_abbreviation': 'unit_of_measure',
  'part_number': 'sku',
  'part_no': 'sku',
  'vendor': 'supplier',
  'purchase_unit_of_measure_abbreviation': 'purchase_unit_of_measure',
};

class _HeaderResult {
  const _HeaderResult({
    required this.headers,
    required this.unknownHeaders,
    required this.error,
  });

  final List<String> headers;
  final List<String> unknownHeaders;
  final String? error;
}
