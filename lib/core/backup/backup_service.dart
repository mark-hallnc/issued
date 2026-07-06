import 'dart:convert';

import '../app_store.dart';
import '../models/models.dart';

class BackupService {
  const BackupService();

  static const int currentBackupVersion = 1;

  String exportBackupJson(AppStore store) {
    final backup = <String, Object?>{
      'backupVersion': currentBackupVersion,
      'appName': 'Issued',
      'createdAt': DateTime.now().toIso8601String(),
      'company': store.company == null ? null : _company(store.company!),
      'currentPlan': _plan(store.currentPlan),
      'companyUsage': _companyUsage(store.companyUsage),
      'unitsOfMeasure': store.unitsOfMeasure.map(_unit).toList(),
      'locations': store.locations.map(_location).toList(),
      'people': store.people.map(_person).toList(),
      'users': store.users.map(_user).toList(),
      'assignmentTargets': store.assignmentTargets
          .map(_assignmentTarget)
          .toList(),
      'items': store.items.map(_item).toList(),
      'itemLocationBalances': store.itemLocationBalances.map(_balance).toList(),
      'inventoryTransactions': store.transactions.map(_transaction).toList(),
      'checkoutRecords': store.checkoutRecords.map(_checkout).toList(),
      'reorderRequests': store.reorderRequests.map(_reorder).toList(),
      'cycleCountSessions': store.cycleCountSessions
          .map(_countSession)
          .toList(),
      'cycleCountLines': store.cycleCountLines.map(_countLine).toList(),
      'customFieldDefinitions': store.customFieldDefinitions
          .map(_customFieldDefinition)
          .toList(),
      'customFieldValues': store.customFieldValues
          .map(_customFieldValue)
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  BackupValidationResult validateBackupJson(String jsonText) {
    final errors = <String>[];
    final warnings = <String>[];
    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map<String, dynamic>) {
        return BackupValidationResult(
          isValid: false,
          message: 'Backup file must contain a JSON object.',
          errors: const ['Backup file must contain a JSON object.'],
        );
      }

      final version = decoded['backupVersion'];
      if (version == null) {
        errors.add('Backup version is missing.');
      } else if ((version is int ? version : int.tryParse('$version')) !=
          currentBackupVersion) {
        warnings.add(
          'Backup version $version will be restored as best effort.',
        );
      }

      final appName = decoded['appName'];
      if (appName != 'Issued') {
        errors.add('This does not look like an Issued backup.');
      }

      const requiredArrays = [
        'unitsOfMeasure',
        'locations',
        'people',
        'users',
        'items',
        'inventoryTransactions',
        'cycleCountSessions',
        'cycleCountLines',
        'customFieldDefinitions',
        'customFieldValues',
      ];
      for (final key in requiredArrays) {
        if (decoded[key] is! List) {
          errors.add('Backup is missing $key.');
        }
      }

      for (final key in [
        'itemLocationBalances',
        'checkoutRecords',
        'reorderRequests',
        'assignmentTargets',
      ]) {
        if (decoded[key] == null) {
          warnings.add('$key is not included in this backup.');
        } else if (decoded[key] is! List) {
          errors.add('$key must be a list.');
        }
      }

      final counts = BackupCounts.fromJson(decoded);
      return BackupValidationResult(
        isValid: errors.isEmpty,
        message: errors.isEmpty ? 'Backup is valid.' : errors.first,
        errors: errors,
        warnings: warnings,
        counts: counts,
        companyName: _map(decoded['company'])?['name']?.toString(),
        backupVersion: version is int ? version : int.tryParse('$version'),
        createdAt: _date(decoded['createdAt']),
      );
    } catch (_) {
      return const BackupValidationResult(
        isValid: false,
        message: 'Backup file is not valid JSON.',
        errors: ['Backup file is not valid JSON.'],
      );
    }
  }

  Map<String, dynamic>? parseBackupJson(String jsonText) {
    final validation = validateBackupJson(jsonText);
    if (!validation.isValid) {
      return null;
    }
    return jsonDecode(jsonText) as Map<String, dynamic>;
  }

