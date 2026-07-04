import 'dart:async';

import 'package:flutter/material.dart';

import 'database/app_database.dart';
import 'database/model_mappers.dart';
import 'models/models.dart';
import 'permissions/app_permissions.dart';
import 'sample_data.dart';

class AppStore extends ChangeNotifier {
  AppStore({AppDatabase? database}) : _database = database ?? AppDatabase();

  final AppDatabase _database;

  final List<Item> _items = [];
  final List<UnitOfMeasure> _unitsOfMeasure = [];
  final List<Location> _locations = [];
  final List<Person> _people = [];
  final List<AppUser> _users = [];
  final List<InventoryTransaction> _transactions = [];
  final List<CheckoutRecord> _checkoutRecords = [];
  final List<ReorderRequest> _reorderRequests = [];
  final List<CycleCountSession> _cycleCountSessions = [];
  final List<CycleCountLine> _cycleCountLines = [];
  final List<CustomFieldDefinition> _customFieldDefinitions = [];
  final List<CustomFieldValue> _customFieldValues = [];
  Company? _company;
  Plan _plan = samplePlan;
  CompanyUsage _companyUsage = sampleCompanyUsage;
  String? _currentUserId;
  UserRole? _currentRoleOverride;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<Item> get items => List.unmodifiable(_items);
  List<UnitOfMeasure> get unitsOfMeasure => List.unmodifiable(_unitsOfMeasure);
  List<Location> get locations => List.unmodifiable(_locations);
  List<Person> get people => List.unmodifiable(_people);
  List<AppUser> get users => List.unmodifiable(_users);
  List<InventoryTransaction> get transactions =>
      List.unmodifiable(_transactions);
  List<CheckoutRecord> get checkoutRecords =>
      List.unmodifiable(_checkoutRecords);
  List<ReorderRequest> get reorderRequests =>
      List.unmodifiable(_reorderRequests);
  List<CycleCountSession> get cycleCountSessions =>
      List.unmodifiable(_cycleCountSessions);
  List<CycleCountLine> get cycleCountLines =>
      List.unmodifiable(_cycleCountLines);
  List<CustomFieldDefinition> get customFieldDefinitions =>
      List.unmodifiable(_customFieldDefinitions);
  List<CustomFieldValue> get customFieldValues =>
      List.unmodifiable(_customFieldValues);
  Company? get company => _company;
  bool get isSetupComplete => _company?.setupCompleted ?? false;
  Plan get plan => _plan;
  CompanyUsage get companyUsage => _companyUsage;
  Plan get currentPlan => _plan;
  AppUser? get currentUser {
    if (_users.isEmpty) {
      return null;
    }

    final requestedUserId = _currentUserId;
    if (requestedUserId != null) {
      for (final user in _users) {
        if (user.id == requestedUserId && user.isActive) {
          return user;
        }
      }
    }

    for (final user in _users) {
      if (user.isActive && user.role == UserRole.admin) {
        return user;
      }
    }

    return _users.firstWhere(
      (user) => user.isActive,
      orElse: () => _users.first,
    );
  }

  Person? get currentPerson {
    final personId = currentUser?.personId;
    if (personId == null) {
      return null;
    }

    for (final person in _people) {
      if (person.id == personId) {
        return person;
      }
    }

    return null;
  }

  UserRole get currentRole {
    return _currentRoleOverride ?? currentUser?.role ?? UserRole.manager;
  }

  AppPermissions get permissions => AppPermissions(currentRole);
  List<Plan> get availablePlans => List.unmodifiable(samplePlans);
  CompanyUsage get currentUsage {
    return CompanyUsage(
      activeItemCount: _items.where((item) => item.isActive).length,
      userCount: _users.where((user) => user.isActive).length,
      locationCount: _locations.where((location) => location.isActive).length,
      photoCount: _items.where((item) {
        if (!item.isActive) {
          return false;
        }

        final photoPath = item.photoPath?.trim();
        return photoPath != null && photoPath.isNotEmpty;
      }).length,
      labelExportCount: _companyUsage.labelExportCount,
    );
  }

