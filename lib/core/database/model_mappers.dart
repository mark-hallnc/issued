import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/models.dart' as domain;
import '../sample_data.dart';
import 'app_database.dart';

extension ItemRecordMapper on ItemRecord {
  domain.Item toDomain() {
    return domain.Item(
      id: id,
      name: name,
      description: description,
      itemType: _enumByName(domain.ItemType.values, itemType),
      category: category,
      locationId: locationId,
      quantityOnHand: quantityOnHand,
      minimumQuantity: minimumQuantity,
      unitOfMeasureId: unitOfMeasureId,
      barcode: barcode,
      sku: sku,
      supplier: supplier,
      unitCost: unitCost,
      photoPath: photoPath,
      isActive: isActive,
      allowFractionalQuantity: allowFractionalQuantity,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension ItemDomainMapper on domain.Item {
  ItemsCompanion toCompanion() {
    return ItemsCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      itemType: Value(itemType.name),
      category: Value(category),
      locationId: Value(locationId),
      quantityOnHand: Value(quantityOnHand),
      minimumQuantity: Value(minimumQuantity),
      unitOfMeasureId: Value(unitOfMeasureId),
      barcode: Value(barcode),
      sku: Value(sku),
      supplier: Value(supplier),
      unitCost: Value(unitCost),
      photoPath: Value(photoPath),
      isActive: Value(isActive),
      allowFractionalQuantity: Value(allowFractionalQuantity),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}

extension UnitOfMeasureRecordMapper on UnitOfMeasureRecord {
  domain.UnitOfMeasure toDomain() {
    return domain.UnitOfMeasure(
      id: id,
      name: name,
      abbreviation: abbreviation,
      allowsDecimal: allowsDecimal,
      isActive: isActive,
    );
  }
}

extension UnitOfMeasureDomainMapper on domain.UnitOfMeasure {
  UnitsOfMeasureCompanion toCompanion() {
    return UnitsOfMeasureCompanion(
      id: Value(id),
      name: Value(name),
      abbreviation: Value(abbreviation),
      allowsDecimal: Value(allowsDecimal),
      isActive: Value(isActive),
    );
  }
}

extension LocationRecordMapper on LocationRecord {
  domain.Location toDomain() {
    return domain.Location(
      id: id,
      name: name,
      type: type,
      parentLocationId: parentLocationId,
      isActive: isActive,
    );
  }
}

extension LocationDomainMapper on domain.Location {
  LocationsCompanion toCompanion() {
    return LocationsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      parentLocationId: Value(parentLocationId),
      isActive: Value(isActive),
    );
  }
}

extension PersonRecordMapper on PersonRecord {
  domain.Person toDomain() {
    return domain.Person(
      id: id,
      displayName: displayName,
      email: email,
      phone: phone,
      isActive: isActive,
      isLoginUser: isLoginUser,
    );
  }
}

extension PersonDomainMapper on domain.Person {
  PeopleCompanion toCompanion() {
    return PeopleCompanion(
      id: Value(id),
      displayName: Value(displayName),
      email: Value(email),
      phone: Value(phone),
      isActive: Value(isActive),
      isLoginUser: Value(isLoginUser),
    );
  }
}

extension AppUserRecordMapper on AppUserRecord {
  domain.AppUser toDomain() {
    return domain.AppUser(
      id: id,
      personId: personId,
      email: email,
      role: _enumByName(domain.UserRole.values, role),
      isActive: isActive,
      createdAt: createdAt,
    );
  }
}

extension AppUserDomainMapper on domain.AppUser {
  AppUsersCompanion toCompanion() {
    return AppUsersCompanion(
      id: Value(id),
      personId: Value(personId),
      email: Value(email),
      role: Value(role.name),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }
}

extension InventoryTransactionRecordMapper on InventoryTransactionRecord {
  domain.InventoryTransaction toDomain() {
    return domain.InventoryTransaction(
      id: id,
      itemId: itemId,
      transactionType: _enumByName(
        domain.InventoryTransactionType.values,
        transactionType,
      ),
      quantityDelta: quantityDelta,
      unitOfMeasureId: unitOfMeasureId,
      fromLocationId: fromLocationId,
      toLocationId: toLocationId,
      assignedToPersonId: assignedToPersonId,
      performedByUserId: performedByUserId,
      notes: notes,
      createdAt: createdAt,
    );
  }
}

extension InventoryTransactionDomainMapper on domain.InventoryTransaction {
  InventoryTransactionsCompanion toCompanion() {
    return InventoryTransactionsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      transactionType: Value(transactionType.name),
      quantityDelta: Value(quantityDelta),
      unitOfMeasureId: Value(unitOfMeasureId),
      fromLocationId: Value(fromLocationId),
      toLocationId: Value(toLocationId),
      assignedToPersonId: Value(assignedToPersonId),
      performedByUserId: Value(performedByUserId),
      notes: Value(notes),
      createdAt: Value(createdAt),
    );
  }
}

extension ReorderRequestRecordMapper on ReorderRequestRecord {
  domain.ReorderRequest toDomain() {
    return domain.ReorderRequest(
      id: id,
      itemId: itemId,
      requestedQuantity: requestedQuantity,
      unitOfMeasureId: unitOfMeasureId,
      supplier: supplier,
      status: _enumByName(domain.ReorderStatus.values, status),
      notes: notes,
      createdAt: createdAt,
      orderedAt: orderedAt,
      receivedAt: receivedAt,
      createdByUserId: createdByUserId,
    );
  }
}

extension ReorderRequestDomainMapper on domain.ReorderRequest {
  ReorderRequestsCompanion toCompanion() {
    return ReorderRequestsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      requestedQuantity: Value(requestedQuantity),
      unitOfMeasureId: Value(unitOfMeasureId),
      supplier: Value(supplier),
      status: Value(status.name),
      notes: Value(notes),
      createdAt: Value(createdAt),
      orderedAt: Value(orderedAt),
      receivedAt: Value(receivedAt),
      createdByUserId: Value(createdByUserId),
    );
  }
}

extension CycleCountSessionRecordMapper on CycleCountSessionRecord {
  domain.CycleCountSession toDomain() {
    return domain.CycleCountSession(
      id: id,
      name: name,
      status: _enumByName(domain.CycleCountStatus.values, status),
      assignedToUserId: assignedToUserId,
      blindCount: blindCount,
      dueAt: dueAt,
      createdAt: createdAt,
      submittedAt: submittedAt,
      approvedAt: approvedAt,
    );
  }
}

extension CycleCountSessionDomainMapper on domain.CycleCountSession {
  CycleCountSessionsCompanion toCompanion() {
    return CycleCountSessionsCompanion(
      id: Value(id),
      name: Value(name),
      status: Value(status.name),
      assignedToUserId: Value(assignedToUserId),
      blindCount: Value(blindCount),
      dueAt: Value(dueAt),
      createdAt: Value(createdAt),
      submittedAt: Value(submittedAt),
      approvedAt: Value(approvedAt),
    );
  }
}

extension CycleCountLineRecordMapper on CycleCountLineRecord {
  domain.CycleCountLine toDomain() {
    return domain.CycleCountLine(
      id: id,
      sessionId: sessionId,
      itemId: itemId,
      locationId: locationId,
      expectedQuantity: expectedQuantity,
      countedQuantity: countedQuantity,
      varianceQuantity: varianceQuantity,
      unitOfMeasureId: unitOfMeasureId,
      notes: notes,
    );
  }
}

extension CycleCountLineDomainMapper on domain.CycleCountLine {
  CycleCountLinesCompanion toCompanion() {
    return CycleCountLinesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      itemId: Value(itemId),
      locationId: Value(locationId),
      expectedQuantity: Value(expectedQuantity),
      countedQuantity: Value(countedQuantity),
      varianceQuantity: Value(varianceQuantity),
      unitOfMeasureId: Value(unitOfMeasureId),
      notes: Value(notes),
    );
  }
}

extension CustomFieldDefinitionRecordMapper on CustomFieldDefinitionRecord {
  domain.CustomFieldDefinition toDomain() {
    return domain.CustomFieldDefinition(
      id: id,
      entityType: _enumByName(domain.CustomFieldEntityType.values, entityType),
      name: name,
      fieldType: _enumByName(domain.CustomFieldType.values, fieldType),
      isRequired: isRequired,
      options: List<String>.from(jsonDecode(optionsJson) as List),
      isActive: isActive,
    );
  }
}

extension CustomFieldDefinitionDomainMapper on domain.CustomFieldDefinition {
  CustomFieldDefinitionsCompanion toCompanion() {
    return CustomFieldDefinitionsCompanion(
      id: Value(id),
      entityType: Value(entityType.name),
      name: Value(name),
      fieldType: Value(fieldType.name),
      isRequired: Value(isRequired),
      optionsJson: Value(jsonEncode(options)),
      isActive: Value(isActive),
    );
  }
}

extension CustomFieldValueRecordMapper on CustomFieldValueRecord {
  domain.CustomFieldValue toDomain() {
    return domain.CustomFieldValue(
      id: id,
      definitionId: definitionId,
      entityId: entityId,
      textValue: textValue,
      numberValue: numberValue,
      dateValue: dateValue,
      booleanValue: booleanValue,
      selectedOption: selectedOption,
    );
  }
}

extension CustomFieldValueDomainMapper on domain.CustomFieldValue {
  CustomFieldValuesCompanion toCompanion() {
    return CustomFieldValuesCompanion(
      id: Value(id),
      definitionId: Value(definitionId),
      entityId: Value(entityId),
      textValue: Value(textValue),
      numberValue: Value(numberValue),
      dateValue: Value(dateValue),
      booleanValue: Value(booleanValue),
      selectedOption: Value(selectedOption),
    );
  }
}

extension PlanRecordMapper on PlanRecord {
  domain.Plan toDomain() {
    final planDefaults = samplePlans.firstWhere(
      (plan) => plan.code == code,
      orElse: () => samplePlan,
    );

    return domain.Plan(
      code: code,
      name: planDefaults.code == code ? planDefaults.name : name,
      itemLimit: planDefaults.code == code ? planDefaults.itemLimit : itemLimit,
      userLimit: planDefaults.code == code ? planDefaults.userLimit : userLimit,
      locationLimit: planDefaults.code == code
          ? planDefaults.locationLimit
          : locationLimit,
      photoLimit: planDefaults.code == code
          ? planDefaults.photoLimit
          : photoLimit,
      labelExportLimit: planDefaults.code == code
          ? planDefaults.labelExportLimit
          : labelExportLimit,
      csvImportEnabled: planDefaults.csvImportEnabled,
      advancedReportsEnabled: planDefaults.advancedReportsEnabled,
    );
  }
}

extension PlanDomainMapper on domain.Plan {
  PlansCompanion toCompanion() {
    return PlansCompanion(
      code: Value(code),
      name: Value(name),
      itemLimit: Value(itemLimit),
      userLimit: Value(userLimit),
      locationLimit: Value(locationLimit),
      photoLimit: Value(photoLimit),
      labelExportLimit: Value(labelExportLimit),
    );
  }
}

extension CompanyUsageRecordMapper on CompanyUsageRecord {
  domain.CompanyUsage toDomain() {
    return domain.CompanyUsage(
      activeItemCount: activeItemCount,
      userCount: userCount,
      locationCount: locationCount,
      photoCount: photoCount,
      labelExportCount: labelExportCount,
    );
  }
}

extension CompanyUsageDomainMapper on domain.CompanyUsage {
  CompanyUsagesCompanion toCompanion() {
    return CompanyUsagesCompanion(
      id: const Value('company'),
      activeItemCount: Value(activeItemCount),
      userCount: Value(userCount),
      locationCount: Value(locationCount),
      photoCount: Value(photoCount),
      labelExportCount: Value(labelExportCount),
    );
  }
}

T _enumByName<T extends Enum>(List<T> values, String name) {
  return values.firstWhere((value) => value.name == name);
}