  IssuedBackupData? parseBackupData(String jsonText) {
    final decoded = parseBackupJson(jsonText);
    if (decoded == null) {
      return null;
    }

    final warnings = <String>[];
    return IssuedBackupData(
      company: _parseCompany(_map(decoded['company'])),
      plan: _parsePlan(_map(decoded['currentPlan'])),
      companyUsage: _parseCompanyUsage(_map(decoded['companyUsage'])),
      unitsOfMeasure: _list(decoded['unitsOfMeasure'])
          .map((row) => _parseUnit(row, warnings))
          .whereType<UnitOfMeasure>()
          .toList(),
      locations: _list(decoded['locations'])
          .map((row) => _parseLocation(row, warnings))
          .whereType<Location>()
          .toList(),
      people: _list(
        decoded['people'],
      ).map((row) => _parsePerson(row, warnings)).whereType<Person>().toList(),
      users: _list(
        decoded['users'],
      ).map((row) => _parseUser(row, warnings)).whereType<AppUser>().toList(),
      assignmentTargets: _list(decoded['assignmentTargets'])
          .map((row) => _parseAssignmentTarget(row, warnings))
          .whereType<AssignmentTarget>()
          .toList(),
      items: _list(
        decoded['items'],
      ).map((row) => _parseItem(row, warnings)).whereType<Item>().toList(),
      itemLocationBalances: _list(decoded['itemLocationBalances'])
          .map((row) => _parseBalance(row, warnings))
          .whereType<ItemLocationBalance>()
          .toList(),
      transactions: _list(decoded['inventoryTransactions'])
          .map((row) => _parseTransaction(row, warnings))
          .whereType<InventoryTransaction>()
          .toList(),
      checkoutRecords: _list(decoded['checkoutRecords'])
          .map((row) => _parseCheckout(row, warnings))
          .whereType<CheckoutRecord>()
          .toList(),
      reorderRequests: _list(decoded['reorderRequests'])
          .map((row) => _parseReorder(row, warnings))
          .whereType<ReorderRequest>()
          .toList(),
      cycleCountSessions: _list(decoded['cycleCountSessions'])
          .map((row) => _parseCountSession(row, warnings))
          .whereType<CycleCountSession>()
          .toList(),
      cycleCountLines: _list(decoded['cycleCountLines'])
          .map((row) => _parseCountLine(row, warnings))
          .whereType<CycleCountLine>()
          .toList(),
      customFieldDefinitions: _list(decoded['customFieldDefinitions'])
          .map((row) => _parseCustomFieldDefinition(row, warnings))
          .whereType<CustomFieldDefinition>()
          .toList(),
      customFieldValues: _list(decoded['customFieldValues'])
          .map((row) => _parseCustomFieldValue(row, warnings))
          .whereType<CustomFieldValue>()
          .toList(),
      warnings: warnings,
    );
  }

  static Map<String, Object?> _company(Company company) {
    return {
      'id': company.id,
      'name': company.name,
      'industry': company.industry,
      'createdAt': company.createdAt.toIso8601String(),
      'updatedAt': company.updatedAt.toIso8601String(),
      'setupCompleted': company.setupCompleted,
    };
  }

  static Map<String, Object?> _plan(Plan plan) {
    return {
      'code': plan.code,
      'name': plan.name,
      'itemLimit': plan.itemLimit,
      'userLimit': plan.userLimit,
      'locationLimit': plan.locationLimit,
      'photoLimit': plan.photoLimit,
      'labelExportLimit': plan.labelExportLimit,
      'csvImportEnabled': plan.csvImportEnabled,
      'advancedReportsEnabled': plan.advancedReportsEnabled,
    };
  }

  static Map<String, Object?> _companyUsage(CompanyUsage usage) {
    return {
      'activeItemCount': usage.activeItemCount,
      'userCount': usage.userCount,
      'locationCount': usage.locationCount,
      'photoCount': usage.photoCount,
      'labelExportCount': usage.labelExportCount,
    };
  }

  static Map<String, Object?> _unit(UnitOfMeasure unit) {
    return {
      'id': unit.id,
      'name': unit.name,
      'abbreviation': unit.abbreviation,
      'allowsDecimal': unit.allowsDecimal,
      'isActive': unit.isActive,
    };
  }

  static Map<String, Object?> _location(Location location) {
    return {
      'id': location.id,
      'name': location.name,
      'type': location.type,
      'parentLocationId': location.parentLocationId,
      'isActive': location.isActive,
    };
  }