  Future<void> initialize() async {
    await _loadFromDatabase();
    await _ensureBasePlanData();
    await _ensureCompanyForExistingData();
    if (isSetupComplete) {
      await _ensureLocalTestUsers();
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _ensureBasePlanData() async {
    if ((await _database.getAllPlans()).isEmpty) {
      await _database.upsertPlan(samplePlan.toCompanion());
      _plan = samplePlan;
    }

    if ((await _database.getAllCompanyUsage()).isEmpty) {
      await _database.upsertCompanyUsage(sampleCompanyUsage.toCompanion());
      _companyUsage = sampleCompanyUsage;
    }
  }

  Future<void> _ensureCompanyForExistingData() async {
    if (_company != null || _items.isEmpty) {
      return;
    }

    final now = DateTime.now();
    _company = Company(
      id: 'company-local',
      name: 'Issued Demo Shop',
      industry: null,
      createdAt: now,
      updatedAt: now,
      setupCompleted: true,
    );
    await _database.upsertCompany(_company!.toCompanion());
  }

  Future<void> _ensureLocalTestUsers() async {
    var addedUsers = false;
    for (final person in samplePeople) {
      if (_people.any((storedPerson) => storedPerson.id == person.id)) {
        continue;
      }

      _people.add(person);
      await _database.upsertPerson(person.toCompanion());
      addedUsers = true;
    }
    for (final user in sampleUsers) {
      if (_users.any((storedUser) => storedUser.id == user.id)) {
        continue;
      }

      _users.add(user);
      await _database.upsertAppUser(user.toCompanion());
      addedUsers = true;
    }

    if (addedUsers) {
      await _loadFromDatabase();
    }
  }

  Future<void> _seedSampleDataIfNeeded() async {
    for (final unit in sampleUnitsOfMeasure) {
      await _ensureUnitOfMeasure(unit);
    }
    for (final location in sampleLocations) {
      await _ensureLocation(location.name, location.type, id: location.id);
    }
    for (final person in samplePeople) {
      await _ensurePerson(person);
    }
    for (final user in sampleUsers) {
      await _ensureUser(user);
    }
    for (final item in sampleItems) {
      if (_items.any((storedItem) => storedItem.id == item.id)) {
        continue;
      }
      _items.add(item);
      await _database.upsertItem(item.toCompanion());
    }
    for (final transaction in sampleTransactions) {
      if (_transactions.any(
        (storedTransaction) => storedTransaction.id == transaction.id,
      )) {
        continue;
      }
      _transactions.add(transaction);
      await _database.upsertTransaction(transaction.toCompanion());
    }
    for (final session in sampleCycleCountSessions) {
      if (_cycleCountSessions.any(
        (storedSession) => storedSession.id == session.id,
      )) {
        continue;
      }
      _cycleCountSessions.add(session);
      await _database.upsertCycleCountSession(session.toCompanion());
    }
    for (final line in sampleCycleCountLines) {
      if (_cycleCountLines.any((storedLine) => storedLine.id == line.id)) {
        continue;
      }
      _cycleCountLines.add(line);
      await _database.upsertCycleCountLine(line.toCompanion());
    }
    for (final field in sampleCustomFieldDefinitions) {
      if (_customFieldDefinitions.any(
        (storedField) => storedField.id == field.id,
      )) {
        continue;
      }
      _customFieldDefinitions.add(field);
      await _database.upsertCustomFieldDefinition(field.toCompanion());
    }
    for (final value in sampleCustomFieldValues) {
      if (_customFieldValues.any((storedValue) => storedValue.id == value.id)) {
        continue;
      }
      _customFieldValues.add(value);
      await _database.upsertCustomFieldValue(value.toCompanion());
    }
  }

  Future<void> _ensureDefaultUnitsOfMeasure() async {
    const defaultUnits = [
      UnitOfMeasure(
        id: 'uom-each',
        name: 'Each',
        abbreviation: 'ea',
        allowsDecimal: false,
        isActive: true,
      ),
      UnitOfMeasure(
        id: 'uom-box',
        name: 'Box',
        abbreviation: 'box',
        allowsDecimal: false,
        isActive: true,
      ),
      UnitOfMeasure(
        id: 'uom-case',
        name: 'Case',
        abbreviation: 'case',
        allowsDecimal: false,
        isActive: true,
      ),
      UnitOfMeasure(
        id: 'uom-pair',
        name: 'Pair',
        abbreviation: 'pair',
        allowsDecimal: false,
        isActive: true,
      ),
      UnitOfMeasure(
        id: 'uom-foot',
        name: 'Foot',
        abbreviation: 'ft',
        allowsDecimal: true,
        isActive: true,
      ),
      UnitOfMeasure(
        id: 'uom-gallon',
        name: 'Gallon',
        abbreviation: 'gal',
        allowsDecimal: true,
        isActive: true,
      ),
      UnitOfMeasure(
        id: 'uom-quart',
        name: 'Quart',
        abbreviation: 'qt',
        allowsDecimal: true,
        isActive: true,
      ),
      UnitOfMeasure(
        id: 'uom-pound',
        name: 'Pound',
        abbreviation: 'lb',
        allowsDecimal: true,
        isActive: true,
      ),
      UnitOfMeasure(
        id: 'uom-set',
        name: 'Set',
        abbreviation: 'set',
        allowsDecimal: false,
        isActive: true,
      ),
      UnitOfMeasure(
        id: 'uom-kit',
        name: 'Kit',
        abbreviation: 'kit',
        allowsDecimal: false,
        isActive: true,
      ),
    ];

    for (final unit in defaultUnits) {
      await _ensureUnitOfMeasure(unit);
    }
  }

  Future<void> _ensureUnitOfMeasure(UnitOfMeasure unit) async {
    final exists = _unitsOfMeasure.any((storedUnit) {
      return storedUnit.id == unit.id ||
          storedUnit.name.toLowerCase() == unit.name.toLowerCase() ||
          storedUnit.abbreviation.toLowerCase() ==
              unit.abbreviation.toLowerCase();
    });
    if (exists) {
      return;
    }

    _unitsOfMeasure.add(unit);
    await _database.upsertUnitOfMeasure(unit.toCompanion());
  }

  Future<void> _ensureLocation(String name, String type, {String? id}) async {
    final normalizedName = name.trim();
    final existing = _locations.any((location) {
      return location.id == id ||
          location.name.toLowerCase() == normalizedName.toLowerCase();
    });
    if (existing) {
      return;
    }

    final location = Location(
      id: id ?? 'loc-${DateTime.now().microsecondsSinceEpoch}',
      name: normalizedName,
      type: type,
      parentLocationId: null,
      isActive: true,
    );
    _locations.add(location);
    await _database.upsertLocation(location.toCompanion());
  }

  Future<void> _ensureAdminUser(
    String displayName,
    String? email,
    DateTime now,
  ) async {
    final person = Person(
      id: 'person-first-admin',
      displayName: displayName,
      email: email,
      phone: null,
      isActive: true,
      isLoginUser: true,
    );
    await _ensurePerson(person);

    final user = AppUser(
      id: 'user-first-admin',
      personId: person.id,
      email: email ?? 'admin@issued.local',
      role: UserRole.admin,
      isActive: true,
      createdAt: now,
    );
    await _ensureUser(user);
    _currentUserId = user.id;
  }

  Future<void> _ensurePerson(Person person) async {
    final exists = _people.any((storedPerson) {
      final emailMatches =
          person.email != null &&
          storedPerson.email?.toLowerCase() == person.email!.toLowerCase();
      return storedPerson.id == person.id || emailMatches;
    });
    if (exists) {
      return;
    }

    _people.add(person);
    await _database.upsertPerson(person.toCompanion());
  }

  Future<void> _ensureUser(AppUser user) async {
    final exists = _users.any((storedUser) {
      return storedUser.id == user.id ||
          storedUser.email.toLowerCase() == user.email.toLowerCase();
    });
    if (exists) {
      return;
    }

    _users.add(user);
    await _database.upsertAppUser(user.toCompanion());
  }

  Future<void> _loadFromDatabase() async {
    _unitsOfMeasure
      ..clear()
      ..addAll(
        (await _database.getAllUnitsOfMeasure()).map((row) => row.toDomain()),
      );
    _locations
      ..clear()
      ..addAll(
        (await _database.getAllLocations()).map((row) => row.toDomain()),
      );
    _people
      ..clear()
      ..addAll((await _database.getAllPeople()).map((row) => row.toDomain()));
    _users
      ..clear()
      ..addAll((await _database.getAllAppUsers()).map((row) => row.toDomain()));
    _items
      ..clear()
      ..addAll((await _database.getAllItems()).map((row) => row.toDomain()));
    _transactions
      ..clear()
      ..addAll(
        (await _database.getAllTransactions()).map((row) => row.toDomain()),
      );
    _checkoutRecords
      ..clear()
      ..addAll(
        (await _database.getAllCheckoutRecords()).map((row) => row.toDomain()),
      );
    _reorderRequests
      ..clear()
      ..addAll(
        (await _database.getAllReorderRequests()).map((row) => row.toDomain()),
      );
    _cycleCountSessions
      ..clear()
      ..addAll(
        (await _database.getAllCycleCountSessions()).map(
          (row) => row.toDomain(),
        ),
      );
    _cycleCountLines
      ..clear()
      ..addAll(
        (await _database.getAllCycleCountLines()).map((row) => row.toDomain()),
      );
    _customFieldDefinitions
      ..clear()
      ..addAll(
        (await _database.getAllCustomFieldDefinitions()).map(
          (row) => row.toDomain(),
        ),
      );
    _customFieldValues
      ..clear()
      ..addAll(
        (await _database.getAllCustomFieldValues()).map(
          (row) => row.toDomain(),
        ),
      );

    final companies = await _database.getAllCompanies();
    _company = companies.isEmpty ? null : companies.first.toDomain();
    final plans = await _database.getAllPlans();
    _plan = plans.isEmpty ? samplePlan : plans.first.toDomain();
    final usages = await _database.getAllCompanyUsage();
    _companyUsage = usages.isEmpty
        ? sampleCompanyUsage
        : usages.first.toDomain();
    _currentUserId ??= currentUser?.id;
  }

  void addItem(Item item) {
    _items.add(item);
    unawaited(_database.upsertItem(item.toCompanion()));
    notifyListeners();
  }

  void updateItem(Item item) {
    final itemIndex = _items.indexWhere(
      (storedItem) => storedItem.id == item.id,
    );
    if (itemIndex == -1) {
      return;
    }

    _items[itemIndex] = item;
    unawaited(_database.upsertItem(item.toCompanion()));
    notifyListeners();
  }

  void recordLabelExport() {
    _companyUsage = _companyUsage.copyWith(
      labelExportCount: _companyUsage.labelExportCount + 1,
    );
    unawaited(_database.upsertCompanyUsage(_companyUsage.toCompanion()));
    notifyListeners();
  }

  bool get canAddItem => currentUsage.activeItemCount < currentPlan.itemLimit;
  bool get canAddLocation =>
      currentUsage.locationCount < currentPlan.locationLimit;
  bool get canAddUser => currentUsage.userCount < currentPlan.userLimit;
  bool get canExportLabel =>
      currentUsage.labelExportCount < currentPlan.labelExportLimit;
  bool get canAddPhoto => currentUsage.photoCount < currentPlan.photoLimit;

  PlanLimitWarning? getLimitWarningForItems() {
    return _limitWarning(
      kind: PlanLimitKind.items,
      used: currentUsage.activeItemCount,
      limit: currentPlan.itemLimit,
      unitLabel: 'item slots',
    );
  }

  PlanLimitWarning? getLimitWarningForLocations() {
    return _limitWarning(
      kind: PlanLimitKind.locations,
      used: currentUsage.locationCount,
      limit: currentPlan.locationLimit,
      unitLabel: 'location slots',
    );
  }

  PlanLimitWarning? getLimitWarningForUsers() {
    return _limitWarning(
      kind: PlanLimitKind.users,
      used: currentUsage.userCount,
      limit: currentPlan.userLimit,
      unitLabel: 'login user slots',
    );
  }

  PlanLimitWarning? getLimitWarningForLabels() {
    return _limitWarning(
      kind: PlanLimitKind.labels,
      used: currentUsage.labelExportCount,
      limit: currentPlan.labelExportLimit,
      unitLabel: 'monthly label exports',
    );
  }

  PlanLimitWarning? getLimitWarningForPhotos() {
    return _limitWarning(
      kind: PlanLimitKind.photos,
      used: currentUsage.photoCount,
      limit: currentPlan.photoLimit,
      unitLabel: 'photo slots',
    );
  }

  List<PlanLimitWarning> getLimitWarnings() {
    final warnings = [
      getLimitWarningForItems(),
      getLimitWarningForLocations(),
      getLimitWarningForUsers(),
      getLimitWarningForLabels(),
      getLimitWarningForPhotos(),
    ].whereType<PlanLimitWarning>().toList();

    warnings.sort((left, right) {
      return _severityRank(
        right.severity,
      ).compareTo(_severityRank(left.severity));
    });

    return warnings;
  }

  void setCurrentPlanForTesting(String planCode) {
    final plan = samplePlans.firstWhere(
      (plan) => plan.code == planCode,
      orElse: () => samplePlan,
    );
    _plan = plan;
    unawaited(_database.upsertPlan(plan.toCompanion()));
    notifyListeners();
  }

  void setCurrentUserForTesting(String userId) {
    for (final user in _users) {
      if (user.id == userId && user.isActive) {
        _currentUserId = userId;
        _currentRoleOverride = null;
        notifyListeners();
        return;
      }
    }
  }

  void setCurrentRoleForTesting(UserRole role) {
    _currentRoleOverride = role;
    notifyListeners();
  }

  Future<void> completeSetup({
    required String companyName,
    required String? industry,
    required String locationName,
    required String locationType,
    required String adminDisplayName,
    required String? adminEmail,
    required bool includeSampleData,
  }) async {
    final now = DateTime.now();
    final normalizedCompanyName = companyName.trim();
    final normalizedIndustry = _emptyToNull(industry);
    final normalizedLocationName = locationName.trim();
    final normalizedAdminName = adminDisplayName.trim();
    final normalizedEmail = _emptyToNull(adminEmail);

    _company = Company(
      id: _company?.id ?? 'company-local',
      name: normalizedCompanyName,
      industry: normalizedIndustry,
      createdAt: _company?.createdAt ?? now,
      updatedAt: now,
      setupCompleted: true,
    );
    await _database.upsertCompany(_company!.toCompanion());

    await _ensureDefaultUnitsOfMeasure();
    await _ensureLocation(normalizedLocationName, locationType);
    await _ensureAdminUser(normalizedAdminName, normalizedEmail, now);

    if (includeSampleData && _items.isEmpty) {
      await _seedSampleDataIfNeeded();
    }

    await _loadFromDatabase();
    _currentUserId ??= currentUser?.id;
    notifyListeners();
  }

  Future<void> updateCompany({
    required String name,
    required String? industry,
  }) async {
    if (!permissions.canManageSettings) {
      return;
    }

    final now = DateTime.now();
    _company = Company(
      id: _company?.id ?? 'company-local',
      name: name.trim(),
      industry: _emptyToNull(industry),
      createdAt: _company?.createdAt ?? now,
      updatedAt: now,
      setupCompleted: _company?.setupCompleted ?? true,
    );
    await _database.upsertCompany(_company!.toCompanion());
    notifyListeners();
  }

  Future<void> resetOnboardingForTesting() async {
    if (!permissions.canManageSettings) {
      return;
    }

    final now = DateTime.now();
    _company = Company(
      id: _company?.id ?? 'company-local',
      name: _company?.name ?? 'Issued Workspace',
      industry: _company?.industry,
      createdAt: _company?.createdAt ?? now,
      updatedAt: now,
      setupCompleted: false,
    );
    await _database.upsertCompany(_company!.toCompanion());
    notifyListeners();
  }

  void addTransaction(InventoryTransaction transaction) {
    _transactions.add(transaction);
    unawaited(_database.upsertTransaction(transaction.toCompanion()));
    notifyListeners();
  }

  List<InventoryTransaction> transactionsForItem(String itemId) {
    final itemTransactions = _transactions
        .where((transaction) => transaction.itemId == itemId)
        .toList();

    itemTransactions.sort(
      (left, right) => right.createdAt.compareTo(left.createdAt),
    );
    return itemTransactions;
  }

  List<InventoryTransaction> recentTransactions({int limit = 10}) {
    final recentTransactions = _transactions.toList()
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));

    return recentTransactions.take(limit).toList();
  }

