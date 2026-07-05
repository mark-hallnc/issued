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
      'items': store.items.map(_item).toList(),
      'itemLocationBalances': store.itemLocationBalances.map(_balance).toList(),
      'inventoryTransactions': store.transactions.map(_transaction).toList(),
      'checkoutRecords': store.checkoutRecords.map(_checkout).toList(),
      'reorderRequests': store.reorderRequests.map(_reorder).toList(),
      'cycleCountSessions': store.cycleCountSessions.map(_countSession).toList(),
      'cycleCountLines': store.cycleCountLines.map(_countLine).toList(),
      'customFieldDefinitions': store.customFieldDefinitions
          .map(_customFieldDefinition)
          .toList(),
      'customFieldValues': store.customFieldValues.map(_customFieldValue).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  BackupValidationResult validateBackupJson(String jsonText) {
    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map<String, dynamic>) {
        return const BackupValidationResult(
          isValid: false,
          message: 'Backup file must contain a JSON object.',
        );
      }

      final version = decoded['backupVersion'];
      if (version == null) {
        return const BackupValidationResult(
          isValid: false,
          message: 'Backup version is missing.',
        );
      }

      final appName = decoded['appName'];
      if (appName != 'Issued') {
        return const BackupValidationResult(
          isValid: false,
          message: 'This does not look like an Issued backup.',
        );
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
          return BackupValidationResult(
            isValid: false,
            message: 'Backup is missing $key.',
          );
        }
      }

      return BackupValidationResult(
        isValid: true,
        message: 'Backup is valid.',
        backupVersion: version is int ? version : int.tryParse('$version'),
        createdAt: _date(decoded['createdAt']),
      );
    } catch (_) {
      return const BackupValidationResult(
        isValid: false,
        message: 'Backup file is not valid JSON.',
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
      'createdAt': user.createdAt.toIso8601String(),
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
      'assignedToText': record.assignedToText,
      'quantity': record.quantity,
      'unitOfMeasureId': record.unitOfMeasureId,
      'status': record.status.name,
      'checkedOutAt': record.checkedOutAt.toIso8601String(),
      'dueAt': record.dueAt?.toIso8601String(),
      'returnedAt': record.returnedAt?.toIso8601String(),
      'checkedOutByUserId': record.checkedOutByUserId,
      'returnedByUserId': record.returnedByUserId,
      'notes': record.notes,
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
}

class BackupValidationResult {
  const BackupValidationResult({
    required this.isValid,
    required this.message,
    this.backupVersion,
    this.createdAt,
  });

  final bool isValid;
  final String message;
  final int? backupVersion;
  final DateTime? createdAt;
}