  static Map<String, Object?> _person(Person person) {
    return {
      'id': person.id,
      'displayName': person.displayName,
      'email': person.email,
      'phone': person.phone,
      'isActive': person.isActive,
      'isLoginUser': person.isLoginUser,
    };
  }

  static Map<String, Object?> _user(AppUser user) {
    return {
      'id': user.id,
      'personId': user.personId,
      'email': user.email,
      'role': user.role.name,
      'isActive': user.isActive,
      'pinHash': user.pinHash,
      'pinSalt': user.pinSalt,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt.toIso8601String(),
      'lastLoginAt': user.lastLoginAt?.toIso8601String(),
    };
  }

  static Map<String, Object?> _assignmentTarget(AssignmentTarget target) {
    return {
      'id': target.id,
      'name': target.name,
      'targetType': target.targetType.name,
      'code': target.code,
      'description': target.description,
      'locationId': target.locationId,
      'isActive': target.isActive,
      'createdAt': target.createdAt.toIso8601String(),
      'updatedAt': target.updatedAt.toIso8601String(),
    };
  }

  static Map<String, Object?> _item(Item item) {
    return {
      'id': item.id,
      'name': item.name,
      'description': item.description,
      'itemType': item.itemType.name,
      'category': item.category,
      'locationId': item.locationId,
      'quantityOnHand': item.quantityOnHand,
      'minimumQuantity': item.minimumQuantity,
      'unitOfMeasureId': item.unitOfMeasureId,
      'purchaseUnitOfMeasureId': item.purchaseUnitOfMeasureId,
      'purchaseToStockConversionFactor': item.purchaseToStockConversionFactor,
      'purchaseUnitLabel': item.purchaseUnitLabel,
      'barcode': item.barcode,
      'sku': item.sku,
      'supplier': item.supplier,
      'unitCost': item.unitCost,
      'photoPath': item.photoPath,
      'isActive': item.isActive,
      'allowFractionalQuantity': item.allowFractionalQuantity,
      'createdAt': item.createdAt.toIso8601String(),
      'updatedAt': item.updatedAt.toIso8601String(),
    };
  }

  static Map<String, Object?> _balance(ItemLocationBalance balance) {
    return {
      'id': balance.id,
      'itemId': balance.itemId,
      'locationId': balance.locationId,
      'quantityOnHand': balance.quantityOnHand,
      'minimumQuantity': balance.minimumQuantity,
      'updatedAt': balance.updatedAt.toIso8601String(),
    };
  }

  static Map<String, Object?> _transaction(InventoryTransaction transaction) {
    return {
      'id': transaction.id,
      'itemId': transaction.itemId,
      'transactionType': transaction.transactionType.name,
      'quantityDelta': transaction.quantityDelta,
      'unitOfMeasureId': transaction.unitOfMeasureId,
      'fromLocationId': transaction.fromLocationId,
      'toLocationId': transaction.toLocationId,
      'assignedToPersonId': transaction.assignedToPersonId,
      'assignedToLocationId': transaction.assignedToLocationId,
      'assignedToTargetId': transaction.assignedToTargetId,
      'assignedToText': transaction.assignedToText,
      'performedByUserId': transaction.performedByUserId,
      'notes': transaction.notes,
      'createdAt': transaction.createdAt.toIso8601String(),
    };
  }

  static Map<String, Object?> _checkout(CheckoutRecord record) {
    return {
      'id': record.id,
      'itemId': record.itemId,
      'assignedToPersonId': record.assignedToPersonId,
      'assignedToLocationId': record.assignedToLocationId,
      'assignedToTargetId': record.assignedToTargetId,
      'assignedToText': record.assignedToText,
      'quantity': record.quantity,
      'quantityCheckedOut': record.quantityCheckedOut,
      'quantityReturned': record.quantityReturned,
      'quantityOpen': record.quantityOpen,
      'sourceLocationId': record.sourceLocationId,
      'unitOfMeasureId': record.unitOfMeasureId,
      'status': record.status.name,
      'checkedOutAt': record.checkedOutAt.toIso8601String(),
      'dueAt': record.dueAt?.toIso8601String(),
      'returnedAt': record.returnedAt?.toIso8601String(),
      'checkedOutByUserId': record.checkedOutByUserId,
      'returnedByUserId': record.returnedByUserId,
      'notes': record.notes,
      'returnNotes': record.returnNotes,
      'conditionOnReturn': record.conditionOnReturn?.name,
    };
  }