  String resolveItemName(String itemId) {
    return _itemById(itemId)?.name ?? 'Unknown item';
  }

  bool isItemLowStock(Item item) {
    return item.isActive &&
        item.minimumQuantity > 0 &&
        item.quantityOnHand <= item.minimumQuantity;
  }

  bool isItemCheckedOut(String itemId) {
    return openCheckoutRecords.any((record) => record.itemId == itemId);
  }

  bool isItemOnActiveReorder(String itemId) {
    return getActiveReorderForItem(itemId) != null;
  }

  InventorySummaryReport getInventorySummary() {
    final activeItems = _items.where((item) => item.isActive).toList();

    return InventorySummaryReport(
      activeItemCount: activeItems.length,
      archivedItemCount: _items.where((item) => !item.isActive).length,
      consumableCount: activeItems
          .where((item) => item.itemType == ItemType.consumable)
          .length,
      returnableCount: activeItems
          .where((item) => item.itemType == ItemType.returnable)
          .length,
      assetCount: activeItems
          .where((item) => item.itemType == ItemType.asset)
          .length,
      locationCount: _locations.where((location) => location.isActive).length,
      lowStockCount: activeItems.where(isItemLowStock).length,
      activeReorderCount: _reorderRequests.where((request) {
        return request.status == ReorderStatus.needed ||
            request.status == ReorderStatus.ordered;
      }).length,
      openCheckoutCount: openCheckoutRecords.length,
    );
  }

