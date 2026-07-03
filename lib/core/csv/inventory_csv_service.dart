import 'package:csv/csv.dart';

import '../app_store.dart';
import '../models/models.dart';

enum CsvDuplicateMode { skip, update, createNew }

class CsvImportPreview {
  const CsvImportPreview({required this.rows, required this.fatalError});

  final List<CsvImportRow> rows;
  final String? fatalError;

  int get validRowCount => rows.where((row) => row.isValid).length;
  int get issueRowCount => rows.where((row) => row.messages.isNotEmpty).length;
}

class CsvImportRow {
  const CsvImportRow({
    required this.rowNumber,
    required this.name,
    required this.description,
    required this.itemType,
    required this.category,
    required this.quantityOnHand,
    required this.quantityProvided,
    required this.minimumQuantity,
    required this.minimumProvided,
    required this.unitOfMeasureName,
    required this.unitOfMeasureAbbreviation,
    required this.locationName,
    required this.barcode,
    required this.sku,
    required this.supplier,
    required this.unitCost,
    required this.unitCostProvided,
    required this.allowFractionalQuantity,
    required this.allowFractionalQuantityProvided,
    required this.duplicateItemId,
    required this.messages,
  });

  final int rowNumber;
  final String name;
  final String? description;
  final ItemType itemType;
  final String? category;
  final double quantityOnHand;
  final bool quantityProvided;
  final double minimumQuantity;
  final bool minimumProvided;
  final String? unitOfMeasureName;
  final String? unitOfMeasureAbbreviation;
  final String? locationName;
  final String? barcode;
  final String? sku;
  final String? supplier;
  final double? unitCost;
  final bool unitCostProvided;
  final bool allowFractionalQuantity;
  final bool allowFractionalQuantityProvided;
  final String? duplicateItemId;
  final List<String> messages;

  bool get isValid =>
      messages.every((message) => !message.startsWith('Error:'));
  bool get isDuplicate => duplicateItemId != null;
}

String buildItemsCsv(AppStore store, {required bool includeArchived}) {
  final rows = <List<Object?>>[
    [
      'id',
      'name',
      'description',
      'item_type',
      'category',
      'quantity_on_hand',
      'minimum_quantity',
      'unit_of_measure',
      'unit_of_measure_abbreviation',
      'location',
      'barcode',
      'sku',
      'supplier',
      'unit_cost',
      'photo_path',
      'allow_fractional_quantity',
      'is_active',
      'created_at',
      'updated_at',
    ],
  ];

  for (final item in store.items) {
    if (!includeArchived && !item.isActive) {
      continue;
    }

    final unit = _unitById(store, item.unitOfMeasureId);
    final location = _locationById(store, item.locationId);
    rows.add([
      item.id,
      item.name,
      item.description,
      item.itemType.name,
      item.category,
      item.quantityOnHand,
      item.minimumQuantity,
      unit?.name ?? '',
      unit?.abbreviation ?? '',
      location?.name ?? '',
      item.barcode ?? '',
      item.sku ?? '',
      item.supplier ?? '',
      item.unitCost ?? '',
      item.photoPath ?? '',
      item.allowFractionalQuantity,
      item.isActive,
      item.createdAt.toIso8601String(),
      item.updatedAt.toIso8601String(),
    ]);
  }

  return const CsvEncoder().convert(rows);
}

String buildActivityCsv(AppStore store) {
  final rows = <List<Object?>>[
    [
      'id',
      'item_id',
      'item_name',
      'transaction_type',
      'quantity_delta',
      'unit_of_measure',
      'from_location',
      'to_location',
      'assigned_to_person',
      'performed_by_user',
      'notes',
      'created_at',
    ],
  ];

  for (final transaction in store.transactions) {
    final item = _itemById(store, transaction.itemId);
    rows.add([
      transaction.id,
      transaction.itemId,
      item?.name ?? 'Unknown',
      transaction.transactionType.name,
      transaction.quantityDelta,
      _unitById(store, transaction.unitOfMeasureId)?.name ?? 'Unknown',
      _locationById(store, transaction.fromLocationId)?.name ?? '',
      _locationById(store, transaction.toLocationId)?.name ?? '',
      _personById(store, transaction.assignedToPersonId)?.displayName ?? '',
      _userNameById(store, transaction.performedByUserId),
      transaction.notes ?? '',
      transaction.createdAt.toIso8601String(),
    ]);
  }

  return const CsvEncoder().convert(rows);
}