  static Map<String, Object?> _reorder(ReorderRequest request) {
    return {
      'id': request.id,
      'itemId': request.itemId,
      'requestedQuantity': request.requestedQuantity,
      'unitOfMeasureId': request.unitOfMeasureId,
      'supplier': request.supplier,
      'status': request.status.name,
      'notes': request.notes,
      'createdAt': request.createdAt.toIso8601String(),
      'orderedAt': request.orderedAt?.toIso8601String(),
      'receivedAt': request.receivedAt?.toIso8601String(),
      'createdByUserId': request.createdByUserId,
    };
  }

  static Map<String, Object?> _countSession(CycleCountSession session) {
    return {
      'id': session.id,
      'name': session.name,
      'status': session.status.name,
      'assignedToUserId': session.assignedToUserId,
      'blindCount': session.blindCount,
      'dueAt': session.dueAt?.toIso8601String(),
      'createdAt': session.createdAt.toIso8601String(),
      'submittedAt': session.submittedAt?.toIso8601String(),
      'approvedAt': session.approvedAt?.toIso8601String(),
    };
  }

  static Map<String, Object?> _countLine(CycleCountLine line) {
    return {
      'id': line.id,
      'sessionId': line.sessionId,
      'itemId': line.itemId,
      'locationId': line.locationId,
      'expectedQuantity': line.expectedQuantity,
      'countedQuantity': line.countedQuantity,
      'varianceQuantity': line.varianceQuantity,
      'unitOfMeasureId': line.unitOfMeasureId,
      'notes': line.notes,
    };
  }

  static Map<String, Object?> _customFieldDefinition(
    CustomFieldDefinition field,
  ) {
    return {
      'id': field.id,
      'entityType': field.entityType.name,
      'name': field.name,
      'fieldType': field.fieldType.name,
      'isRequired': field.isRequired,
      'options': field.options,
      'appliesToItemType': field.appliesToItemType?.name,
      'appliesToCategory': field.appliesToCategory,
      'sortOrder': field.sortOrder,
      'isActive': field.isActive,
    };
  }

  static Map<String, Object?> _customFieldValue(CustomFieldValue value) {
    return {
      'id': value.id,
      'definitionId': value.definitionId,
      'entityId': value.entityId,
      'textValue': value.textValue,
      'numberValue': value.numberValue,
      'dateValue': value.dateValue?.toIso8601String(),
      'booleanValue': value.booleanValue,
      'selectedOption': value.selectedOption,
    };
  }

  static DateTime? _date(Object? value) {
    return value == null ? null : DateTime.tryParse('$value');
  }

  static List<Map<String, dynamic>> _list(Object? value) {
    if (value is! List) {
      return const [];
    }
    return value.whereType<Map>().map((row) {
      return Map<String, dynamic>.from(row);
    }).toList();
  }