  InventoryValueReport getInventoryValueReport() {
    final byType = <ItemType, double>{};
    final byLocation = <String, double>{};
    var totalValue = 0.0;
    var missingCostCount = 0;
    var missingCostValue = 0.0;

    for (final item in _items.where((item) => item.isActive)) {
      final unitCost = item.unitCost;
      if (unitCost == null) {
        missingCostCount += 1;
        missingCostValue += item.quantityOnHand;
        continue;
      }

      final value = item.quantityOnHand * unitCost;
      totalValue += value;
      byType[item.itemType] = (byType[item.itemType] ?? 0) + value;
      byLocation[item.locationId] = (byLocation[item.locationId] ?? 0) + value;
    }

    return InventoryValueReport(
      totalValue: totalValue,
      valueByType: byType,
      valueByLocation: byLocation,
      missingCostCount: missingCostCount,
      missingCostQuantity: missingCostValue,
    );
  }

  Map<ItemType, double> getInventoryValueByType() {
    return getInventoryValueReport().valueByType;
  }

  Map<String, double> getInventoryValueByLocation() {
    return getInventoryValueReport().valueByLocation;
  }

  List<UsageByItemRow> getUsageByItem(DateTime? start) {
    final rowsByItem = <String, UsageByItemRow>{};
    for (final transaction in _usageTransactions(start)) {
      final quantity = transaction.quantityDelta.abs();
      final existing = rowsByItem[transaction.itemId];
      rowsByItem[transaction.itemId] = UsageByItemRow(
        itemId: transaction.itemId,
        quantity: (existing?.quantity ?? 0) + quantity,
        unitOfMeasureId: transaction.unitOfMeasureId,
        transactionCount: (existing?.transactionCount ?? 0) + 1,
      );
    }

    final rows = rowsByItem.values.toList();
    rows.sort((left, right) => right.quantity.compareTo(left.quantity));
    return rows;
  }

  List<UsageByPersonRow> getUsageByPerson(DateTime? start) {
    final rowsByPerson = <String, UsageByPersonRow>{};
    final itemCountsByPerson = <String, Map<String, int>>{};
    for (final transaction in _usageTransactions(start)) {
      final personId = transaction.assignedToPersonId;
      if (personId == null) {
        continue;
      }

      final existing = rowsByPerson[personId];
      rowsByPerson[personId] = UsageByPersonRow(
        personId: personId,
        quantity: (existing?.quantity ?? 0) + transaction.quantityDelta.abs(),
        transactionCount: (existing?.transactionCount ?? 0) + 1,
        topItemIds: const [],
      );
      final itemCounts = itemCountsByPerson.putIfAbsent(personId, () => {});
      itemCounts[transaction.itemId] =
          (itemCounts[transaction.itemId] ?? 0) + 1;
    }

    final rows = rowsByPerson.values.map((row) {
      final itemCounts = itemCountsByPerson[row.personId] ?? {};
      final topItemIds = itemCounts.entries.toList()
        ..sort((left, right) => right.value.compareTo(left.value));
      return UsageByPersonRow(
        personId: row.personId,
        quantity: row.quantity,
        transactionCount: row.transactionCount,
        topItemIds: topItemIds.take(3).map((entry) => entry.key).toList(),
      );
    }).toList();
    rows.sort(
      (left, right) => right.transactionCount.compareTo(left.transactionCount),
    );
    return rows;
  }

  List<LostDamagedReportRow> getLostDamagedActivity() {
    final rows = <LostDamagedReportRow>[];
    for (final transaction in _transactions) {
      if (transaction.transactionType != InventoryTransactionType.markLost &&
          transaction.transactionType != InventoryTransactionType.markDamaged) {
        continue;
      }

      rows.add(
        LostDamagedReportRow(
          itemId: transaction.itemId,
          status:
              transaction.transactionType == InventoryTransactionType.markLost
              ? 'Lost'
              : 'Damaged',
          quantity: transaction.quantityDelta.abs(),
          unitOfMeasureId: transaction.unitOfMeasureId,
          createdAt: transaction.createdAt,
          notes: transaction.notes,
          assignedToPersonId: transaction.assignedToPersonId,
          locationId: transaction.fromLocationId ?? transaction.toLocationId,
        ),
      );
    }

    for (final record in _checkoutRecords) {
      if (record.status != CheckoutStatus.lost &&
          record.status != CheckoutStatus.damaged) {
        continue;
      }

      rows.add(
        LostDamagedReportRow(
          itemId: record.itemId,
          status: checkoutStatusLabel(record.status),
          quantity: record.quantity,
          unitOfMeasureId: record.unitOfMeasureId,
          createdAt: record.returnedAt ?? record.checkedOutAt,
          notes: record.notes,
          assignedToPersonId: record.assignedToPersonId,
          locationId: record.assignedToLocationId,
        ),
      );
    }

    rows.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return rows;
  }

