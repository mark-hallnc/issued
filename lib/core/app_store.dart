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
  final List<ReorderRequest> _reorderRequests = [];
  final List<CycleCountSession> _cycleCountSessions = [];
  final List<CycleCountLine> _cycleCountLines = [];
  final List<CustomFieldDefinition> _customFieldDefinitions = [];
  final List<CustomFieldValue> _customFieldValues = [];
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
    if (await _database.isEmpty) {
      await _seedDatabase();
    }

    await _loadFromDatabase();
    await _ensureLocalTestUsers();
    _isInitialized = true;
    notifyListeners();
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

  Future<void> _seedDatabase() async {
    for (final unit in sampleUnitsOfMeasure) {
      await _database.upsertUnitOfMeasure(unit.toCompanion());
    }
    for (final location in sampleLocations) {
      await _database.upsertLocation(location.toCompanion());
    }
    for (final person in samplePeople) {
      await _database.upsertPerson(person.toCompanion());
    }
    for (final user in sampleUsers) {
      await _database.upsertAppUser(user.toCompanion());
    }
    for (final item in sampleItems) {
      await _database.upsertItem(item.toCompanion());
    }
    for (final transaction in sampleTransactions) {
      await _database.upsertTransaction(transaction.toCompanion());
    }
    for (final session in sampleCycleCountSessions) {
      await _database.upsertCycleCountSession(session.toCompanion());
    }
    for (final line in sampleCycleCountLines) {
      await _database.upsertCycleCountLine(line.toCompanion());
    }
    for (final field in sampleCustomFieldDefinitions) {
      await _database.upsertCustomFieldDefinition(field.toCompanion());
    }
    for (final value in sampleCustomFieldValues) {
      await _database.upsertCustomFieldValue(value.toCompanion());
    }
    await _database.upsertPlan(samplePlan.toCompanion());
    await _database.upsertCompanyUsage(sampleCompanyUsage.toCompanion());
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

  void addTransaction(InventoryTransaction transaction) {
    _transactions.add(transaction);
    unawaited(_database.upsertTransaction(transaction.toCompanion()));
    notifyListeners();
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