  static Map<String, dynamic>? _map(Object? value) {
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  static String _string(Map<String, dynamic> row, String key, String fallback) {
    return row[key]?.toString() ?? fallback;
  }

  static double _double(
    Map<String, dynamic> row,
    String key, [
    double fallback = 0,
  ]) {
    final value = row[key];
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('$value') ?? fallback;
  }

  static int _int(Map<String, dynamic> row, String key, [int fallback = 0]) {
    final value = row[key];
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value') ?? fallback;
  }

  static bool _bool(
    Map<String, dynamic> row,
    String key, [
    bool fallback = false,
  ]) {
    final value = row[key];
    if (value is bool) {
      return value;
    }
    return value?.toString().toLowerCase() == 'true' ? true : fallback;
  }

  static T? _enum<T extends Enum>(
    List<T> values,
    Object? value,
    List<String> warnings,
    String label,
  ) {
    final name = value?.toString();
    for (final enumValue in values) {
      if (enumValue.name == name) {
        return enumValue;
      }
    }
    warnings.add('Skipped record with unknown $label: $name.');
    return null;
  }

  static Company? _parseCompany(Map<String, dynamic>? row) {
    if (row == null) {
      return null;
    }
    final now = DateTime.now();
    return Company(
      id: _string(row, 'id', 'company-local'),
      name: _string(row, 'name', 'Issued Workspace'),
      industry: row['industry']?.toString(),
      createdAt: _date(row['createdAt']) ?? now,
      updatedAt: _date(row['updatedAt']) ?? now,
      setupCompleted: _bool(row, 'setupCompleted', true),
    );
  }

  static Plan? _parsePlan(Map<String, dynamic>? row) {
    if (row == null) {
      return null;
    }
    return Plan(
      code: _string(row, 'code', 'free'),
      name: _string(row, 'name', 'Free'),
      itemLimit: _int(row, 'itemLimit', 100),
      userLimit: _int(row, 'userLimit', 1),
      locationLimit: _int(row, 'locationLimit', 2),
      photoLimit: _int(row, 'photoLimit', 50),
      labelExportLimit: _int(row, 'labelExportLimit', 5),
      csvImportEnabled: _bool(row, 'csvImportEnabled'),
      advancedReportsEnabled: _bool(row, 'advancedReportsEnabled'),
    );
  }

  static CompanyUsage? _parseCompanyUsage(Map<String, dynamic>? row) {
    if (row == null) {
      return null;
    }
    return CompanyUsage(
      activeItemCount: _int(row, 'activeItemCount'),
      userCount: _int(row, 'userCount'),
      locationCount: _int(row, 'locationCount'),
      photoCount: _int(row, 'photoCount'),
      labelExportCount: _int(row, 'labelExportCount'),
    );
  }

  static UnitOfMeasure? _parseUnit(
    Map<String, dynamic> row,
    List<String> warnings,
  ) {
    final id = row['id']?.toString();
    if (id == null) {
      warnings.add('Skipped unit without an id.');
      return null;
    }
    return UnitOfMeasure(
      id: id,
      name: _string(row, 'name', id),
      abbreviation: _string(row, 'abbreviation', id),
      allowsDecimal: _bool(row, 'allowsDecimal'),
      isActive: _bool(row, 'isActive', true),
    );
  }

  static Location? _parseLocation(
    Map<String, dynamic> row,
    List<String> warnings,
  ) {
    final id = row['id']?.toString();
    if (id == null) {
      warnings.add('Skipped location without an id.');
      return null;
    }
    return Location(
      id: id,
      name: _string(row, 'name', id),
      type: _string(row, 'type', 'Other'),
      parentLocationId: row['parentLocationId']?.toString(),
      isActive: _bool(row, 'isActive', true),
    );
  }

  static Person? _parsePerson(Map<String, dynamic> row, List<String> warnings) {
    final id = row['id']?.toString();
    if (id == null) {
      warnings.add('Skipped person without an id.');
      return null;
    }
    return Person(
      id: id,
      displayName: _string(row, 'displayName', 'Unknown'),
      email: row['email']?.toString(),
      phone: row['phone']?.toString(),
      isActive: _bool(row, 'isActive', true),
      isLoginUser: _bool(row, 'isLoginUser'),
    );
  }

  static AppUser? _parseUser(Map<String, dynamic> row, List<String> warnings) {
    final role = _enum(UserRole.values, row['role'], warnings, 'user role');
    final id = row['id']?.toString();
    if (id == null || role == null) {
      return null;
    }
    return AppUser(
      id: id,
      personId: _string(row, 'personId', ''),
      email: _string(row, 'email', ''),
      role: role,
      isActive: _bool(row, 'isActive', true),
      pinHash: row['pinHash']?.toString(),
      pinSalt: row['pinSalt']?.toString(),
      createdAt: _date(row['createdAt']) ?? DateTime.now(),
      updatedAt:
          _date(row['updatedAt']) ?? _date(row['createdAt']) ?? DateTime.now(),
      lastLoginAt: _date(row['lastLoginAt']),
    );
  }

  static AssignmentTarget? _parseAssignmentTarget(
    Map<String, dynamic> row,
    List<String> warnings,
  ) {
    final type = _enum(
      AssignmentTargetType.values,
      row['targetType'],
      warnings,
      'assignment target type',
    );
    final id = row['id']?.toString();
    if (id == null || type == null) {
      return null;
    }
    final now = DateTime.now();
    return AssignmentTarget(
      id: id,
      name: _string(row, 'name', id),
      targetType: type,
      code: row['code']?.toString(),
      description: row['description']?.toString(),
      locationId: row['locationId']?.toString(),
      isActive: _bool(row, 'isActive', true),
      createdAt: _date(row['createdAt']) ?? now,
      updatedAt: _date(row['updatedAt']) ?? now,
    );
  }

  static Item? _parseItem(Map<String, dynamic> row, List<String> warnings) {
    final type = _enum(ItemType.values, row['itemType'], warnings, 'item type');
    final id = row['id']?.toString();
    if (id == null || type == null) {
      return null;
    }
    final now = DateTime.now();
    return Item(
      id: id,
      name: _string(row, 'name', id),
      description: _string(row, 'description', ''),
      itemType: type,
      category: _string(row, 'category', ''),
      locationId: _string(row, 'locationId', ''),
      quantityOnHand: _double(row, 'quantityOnHand'),
      minimumQuantity: _double(row, 'minimumQuantity'),
      unitOfMeasureId: _string(row, 'unitOfMeasureId', ''),
      purchaseUnitOfMeasureId: row['purchaseUnitOfMeasureId']?.toString(),
      purchaseToStockConversionFactor:
          row['purchaseToStockConversionFactor'] == null
          ? null
          : _double(row, 'purchaseToStockConversionFactor'),
      purchaseUnitLabel: row['purchaseUnitLabel']?.toString(),
      barcode: row['barcode']?.toString(),
      sku: row['sku']?.toString(),
      supplier: row['supplier']?.toString(),
      unitCost: row['unitCost'] == null ? null : _double(row, 'unitCost'),
      photoPath: row['photoPath']?.toString(),
      isActive: _bool(row, 'isActive', true),
      allowFractionalQuantity: _bool(row, 'allowFractionalQuantity'),
      createdAt: _date(row['createdAt']) ?? now,
      updatedAt: _date(row['updatedAt']) ?? now,
    );
  }

  static ItemLocationBalance? _parseBalance(
    Map<String, dynamic> row,
    List<String> warnings,
  ) {
    final id = row['id']?.toString();
    if (id == null) {
      warnings.add('Skipped balance without an id.');
      return null;
    }
    return ItemLocationBalance(
      id: id,
      itemId: _string(row, 'itemId', ''),
      locationId: _string(row, 'locationId', ''),
      quantityOnHand: _double(row, 'quantityOnHand'),
      minimumQuantity: _double(row, 'minimumQuantity'),
      updatedAt: _date(row['updatedAt']) ?? DateTime.now(),
    );
  }

  static InventoryTransaction? _parseTransaction(
    Map<String, dynamic> row,
    List<String> warnings,
  ) {
    final type = _enum(
      InventoryTransactionType.values,
      row['transactionType'],
      warnings,
      'transaction type',
    );
    final id = row['id']?.toString();
    if (id == null || type == null) {
      return null;
    }
    return InventoryTransaction(
      id: id,
      itemId: _string(row, 'itemId', ''),
      transactionType: type,
      quantityDelta: _double(row, 'quantityDelta'),
      unitOfMeasureId: _string(row, 'unitOfMeasureId', ''),
      fromLocationId: row['fromLocationId']?.toString(),
      toLocationId: row['toLocationId']?.toString(),
      assignedToPersonId: row['assignedToPersonId']?.toString(),
      assignedToLocationId: row['assignedToLocationId']?.toString(),
      assignedToTargetId: row['assignedToTargetId']?.toString(),
      assignedToText: row['assignedToText']?.toString(),
      performedByUserId: row['performedByUserId']?.toString(),
      notes: row['notes']?.toString(),
      createdAt: _date(row['createdAt']) ?? DateTime.now(),
    );
  }

  static CheckoutRecord? _parseCheckout(
    Map<String, dynamic> row,
    List<String> warnings,
  ) {
    final status = _enum(
      CheckoutStatus.values,
      row['status'],
      warnings,
      'checkout status',
    );
    final id = row['id']?.toString();
    if (id == null || status == null) {
      return null;
    }
    final quantity = _double(
      row,
      row.containsKey('quantityCheckedOut') ? 'quantityCheckedOut' : 'quantity',
    );
    final returned = row.containsKey('quantityReturned')
        ? _double(row, 'quantityReturned')
        : status == CheckoutStatus.returned
        ? quantity
        : 0.0;
    return CheckoutRecord(
      id: id,
      itemId: _string(row, 'itemId', ''),
      assignedToPersonId: row['assignedToPersonId']?.toString(),
      assignedToLocationId: row['assignedToLocationId']?.toString(),
      assignedToTargetId: row['assignedToTargetId']?.toString(),
      assignedToText: row['assignedToText']?.toString(),
      quantity: quantity,
      quantityReturned: returned,
      sourceLocationId: row['sourceLocationId']?.toString(),
      unitOfMeasureId: _string(row, 'unitOfMeasureId', ''),
      status: status,
      checkedOutAt: _date(row['checkedOutAt']) ?? DateTime.now(),
      dueAt: _date(row['dueAt']),
      returnedAt: _date(row['returnedAt']),
      checkedOutByUserId: row['checkedOutByUserId']?.toString(),
      returnedByUserId: row['returnedByUserId']?.toString(),
      notes: row['notes']?.toString(),
      returnNotes: row['returnNotes']?.toString(),
      conditionOnReturn: row['conditionOnReturn'] == null
          ? null
          : _enum(
              CheckoutReturnCondition.values,
              row['conditionOnReturn'],
              warnings,
              'checkout return condition',
            ),
    );
  }

  static ReorderRequest? _parseReorder(
    Map<String, dynamic> row,
    List<String> warnings,
  ) {
    final status = _enum(
      ReorderStatus.values,
      row['status'],
      warnings,
      'reorder status',
    );
    final id = row['id']?.toString();
    if (id == null || status == null) {
      return null;
    }
    return ReorderRequest(
      id: id,
      itemId: _string(row, 'itemId', ''),
      requestedQuantity: _double(row, 'requestedQuantity'),
      unitOfMeasureId: _string(row, 'unitOfMeasureId', ''),
      supplier: row['supplier']?.toString(),
      status: status,
      notes: row['notes']?.toString(),
      createdAt: _date(row['createdAt']) ?? DateTime.now(),
      orderedAt: _date(row['orderedAt']),
      receivedAt: _date(row['receivedAt']),
      createdByUserId: row['createdByUserId']?.toString(),
    );
  }

  static CycleCountSession? _parseCountSession(
    Map<String, dynamic> row,
    List<String> warnings,
  ) {
    final status = _enum(
      CycleCountStatus.values,
      row['status'],
      warnings,
      'cycle count status',
    );
    final id = row['id']?.toString();
    if (id == null || status == null) {
      return null;
    }
    return CycleCountSession(
      id: id,
      name: _string(row, 'name', id),
      status: status,
      assignedToUserId: row['assignedToUserId']?.toString(),
      blindCount: _bool(row, 'blindCount', true),
      dueAt: _date(row['dueAt']),
      createdAt: _date(row['createdAt']) ?? DateTime.now(),
      submittedAt: _date(row['submittedAt']),
      approvedAt: _date(row['approvedAt']),
    );
  }

  static CycleCountLine? _parseCountLine(
    Map<String, dynamic> row,
    List<String> warnings,
  ) {
    final id = row['id']?.toString();
    if (id == null) {
      warnings.add('Skipped cycle count line without an id.');
      return null;
    }
    return CycleCountLine(
      id: id,
      sessionId: _string(row, 'sessionId', ''),
      itemId: _string(row, 'itemId', ''),
      locationId: _string(row, 'locationId', ''),
      expectedQuantity: _double(row, 'expectedQuantity'),
      countedQuantity: row['countedQuantity'] == null
          ? null
          : _double(row, 'countedQuantity'),
      varianceQuantity: row['varianceQuantity'] == null
          ? null
          : _double(row, 'varianceQuantity'),
      unitOfMeasureId: _string(row, 'unitOfMeasureId', ''),
      notes: row['notes']?.toString(),
    );
  }

  static CustomFieldDefinition? _parseCustomFieldDefinition(
    Map<String, dynamic> row,
    List<String> warnings,
  ) {
    final entityType = _enum(
      CustomFieldEntityType.values,
      row['entityType'],
      warnings,
      'custom field entity type',
    );
    final fieldType = _enum(
      CustomFieldType.values,
      row['fieldType'],
      warnings,
      'custom field type',
    );
    final id = row['id']?.toString();
    if (id == null || entityType == null || fieldType == null) {
      return null;
    }
    return CustomFieldDefinition(
      id: id,
      entityType: entityType,
      name: _string(row, 'name', id),
      fieldType: fieldType,
      isRequired: _bool(row, 'isRequired'),
      options: row['options'] is List
          ? List<String>.from(row['options'] as List)
          : const [],
      appliesToItemType: row['appliesToItemType'] == null
          ? null
          : _enum(
              ItemType.values,
              row['appliesToItemType'],
              warnings,
              'item type',
            ),
      appliesToCategory: row['appliesToCategory']?.toString(),
      sortOrder: _int(row, 'sortOrder'),
      isActive: _bool(row, 'isActive', true),
    );
  }

  static CustomFieldValue? _parseCustomFieldValue(
    Map<String, dynamic> row,
    List<String> warnings,
  ) {
    final id = row['id']?.toString();
    if (id == null) {
      warnings.add('Skipped custom field value without an id.');
      return null;
    }
    return CustomFieldValue(
      id: id,
      definitionId: _string(row, 'definitionId', ''),
      entityId: _string(row, 'entityId', ''),
      textValue: row['textValue']?.toString(),
      numberValue: row['numberValue'] == null
          ? null
          : _double(row, 'numberValue'),
      dateValue: _date(row['dateValue']),
      booleanValue: row['booleanValue'] is bool
          ? row['booleanValue'] as bool
          : null,
      selectedOption: row['selectedOption']?.toString(),
    );
  }
}

class BackupValidationResult {
  const BackupValidationResult({
    required this.isValid,
    required this.message,
    this.errors = const [],
    this.warnings = const [],
    this.counts = const BackupCounts(),
    this.companyName,
    this.backupVersion,
    this.createdAt,
  });