  List<CycleCountVarianceRow> getCycleCountVarianceRows() {
    final rows = <CycleCountVarianceRow>[];
    for (final line in _cycleCountLines) {
      final counted = line.countedQuantity;
      final variance = line.varianceQuantity;
      if (counted == null || variance == null || variance == 0) {
        continue;
      }

      final session = _cycleCountSessionById(line.sessionId);
      rows.add(
        CycleCountVarianceRow(
          itemId: line.itemId,
          sessionName: session?.name ?? 'Unknown count',
          sessionDate:
              session?.approvedAt ??
              session?.submittedAt ??
              session?.createdAt ??
              DateTime.now(),
          expectedQuantity: line.expectedQuantity,
          countedQuantity: counted,
          varianceQuantity: variance,
          unitOfMeasureId: line.unitOfMeasureId,
        ),
      );
    }

    rows.sort((left, right) => right.sessionDate.compareTo(left.sessionDate));
    return rows;
  }

  ReorderStatusSummary getReorderStatusSummary() {
    return ReorderStatusSummary(
      needed: _reorderRequests
          .where((request) => request.status == ReorderStatus.needed)
          .length,
      ordered: _reorderRequests
          .where((request) => request.status == ReorderStatus.ordered)
          .length,
      received: _reorderRequests
          .where((request) => request.status == ReorderStatus.received)
          .length,
      canceled: _reorderRequests
          .where((request) => request.status == ReorderStatus.canceled)
          .length,
    );
  }

  Item? itemById(String itemId) {
    return _itemById(itemId);
  }

  String resolveUomAbbreviation(String uomId) {
    return _unitById(uomId)?.abbreviation ?? '';
  }

  String? resolveLocationName(String? locationId) {
    if (locationId == null) {
      return null;
    }

    for (final location in _locations) {
      if (location.id == locationId) {
        return location.name;
      }
    }

    return 'Unknown';
  }

  String? resolvePersonName(String? personId) {
    if (personId == null) {
      return null;
    }

    for (final person in _people) {
      if (person.id == personId) {
        return person.displayName;
      }
    }

    return 'Unknown';
  }

  String? resolveUserName(String? userId) {
    if (userId == null) {
      return null;
    }

    for (final user in _users) {
      if (user.id == userId) {
        return resolvePersonName(user.personId) ?? user.email;
      }
    }

    return 'Unknown';
  }

  List<CheckoutRecord> get openCheckoutRecords {
    final records = _checkoutRecords
        .where((record) => record.status == CheckoutStatus.checkedOut)
        .toList();

    records.sort((left, right) {
      final leftDue = left.dueAt;
      final rightDue = right.dueAt;
      if (leftDue == null && rightDue == null) {
        return right.checkedOutAt.compareTo(left.checkedOutAt);
      }
      if (leftDue == null) {
        return 1;
      }
      if (rightDue == null) {
        return -1;
      }
      return leftDue.compareTo(rightDue);
    });

    return records;
  }

  List<CheckoutRecord> get overdueCheckoutRecords {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return openCheckoutRecords.where((record) {
      final dueAt = record.dueAt;
      return dueAt != null && dueAt.isBefore(startOfToday);
    }).toList();
  }

  List<CheckoutRecord> openCheckoutRecordsForItem(String itemId) {
    return openCheckoutRecords
        .where((record) => record.itemId == itemId)
        .toList();
  }

  bool checkOutItem({
    required String itemId,
    required double quantity,
    String? assignedToPersonId,
    String? assignedToLocationId,
    String? assignedToText,
    DateTime? dueAt,
    String? notes,
  }) {
    if (!permissions.canIssueItems || quantity <= 0) {
      return false;
    }

    final itemIndex = _items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) {
      return false;
    }

    final item = _items[itemIndex];
    final now = DateTime.now();
    final normalizedAssignedText = assignedToText?.trim();
    final normalizedNotes = notes?.trim();
    final updatedItem = item.copyWith(
      quantityOnHand: item.quantityOnHand - quantity,
      updatedAt: now,
    );
    _items[itemIndex] = updatedItem;
    unawaited(_database.upsertItem(updatedItem.toCompanion()));

    final record = CheckoutRecord(
      id: 'checkout-${now.microsecondsSinceEpoch}',
      itemId: item.id,
      assignedToPersonId: assignedToPersonId,
      assignedToLocationId: assignedToLocationId,
      assignedToText:
          normalizedAssignedText == null || normalizedAssignedText.isEmpty
          ? null
          : normalizedAssignedText,
      quantity: quantity,
      unitOfMeasureId: item.unitOfMeasureId,
      status: CheckoutStatus.checkedOut,
      checkedOutAt: now,
      dueAt: dueAt,
      returnedAt: null,
      checkedOutByUserId: currentUser?.id,
      returnedByUserId: null,
      notes: normalizedNotes == null || normalizedNotes.isEmpty
          ? null
          : normalizedNotes,
    );
    _checkoutRecords.add(record);
    unawaited(_database.upsertCheckoutRecord(record.toCompanion()));