String buildImportTemplateCsv() {
  return const CsvEncoder().convert([
    [
      'name',
      'description',
      'item_type',
      'category',
      'quantity_on_hand',
      'minimum_quantity',
      'unit_of_measure',
      'unit_of_measure_abbreviation',
      'location',
      'barcode',
      'sku',
      'supplier',
      'unit_cost',
      'allow_fractional_quantity',
    ],
    [
      'Nitrile Gloves',
      'Disposable shop gloves',
      'consumable',
      'PPE',
      '100',
      '25',
      'Each',
      'ea',
      'Main Tool Crib',
      '',
      'GLOVE-NITRILE',
      'Safety Supply Co.',
      '12.50',
      'false',
    ],
    [
      'Torque Wrench',
      'Half-inch drive calibrated torque wrench',
      'asset',
      'Tools',
      '1',
      '1',
      'Each',
      'ea',
      'Main Tool Crib',
      'TW-IMPORT-001',
      'TW-050',
      'Tool House',
      '148.00',
      'false',
    ],
    [
      'Oil Filter',
      'Replacement hydraulic oil filter',
      'consumable',
      'Maintenance',
      '6',
      '2',
      'Each',
      'ea',
      'Main Tool Crib',
      '',
      'FILTER-OIL',
      'Industrial Supply Co.',
      '18.75',
      'false',
    ],
  ]);
}

CsvImportPreview parseItemsCsv(String csvText, AppStore store) {
  if (csvText.trim().isEmpty) {
    return const CsvImportPreview(
      rows: [],
      fatalError: 'The CSV file is empty.',
    );
  }

  final table = const CsvDecoder(dynamicTyping: false).convert(csvText);
  if (table.isEmpty) {
    return const CsvImportPreview(
      rows: [],
      fatalError: 'The CSV file is empty.',
    );
  }

  final headers = table.first
      .map((value) => _normalizeHeader('$value'))
      .toList();
  if (!headers.contains('name')) {
    return const CsvImportPreview(
      rows: [],
      fatalError: 'The CSV must include a name column.',
    );
  }

  final rows = <CsvImportRow>[];
  for (var index = 1; index < table.length; index++) {
    final values = table[index];
    if (values.every((value) => '$value'.trim().isEmpty)) {
      continue;
    }

    rows.add(_parseRow(index + 1, headers, values, store));
  }

  if (rows.isEmpty) {
    return const CsvImportPreview(
      rows: [],
      fatalError: 'No item rows were found in the CSV.',
    );
  }

  return CsvImportPreview(rows: rows, fatalError: null);
}

int newActiveItemCountForMode(CsvImportPreview preview, CsvDuplicateMode mode) {
  return preview.rows.where((row) {
    if (!row.isValid) {
      return false;
    }

    return switch (mode) {
      CsvDuplicateMode.skip => !row.isDuplicate,
      CsvDuplicateMode.update => !row.isDuplicate,
      CsvDuplicateMode.createNew => true,
    };
  }).length;
}

Set<String> newLocationNamesForImport(
  CsvImportPreview preview,
  AppStore store,
) {
  final existingNames = store.locations
      .where((location) => location.isActive)
      .map((location) => _normalize(location.name))
      .toSet();

  return preview.rows
      .where((row) => row.isValid)
      .map((row) => row.locationName?.trim())
      .whereType<String>()
      .where((name) => name.isNotEmpty)
      .where((name) => !existingNames.contains(_normalize(name)))
      .toSet();
}

CsvImportRow _parseRow(
  int rowNumber,
  List<String> headers,
  List<dynamic> values,
  AppStore store,
) {
  final messages = <String>[];
  final name = _cell(headers, values, 'name') ?? '';
  if (name.trim().isEmpty) {
    messages.add('Error: name is required.');
  }

  final itemTypeText = _cell(headers, values, 'item_type');
  final itemType = _parseItemType(itemTypeText, messages);
  final quantityText = _cell(headers, values, 'quantity_on_hand');
  final quantity = _parseDouble(
    quantityText,
    'quantity_on_hand',
    messages,
    defaultValue: 0,
  );
  final minimumText = _cell(headers, values, 'minimum_quantity');
  final minimum = _parseDouble(
    minimumText,
    'minimum_quantity',
    messages,
    defaultValue: 0,
  );
  final unitCostText = _cell(headers, values, 'unit_cost');
  final unitCost = unitCostText == null || unitCostText.isEmpty
      ? null
      : _parseDouble(unitCostText, 'unit_cost', messages);
  final allowFractionalText = _cell(
    headers,
    values,
    'allow_fractional_quantity',
  );
  final allowFractional = _parseBool(allowFractionalText, messages);
  final unitName = _cell(headers, values, 'unit_of_measure');
  final unitAbbreviation = _cell(
    headers,
    values,
    'unit_of_measure_abbreviation',
  );
  final locationName = _cell(headers, values, 'location');

  if ((unitName != null || unitAbbreviation != null) &&
      !_unitExists(store, unitName, unitAbbreviation)) {
    messages.add('Warning: unit will be created.');
  }

  if (locationName != null && !_locationExists(store, locationName)) {
    messages.add('Warning: location will be created if your plan allows it.');
  }

  final duplicateItem = _duplicateFor(
    store,
    barcode: _cell(headers, values, 'barcode'),
    sku: _cell(headers, values, 'sku'),
    name: name,
  );
  if (duplicateItem != null) {
    messages.add('Warning: duplicate of ${duplicateItem.name}.');
  }

  return CsvImportRow(
    rowNumber: rowNumber,
    name: name.trim(),
    description: _cell(headers, values, 'description'),
    itemType: itemType,
    category: _cell(headers, values, 'category'),
    quantityOnHand: quantity ?? 0,
    quantityProvided: quantityText != null,
    minimumQuantity: minimum ?? 0,
    minimumProvided: minimumText != null,
    unitOfMeasureName: unitName,
    unitOfMeasureAbbreviation: unitAbbreviation,
    locationName: locationName,
    barcode: _cell(headers, values, 'barcode'),
    sku: _cell(headers, values, 'sku'),
    supplier: _cell(headers, values, 'supplier'),
    unitCost: unitCost,
    unitCostProvided: unitCostText != null,
    allowFractionalQuantity: allowFractional ?? false,
    allowFractionalQuantityProvided: allowFractionalText != null,
    duplicateItemId: duplicateItem?.id,
    messages: messages,
  );
}