  final bool isValid;
  final String message;
  final List<String> errors;
  final List<String> warnings;
  final BackupCounts counts;
  final String? companyName;
  final int? backupVersion;
  final DateTime? createdAt;
}

class BackupCounts {
  const BackupCounts({
    this.items = 0,
    this.locations = 0,
    this.people = 0,
    this.users = 0,
    this.transactions = 0,
    this.cycleCounts = 0,
    this.balances = 0,
    this.checkouts = 0,
    this.reorderRequests = 0,
    this.assignmentTargets = 0,
    this.customFields = 0,
  });

  factory BackupCounts.fromJson(Map<String, dynamic> json) {
    int count(String key) => json[key] is List ? (json[key] as List).length : 0;
    return BackupCounts(
      items: count('items'),
      locations: count('locations'),
      people: count('people'),
      users: count('users'),
      transactions: count('inventoryTransactions'),
      cycleCounts: count('cycleCountSessions'),
      balances: count('itemLocationBalances'),
      checkouts: count('checkoutRecords'),
      reorderRequests: count('reorderRequests'),
      assignmentTargets: count('assignmentTargets'),
      customFields: count('customFieldDefinitions'),
    );
  }

  final int items;
  final int locations;
  final int people;
  final int users;
  final int transactions;
  final int cycleCounts;
  final int balances;
  final int checkouts;
  final int reorderRequests;
  final int assignmentTargets;
  final int customFields;
}

class IssuedBackupData {
  const IssuedBackupData({
    required this.company,
    required this.plan,
    required this.companyUsage,
    required this.unitsOfMeasure,
    required this.locations,
    required this.people,
    required this.users,
    required this.assignmentTargets,
    required this.items,
    required this.itemLocationBalances,
    required this.transactions,
    required this.checkoutRecords,
    required this.reorderRequests,
    required this.cycleCountSessions,
    required this.cycleCountLines,
    required this.customFieldDefinitions,
    required this.customFieldValues,
    required this.warnings,
  });

  final Company? company;
  final Plan? plan;
  final CompanyUsage? companyUsage;
  final List<UnitOfMeasure> unitsOfMeasure;
  final List<Location> locations;
  final List<Person> people;
  final List<AppUser> users;
  final List<AssignmentTarget> assignmentTargets;
  final List<Item> items;
  final List<ItemLocationBalance> itemLocationBalances;
  final List<InventoryTransaction> transactions;
  final List<CheckoutRecord> checkoutRecords;
  final List<ReorderRequest> reorderRequests;
  final List<CycleCountSession> cycleCountSessions;
  final List<CycleCountLine> cycleCountLines;
  final List<CustomFieldDefinition> customFieldDefinitions;
  final List<CustomFieldValue> customFieldValues;
  final List<String> warnings;
}