    final transaction = InventoryTransaction(
      id: 'txn-checkout-${now.microsecondsSinceEpoch}',
      itemId: item.id,
      transactionType: InventoryTransactionType.checkout,
      quantityDelta: -quantity,
      unitOfMeasureId: item.unitOfMeasureId,
      fromLocationId: item.locationId,
      toLocationId: null,
      assignedToPersonId: assignedToPersonId,
      performedByUserId: currentUser?.id,
      notes: record.notes,
      createdAt: now,
    );
    _transactions.add(transaction);
    unawaited(_database.upsertTransaction(transaction.toCompanion()));
    notifyListeners();
    return true;
  }

  bool returnCheckout({
    required String checkoutRecordId,
    required double returnedQuantity,
    String? notes,
  }) {
    if (!permissions.canIssueItems || returnedQuantity <= 0) {
      return false;
    }

    final recordIndex = _checkoutRecords.indexWhere(
      (record) => record.id == checkoutRecordId,
    );
    if (recordIndex == -1) {
      return false;
    }

    final record = _checkoutRecords[recordIndex];
    if (record.status != CheckoutStatus.checkedOut ||
        returnedQuantity != record.quantity) {
      return false;
    }

    final itemIndex = _items.indexWhere((item) => item.id == record.itemId);
    if (itemIndex == -1) {
      return false;
    }

    final now = DateTime.now();
    final item = _items[itemIndex];
    final updatedItem = item.copyWith(
      quantityOnHand: item.quantityOnHand + returnedQuantity,
      updatedAt: now,
    );
    _items[itemIndex] = updatedItem;
    unawaited(_database.upsertItem(updatedItem.toCompanion()));

    final normalizedNotes = notes?.trim();
    final updatedRecord = record.copyWith(
      status: CheckoutStatus.returned,
      returnedAt: now,
      returnedByUserId: currentUser?.id,
      notes: normalizedNotes == null || normalizedNotes.isEmpty
          ? record.notes
          : normalizedNotes,
    );
    _checkoutRecords[recordIndex] = updatedRecord;
    unawaited(_database.upsertCheckoutRecord(updatedRecord.toCompanion()));

    final transaction = InventoryTransaction(
      id: 'txn-return-${now.microsecondsSinceEpoch}',
      itemId: item.id,
      transactionType: InventoryTransactionType.returnItem,
      quantityDelta: returnedQuantity,
      unitOfMeasureId: item.unitOfMeasureId,
      fromLocationId: null,
      toLocationId: item.locationId,
      assignedToPersonId: record.assignedToPersonId,
      performedByUserId: currentUser?.id,
      notes: normalizedNotes == null || normalizedNotes.isEmpty
          ? 'Returned checked out item'
          : normalizedNotes,
      createdAt: now,
    );
    _transactions.add(transaction);
    unawaited(_database.upsertTransaction(transaction.toCompanion()));
    notifyListeners();
    return true;
  }

  bool markCheckoutLost(String checkoutRecordId, String? notes) {
    return _closeCheckoutWithoutRestock(
      checkoutRecordId,
      CheckoutStatus.lost,
      InventoryTransactionType.markLost,
      notes,
    );
  }

  bool markCheckoutDamaged(String checkoutRecordId, String? notes) {
    return _closeCheckoutWithoutRestock(
      checkoutRecordId,
      CheckoutStatus.damaged,
      InventoryTransactionType.markDamaged,
      notes,
    );
  }

  bool _closeCheckoutWithoutRestock(
    String checkoutRecordId,
    CheckoutStatus status,
    InventoryTransactionType transactionType,
    String? notes,
  ) {
    if (!permissions.canAdjustQuantity) {
      return false;
    }

    final recordIndex = _checkoutRecords.indexWhere(
      (record) => record.id == checkoutRecordId,
    );
    if (recordIndex == -1) {
      return false;
    }

    final record = _checkoutRecords[recordIndex];
    if (record.status != CheckoutStatus.checkedOut) {
      return false;
    }

    final item = _itemById(record.itemId);
    if (item == null) {
      return false;
    }

    final now = DateTime.now();
    final normalizedNotes = notes?.trim();
    final updatedRecord = record.copyWith(
      status: status,
      returnedAt: now,
      returnedByUserId: currentUser?.id,
      notes: normalizedNotes == null || normalizedNotes.isEmpty
          ? record.notes
          : normalizedNotes,
    );
    _checkoutRecords[recordIndex] = updatedRecord;
    unawaited(_database.upsertCheckoutRecord(updatedRecord.toCompanion()));

    final transaction = InventoryTransaction(
      id: 'txn-${transactionType.name}-${now.microsecondsSinceEpoch}',
      itemId: item.id,
      transactionType: transactionType,
      quantityDelta: -record.quantity,
      unitOfMeasureId: item.unitOfMeasureId,
      fromLocationId: item.locationId,
      toLocationId: null,
      assignedToPersonId: record.assignedToPersonId,
      performedByUserId: currentUser?.id,
      notes: normalizedNotes == null || normalizedNotes.isEmpty
          ? checkoutStatusLabel(status)
          : normalizedNotes,
      createdAt: now,
    );
    _transactions.add(transaction);
    unawaited(_database.upsertTransaction(transaction.toCompanion()));
    notifyListeners();
    return true;
  }

  List<Item> getLowStockItems() {
    final lowStockItems = _items.where((item) {
      return item.isActive &&
          item.minimumQuantity > 0 &&
          item.quantityOnHand <= item.minimumQuantity;
    }).toList();

    lowStockItems.sort((left, right) {
      return left.name.toLowerCase().compareTo(right.name.toLowerCase());
    });

    return lowStockItems;
  }

  double getSuggestedReorderQuantity(Item item) {
    var quantity = item.minimumQuantity - item.quantityOnHand;
    if (quantity <= 0) {
      quantity = 1;
    }

    final unit = _unitById(item.unitOfMeasureId);
    if (unit == null || !unit.allowsDecimal || !item.allowFractionalQuantity) {
      return quantity.ceilToDouble();
    }

    return quantity;
  }

  ReorderRequest? getActiveReorderForItem(String itemId) {
    for (final request in _reorderRequests) {
      if (request.itemId == itemId &&
          (request.status == ReorderStatus.needed ||
              request.status == ReorderStatus.ordered)) {
        return request;
      }
    }

    return null;
  }

  ReorderRequest? reorderRequestById(String reorderId) {
    for (final request in _reorderRequests) {
      if (request.id == reorderId) {
        return request;
      }
    }

    return null;
  }

  bool get canManageReorders => permissions.canManageItems;
  bool get canReceiveReorders =>
      canManageReorders || permissions.canReceiveStock;

  bool createReorderRequest(String itemId, double quantity, String? notes) {
    if (!canManageReorders || quantity <= 0) {
      return false;
    }

    final item = _itemById(itemId);
    if (item == null || getActiveReorderForItem(itemId) != null) {
      return false;
    }

    final now = DateTime.now();
    final normalizedNotes = notes?.trim();
    final request = ReorderRequest(
      id: 'reorder-${now.microsecondsSinceEpoch}',
      itemId: item.id,
      requestedQuantity: quantity,
      unitOfMeasureId: item.unitOfMeasureId,
      supplier: item.supplier,
      status: ReorderStatus.needed,
      notes: normalizedNotes == null || normalizedNotes.isEmpty
          ? null
          : normalizedNotes,
      createdAt: now,
      orderedAt: null,
      receivedAt: null,
      createdByUserId: currentUser?.id,
    );

    _reorderRequests.add(request);
    unawaited(_database.upsertReorderRequest(request.toCompanion()));
    notifyListeners();
    return true;
  }

  bool markReorderOrdered(String reorderId) {
    if (!canManageReorders) {
      return false;
    }

    final requestIndex = _reorderRequests.indexWhere(
      (request) => request.id == reorderId,
    );
    if (requestIndex == -1) {
      return false;
    }

    final request = _reorderRequests[requestIndex];
    if (request.status != ReorderStatus.needed) {
      return false;
    }

    final now = DateTime.now();
    final updatedRequest = request.copyWith(
      status: ReorderStatus.ordered,
      orderedAt: now,
    );
    _reorderRequests[requestIndex] = updatedRequest;
    unawaited(_database.upsertReorderRequest(updatedRequest.toCompanion()));
    notifyListeners();
    return true;
  }

  bool receiveReorder(
    String reorderId,
    double receivedQuantity,
    String? notes,
  ) {
    if (!canReceiveReorders || receivedQuantity <= 0) {
      return false;
    }

    final requestIndex = _reorderRequests.indexWhere(
      (request) => request.id == reorderId,
    );
    if (requestIndex == -1) {
      return false;
    }

    final request = _reorderRequests[requestIndex];
    if (request.status != ReorderStatus.needed &&
        request.status != ReorderStatus.ordered) {
      return false;
    }

    final itemIndex = _items.indexWhere((item) => item.id == request.itemId);
    if (itemIndex == -1) {
      return false;
    }

    final now = DateTime.now();
    final item = _items[itemIndex];
    final updatedItem = item.copyWith(
      quantityOnHand: item.quantityOnHand + receivedQuantity,
      updatedAt: now,
    );
    _items[itemIndex] = updatedItem;
    unawaited(_database.upsertItem(updatedItem.toCompanion()));

    final normalizedNotes = notes?.trim();
    final transaction = InventoryTransaction(
      id: 'txn-reorder-${now.microsecondsSinceEpoch}',
      itemId: item.id,
      transactionType: InventoryTransactionType.receive,
      quantityDelta: receivedQuantity,
      unitOfMeasureId: item.unitOfMeasureId,
      fromLocationId: null,
      toLocationId: item.locationId,
      assignedToPersonId: null,
      performedByUserId: currentUser?.id,
      notes: normalizedNotes == null || normalizedNotes.isEmpty
          ? 'Received from reorder'
          : 'Received from reorder: $normalizedNotes',
      createdAt: now,
    );
    _transactions.add(transaction);
    unawaited(_database.upsertTransaction(transaction.toCompanion()));

    final updatedRequest = request.copyWith(
      status: ReorderStatus.received,
      receivedAt: now,
    );
    _reorderRequests[requestIndex] = updatedRequest;
    unawaited(_database.upsertReorderRequest(updatedRequest.toCompanion()));
    notifyListeners();
    return true;
  }

  bool cancelReorder(String reorderId) {
    if (!canManageReorders) {
      return false;
    }

    final requestIndex = _reorderRequests.indexWhere(
      (request) => request.id == reorderId,
    );
    if (requestIndex == -1) {
      return false;
    }

    final request = _reorderRequests[requestIndex];
    if (request.status != ReorderStatus.needed &&
        request.status != ReorderStatus.ordered) {
      return false;
    }

    final updatedRequest = request.copyWith(status: ReorderStatus.canceled);
    _reorderRequests[requestIndex] = updatedRequest;
    unawaited(_database.upsertReorderRequest(updatedRequest.toCompanion()));
    notifyListeners();
    return true;
  }

  Item? _itemById(String itemId) {
    for (final item in _items) {
      if (item.id == itemId) {
        return item;
      }
    }

    return null;
  }

  UnitOfMeasure? _unitById(String unitOfMeasureId) {
    for (final unit in _unitsOfMeasure) {
      if (unit.id == unitOfMeasureId) {
        return unit;
      }
    }

    return null;
  }

  CycleCountSession? _cycleCountSessionById(String sessionId) {
    for (final session in _cycleCountSessions) {
      if (session.id == sessionId) {
        return session;
      }
    }

    return null;
  }

  Iterable<InventoryTransaction> _usageTransactions(DateTime? start) {
    return _transactions.where((transaction) {
      if (start != null && transaction.createdAt.isBefore(start)) {
        return false;
      }

      return switch (transaction.transactionType) {
        InventoryTransactionType.issue ||
        InventoryTransactionType.checkout ||
        InventoryTransactionType.markLost ||
        InventoryTransactionType.markDamaged => true,
        InventoryTransactionType.cycleCountAdjustment =>
          transaction.quantityDelta < 0,
        _ => false,
      };
    });
  }

  PlanLimitWarning? _limitWarning({
    required PlanLimitKind kind,
    required int used,
    required int limit,
    required String unitLabel,
  }) {
    if (limit <= 0) {
      return null;
    }

    final ratio = used / limit;
    final severity = switch (ratio) {
      >= 1 => PlanLimitSeverity.reached,
      >= 0.95 => PlanLimitSeverity.nearlyFull,
      >= 0.8 => PlanLimitSeverity.approaching,
      _ => null,
    };

    if (severity == null) {
      return null;
    }

    final message = switch (severity) {
      PlanLimitSeverity.reached =>
        'You are using $used of $limit ${currentPlan.name} plan $unitLabel.',
      PlanLimitSeverity.nearlyFull =>
        'You are using $used of $limit ${currentPlan.name} plan $unitLabel.',
      PlanLimitSeverity.approaching =>
        'You are using $used of $limit ${currentPlan.name} plan $unitLabel.',
    };

    return PlanLimitWarning(
      kind: kind,
      message: message,
      severity: severity,
      recommendedPlanCode: _recommendedPlanCode(kind, used),
    );
  }

  String? _recommendedPlanCode(PlanLimitKind kind, int used) {
    for (final plan in samplePlans) {
      final limit = switch (kind) {
        PlanLimitKind.items => plan.itemLimit,
        PlanLimitKind.users => plan.userLimit,
        PlanLimitKind.locations => plan.locationLimit,
        PlanLimitKind.photos => plan.photoLimit,
        PlanLimitKind.labels => plan.labelExportLimit,
      };

      if (limit > used && plan.code != currentPlan.code) {
        return plan.code;
      }
    }

    return null;
  }

  int _severityRank(PlanLimitSeverity severity) {
    return switch (severity) {
      PlanLimitSeverity.reached => 3,
      PlanLimitSeverity.nearlyFull => 2,
      PlanLimitSeverity.approaching => 1,
    };
  }

  void addUnitOfMeasure(UnitOfMeasure unit) {
    _unitsOfMeasure.add(unit);
    unawaited(_database.upsertUnitOfMeasure(unit.toCompanion()));
    notifyListeners();
  }

  void addLocation(Location location) {
    _locations.add(location);
    unawaited(_database.upsertLocation(location.toCompanion()));
    notifyListeners();
  }

  void addCustomFieldDefinition(CustomFieldDefinition field) {
    _customFieldDefinitions.add(field);
    unawaited(_database.upsertCustomFieldDefinition(field.toCompanion()));
    notifyListeners();
  }

  void addCycleCountSession(CycleCountSession session) {
    _cycleCountSessions.add(session);
    unawaited(_database.upsertCycleCountSession(session.toCompanion()));
    notifyListeners();
  }

  void updateCycleCountSession(CycleCountSession session) {
    final sessionIndex = _cycleCountSessions.indexWhere(
      (storedSession) => storedSession.id == session.id,
    );
    if (sessionIndex == -1) {
      return;
    }

    _cycleCountSessions[sessionIndex] = session;
    unawaited(_database.upsertCycleCountSession(session.toCompanion()));
    notifyListeners();
  }

  void addCycleCountLines(List<CycleCountLine> lines) {
    _cycleCountLines.addAll(lines);
    for (final line in lines) {
      unawaited(_database.upsertCycleCountLine(line.toCompanion()));
    }
    notifyListeners();
  }

  void updateCycleCountLine(CycleCountLine line) {
    final lineIndex = _cycleCountLines.indexWhere(
      (storedLine) => storedLine.id == line.id,
    );
    if (lineIndex == -1) {
      return;
    }

    _cycleCountLines[lineIndex] = line;
    unawaited(_database.upsertCycleCountLine(line.toCompanion()));
    notifyListeners();
  }

  void approveCycleCount(String sessionId) {
    final sessionIndex = _cycleCountSessions.indexWhere(
      (session) =>
          session.id == sessionId &&
          session.status == CycleCountStatus.submitted,
    );
    if (sessionIndex == -1) {
      return;
    }

    final session = _cycleCountSessions[sessionIndex];
    final now = DateTime.now();
    final lines = _cycleCountLines.where((line) {
      return line.sessionId == sessionId && line.countedQuantity != null;
    });

    for (final line in lines) {
      final countedQuantity = line.countedQuantity!;
      final variance =
          line.varianceQuantity ?? countedQuantity - line.expectedQuantity;
      final itemIndex = _items.indexWhere((item) => item.id == line.itemId);
      if (itemIndex == -1) {
        continue;
      }

      final item = _items[itemIndex];
      final updatedItem = item.copyWith(
        quantityOnHand: countedQuantity,
        updatedAt: now,
      );
      _items[itemIndex] = updatedItem;
      unawaited(_database.upsertItem(updatedItem.toCompanion()));

      if (variance != 0) {
        final transaction = InventoryTransaction(
          id: 'txn-cycle-${now.microsecondsSinceEpoch}-${line.id}',
          itemId: item.id,
          transactionType: InventoryTransactionType.cycleCountAdjustment,
          quantityDelta: variance,
          unitOfMeasureId: line.unitOfMeasureId,
          fromLocationId: variance < 0 ? line.locationId : null,
          toLocationId: variance > 0 ? line.locationId : null,
          assignedToPersonId: null,
          performedByUserId: _users.isEmpty ? null : _users.first.id,
          notes: 'Cycle count adjustment: ${session.name}',
          createdAt: now,
        );
        _transactions.add(transaction);
        unawaited(_database.upsertTransaction(transaction.toCompanion()));
      }
    }

    final approvedSession = session.copyWith(
      status: CycleCountStatus.approved,
      approvedAt: now,
    );
    _cycleCountSessions[sessionIndex] = approvedSession;
    unawaited(_database.upsertCycleCountSession(approvedSession.toCompanion()));
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_database.close());
    super.dispose();
  }
}

