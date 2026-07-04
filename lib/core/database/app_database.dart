import 'package:drift/drift.dart';

import 'database_connection.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Items,
    UnitsOfMeasure,
    Locations,
    People,
    AppUsers,
    InventoryTransactions,
    ReorderRequests,
    CycleCountSessions,
    CycleCountLines,
    CustomFieldDefinitions,
    CustomFieldValues,
    Plans,
    CompanyUsages,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? openDatabaseConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(reorderRequests);
        }
      },
    );
  }

  Future<bool> get isEmpty async {
    final itemCount = await select(items).get();
    return itemCount.isEmpty;
  }

  Future<List<ItemRecord>> getAllItems() => select(items).get();
  Future<List<UnitOfMeasureRecord>> getAllUnitsOfMeasure() =>
      select(unitsOfMeasure).get();
  Future<List<LocationRecord>> getAllLocations() => select(locations).get();
  Future<List<PersonRecord>> getAllPeople() => select(people).get();
  Future<List<AppUserRecord>> getAllAppUsers() => select(appUsers).get();
  Future<List<InventoryTransactionRecord>> getAllTransactions() =>
      select(inventoryTransactions).get();
  Future<List<ReorderRequestRecord>> getAllReorderRequests() =>
      select(reorderRequests).get();
  Future<List<CycleCountSessionRecord>> getAllCycleCountSessions() =>
      select(cycleCountSessions).get();
  Future<List<CycleCountLineRecord>> getAllCycleCountLines() =>
      select(cycleCountLines).get();
  Future<List<CustomFieldDefinitionRecord>> getAllCustomFieldDefinitions() =>
      select(customFieldDefinitions).get();
  Future<List<CustomFieldValueRecord>> getAllCustomFieldValues() =>
      select(customFieldValues).get();
  Future<List<PlanRecord>> getAllPlans() => select(plans).get();
  Future<List<CompanyUsageRecord>> getAllCompanyUsage() =>
      select(companyUsages).get();

  Future<void> upsertItem(ItemsCompanion item) {
    return into(items).insertOnConflictUpdate(item);
  }

  Future<void> upsertUnitOfMeasure(UnitsOfMeasureCompanion unit) {
    return into(unitsOfMeasure).insertOnConflictUpdate(unit);
  }

  Future<void> upsertLocation(LocationsCompanion location) {
    return into(locations).insertOnConflictUpdate(location);
  }

  Future<void> upsertPerson(PeopleCompanion person) {
    return into(people).insertOnConflictUpdate(person);
  }

  Future<void> upsertAppUser(AppUsersCompanion user) {
    return into(appUsers).insertOnConflictUpdate(user);
  }

  Future<void> upsertTransaction(InventoryTransactionsCompanion transaction) {
    return into(inventoryTransactions).insertOnConflictUpdate(transaction);
  }

  Future<void> upsertReorderRequest(ReorderRequestsCompanion request) {
    return into(reorderRequests).insertOnConflictUpdate(request);
  }

  Future<void> upsertCycleCountSession(CycleCountSessionsCompanion session) {
    return into(cycleCountSessions).insertOnConflictUpdate(session);
  }

  Future<void> upsertCycleCountLine(CycleCountLinesCompanion line) {
    return into(cycleCountLines).insertOnConflictUpdate(line);
  }

  Future<void> upsertCustomFieldDefinition(
    CustomFieldDefinitionsCompanion field,
  ) {
    return into(customFieldDefinitions).insertOnConflictUpdate(field);
  }

  Future<void> upsertCustomFieldValue(CustomFieldValuesCompanion value) {
    return into(customFieldValues).insertOnConflictUpdate(value);
  }

  Future<void> upsertPlan(PlansCompanion plan) {
    return into(plans).insertOnConflictUpdate(plan);
  }

  Future<void> upsertCompanyUsage(CompanyUsagesCompanion usage) {
    return into(companyUsages).insertOnConflictUpdate(usage);
  }
}
