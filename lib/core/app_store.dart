import 'dart:async';

import 'package:flutter/material.dart';

import 'backup/backup_service.dart';
import 'database/app_database.dart';
import 'database/model_mappers.dart';
import 'data_health/data_health_service.dart';
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
  final List<ItemLocationBalance> _itemLocationBalances = [];
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
  List<ItemLocationBalance> get itemLocationBalances =>
      List.unmodifiable(_itemLocationBalances);
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
    await _backfillItemLocationBalances();
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
    _itemLocationBalances
      ..clear()
      ..addAll(
        (await _database.getAllItemLocationBalances()).map(
          (row) => row.toDomain(),
        ),
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

  void addItemWithInitialBalance(Item item, String locationId) {
    _items.add(item);
    unawaited(_database.upsertItem(item.toCompanion()));
    final balance = ItemLocationBalance(
      id: _balanceId(item.id, locationId),
      itemId: item.id,
      locationId: locationId,
      quantityOnHand: item.quantityOnHand,
      minimumQuantity: 0,
      updatedAt: item.updatedAt,
    );
    _upsertBalanceInMemory(balance);
    unawaited(_database.upsertItemLocationBalance(balance.toCompanion()));
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

  Future<BackupValidationResult> restoreFromBackupJson(String jsonText) async {
    if (!(currentRole == UserRole.admin ||
        (currentRole == UserRole.manager &&
            permissions.canImportExport &&
            permissions.canManageSettings))) {
      return const BackupValidationResult(
        isValid: false,
        message: 'Your current role does not allow this action.',
        errors: ['Your current role does not allow this action.'],
      );
    }

    final service = const BackupService();
    final validation = service.validateBackupJson(jsonText);
    if (!validation.isValid) {
      return validation;
    }

    final backup = service.parseBackupData(jsonText);
    if (backup == null) {
      return const BackupValidationResult(
        isValid: false,
        message: 'Could not read backup data.',
        errors: ['Could not read backup data.'],
      );
    }

    await _database.restoreWorkspaceData(
      unitRows: backup.unitsOfMeasure
          .map((unit) => unit.toCompanion())
          .toList(),
      locationRows: backup.locations
          .map((location) => location.toCompanion())
          .toList(),
      personRows: backup.people.map((person) => person.toCompanion()).toList(),
      userRows: backup.users.map((user) => user.toCompanion()).toList(),
      itemRows: backup.items.map((item) => item.toCompanion()).toList(),
      balanceRows: backup.itemLocationBalances
          .map((balance) => balance.toCompanion())
          .toList(),
      transactionRows: backup.transactions
          .map((transaction) => transaction.toCompanion())
          .toList(),
      checkoutRows: backup.checkoutRecords
          .map((record) => record.toCompanion())
          .toList(),
      reorderRows: backup.reorderRequests
          .map((request) => request.toCompanion())
          .toList(),
      cycleSessionRows: backup.cycleCountSessions
          .map((session) => session.toCompanion())
          .toList(),
      cycleLineRows: backup.cycleCountLines
          .map((line) => line.toCompanion())
          .toList(),
      customFieldRows: backup.customFieldDefinitions
          .map((field) => field.toCompanion())
          .toList(),
      customValueRows: backup.customFieldValues
          .map((value) => value.toCompanion())
          .toList(),
      planRows: [if (backup.plan != null) backup.plan!.toCompanion()],
      usageRows: [
        if (backup.companyUsage != null) backup.companyUsage!.toCompanion(),
      ],
      companyRows: [if (backup.company != null) backup.company!.toCompanion()],
    );

    await _loadFromDatabase();
    await _ensureBasePlanData();
    await _loadFromDatabase();
    notifyListeners();

    return BackupValidationResult(
      isValid: true,
      message: 'Backup restored.',
      warnings: [...validation.warnings, ...backup.warnings],
      counts: validation.counts,
      companyName: validation.companyName,
      backupVersion: validation.backupVersion,
      createdAt: validation.createdAt,
    );
  }

  DataHealthReport runDataHealthCheck() {
    return const DataHealthService().run(this);
  }

  Future<bool> repairDataHealthIssue(String issueId) async {
    if (!_canRepairDataHealth) {
      return false;
    }

    final report = runDataHealthCheck();
    DataHealthIssue? issue;
    for (final candidate in report.issues) {
      if (candidate.id == issueId) {
        issue = candidate;
        break;
      }
    }
    if (issue == null || !issue.canRepair || issue.repairAction == null) {
      return false;
    }

    return _repairDataHealthIssue(issue);
  }

  Future<int> repairAllSafeDataHealthIssues() async {
    if (!_canRepairDataHealth) {
      return 0;
    }

    var repaired = 0;
    var report = runDataHealthCheck();
    while (true) {
      final safeIssues = report.issues.where((issue) {
        return issue.canRepair && issue.repairAction != null;
      }).toList();
      if (safeIssues.isEmpty) {
        return repaired;
      }

      var changed = false;
      for (final issue in safeIssues) {
        if (await _repairDataHealthIssue(issue)) {
          repaired += 1;
          changed = true;
        }
      }
      if (!changed) {
        return repaired;
      }
      report = runDataHealthCheck();
    }
  }

  bool get _canRepairDataHealth {
    return currentRole == UserRole.admin ||
        (currentRole == UserRole.manager &&
            permissions.canManageSettings &&
            permissions.canManageItems);
  }

  Future<bool> _repairDataHealthIssue(DataHealthIssue issue) {
    return switch (issue.repairAction) {
      DataHealthRepairAction.syncItemQuantityFromBalances =>
        syncItemQuantityFromBalances(issue.affectedRecordId ?? ''),
      DataHealthRepairAction.createMissingBalanceForItem =>
        createMissingBalanceForItem(issue.affectedRecordId ?? ''),
      DataHealthRepairAction.reassignBalanceToFallbackLocation =>
        reassignBalanceToFallbackLocation(issue.affectedRecordId ?? ''),
      DataHealthRepairAction.cancelOrphanReorderRequest =>
        cancelOrphanReorderRequest(issue.affectedRecordId ?? ''),
      DataHealthRepairAction.removeOrphanCustomFieldValue =>
        removeOrphanCustomFieldValue(issue.affectedRecordId ?? ''),
      DataHealthRepairAction.resetNegativeMinimumQuantity =>
        resetNegativeMinimumQuantity(issue.affectedRecordId ?? ''),
      DataHealthRepairAction.createMissingDefaultSetup =>
        createMissingDefaultSetup(),
      null => Future.value(false),
    };
  }

  Future<bool> syncItemQuantityFromBalances(String itemId) async {
    final itemIndex = _items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) {
      return false;
    }
    final now = DateTime.now();
    final updatedItem = _items[itemIndex].copyWith(
      quantityOnHand: totalQuantityForItem(itemId),
      updatedAt: now,
    );
    _items[itemIndex] = updatedItem;
    await _database.upsertItem(updatedItem.toCompanion());
    notifyListeners();
    return true;
  }

  Future<bool> createMissingBalanceForItem(String itemId) async {
    final item = _itemById(itemId);
    if (item == null || itemBalancesForItem(itemId).isNotEmpty) {
      return false;
    }
    final locationId =
        _locationById(item.locationId)?.id ?? _firstActiveLocationId();
    if (locationId == null) {
      return false;
    }

    final balance = ItemLocationBalance(
      id: _balanceId(itemId, locationId),
      itemId: itemId,
      locationId: locationId,
      quantityOnHand: item.quantityOnHand,
      minimumQuantity: 0,
      updatedAt: DateTime.now(),
    );
    _upsertBalanceInMemory(balance);
    await _database.upsertItemLocationBalance(balance.toCompanion());
    notifyListeners();
    return true;
  }

  Future<bool> reassignBalanceToFallbackLocation(String balanceId) async {
    final balanceIndex = _itemLocationBalances.indexWhere(
      (balance) => balance.id == balanceId,
    );
    if (balanceIndex == -1) {
      return false;
    }
    final balance = _itemLocationBalances[balanceIndex];
    final item = _itemById(balance.itemId);
    final fallbackLocationId =
        item != null && _locationById(item.locationId) != null
        ? item.locationId
        : _firstActiveLocationId();
    if (fallbackLocationId == null) {
      return false;
    }

    final existing = _balanceFor(balance.itemId, fallbackLocationId);
    final updated = (existing ?? balance).copyWith(
      id: existing?.id ?? _balanceId(balance.itemId, fallbackLocationId),
      locationId: fallbackLocationId,
      quantityOnHand: (existing?.quantityOnHand ?? 0) + balance.quantityOnHand,
      updatedAt: DateTime.now(),
    );
    if (existing == null) {
      _itemLocationBalances[balanceIndex] = updated;
    } else {
      _upsertBalanceInMemory(updated);
      _itemLocationBalances.removeWhere((stored) => stored.id == balance.id);
      await _database.deleteItemLocationBalance(balance.id);
    }
    await _database.upsertItemLocationBalance(updated.toCompanion());
    await syncItemQuantityFromBalances(balance.itemId);
    notifyListeners();
    return true;
  }

  Future<bool> cancelOrphanReorderRequest(String reorderId) async {
    final index = _reorderRequests.indexWhere(
      (request) => request.id == reorderId,
    );
    if (index == -1) {
      return false;
    }
    final request = _reorderRequests[index];
    if (request.status != ReorderStatus.needed &&
        request.status != ReorderStatus.ordered) {
      return false;
    }
    final updated = request.copyWith(
      status: ReorderStatus.canceled,
      notes: [
        if (request.notes?.trim().isNotEmpty == true) request.notes!.trim(),
        'Canceled by Data Health repair because the item is missing.',
      ].join(' '),
    );
    _reorderRequests[index] = updated;
    await _database.upsertReorderRequest(updated.toCompanion());
    notifyListeners();
    return true;
  }

  Future<bool> removeOrphanCustomFieldValue(String valueId) async {
    final removed = _customFieldValues.any((value) => value.id == valueId);
    if (!removed) {
      return false;
    }
    _customFieldValues.removeWhere((value) => value.id == valueId);
    await _database.deleteCustomFieldValueById(valueId);
    notifyListeners();
    return true;
  }

  Future<bool> resetNegativeMinimumQuantity(String itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1 || _items[index].minimumQuantity >= 0) {
      return false;
    }
    final updated = _items[index].copyWith(
      minimumQuantity: 0,
      updatedAt: DateTime.now(),
    );
    _items[index] = updated;
    await _database.upsertItem(updated.toCompanion());
    notifyListeners();
    return true;
  }

  Future<bool> createMissingDefaultSetup() async {
    final now = DateTime.now();
    if (_company == null) {
      _company = Company(
        id: 'company-local',
        name: 'Issued Workspace',
        industry: null,
        createdAt: now,
        updatedAt: now,
        setupCompleted: true,
      );
      await _database.upsertCompany(_company!.toCompanion());
    }
    await _ensureDefaultUnitsOfMeasure();
    if (!_locations.any((location) => location.isActive)) {
      await _ensureLocation('Main Stockroom', 'Stockroom', id: 'loc-main');
    }
    if (!_users.any((user) => user.isActive && user.role == UserRole.admin)) {
      await _ensureAdminUser('Admin User', 'admin@issued.local', now);
    }
    await _loadFromDatabase();
    notifyListeners();
    return true;
  }

  String? _firstActiveLocationId() {
    for (final location in _locations) {
      if (location.isActive) {
        return location.id;
      }
    }
    return null;
  }

  bool updateItemDetails(
    Item updatedItem, {
    List<CustomFieldValue> customFieldValues = const [],
    String? activityNote,
  }) {
    if (!permissions.canManageItems) {
      return false;
    }

    final itemIndex = _items.indexWhere(
      (storedItem) => storedItem.id == updatedItem.id,
    );
    if (itemIndex == -1) {
      return false;
    }

    final existingItem = _items[itemIndex];
    final savedItem = Item(
      id: updatedItem.id,
      name: updatedItem.name,
      description: updatedItem.description,
      itemType: updatedItem.itemType,
      category: updatedItem.category,
      locationId: updatedItem.locationId,
      quantityOnHand: existingItem.quantityOnHand,
      minimumQuantity: updatedItem.minimumQuantity,
      unitOfMeasureId: updatedItem.unitOfMeasureId,
      purchaseUnitOfMeasureId: updatedItem.purchaseUnitOfMeasureId,
      purchaseToStockConversionFactor:
          updatedItem.purchaseToStockConversionFactor,
      purchaseUnitLabel: updatedItem.purchaseUnitLabel,
      barcode: updatedItem.barcode,
      sku: updatedItem.sku,
      supplier: updatedItem.supplier,
      unitCost: updatedItem.unitCost,
      photoPath: existingItem.photoPath,
      isActive: existingItem.isActive,
      allowFractionalQuantity: updatedItem.allowFractionalQuantity,
      createdAt: existingItem.createdAt,
      updatedAt: DateTime.now(),
    );
    _items[itemIndex] = savedItem;
    unawaited(_database.upsertItem(savedItem.toCompanion()));

    for (final value in customFieldValues) {
      final valueIndex = _customFieldValues.indexWhere(
        (storedValue) => storedValue.id == value.id,
      );
      if (valueIndex == -1) {
        _customFieldValues.add(value);
      } else {
        _customFieldValues[valueIndex] = value;
      }
      unawaited(_database.upsertCustomFieldValue(value.toCompanion()));
    }

    final note = activityNote?.trim();
    if (note != null && note.isNotEmpty) {
      final transaction = InventoryTransaction(
        id: 'txn-item-edit-${DateTime.now().microsecondsSinceEpoch}',
        itemId: savedItem.id,
        transactionType: InventoryTransactionType.adjustment,
        quantityDelta: 0,
        unitOfMeasureId: savedItem.unitOfMeasureId,
        fromLocationId: null,
        toLocationId: null,
        assignedToPersonId: null,
        performedByUserId: currentUser?.id,
        notes: note,
        createdAt: DateTime.now(),
      );
      _transactions.add(transaction);
      unawaited(_database.upsertTransaction(transaction.toCompanion()));
    }

    notifyListeners();
    return true;
  }

  bool hasTransactionsForItem(String itemId) {
    return _transactions.any((transaction) => transaction.itemId == itemId);
  }

  bool hasOpenCheckoutsForItem(String itemId) {
    return openCheckoutRecordsForItem(itemId).isNotEmpty;
  }

  bool isBarcodeInUse(String barcode, {String? excludingItemId}) {
    final normalized = barcode.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }
    return _items.any((item) {
      return item.isActive &&
          item.id != excludingItemId &&
          (item.barcode ?? '').trim().toLowerCase() == normalized;
    });
  }

  bool isSkuInUse(String sku, {String? excludingItemId}) {
    final normalized = sku.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }
    return _items.any((item) {
      return item.isActive &&
          item.id != excludingItemId &&
          (item.sku ?? '').trim().toLowerCase() == normalized;
    });
  }

  void addTransaction(InventoryTransaction transaction) {
    _transactions.add(transaction);
    unawaited(_database.upsertTransaction(transaction.toCompanion()));
    notifyListeners();
  }

  List<ItemLocationBalance> itemBalancesForItem(String itemId) {
    final balances = _itemLocationBalances
        .where((balance) => balance.itemId == itemId)
        .toList();
    balances.sort((left, right) {
      final leftQuantity = left.quantityOnHand;
      final rightQuantity = right.quantityOnHand;
      final quantityCompare = rightQuantity.compareTo(leftQuantity);
      if (quantityCompare != 0) {
        return quantityCompare;
      }
      return (resolveLocationName(left.locationId) ?? '').compareTo(
        resolveLocationName(right.locationId) ?? '',
      );
    });
    return balances;
  }

  double totalQuantityForItem(String itemId) {
    return itemBalancesForItem(
      itemId,
    ).fold<double>(0, (sum, balance) => sum + balance.quantityOnHand);
  }

  Location? primaryLocationForItem(String itemId) {
    final balances = itemBalancesForItem(
      itemId,
    ).where((balance) => balance.quantityOnHand > 0).toList();
    if (balances.isEmpty) {
      final item = _itemById(itemId);
      return item == null ? null : _locationById(item.locationId);
    }
    return _locationById(balances.first.locationId);
  }

  void updateItemCachedQuantity(String itemId) {
    final itemIndex = _items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) {
      return;
    }
    final item = _items[itemIndex];
    final updatedItem = item.copyWith(
      quantityOnHand: totalQuantityForItem(itemId),
      updatedAt: DateTime.now(),
    );
    _items[itemIndex] = updatedItem;
    unawaited(_database.upsertItem(updatedItem.toCompanion()));
    notifyListeners();
  }

  bool setItemLocationBalance(
    String itemId,
    String locationId,
    double quantity,
  ) {
    if (quantity < 0 || !_isWholeQuantityAllowed(itemId, quantity)) {
      return false;
    }
    final now = DateTime.now();
    final balance =
        _balanceFor(
          itemId,
          locationId,
        )?.copyWith(quantityOnHand: quantity, updatedAt: now) ??
        ItemLocationBalance(
          id: _balanceId(itemId, locationId),
          itemId: itemId,
          locationId: locationId,
          quantityOnHand: quantity,
          minimumQuantity: 0,
          updatedAt: now,
        );
    _upsertBalanceInMemory(balance);
    unawaited(_database.upsertItemLocationBalance(balance.toCompanion()));
    _syncItemCachedQuantity(itemId, now);
    notifyListeners();
    return true;
  }

  bool adjustItemLocationBalance(
    String itemId,
    String locationId,
    double delta,
  ) {
    final current = _balanceFor(itemId, locationId)?.quantityOnHand ?? 0;
    return setItemLocationBalance(itemId, locationId, current + delta);
  }

  bool receiveItemToLocation({
    required String itemId,
    required String locationId,
    required double quantity,
    String? notes,
  }) {
    if (!permissions.canReceiveStock ||
        !_canMutateItemQuantity(itemId, quantity)) {
      return false;
    }
    if (!adjustItemLocationBalance(itemId, locationId, quantity)) {
      return false;
    }
    _appendInventoryTransaction(
      itemId: itemId,
      type: InventoryTransactionType.receive,
      quantityDelta: quantity,
      toLocationId: locationId,
      notes: notes,
    );
    return true;
  }

  bool issueItemFromLocation({
    required String itemId,
    required String locationId,
    required double quantity,
    String? assignedToPersonId,
    String? notes,
  }) {
    if (!permissions.canIssueItems ||
        !_canMutateItemQuantity(itemId, quantity)) {
      return false;
    }
    final current = _balanceFor(itemId, locationId)?.quantityOnHand ?? 0;
    if (current < quantity) {
      return false;
    }
    if (!adjustItemLocationBalance(itemId, locationId, -quantity)) {
      return false;
    }
    _appendInventoryTransaction(
      itemId: itemId,
      type: InventoryTransactionType.issue,
      quantityDelta: -quantity,
      fromLocationId: locationId,
      assignedToPersonId: assignedToPersonId,
      notes: notes,
    );
    return true;
  }

  bool transferItemBetweenLocations({
    required String itemId,
    required String fromLocationId,
    required String toLocationId,
    required double quantity,
    String? notes,
  }) {
    if (!permissions.canTransferStock ||
        fromLocationId == toLocationId ||
        !_canMutateItemQuantity(itemId, quantity)) {
      return false;
    }
    final current = _balanceFor(itemId, fromLocationId)?.quantityOnHand ?? 0;
    if (current < quantity) {
      return false;
    }
    final now = DateTime.now();
    _setBalanceQuantity(itemId, fromLocationId, current - quantity, now);
    final toCurrent = _balanceFor(itemId, toLocationId)?.quantityOnHand ?? 0;
    _setBalanceQuantity(itemId, toLocationId, toCurrent + quantity, now);
    _syncItemCachedQuantity(itemId, now);
    _appendInventoryTransaction(
      itemId: itemId,
      type: InventoryTransactionType.transfer,
      quantityDelta: 0,
      fromLocationId: fromLocationId,
      toLocationId: toLocationId,
      notes: notes,
    );
    notifyListeners();
    return true;
  }

  bool adjustItemQuantityAtLocation({
    required String itemId,
    required String locationId,
    required double quantity,
    required bool setQuantity,
    String? notes,
  }) {
    if (!permissions.canAdjustQuantity) {
      return false;
    }
    final current = _balanceFor(itemId, locationId)?.quantityOnHand ?? 0;
    final newQuantity = setQuantity ? quantity : current + quantity;
    if (newQuantity < 0 || !_isWholeQuantityAllowed(itemId, newQuantity)) {
      return false;
    }
    if (!setItemLocationBalance(itemId, locationId, newQuantity)) {
      return false;
    }
    final delta = newQuantity - current;
    _appendInventoryTransaction(
      itemId: itemId,
      type: InventoryTransactionType.adjustment,
      quantityDelta: delta,
      fromLocationId: delta < 0 ? locationId : null,
      toLocationId: delta >= 0 ? locationId : null,
      notes: notes,
    );
    return true;
  }

  bool markItemDamagedAtLocation({
    required String itemId,
    required String locationId,
    required double quantity,
    String? notes,
  }) {
    if (!permissions.canAdjustQuantity ||
        !_canMutateItemQuantity(itemId, quantity)) {
      return false;
    }
    final current = _balanceFor(itemId, locationId)?.quantityOnHand ?? 0;
    if (current < quantity) {
      return false;
    }
    if (!adjustItemLocationBalance(itemId, locationId, -quantity)) {
      return false;
    }
    _appendInventoryTransaction(
      itemId: itemId,
      type: InventoryTransactionType.markDamaged,
      quantityDelta: -quantity,
      fromLocationId: locationId,
      notes: notes,
    );
    return true;
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

  List<CustomFieldDefinition> activeCustomFieldsForItem(Item item) {
    final fields = _customFieldDefinitions.where((field) {
      if (!field.isActive || field.entityType != CustomFieldEntityType.item) {
        return false;
      }
      final appliesToItemType = field.appliesToItemType;
      if (appliesToItemType != null && appliesToItemType != item.itemType) {
        return false;
      }
      final appliesToCategory = field.appliesToCategory?.trim();
      if (appliesToCategory != null &&
          appliesToCategory.isNotEmpty &&
          appliesToCategory.toLowerCase() != item.category.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();

    fields.sort((left, right) {
      final orderCompare = left.sortOrder.compareTo(right.sortOrder);
      if (orderCompare != 0) {
        return orderCompare;
      }
      return left.name.toLowerCase().compareTo(right.name.toLowerCase());
    });
    return fields;
  }

  List<CustomFieldValue> customFieldValuesForEntity(
    String entityType,
    String entityId,
  ) {
    return _customFieldValues
        .where((value) => value.entityId == entityId)
        .toList();
  }

  CustomFieldValue? getCustomFieldValue(
    String fieldDefinitionId,
    String entityId,
  ) {
    for (final value in _customFieldValues) {
      if (value.definitionId == fieldDefinitionId &&
          value.entityId == entityId) {
        return value;
      }
    }
    return null;
  }

  void setCustomFieldValue(CustomFieldValue value) {
    final valueIndex = _customFieldValues.indexWhere(
      (storedValue) => storedValue.id == value.id,
    );
    if (valueIndex == -1) {
      _customFieldValues.add(value);
    } else {
      _customFieldValues[valueIndex] = value;
    }
    unawaited(_database.upsertCustomFieldValue(value.toCompanion()));
    notifyListeners();
  }

  void deleteCustomFieldValue(String valueId) {
    _customFieldValues.removeWhere((value) => value.id == valueId);
    unawaited(_database.deleteCustomFieldValueById(valueId));
    notifyListeners();
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
          locationId: _cycleCountLineLocationId(line),
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

  UnitOfMeasure? getStockUom(Item item) {
    return _unitById(item.unitOfMeasureId);
  }

  UnitOfMeasure? getPurchaseUom(Item item) {
    final purchaseUomId = item.purchaseUnitOfMeasureId;
    if (purchaseUomId == null || purchaseUomId.trim().isEmpty) {
      return null;
    }
    return _unitById(purchaseUomId);
  }

  bool hasPurchaseConversion(Item item) {
    final purchaseUom = getPurchaseUom(item);
    final factor = item.purchaseToStockConversionFactor;
    return purchaseUom != null &&
        purchaseUom.id != item.unitOfMeasureId &&
        factor != null &&
        factor > 0;
  }

  double convertPurchaseToStock(Item item, double purchaseQuantity) {
    final factor = item.purchaseToStockConversionFactor;
    if (!hasPurchaseConversion(item) || factor == null) {
      return purchaseQuantity;
    }
    return purchaseQuantity * factor;
  }

  String formatStockQuantity(Item item, double quantity) {
    final unit = getStockUom(item);
    return '${_formatQuantity(quantity)} ${unit?.abbreviation ?? ''}'.trim();
  }

  String formatPurchaseQuantity(Item item, double quantity) {
    final unit = getPurchaseUom(item);
    return '${_formatQuantity(quantity)} ${unit?.abbreviation ?? item.purchaseUnitLabel ?? ''}'
        .trim();
  }

  String? validatePurchaseReceiveQuantity(Item item, double purchaseQuantity) {
    if (purchaseQuantity <= 0) {
      return 'Enter a quantity greater than 0.';
    }
    final purchaseUom = getPurchaseUom(item);
    if (purchaseUom != null &&
        !purchaseUom.allowsDecimal &&
        purchaseQuantity != purchaseQuantity.roundToDouble()) {
      return 'Purchase quantity must be a whole number.';
    }
    final stockQuantity = convertPurchaseToStock(item, purchaseQuantity);
    final stockUom = getStockUom(item);
    if (!item.allowFractionalQuantity &&
        stockUom?.allowsDecimal != true &&
        stockQuantity != stockQuantity.roundToDouble()) {
      return 'Converted stock quantity must be a whole number.';
    }
    return null;
  }

  String? purchaseConversionPreview(Item item) {
    if (!hasPurchaseConversion(item)) {
      return null;
    }
    final purchaseUom = getPurchaseUom(item);
    final stockUom = getStockUom(item);
    final factor = item.purchaseToStockConversionFactor!;
    return '1 ${purchaseUom?.abbreviation ?? item.purchaseUnitLabel ?? 'purchase unit'} = ${_formatQuantity(factor)} ${stockUom?.abbreviation ?? ''}'
        .trim();
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
    required String sourceLocationId,
    String? assignedToPersonId,
    String? assignedToLocationId,
    String? assignedToText,
    DateTime? dueAt,
    String? notes,
  }) {
    if (!permissions.canIssueItems ||
        !_canMutateItemQuantity(itemId, quantity)) {
      return false;
    }

    final itemIndex = _items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) {
      return false;
    }

    final item = _items[itemIndex];
    final now = DateTime.now();
    final sourceBalance =
        _balanceFor(itemId, sourceLocationId)?.quantityOnHand ?? 0;
    if (sourceBalance < quantity) {
      return false;
    }
    final normalizedAssignedText = assignedToText?.trim();
    final normalizedNotes = notes?.trim();
    _setBalanceQuantity(
      itemId,
      sourceLocationId,
      sourceBalance - quantity,
      now,
    );
    _syncItemCachedQuantity(itemId, now);

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
      fromLocationId: sourceLocationId,
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
    required String returnToLocationId,
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
    final current =
        _balanceFor(item.id, returnToLocationId)?.quantityOnHand ?? 0;
    _setBalanceQuantity(
      item.id,
      returnToLocationId,
      current + returnedQuantity,
      now,
    );
    _syncItemCachedQuantity(item.id, now);

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
      toLocationId: returnToLocationId,
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

    final item = _itemById(request.itemId);
    if (item == null) {
      return false;
    }

    final now = DateTime.now();
    final locationId = primaryLocationForItem(item.id)?.id ?? item.locationId;
    final current = _balanceFor(item.id, locationId)?.quantityOnHand ?? 0;
    _setBalanceQuantity(item.id, locationId, current + receivedQuantity, now);
    _syncItemCachedQuantity(item.id, now);

    final normalizedNotes = notes?.trim();
    final transaction = InventoryTransaction(
      id: 'txn-reorder-${now.microsecondsSinceEpoch}',
      itemId: item.id,
      transactionType: InventoryTransactionType.receive,
      quantityDelta: receivedQuantity,
      unitOfMeasureId: item.unitOfMeasureId,
      fromLocationId: null,
      toLocationId: locationId,
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

  Location? _locationById(String locationId) {
    for (final location in _locations) {
      if (location.id == locationId) {
        return location;
      }
    }

    return null;
  }

  ItemLocationBalance? _balanceFor(String itemId, String locationId) {
    for (final balance in _itemLocationBalances) {
      if (balance.itemId == itemId && balance.locationId == locationId) {
        return balance;
      }
    }
    return null;
  }

  String _balanceId(String itemId, String locationId) {
    return 'balance-$itemId-$locationId';
  }

  void _upsertBalanceInMemory(ItemLocationBalance balance) {
    final index = _itemLocationBalances.indexWhere(
      (storedBalance) => storedBalance.id == balance.id,
    );
    if (index == -1) {
      _itemLocationBalances.add(balance);
    } else {
      _itemLocationBalances[index] = balance;
    }
  }

  void _setBalanceQuantity(
    String itemId,
    String locationId,
    double quantity,
    DateTime updatedAt,
  ) {
    final balance =
        _balanceFor(
          itemId,
          locationId,
        )?.copyWith(quantityOnHand: quantity, updatedAt: updatedAt) ??
        ItemLocationBalance(
          id: _balanceId(itemId, locationId),
          itemId: itemId,
          locationId: locationId,
          quantityOnHand: quantity,
          minimumQuantity: 0,
          updatedAt: updatedAt,
        );
    _upsertBalanceInMemory(balance);
    unawaited(_database.upsertItemLocationBalance(balance.toCompanion()));
  }

  void _syncItemCachedQuantity(String itemId, DateTime updatedAt) {
    final itemIndex = _items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) {
      return;
    }
    final item = _items[itemIndex];
    _items[itemIndex] = item.copyWith(
      quantityOnHand: totalQuantityForItem(itemId),
      updatedAt: updatedAt,
    );
    unawaited(_database.upsertItem(_items[itemIndex].toCompanion()));
  }

  bool _isWholeQuantityAllowed(String itemId, double quantity) {
    final item = _itemById(itemId);
    if (item == null || item.allowFractionalQuantity) {
      return true;
    }
    final unit = _unitById(item.unitOfMeasureId);
    if (unit?.allowsDecimal == true) {
      return true;
    }
    return quantity == quantity.roundToDouble();
  }

  bool _canMutateItemQuantity(String itemId, double quantity) {
    final item = _itemById(itemId);
    return item != null &&
        item.isActive &&
        quantity > 0 &&
        _isWholeQuantityAllowed(itemId, quantity);
  }

  void _appendInventoryTransaction({
    required String itemId,
    required InventoryTransactionType type,
    required double quantityDelta,
    String? fromLocationId,
    String? toLocationId,
    String? assignedToPersonId,
    String? notes,
  }) {
    final item = _itemById(itemId);
    if (item == null) {
      return;
    }
    final transaction = InventoryTransaction(
      id: 'txn-${type.name}-${DateTime.now().microsecondsSinceEpoch}',
      itemId: itemId,
      transactionType: type,
      quantityDelta: quantityDelta,
      unitOfMeasureId: item.unitOfMeasureId,
      fromLocationId: fromLocationId,
      toLocationId: toLocationId,
      assignedToPersonId: assignedToPersonId,
      performedByUserId: currentUser?.id,
      notes: notes,
      createdAt: DateTime.now(),
    );
    _transactions.add(transaction);
    unawaited(_database.upsertTransaction(transaction.toCompanion()));
  }

  Future<void> _backfillItemLocationBalances() async {
    var changed = false;
    Location? firstActiveLocation;
    for (final location in _locations) {
      if (location.isActive) {
        firstActiveLocation = location;
        break;
      }
    }
    for (final item in _items.where((item) => item.isActive)) {
      if (_itemLocationBalances.any((balance) => balance.itemId == item.id)) {
        continue;
      }
      final locationId =
          _locations.any((location) => location.id == item.locationId)
          ? item.locationId
          : firstActiveLocation?.id;
      if (locationId == null) {
        continue;
      }
      final balance = ItemLocationBalance(
        id: _balanceId(item.id, locationId),
        itemId: item.id,
        locationId: locationId,
        quantityOnHand: item.quantityOnHand,
        minimumQuantity: 0,
        updatedAt: item.updatedAt,
      );
      _itemLocationBalances.add(balance);
      await _database.upsertItemLocationBalance(balance.toCompanion());
      changed = true;
    }
    for (final item in _items) {
      final total = totalQuantityForItem(item.id);
      if (item.quantityOnHand != total &&
          _itemLocationBalances.any((balance) => balance.itemId == item.id)) {
        final itemIndex = _items.indexWhere(
          (storedItem) => storedItem.id == item.id,
        );
        _items[itemIndex] = item.copyWith(quantityOnHand: total);
        await _database.upsertItem(_items[itemIndex].toCompanion());
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  CycleCountSession? _cycleCountSessionById(String sessionId) {
    for (final session in _cycleCountSessions) {
      if (session.id == sessionId) {
        return session;
      }
    }

    return null;
  }

  bool _cycleCountItemMatchesScope(
    Item item,
    CycleCountScope scope, {
    String? locationId,
    String? category,
    ItemType? itemType,
  }) {
    return switch (scope) {
      CycleCountScope.allItems => true,
      CycleCountScope.location =>
        locationId != null &&
            (_cycleCountLocationsForItem(
              item,
              scope,
              locationId: locationId,
            ).isNotEmpty),
      CycleCountScope.category => item.category == category,
      CycleCountScope.lowStock => isItemLowStock(item),
      CycleCountScope.itemType => item.itemType == itemType,
    };
  }

  List<String> _cycleCountLocationsForItem(
    Item item,
    CycleCountScope scope, {
    String? locationId,
  }) {
    final balances = itemBalancesForItem(item.id);
    if (scope == CycleCountScope.location) {
      if (locationId == null) {
        return const [];
      }
      if (balances.any((balance) => balance.locationId == locationId)) {
        return [locationId];
      }
      if (item.locationId == locationId) {
        return [locationId];
      }
      return const [];
    }

    if (balances.isNotEmpty) {
      return balances.map((balance) => balance.locationId).toSet().toList();
    }
    return [item.locationId];
  }

  String _cycleCountLineLocationId(CycleCountLine line) {
    if (line.locationId.trim().isNotEmpty) {
      return line.locationId;
    }
    final item = _itemById(line.itemId);
    return primaryLocationForItem(line.itemId)?.id ?? item?.locationId ?? '';
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

  void updateCustomFieldDefinition(CustomFieldDefinition field) {
    final fieldIndex = _customFieldDefinitions.indexWhere(
      (storedField) => storedField.id == field.id,
    );
    if (fieldIndex == -1) {
      return;
    }

    _customFieldDefinitions[fieldIndex] = field;
    unawaited(_database.upsertCustomFieldDefinition(field.toCompanion()));
    notifyListeners();
  }

  void archiveCustomFieldDefinition(String fieldId) {
    final fieldIndex = _customFieldDefinitions.indexWhere(
      (field) => field.id == fieldId,
    );
    if (fieldIndex == -1) {
      return;
    }

    final archivedField = _customFieldDefinitions[fieldIndex].copyWith(
      isActive: false,
    );
    _customFieldDefinitions[fieldIndex] = archivedField;
    unawaited(
      _database.upsertCustomFieldDefinition(archivedField.toCompanion()),
    );
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

  double getExpectedQuantityForItemAtLocation(
    String itemId,
    String locationId,
  ) {
    final balance = _balanceFor(itemId, locationId);
    if (balance != null) {
      return balance.quantityOnHand;
    }

    final item = _itemById(itemId);
    if (item == null) {
      return 0;
    }
    if (item.locationId == locationId && itemBalancesForItem(itemId).isEmpty) {
      return item.quantityOnHand;
    }
    return 0;
  }

  List<CycleCountLine> getCycleCountCandidateLines({
    required String sessionId,
    required CycleCountScope scope,
    String? locationId,
    String? category,
    ItemType? itemType,
  }) {
    final lines = <CycleCountLine>[];
    for (final item in _items.where((item) => item.isActive)) {
      if (!_cycleCountItemMatchesScope(
        item,
        scope,
        locationId: locationId,
        category: category,
        itemType: itemType,
      )) {
        continue;
      }

      final locations = _cycleCountLocationsForItem(
        item,
        scope,
        locationId: locationId,
      );
      for (final countedLocationId in locations) {
        lines.add(
          CycleCountLine(
            id: 'line-$sessionId-${item.id}-$countedLocationId',
            sessionId: sessionId,
            itemId: item.id,
            locationId: countedLocationId,
            expectedQuantity: getExpectedQuantityForItemAtLocation(
              item.id,
              countedLocationId,
            ),
            countedQuantity: null,
            varianceQuantity: null,
            unitOfMeasureId: item.unitOfMeasureId,
            notes: null,
          ),
        );
      }
    }

    lines.sort((left, right) {
      final locationCompare = (resolveLocationName(left.locationId) ?? '')
          .compareTo(resolveLocationName(right.locationId) ?? '');
      if (locationCompare != 0) {
        return locationCompare;
      }
      return resolveItemName(
        left.itemId,
      ).compareTo(resolveItemName(right.itemId));
    });
    return lines;
  }

  CycleCountSession? createCycleCountSessionFromScope({
    required String name,
    required CycleCountScope scope,
    required bool blindCount,
    DateTime? dueAt,
    String? locationId,
    String? category,
    ItemType? itemType,
  }) {
    if (!permissions.canManageCycleCounts) {
      return null;
    }

    final now = DateTime.now();
    final session = CycleCountSession(
      id: 'count-${now.microsecondsSinceEpoch}',
      name: name,
      status: CycleCountStatus.assigned,
      assignedToUserId: currentUser?.id,
      blindCount: blindCount,
      dueAt: dueAt,
      createdAt: now,
      submittedAt: null,
      approvedAt: null,
    );
    final lines = getCycleCountCandidateLines(
      sessionId: session.id,
      scope: scope,
      locationId: locationId,
      category: category,
      itemType: itemType,
    );
    if (lines.isEmpty) {
      return null;
    }

    _cycleCountSessions.add(session);
    unawaited(_database.upsertCycleCountSession(session.toCompanion()));
    _cycleCountLines.addAll(lines);
    for (final line in lines) {
      unawaited(_database.upsertCycleCountLine(line.toCompanion()));
    }
    notifyListeners();
    return session;
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
      final locationId = _cycleCountLineLocationId(line);
      _setBalanceQuantity(item.id, locationId, countedQuantity, now);
      _syncItemCachedQuantity(item.id, now);

      if (variance != 0) {
        final locationName =
            resolveLocationName(locationId) ?? 'Unknown location';
        final noteParts = [
          'Cycle count adjustment from ${session.name} at $locationName.',
          if ((line.notes ?? '').trim().isNotEmpty)
            'Count note: ${line.notes!.trim()}',
        ];
        final transaction = InventoryTransaction(
          id: 'txn-cycle-${now.microsecondsSinceEpoch}-${line.id}',
          itemId: item.id,
          transactionType: InventoryTransactionType.cycleCountAdjustment,
          quantityDelta: variance,
          unitOfMeasureId: line.unitOfMeasureId,
          fromLocationId: variance < 0 ? locationId : null,
          toLocationId: variance > 0 ? locationId : null,
          assignedToPersonId: null,
          performedByUserId: currentUser?.id,
          notes: noteParts.join(' '),
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

String _formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toStringAsFixed(0);
  }
  return quantity.toStringAsFixed(2);
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
    required this.locationId,
  });

  final String itemId;
  final String sessionName;
  final DateTime sessionDate;
  final double expectedQuantity;
  final double countedQuantity;
  final double varianceQuantity;
  final String unitOfMeasureId;
  final String locationId;
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