String? _emptyToNull(String? value) {
  final trimmedValue = value?.trim();
  if (trimmedValue == null || trimmedValue.isEmpty) {
    return null;
  }

  return trimmedValue;
}

class InventorySummaryReport {
  const InventorySummaryReport({
    required this.activeItemCount,
    required this.archivedItemCount,
    required this.consumableCount,
    required this.returnableCount,
    required this.assetCount,
    required this.locationCount,
    required this.lowStockCount,
    required this.activeReorderCount,
    required this.openCheckoutCount,
  });

  final int activeItemCount;
  final int archivedItemCount;
  final int consumableCount;
  final int returnableCount;
  final int assetCount;
  final int locationCount;
  final int lowStockCount;
  final int activeReorderCount;
  final int openCheckoutCount;
}

class InventoryValueReport {
  const InventoryValueReport({
    required this.totalValue,
    required this.valueByType,
    required this.valueByLocation,
    required this.missingCostCount,
    required this.missingCostQuantity,
  });

  final double totalValue;
  final Map<ItemType, double> valueByType;
  final Map<String, double> valueByLocation;
  final int missingCostCount;
  final double missingCostQuantity;
}

class UsageByItemRow {
  const UsageByItemRow({
    required this.itemId,
    required this.quantity,
    required this.unitOfMeasureId,
    required this.transactionCount,
  });

