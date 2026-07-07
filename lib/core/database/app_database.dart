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
    ItemLocationBalances,
    Suppliers,
    ReorderRequests,
    CheckoutRecords,
    AssignmentTargets,
    CycleCountSessions,
    CycleCountLines,
    CustomFieldDefinitions,
    CustomFieldValues,
    Plans,
    CompanyUsages,
    Companies,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? openDatabaseConnection());

  @override
  int get schemaVersion => 15;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(reorderRequests);
        }
        if (from < 3) {
          await migrator.createTable(checkoutRecords);
        }
        if (from < 4) {
          await migrator.createTable(companies);
        }
        if (from < 5) {
          await migrator.addColumn(
            customFieldDefinitions,
            customFieldDefinitions.appliesToItemType,
          );
          await migrator.addColumn(
            customFieldDefinitions,
            customFieldDefinitions.appliesToCategory,
          );
          await migrator.addColumn(
            customFieldDefinitions,
            customFieldDefinitions.sortOrder,
          );
        }
        if (from < 6) {
          await migrator.createTable(itemLocationBalances);
        }
        if (from < 7) {
          await migrator.addColumn(items, items.purchaseUnitOfMeasureId);
          await migrator.addColumn(
            items,
            items.purchaseToStockConversionFactor,
          );
          await migrator.addColumn(items, items.purchaseUnitLabel);
        }
        if (from < 8) {
          await migrator.createTable(assignmentTargets);
          await migrator.addColumn(
            inventoryTransactions,
            inventoryTransactions.assignedToTargetId,
          );
          await migrator.addColumn(
            inventoryTransactions,
            inventoryTransactions.assignedToText,
          );
          await migrator.addColumn(
            checkoutRecords,
            checkoutRecords.assignedToTargetId,
          );
        }
        if (from < 9) {
          await migrator.addColumn(appUsers, appUsers.pinHash);
          await migrator.addColumn(appUsers, appUsers.pinSalt);
          await migrator.addColumn(appUsers, appUsers.updatedAt);
          await migrator.addColumn(appUsers, appUsers.lastLoginAt);
        }
        if (from < 10) {
          await migrator.addColumn(
            checkoutRecords,
            checkoutRecords.quantityReturned,
          );
          await migrator.addColumn(
            checkoutRecords,
            checkoutRecords.sourceLocationId,
          );
          await migrator.addColumn(
            checkoutRecords,
            checkoutRecords.returnNotes,
          );
          await migrator.addColumn(
            checkoutRecords,
            checkoutRecords.conditionOnReturn,
          );
        }
        if (from < 11) {
          await migrator.addColumn(
            inventoryTransactions,
            inventoryTransactions.assignedToLocationId,
          );
          if (from >= 8) {
            await migrator.addColumn(assignmentTargets, assignmentTargets.code);
          }
        }
        if (from < 12) {
          await migrator.addColumn(
            reorderRequests,
            reorderRequests.receivedQuantity,
          );
          await migrator.addColumn(
            reorderRequests,
            reorderRequests.cancelledAt,
          );
          await migrator.addColumn(
            reorderRequests,
            reorderRequests.orderedByUserId,
          );
          await migrator.addColumn(
            reorderRequests,
            reorderRequests.receivedByUserId,
          );
          await migrator.addColumn(
            reorderRequests,
            reorderRequests.destinationLocationId,
          );
          await migrator.addColumn(
            reorderRequests,
            reorderRequests.purchaseUnitOfMeasureId,
          );
          await migrator.addColumn(
            reorderRequests,
            reorderRequests.purchaseQuantity,
          );
          await migrator.addColumn(
            reorderRequests,
            reorderRequests.purchaseToStockConversionFactor,
          );
          await migrator.addColumn(
            reorderRequests,
            reorderRequests.expectedCost,
          );
          await migrator.addColumn(
            reorderRequests,
            reorderRequests.orderNumber,
          );
        }
        if (from < 13) {
          await migrator.createTable(suppliers);
          await migrator.addColumn(items, items.supplierId);
          await migrator.addColumn(reorderRequests, reorderRequests.supplierId);
        }
        if (from < 14) {
          await migrator.addColumn(locations, locations.description);
          await migrator.addColumn(locations, locations.code);
          await migrator.addColumn(locations, locations.createdAt);
          await migrator.addColumn(locations, locations.updatedAt);
        }
        if (from < 15) {
          await migrator.addColumn(
            inventoryTransactions,
            inventoryTransactions.reversedByTransactionId,
          );
          await migrator.addColumn(
            inventoryTransactions,
            inventoryTransactions.reversesTransactionId,
          );
          await migrator.addColumn(
            inventoryTransactions,
            inventoryTransactions.correctionReason,
          );
          await migrator.addColumn(
            inventoryTransactions,
            inventoryTransactions.correctedAt,
          );
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
  Future<List<ItemLocationBalanceRecord>> getAllItemLocationBalances() =>
      select(itemLocationBalances).get();
  Future<List<SupplierRecord>> getAllSuppliers() => select(suppliers).get();
  Future<List<ReorderRequestRecord>> getAllReorderRequests() =>
      select(reorderRequests).get();
  Future<List<CheckoutRecordRow>> getAllCheckoutRecords() =>
      select(checkoutRecords).get();
  Future<List<AssignmentTargetRecord>> getAllAssignmentTargets() =>
      select(assignmentTargets).get();
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
  Future<List<CompanyRecord>> getAllCompanies() => select(companies).get();

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

  Future<void> upsertItemLocationBalance(
    ItemLocationBalancesCompanion balance,
  ) {
    return into(itemLocationBalances).insertOnConflictUpdate(balance);
  }

  Future<void> deleteItemLocationBalance(String id) {
    return (delete(
      itemLocationBalances,
    )..where((row) => row.id.equals(id))).go();
  }

  Future<void> upsertSupplier(SuppliersCompanion supplier) {
    return into(suppliers).insertOnConflictUpdate(supplier);
  }

  Future<void> upsertReorderRequest(ReorderRequestsCompanion request) {
    return into(reorderRequests).insertOnConflictUpdate(request);
  }

  Future<void> upsertCheckoutRecord(CheckoutRecordsCompanion record) {
    return into(checkoutRecords).insertOnConflictUpdate(record);
  }

  Future<void> upsertAssignmentTarget(AssignmentTargetsCompanion target) {
    return into(assignmentTargets).insertOnConflictUpdate(target);
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

  Future<void> deleteCustomFieldValueById(String id) {
    return (delete(
      customFieldValues,
    )..where((value) => value.id.equals(id))).go();
  }

  Future<void> upsertPlan(PlansCompanion plan) {
    return into(plans).insertOnConflictUpdate(plan);
  }

  Future<void> upsertCompanyUsage(CompanyUsagesCompanion usage) {
    return into(companyUsages).insertOnConflictUpdate(usage);
  }

  Future<void> upsertCompany(CompaniesCompanion company) {
    return into(companies).insertOnConflictUpdate(company);
  }

  Future<void> restoreWorkspaceData({
    required List<UnitsOfMeasureCompanion> unitRows,
    required List<LocationsCompanion> locationRows,
    required List<PeopleCompanion> personRows,
    required List<AppUsersCompanion> userRows,
    required List<ItemsCompanion> itemRows,
    required List<ItemLocationBalancesCompanion> balanceRows,
    required List<SuppliersCompanion> supplierRows,
    required List<InventoryTransactionsCompanion> transactionRows,
    required List<CheckoutRecordsCompanion> checkoutRows,
    required List<AssignmentTargetsCompanion> assignmentTargetRows,
    required List<ReorderRequestsCompanion> reorderRows,
    required List<CycleCountSessionsCompanion> cycleSessionRows,
    required List<CycleCountLinesCompanion> cycleLineRows,
    required List<CustomFieldDefinitionsCompanion> customFieldRows,
    required List<CustomFieldValuesCompanion> customValueRows,
    required List<PlansCompanion> planRows,
    required List<CompanyUsagesCompanion> usageRows,
    required List<CompaniesCompanion> companyRows,
  }) {
    return transaction(() async {
      await delete(customFieldValues).go();
      await delete(customFieldDefinitions).go();
      await delete(cycleCountLines).go();
      await delete(cycleCountSessions).go();
      await delete(reorderRequests).go();
      await delete(checkoutRecords).go();
      await delete(assignmentTargets).go();
      await delete(itemLocationBalances).go();
      await delete(inventoryTransactions).go();
      await delete(items).go();
      await delete(suppliers).go();
      await delete(appUsers).go();
      await delete(people).go();
      await delete(locations).go();
      await delete(unitsOfMeasure).go();
      await delete(companyUsages).go();
      await delete(companies).go();

      await batch((batch) {
        batch.insertAll(
          unitsOfMeasure,
          unitRows,
          mode: InsertMode.insertOrReplace,
        );
        batch.insertAll(
          locations,
          locationRows,
          mode: InsertMode.insertOrReplace,
        );
        batch.insertAll(people, personRows, mode: InsertMode.insertOrReplace);
        batch.insertAll(appUsers, userRows, mode: InsertMode.insertOrReplace);
        batch.insertAll(
          suppliers,
          supplierRows,
          mode: InsertMode.insertOrReplace,
        );
        batch.insertAll(items, itemRows, mode: InsertMode.insertOrReplace);
        batch.insertAll(
          itemLocationBalances,
          balanceRows,
          mode: InsertMode.insertOrReplace,
        );
        batch.insertAll(
          inventoryTransactions,
          transactionRows,
          mode: InsertMode.insertOrReplace,
        );
        batch.insertAll(
          checkoutRecords,
          checkoutRows,
          mode: InsertMode.insertOrReplace,
        );
        batch.insertAll(
          assignmentTargets,
          assignmentTargetRows,
          mode: InsertMode.insertOrReplace,
        );
        batch.insertAll(
          reorderRequests,
          reorderRows,
          mode: InsertMode.insertOrReplace,
        );
        batch.insertAll(
          cycleCountSessions,
          cycleSessionRows,
          mode: InsertMode.insertOrReplace,
        );
        batch.insertAll(
          cycleCountLines,
          cycleLineRows,
          mode: InsertMode.insertOrReplace,
        );
        batch.insertAll(
          customFieldDefinitions,
          customFieldRows,
          mode: InsertMode.insertOrReplace,
        );
        batch.insertAll(
          customFieldValues,
          customValueRows,
          mode: InsertMode.insertOrReplace,
        );
        batch.insertAll(plans, planRows, mode: InsertMode.insertOrReplace);
        batch.insertAll(
          companyUsages,
          usageRows,
          mode: InsertMode.insertOrReplace,
        );
        batch.insertAll(
          companies,
          companyRows,
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<void> clearLocalInventoryTestData() {
    return transaction(() async {
      await delete(customFieldValues).go();
      await delete(customFieldDefinitions).go();
      await delete(cycleCountLines).go();
      await delete(cycleCountSessions).go();
      await delete(reorderRequests).go();
      await delete(checkoutRecords).go();
      await delete(assignmentTargets).go();
      await delete(itemLocationBalances).go();
      await delete(inventoryTransactions).go();
      await delete(items).go();
      await delete(suppliers).go();
      await delete(locations).go();
    });
  }

  Future<void> clearAllLocalData() {
    return transaction(() async {
      await delete(customFieldValues).go();
      await delete(customFieldDefinitions).go();
      await delete(cycleCountLines).go();
      await delete(cycleCountSessions).go();
      await delete(reorderRequests).go();
      await delete(checkoutRecords).go();
      await delete(assignmentTargets).go();
      await delete(itemLocationBalances).go();
      await delete(inventoryTransactions).go();
      await delete(items).go();
      await delete(suppliers).go();
      await delete(appUsers).go();
      await delete(people).go();
      await delete(locations).go();
      await delete(unitsOfMeasure).go();
      await delete(companyUsages).go();
      await delete(companies).go();
      await delete(plans).go();
    });
  }
}