String _normalizeHeader(String value) {
  return value.trim().toLowerCase().replaceAll(' ', '_');
}

String? _cell(List<String> headers, List<dynamic> values, String header) {
  final index = headers.indexOf(header);
  if (index == -1 || index >= values.length) {
    return null;
  }

  final text = '${values[index]}'.trim();
  return text.isEmpty ? null : text;
}

ItemType _parseItemType(String? value, List<String> messages) {
  if (value == null || value.trim().isEmpty) {
    return ItemType.consumable;
  }

  return switch (_normalize(value)) {
    'consumable' => ItemType.consumable,
    'returnable' => ItemType.returnable,
    'asset' => ItemType.asset,
    _ => () {
      messages.add(
        'Error: item_type must be consumable, returnable, or asset.',
      );
      return ItemType.consumable;
    }(),
  };
}

double? _parseDouble(
  String? value,
  String field,
  List<String> messages, {
  double? defaultValue,
}) {
  if (value == null || value.trim().isEmpty) {
    return defaultValue;
  }

  final parsed = double.tryParse(value.trim());
  if (parsed == null) {
    messages.add('Error: $field must be a number.');
  }

  return parsed;
}

bool? _parseBool(String? value, List<String> messages) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  return switch (_normalize(value)) {
    'true' || 'yes' || '1' => true,
    'false' || 'no' || '0' => false,
    _ => () {
      messages.add(
        'Error: allow_fractional_quantity must be true/false, yes/no, or 1/0.',
      );
      return null;
    }(),
  };
}

bool _unitExists(AppStore store, String? name, String? abbreviation) {
  return store.unitsOfMeasure.any((unit) {
    return (name != null && _normalize(unit.name) == _normalize(name)) ||
        (abbreviation != null &&
            _normalize(unit.abbreviation) == _normalize(abbreviation));
  });
}

bool _locationExists(AppStore store, String name) {
  return store.locations.any((location) {
    return location.isActive && _normalize(location.name) == _normalize(name);
  });
}

Item? _duplicateFor(
  AppStore store, {
  required String? barcode,
  required String? sku,
  required String name,
}) {
  if (barcode != null) {
    return store.items
        .where((item) => item.barcode != null)
        .cast<Item?>()
        .firstWhere(
          (item) => _normalize(item!.barcode!) == _normalize(barcode),
          orElse: () => null,
        );
  }

  if (sku != null) {
    return store.items
        .where((item) => item.sku != null)
        .cast<Item?>()
        .firstWhere(
          (item) => _normalize(item!.sku!) == _normalize(sku),
          orElse: () => null,
        );
  }

  return store.items.cast<Item?>().firstWhere(
    (item) => _normalize(item!.name) == _normalize(name),
    orElse: () => null,
  );
}

Item? _itemById(AppStore store, String itemId) {
  return store.items.cast<Item?>().firstWhere(
    (item) => item!.id == itemId,
    orElse: () => null,
  );
}

UnitOfMeasure? _unitById(AppStore store, String? unitId) {
  if (unitId == null) {
    return null;
  }

  return store.unitsOfMeasure.cast<UnitOfMeasure?>().firstWhere(
    (unit) => unit!.id == unitId,
    orElse: () => null,
  );
}

Location? _locationById(AppStore store, String? locationId) {
  if (locationId == null) {
    return null;
  }

  return store.locations.cast<Location?>().firstWhere(
    (location) => location!.id == locationId,
    orElse: () => null,
  );
}

Person? _personById(AppStore store, String? personId) {
  if (personId == null) {
    return null;
  }

  return store.people.cast<Person?>().firstWhere(
    (person) => person!.id == personId,
    orElse: () => null,
  );
}

String _userNameById(AppStore store, String? userId) {
  if (userId == null) {
    return '';
  }

  final user = store.users.cast<AppUser?>().firstWhere(
    (user) => user!.id == userId,
    orElse: () => null,
  );
  if (user == null) {
    return 'Unknown';
  }

  return _personById(store, user.personId)?.displayName ?? user.email;
}

String _normalize(String value) => value.trim().toLowerCase();