  final String itemId;
  final double quantity;
  final String unitOfMeasureId;
  final int transactionCount;
}

class UsageByPersonRow {
  const UsageByPersonRow({
    required this.personId,
    required this.quantity,
    required this.transactionCount,
    required this.topItemIds,
  });

  final String personId;
  final double quantity;
  final int transactionCount;
  final List<String> topItemIds;
}

class LostDamagedReportRow {
  const LostDamagedReportRow({
    required this.itemId,
    required this.status,
    required this.quantity,
    required this.unitOfMeasureId,
    required this.createdAt,
    required this.notes,
    required this.assignedToPersonId,
    required this.locationId,
  });

  final String itemId;
  final String status;
  final double quantity;
  final String unitOfMeasureId;
  final DateTime createdAt;
  final String? notes;
  final String? assignedToPersonId;
  final String? locationId;
}

class CycleCountVarianceRow {
  const CycleCountVarianceRow({
    required this.itemId,
    required this.sessionName,
    required this.sessionDate,
    required this.expectedQuantity,
    required this.countedQuantity,
    required this.varianceQuantity,
    required this.unitOfMeasureId,
  });

  final String itemId;
  final String sessionName;
  final DateTime sessionDate;
  final double expectedQuantity;
  final double countedQuantity;
  final double varianceQuantity;
  final String unitOfMeasureId;
}

class ReorderStatusSummary {
  const ReorderStatusSummary({
    required this.needed,
    required this.ordered,
    required this.received,
    required this.canceled,
  });

  final int needed;
  final int ordered;
  final int received;
  final int canceled;
}

class AppStoreScope extends InheritedNotifier<AppStore> {
  const AppStoreScope({
    super.key,
    required AppStore store,
    required super.child,
  }) : super(notifier: store);

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStoreScope>();
    assert(scope != null, 'No AppStoreScope found in context.');
    return scope!.notifier!;
  }
}
