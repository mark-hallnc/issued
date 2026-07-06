import 'package:drift/drift.dart';

@DataClassName('ItemRecord')
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get itemType => text()();
  TextColumn get category => text()();
  TextColumn get locationId => text()();
  RealColumn get quantityOnHand => real()();
  RealColumn get minimumQuantity => real()();
  TextColumn get unitOfMeasureId => text()();
  TextColumn get purchaseUnitOfMeasureId => text().nullable()();
  RealColumn get purchaseToStockConversionFactor => real().nullable()();
  TextColumn get purchaseUnitLabel => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get sku => text().nullable()();
  TextColumn get supplier => text().nullable()();
  RealColumn get unitCost => real().nullable()();
  TextColumn get photoPath => text().nullable()();
  BoolColumn get isActive => boolean()();
  BoolColumn get allowFractionalQuantity => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('UnitOfMeasureRecord')
class UnitsOfMeasure extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get abbreviation => text()();
  BoolColumn get allowsDecimal => boolean()();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LocationRecord')
class Locations extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get parentLocationId => text().nullable()();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PersonRecord')
class People extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  BoolColumn get isActive => boolean()();
  BoolColumn get isLoginUser => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AppUserRecord')
class AppUsers extends Table {
  TextColumn get id => text()();
  TextColumn get personId => text()();
  TextColumn get email => text()();
  TextColumn get role => text()();
  BoolColumn get isActive => boolean()();
  TextColumn get pinHash => text().nullable()();
  TextColumn get pinSalt => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('InventoryTransactionRecord')
class InventoryTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get transactionType => text()();
  RealColumn get quantityDelta => real()();
  TextColumn get unitOfMeasureId => text()();
  TextColumn get fromLocationId => text().nullable()();
  TextColumn get toLocationId => text().nullable()();
  TextColumn get assignedToPersonId => text().nullable()();
  TextColumn get assignedToLocationId => text().nullable()();
  TextColumn get assignedToTargetId => text().nullable()();
  TextColumn get assignedToText => text().nullable()();
  TextColumn get performedByUserId => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ItemLocationBalanceRecord')
class ItemLocationBalances extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get locationId => text()();
  RealColumn get quantityOnHand => real()();
  RealColumn get minimumQuantity => real().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ReorderRequestRecord')
class ReorderRequests extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  RealColumn get requestedQuantity => real()();
  TextColumn get unitOfMeasureId => text()();
  TextColumn get supplier => text().nullable()();
  TextColumn get status => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get orderedAt => dateTime().nullable()();
  DateTimeColumn get receivedAt => dateTime().nullable()();
  TextColumn get createdByUserId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CheckoutRecordRow')
class CheckoutRecords extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get assignedToPersonId => text().nullable()();
  TextColumn get assignedToLocationId => text().nullable()();
  TextColumn get assignedToTargetId => text().nullable()();
  TextColumn get assignedToText => text().nullable()();
  RealColumn get quantity => real()();
  RealColumn get quantityReturned => real().withDefault(const Constant(0))();
  TextColumn get sourceLocationId => text().nullable()();
  TextColumn get unitOfMeasureId => text()();
  TextColumn get status => text()();
  DateTimeColumn get checkedOutAt => dateTime()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get returnedAt => dateTime().nullable()();
  TextColumn get checkedOutByUserId => text().nullable()();
  TextColumn get returnedByUserId => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get returnNotes => text().nullable()();
  TextColumn get conditionOnReturn => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AssignmentTargetRecord')
class AssignmentTargets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get targetType => text()();
  TextColumn get code => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get locationId => text().nullable()();
  BoolColumn get isActive => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CycleCountSessionRecord')
class CycleCountSessions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get status => text()();
  TextColumn get assignedToUserId => text().nullable()();
  BoolColumn get blindCount => boolean()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get submittedAt => dateTime().nullable()();
  DateTimeColumn get approvedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CycleCountLineRecord')
class CycleCountLines extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get itemId => text()();
  TextColumn get locationId => text()();
  RealColumn get expectedQuantity => real()();
  RealColumn get countedQuantity => real().nullable()();
  RealColumn get varianceQuantity => real().nullable()();
  TextColumn get unitOfMeasureId => text()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CustomFieldDefinitionRecord')
class CustomFieldDefinitions extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get name => text()();
  TextColumn get fieldType => text()();
  BoolColumn get isRequired => boolean()();
  TextColumn get optionsJson => text()();
  TextColumn get appliesToItemType => text().nullable()();
  TextColumn get appliesToCategory => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CustomFieldValueRecord')
class CustomFieldValues extends Table {
  TextColumn get id => text()();
  TextColumn get definitionId => text()();
  TextColumn get entityId => text()();
  TextColumn get textValue => text().nullable()();
  RealColumn get numberValue => real().nullable()();
  DateTimeColumn get dateValue => dateTime().nullable()();
  BoolColumn get booleanValue => boolean().nullable()();
  TextColumn get selectedOption => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PlanRecord')
class Plans extends Table {
  TextColumn get code => text()();
  TextColumn get name => text()();
  IntColumn get itemLimit => integer()();
  IntColumn get userLimit => integer()();
  IntColumn get locationLimit => integer()();
  IntColumn get photoLimit => integer()();
  IntColumn get labelExportLimit => integer()();

  @override
  Set<Column<Object>> get primaryKey => {code};
}

@DataClassName('CompanyUsageRecord')
class CompanyUsages extends Table {
  TextColumn get id => text()();
  IntColumn get activeItemCount => integer()();
  IntColumn get userCount => integer()();
  IntColumn get locationCount => integer()();
  IntColumn get photoCount => integer()();
  IntColumn get labelExportCount => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CompanyRecord')
class Companies extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get industry => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get setupCompleted => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
