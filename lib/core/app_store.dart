import 'package:flutter/material.dart';

import 'models/models.dart';
import 'sample_data.dart';

class AppStore extends ChangeNotifier {
  AppStore()
    : _items = List.of(sampleItems),
      _unitsOfMeasure = List.of(sampleUnitsOfMeasure),
      _locations = List.of(sampleLocations),
      _people = List.of(samplePeople),
      _users = List.of(sampleUsers),
      _transactions = List.of(sampleTransactions),
      _cycleCountSessions = List.of(sampleCycleCountSessions),
      _cycleCountLines = List.of(sampleCycleCountLines),
      _customFieldDefinitions = List.of(sampleCustomFieldDefinitions),
      _customFieldValues = List.of(sampleCustomFieldValues),
      _plan = samplePlan,
      _companyUsage = sampleCompanyUsage;

  final List<Item> _items;
  final List<UnitOfMeasure> _unitsOfMeasure;
  final List<Location> _locations;
  final List<Person> _people;
  final List<AppUser> _users;
  final List<InventoryTransaction> _transactions;
  final List<CycleCountSession> _cycleCountSessions;
  final List<CycleCountLine> _cycleCountLines;
  final List<CustomFieldDefinition> _customFieldDefinitions;
  final List<CustomFieldValue> _customFieldValues;
  final Plan _plan;
  final CompanyUsage _companyUsage;

  List<Item> get items => List.unmodifiable(_items);
  List<UnitOfMeasure> get unitsOfMeasure => List.unmodifiable(_unitsOfMeasure);
  List<Location> get locations => List.unmodifiable(_locations);
  List<Person> get people => List.unmodifiable(_people);
  List<AppUser> get users => List.unmodifiable(_users);
  List<InventoryTransaction> get transactions =>
      List.unmodifiable(_transactions);
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

  void addItem(Item item) {
    _items.add(item);
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
    notifyListeners();
  }

  void addTransaction(InventoryTransaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void addUnitOfMeasure(UnitOfMeasure unit) {
    _unitsOfMeasure.add(unit);
    notifyListeners();
  }

  void addLocation(Location location) {
    _locations.add(location);
    notifyListeners();
  }

  void addCustomFieldDefinition(CustomFieldDefinition field) {
    _customFieldDefinitions.add(field);
    notifyListeners();
  }

  void addCycleCountSession(CycleCountSession session) {
    _cycleCountSessions.add(session);
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
    notifyListeners();
  }

  void addCycleCountLines(List<CycleCountLine> lines) {
    _cycleCountLines.addAll(lines);
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
      _items[itemIndex] = item.copyWith(
        quantityOnHand: countedQuantity,
        updatedAt: now,
      );

      if (variance != 0) {
        _transactions.add(
          InventoryTransaction(
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
          ),
        );
      }
    }

    _cycleCountSessions[sessionIndex] = session.copyWith(
      status: CycleCountStatus.approved,
      approvedAt: now,
    );
    notifyListeners();
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
