import '../app_store.dart';
import '../data_health/data_health_service.dart';
import '../models/models.dart';

class ReportDateRange {
  const ReportDateRange({required this.label, required this.start, this.end});

  final String label;
  final DateTime? start;
  final DateTime? end;

  bool contains(DateTime value) {
    final startValue = start;
    final endValue = end;
    if (startValue != null && value.isBefore(startValue)) {
      return false;
    }
    if (endValue != null && value.isAfter(endValue)) {
      return false;
    }
    return true;
  }
}

class ReportsSnapshot {
  const ReportsSnapshot({
    required this.inventorySummary,
    required this.inventoryValueRows,
    required this.stockByLocationRows,
    required this.usageByItemRows,
    required this.usageByPersonRows,
    required this.usageByAssignmentTargetRows,
    required this.checkoutAgingRows,
    required this.openReorders,
    required this.reordersBySupplierRows,
    required this.lowStockWithoutReorder,
    required this.cycleCountVarianceRows,
    required this.recentActivityRows,
    required this.dataHealthReport,
  });

  final ReportsInventorySummary inventorySummary;
  final List<InventoryValueRow> inventoryValueRows;
  final List<StockByLocationRow> stockByLocationRows;
  final List<UsageByItemReportRow> usageByItemRows;
  final List<UsageByPersonReportRow> usageByPersonRows;
  final List<UsageByAssignmentTargetReportRow> usageByAssignmentTargetRows;
  final List<CheckoutAgingRow> checkoutAgingRows;
  final List<ReorderReportRow> openReorders;
  final List<ReordersBySupplierRow> reordersBySupplierRows;
  final List<Item> lowStockWithoutReorder;
  final List<CycleCountVarianceRow> cycleCountVarianceRows;
  final List<ActivityReportRow> recentActivityRows;
  final DataHealthReport dataHealthReport;
}

class ReportService {
  const ReportService();

  ReportsSnapshot build(AppStore store, ReportDateRange range) {
    return ReportsSnapshot(
      inventorySummary: _inventorySummary(store),
      inventoryValueRows: inventoryValueRows(store),
      stockByLocationRows: stockByLocationRows(store),
      usageByItemRows: usageByItemRows(store, range),
      usageByPersonRows: usageByPersonRows(store, range),
      usageByAssignmentTargetRows: usageByAssignmentTargetRows(store, range),
      checkoutAgingRows: checkoutAgingRows(store),
      openReorders: reorderRows(
        store,
        store.reorderRequests.where((request) => request.isOpen),
      ),
      reordersBySupplierRows: reordersBySupplierRows(store),
      lowStockWithoutReorder: lowStockWithoutReorder(store),
      cycleCountVarianceRows: cycleCountVarianceRows(store, range),
      recentActivityRows: recentActivityRows(store, range),
      dataHealthReport: const DataHealthService().run(store),
    );
  }

  ReportsInventorySummary _inventorySummary(AppStore store) {
    final activeItems = store.items.where((item) => item.isActive).toList();
    return ReportsInventorySummary(
      activeItemCount: activeItems.length,
      archivedItemCount: store.items.where((item) => !item.isActive).length,
      totalStockQuantity: activeItems.fold<double>(
        0,
        (sum, item) => sum + item.quantityOnHand,
      ),
      lowStockCount: activeItems
          .where(
            (item) =>
                item.minimumQuantity > 0 &&
                item.quantityOnHand <= item.minimumQuantity &&
                item.quantityOnHand > 0,
          )
          .length,
      outOfStockCount: activeItems
          .where((item) => item.minimumQuantity > 0 && item.quantityOnHand <= 0)
          .length,
      checkedOutCount: store.openCheckoutRecords.length,
      openReorderCount: store.reorderRequests
          .where((request) => request.isOpen)
          .length,
      activeLocationCount: store.locations
          .where((location) => location.isActive)
          .length,
      activeSupplierCount: store.suppliers
          .where((supplier) => supplier.isActive)
          .length,
    );
  }

  List<InventoryValueRow> inventoryValueRows(AppStore store) {
    final rows = <InventoryValueRow>[
      for (final item in store.items.where((item) => item.isActive))
        InventoryValueRow(
          item: item,
          category: item.category,
          quantityOnHand: item.quantityOnHand,
          unitCost: item.unitCost,
          estimatedValue: item.unitCost == null
              ? null
              : item.unitCost! * item.quantityOnHand,
          supplierName: store.resolveSupplierName(
            item.supplierId,
            fallback: item.supplier,
          ),
          locationName: store.resolveLocationPath(item.locationId),
        ),
    ];
    rows.sort((left, right) {
      return (right.estimatedValue ?? -1).compareTo(left.estimatedValue ?? -1);
    });
    return rows;
  }

  List<StockByLocationRow> stockByLocationRows(AppStore store) {
    final rows = <StockByLocationRow>[];
    for (final location in store.locations) {
      final balances = store
          .getBalancesAtLocation(location.id)
          .where((balance) => balance.quantityOnHand > 0)
          .toList();
      if (balances.isEmpty) {
        continue;
      }
      var estimatedValue = 0.0;
      var missingCostCount = 0;
      var lowStockCount = 0;
      final itemRows = <StockByLocationItemRow>[];
      for (final balance in balances) {
        final item = store.findItemById(balance.itemId);
        if (item == null) {
          continue;
        }
        final value = item.unitCost == null
            ? null
            : item.unitCost! * balance.quantityOnHand;
        if (value == null) {
          missingCostCount++;
        } else {
          estimatedValue += value;
        }
        if (item.minimumQuantity > 0 &&
            item.quantityOnHand <= item.minimumQuantity) {
          lowStockCount++;
        }
        itemRows.add(
          StockByLocationItemRow(
            item: item,
            quantityAtLocation: balance.quantityOnHand,
            estimatedValue: value,
          ),
        );
      }
      itemRows.sort((left, right) => left.item.name.compareTo(right.item.name));
      rows.add(
        StockByLocationRow(
          location: location,
          locationPath: store.resolveLocationPath(location.id),
          itemCount: itemRows.length,
          totalQuantity: balances.fold<double>(
            0,
            (sum, balance) => sum + balance.quantityOnHand,
          ),
          lowStockItemCount: lowStockCount,
          estimatedValue: estimatedValue,
          missingCostCount: missingCostCount,
          items: itemRows,
        ),
      );
    }
    rows.sort((left, right) => left.locationPath.compareTo(right.locationPath));
    return rows;
  }

  List<UsageByItemReportRow> usageByItemRows(
    AppStore store,
    ReportDateRange range,
  ) {
    final rowsByItem = <String, _UsageByItemAccumulator>{};
    for (final transaction in _transactionsInRange(store, range)) {
      final item = store.findItemById(transaction.itemId);
      final accumulator = rowsByItem.putIfAbsent(
        transaction.itemId,
        () => _UsageByItemAccumulator(item: item, itemId: transaction.itemId),
      );
      accumulator.lastActivity = _latest(
        accumulator.lastActivity,
        transaction.createdAt,
      );
      switch (transaction.transactionType) {
        case InventoryTransactionType.issue:
          accumulator.issuedQuantity += transaction.quantityDelta.abs();
          break;
        case InventoryTransactionType.receive:
          accumulator.receivedQuantity += transaction.quantityDelta.abs();
          break;
        case InventoryTransactionType.checkout:
          accumulator.checkoutCount++;
          break;
        case InventoryTransactionType.adjustment ||
            InventoryTransactionType.cycleCountAdjustment:
          accumulator.adjustmentCount++;
          break;
        case InventoryTransactionType.markLost:
          accumulator.lostCount++;
          break;
        case InventoryTransactionType.markDamaged:
          accumulator.damagedCount++;
          break;
        case InventoryTransactionType.returnItem ||
            InventoryTransactionType.transfer:
          break;
      }
    }
    final rows = [
      for (final accumulator in rowsByItem.values) accumulator.toRow(store),
    ];
    rows.sort((left, right) {
      final quantityCompare = right.issuedQuantity.compareTo(
        left.issuedQuantity,
      );
      return quantityCompare != 0
          ? quantityCompare
          : right.checkoutCount.compareTo(left.checkoutCount);
    });
    return rows;
  }

  List<UsageByPersonReportRow> usageByPersonRows(
    AppStore store,
    ReportDateRange range,
  ) {
    final rowsByPerson = <String, _UsageByPersonAccumulator>{};
    for (final transaction in _transactionsInRange(store, range)) {
      final performedByPersonId = _userPersonId(
        store,
        transaction.performedByUserId,
      );
      final ids = [
        if (performedByPersonId != null) 'performed:$performedByPersonId',
        if (transaction.assignedToPersonId != null)
          'assigned:${transaction.assignedToPersonId}',
      ];
      for (final id in ids) {
        final accumulator = rowsByPerson.putIfAbsent(
          id,
          () => _UsageByPersonAccumulator(
            personId: id.split(':').last,
            role: id.startsWith('performed') ? 'Performed By' : 'Assigned To',
          ),
        );
        accumulator.add(transaction);
      }
    }
    final rows = [
      for (final accumulator in rowsByPerson.values) accumulator.toRow(store),
    ];
    rows.sort((left, right) {
      return (right.issuedQuantity + right.checkoutCount).compareTo(
        left.issuedQuantity + left.checkoutCount,
      );
    });
    return rows;
  }

  List<UsageByAssignmentTargetReportRow> usageByAssignmentTargetRows(
    AppStore store,
    ReportDateRange range,
  ) {
    final rowsByTarget = <String, _UsageByTargetAccumulator>{};
    for (final transaction in _transactionsInRange(store, range)) {
      final targetId = transaction.assignedToTargetId;
      if (targetId == null) {
        continue;
      }
      rowsByTarget
          .putIfAbsent(
            targetId,
            () => _UsageByTargetAccumulator(targetId: targetId),
          )
          .add(transaction);
    }
    final rows = [
      for (final accumulator in rowsByTarget.values) accumulator.toRow(store),
    ];
    rows.sort((left, right) {
      return (right.issuedQuantity + right.checkoutCount).compareTo(
        left.issuedQuantity + left.checkoutCount,
      );
    });
    return rows;
  }

  List<CheckoutAgingRow> checkoutAgingRows(AppStore store) {
    final rowsByBucket = <String, List<CheckoutRecord>>{};
    final now = DateTime.now();
    for (final record in store.openCheckoutRecords) {
      rowsByBucket
          .putIfAbsent(_checkoutAgingBucket(record, now), () => [])
          .add(record);
    }
    final order = [
      'Due today',
      '1-7 days overdue',
      '8-30 days overdue',
      '31+ days overdue',
      'Not overdue',
      'No due date',
    ];
    return [
      for (final bucket in order)
        if ((rowsByBucket[bucket] ?? const []).isNotEmpty)
          CheckoutAgingRow(bucket: bucket, records: rowsByBucket[bucket]!),
    ];
  }

  List<ReorderReportRow> reorderRows(
    AppStore store,
    Iterable<ReorderRequest> requests,
  ) {
    final now = DateTime.now();
    final rows = [
      for (final request in requests)
        ReorderReportRow(
          request: request,
          itemName: store.resolveItemName(request.itemId),
          supplierName: store.resolveSupplierName(
            request.supplierId,
            fallback: request.supplier,
          ),
          destinationLocationName: request.destinationLocationId == null
              ? null
              : store.resolveLocationPath(request.destinationLocationId!),
          daysOpen: now.difference(request.createdAt).inDays,
        ),
    ];
    rows.sort(
      (left, right) =>
          right.request.createdAt.compareTo(left.request.createdAt),
    );
    return rows;
  }

  List<ReordersBySupplierRow> reordersBySupplierRows(AppStore store) {
    final rowsBySupplier = <String, _ReordersBySupplierAccumulator>{};
    for (final request in store.reorderRequests.where(
      (request) => request.isOpen,
    )) {
      final supplierName =
          store.resolveSupplierName(
            request.supplierId,
            fallback: request.supplier,
          ) ??
          'No supplier';
      rowsBySupplier
          .putIfAbsent(
            supplierName,
            () => _ReordersBySupplierAccumulator(supplierName: supplierName),
          )
          .add(request);
    }
    final rows = [
      for (final accumulator in rowsBySupplier.values) accumulator.toRow(store),
    ];
    rows.sort((left, right) => left.supplierName.compareTo(right.supplierName));
    return rows;
  }

  List<Item> lowStockWithoutReorder(AppStore store) {
    final rows = store
        .getLowStockItems()
        .where((item) => store.getActiveReorderForItem(item.id) == null)
        .toList();
    rows.sort((left, right) => left.name.compareTo(right.name));
    return rows;
  }

  List<CycleCountVarianceRow> cycleCountVarianceRows(
    AppStore store,
    ReportDateRange range,
  ) {
    return store
        .getCycleCountVarianceRows()
        .where((row) => range.contains(row.sessionDate))
        .toList();
  }

  List<ActivityReportRow> recentActivityRows(
    AppStore store,
    ReportDateRange range,
  ) {
    final rows = [
      for (final transaction in _transactionsInRange(store, range))
        ActivityReportRow(
          transaction: transaction,
          itemName: store.resolveItemName(transaction.itemId),
          fromLocationName: transaction.fromLocationId == null
              ? null
              : store.resolveLocationPath(transaction.fromLocationId!),
          toLocationName: transaction.toLocationId == null
              ? null
              : store.resolveLocationPath(transaction.toLocationId!),
          assignedTo: store.resolveAssignedTo(
            personId: transaction.assignedToPersonId,
            targetId: transaction.assignedToTargetId,
            locationId: transaction.assignedToLocationId,
            text: transaction.assignedToText,
          ),
          performedBy: _resolveUserName(store, transaction.performedByUserId),
        ),
    ];
    rows.sort(
      (left, right) =>
          right.transaction.createdAt.compareTo(left.transaction.createdAt),
    );
    return rows;
  }

  List<InventoryTransaction> _transactionsInRange(
    AppStore store,
    ReportDateRange range,
  ) {
    return store.transactions
        .where((transaction) => range.contains(transaction.createdAt))
        .toList();
  }
}

class ReportsInventorySummary {
  const ReportsInventorySummary({
    required this.activeItemCount,
    required this.archivedItemCount,
    required this.totalStockQuantity,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.checkedOutCount,
    required this.openReorderCount,
    required this.activeLocationCount,
    required this.activeSupplierCount,
  });

  final int activeItemCount;
  final int archivedItemCount;
  final double totalStockQuantity;
  final int lowStockCount;
  final int outOfStockCount;
  final int checkedOutCount;
  final int openReorderCount;
  final int activeLocationCount;
  final int activeSupplierCount;
}

class InventoryValueRow {
  const InventoryValueRow({
    required this.item,
    required this.category,
    required this.quantityOnHand,
    required this.unitCost,
    required this.estimatedValue,
    required this.supplierName,
    required this.locationName,
  });

  final Item item;
  final String category;
  final double quantityOnHand;
  final double? unitCost;
  final double? estimatedValue;
  final String? supplierName;
  final String locationName;
}

class StockByLocationRow {
  const StockByLocationRow({
    required this.location,
    required this.locationPath,
    required this.itemCount,
    required this.totalQuantity,
    required this.lowStockItemCount,
    required this.estimatedValue,
    required this.missingCostCount,
    required this.items,
  });

  final Location location;
  final String locationPath;
  final int itemCount;
  final double totalQuantity;
  final int lowStockItemCount;
  final double estimatedValue;
  final int missingCostCount;
  final List<StockByLocationItemRow> items;
}

class StockByLocationItemRow {
  const StockByLocationItemRow({
    required this.item,
    required this.quantityAtLocation,
    required this.estimatedValue,
  });

  final Item item;
  final double quantityAtLocation;
  final double? estimatedValue;
}

class UsageByItemReportRow {
  const UsageByItemReportRow({
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.unitOfMeasureId,
    required this.issuedQuantity,
    required this.receivedQuantity,
    required this.adjustmentCount,
    required this.checkoutCount,
    required this.lostCount,
    required this.damagedCount,
    required this.lastActivity,
  });

  final String itemId;
  final String itemName;
  final String category;
  final String unitOfMeasureId;
  final double issuedQuantity;
  final double receivedQuantity;
  final int adjustmentCount;
  final int checkoutCount;
  final int lostCount;
  final int damagedCount;
  final DateTime? lastActivity;
}

class UsageByPersonReportRow {
  const UsageByPersonReportRow({
    required this.personId,
    required this.displayName,
    required this.role,
    required this.issuedQuantity,
    required this.checkoutCount,
    required this.returnCount,
    required this.openCheckoutCount,
    required this.overdueCheckoutCount,
    required this.topItemNames,
  });

  final String personId;
  final String displayName;
  final String role;
  final double issuedQuantity;
  final int checkoutCount;
  final int returnCount;
  final int openCheckoutCount;
  final int overdueCheckoutCount;
  final List<String> topItemNames;
}

class UsageByAssignmentTargetReportRow {
  const UsageByAssignmentTargetReportRow({
    required this.targetId,
    required this.targetName,
    required this.targetType,
    required this.issuedQuantity,
    required this.checkoutCount,
    required this.openCheckoutCount,
    required this.lostDamagedCount,
    required this.topItemNames,
  });

  final String targetId;
  final String targetName;
  final String targetType;
  final double issuedQuantity;
  final int checkoutCount;
  final int openCheckoutCount;
  final int lostDamagedCount;
  final List<String> topItemNames;
}

class CheckoutAgingRow {
  const CheckoutAgingRow({required this.bucket, required this.records});

  final String bucket;
  final List<CheckoutRecord> records;
}

class ReorderReportRow {
  const ReorderReportRow({
    required this.request,
    required this.itemName,
    required this.supplierName,
    required this.destinationLocationName,
    required this.daysOpen,
  });

  final ReorderRequest request;
  final String itemName;
  final String? supplierName;
  final String? destinationLocationName;
  final int daysOpen;
}

class ReordersBySupplierRow {
  const ReordersBySupplierRow({
    required this.supplierName,
    required this.neededCount,
    required this.orderedCount,
    required this.partiallyReceivedCount,
    required this.remainingQuantity,
    required this.requests,
  });

  final String supplierName;
  final int neededCount;
  final int orderedCount;
  final int partiallyReceivedCount;
  final double remainingQuantity;
  final List<ReorderRequest> requests;
}

class ActivityReportRow {
  const ActivityReportRow({
    required this.transaction,
    required this.itemName,
    required this.fromLocationName,
    required this.toLocationName,
    required this.assignedTo,
    required this.performedBy,
  });

  final InventoryTransaction transaction;
  final String itemName;
  final String? fromLocationName;
  final String? toLocationName;
  final String? assignedTo;
  final String? performedBy;
}

class _UsageByItemAccumulator {
  _UsageByItemAccumulator({required this.item, required this.itemId});

  final Item? item;
  final String itemId;
  double issuedQuantity = 0;
  double receivedQuantity = 0;
  int adjustmentCount = 0;
  int checkoutCount = 0;
  int lostCount = 0;
  int damagedCount = 0;
  DateTime? lastActivity;

  UsageByItemReportRow toRow(AppStore store) {
    return UsageByItemReportRow(
      itemId: itemId,
      itemName: item?.name ?? store.resolveItemName(itemId),
      category: item?.category ?? 'Unknown',
      unitOfMeasureId: item?.unitOfMeasureId ?? '',
      issuedQuantity: issuedQuantity,
      receivedQuantity: receivedQuantity,
      adjustmentCount: adjustmentCount,
      checkoutCount: checkoutCount,
      lostCount: lostCount,
      damagedCount: damagedCount,
      lastActivity: lastActivity,
    );
  }
}

class _UsageByPersonAccumulator {
  _UsageByPersonAccumulator({required this.personId, required this.role});

  final String personId;
  final String role;
  double issuedQuantity = 0;
  int checkoutCount = 0;
  int returnCount = 0;
  final Map<String, int> itemCounts = {};

  void add(InventoryTransaction transaction) {
    switch (transaction.transactionType) {
      case InventoryTransactionType.issue:
        issuedQuantity += transaction.quantityDelta.abs();
        break;
      case InventoryTransactionType.checkout:
        checkoutCount++;
        break;
      case InventoryTransactionType.returnItem:
        returnCount++;
        break;
      case InventoryTransactionType.receive ||
          InventoryTransactionType.transfer ||
          InventoryTransactionType.adjustment ||
          InventoryTransactionType.markLost ||
          InventoryTransactionType.markDamaged ||
          InventoryTransactionType.cycleCountAdjustment:
        break;
    }
    itemCounts[transaction.itemId] = (itemCounts[transaction.itemId] ?? 0) + 1;
  }

  UsageByPersonReportRow toRow(AppStore store) {
    final openCheckouts = store.openCheckoutRecords.where((record) {
      return record.assignedToPersonId == personId ||
          _userPersonId(store, record.checkedOutByUserId) == personId;
    }).toList();
    final topItems = itemCounts.entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));
    return UsageByPersonReportRow(
      personId: personId,
      displayName: store.resolvePersonName(personId) ?? 'Unknown person',
      role: role,
      issuedQuantity: issuedQuantity,
      checkoutCount: checkoutCount,
      returnCount: returnCount,
      openCheckoutCount: openCheckouts.length,
      overdueCheckoutCount: openCheckouts.where(_isOverdue).length,
      topItemNames: [
        for (final entry in topItems.take(3)) store.resolveItemName(entry.key),
      ],
    );
  }
}

class _UsageByTargetAccumulator {
  _UsageByTargetAccumulator({required this.targetId});

  final String targetId;
  double issuedQuantity = 0;
  int checkoutCount = 0;
  int lostDamagedCount = 0;
  final Map<String, int> itemCounts = {};

  void add(InventoryTransaction transaction) {
    switch (transaction.transactionType) {
      case InventoryTransactionType.issue:
        issuedQuantity += transaction.quantityDelta.abs();
        break;
      case InventoryTransactionType.checkout:
        checkoutCount++;
        break;
      case InventoryTransactionType.markLost ||
          InventoryTransactionType.markDamaged:
        lostDamagedCount++;
        break;
      case InventoryTransactionType.receive ||
          InventoryTransactionType.returnItem ||
          InventoryTransactionType.transfer ||
          InventoryTransactionType.adjustment ||
          InventoryTransactionType.cycleCountAdjustment:
        break;
    }
    itemCounts[transaction.itemId] = (itemCounts[transaction.itemId] ?? 0) + 1;
  }

  UsageByAssignmentTargetReportRow toRow(AppStore store) {
    final target = store.assignmentTargetById(targetId);
    final topItems = itemCounts.entries.toList()
      ..sort((left, right) => right.value.compareTo(left.value));
    return UsageByAssignmentTargetReportRow(
      targetId: targetId,
      targetName:
          store.resolveAssignmentTargetName(targetId) ?? 'Unknown target',
      targetType: target == null
          ? 'Unknown'
          : assignmentTargetTypeLabel(target.targetType),
      issuedQuantity: issuedQuantity,
      checkoutCount: checkoutCount,
      openCheckoutCount: store.openCheckoutRecords
          .where((record) => record.assignedToTargetId == targetId)
          .length,
      lostDamagedCount: lostDamagedCount,
      topItemNames: [
        for (final entry in topItems.take(3)) store.resolveItemName(entry.key),
      ],
    );
  }
}

class _ReordersBySupplierAccumulator {
  _ReordersBySupplierAccumulator({required this.supplierName});

  final String supplierName;
  final List<ReorderRequest> requests = [];

  void add(ReorderRequest request) {
    requests.add(request);
  }

  ReordersBySupplierRow toRow(AppStore store) {
    return ReordersBySupplierRow(
      supplierName: supplierName,
      neededCount: requests
          .where((request) => request.status == ReorderStatus.needed)
          .length,
      orderedCount: requests
          .where((request) => request.status == ReorderStatus.ordered)
          .length,
      partiallyReceivedCount: requests
          .where((request) => request.status == ReorderStatus.partiallyReceived)
          .length,
      remainingQuantity: requests.fold<double>(
        0,
        (sum, request) => sum + request.remainingQuantity,
      ),
      requests: [
        for (final row in const ReportService().reorderRows(store, requests))
          row.request,
      ],
    );
  }
}

DateTime? _latest(DateTime? current, DateTime candidate) {
  if (current == null || candidate.isAfter(current)) {
    return candidate;
  }
  return current;
}

bool _isOverdue(CheckoutRecord record) {
  final dueAt = record.dueAt;
  return record.isOpen && dueAt != null && dueAt.isBefore(DateTime.now());
}

String? _resolveUserName(AppStore store, String? userId) {
  if (userId == null) {
    return null;
  }
  final personId = _userPersonId(store, userId);
  return personId == null ? null : store.resolvePersonName(personId);
}

String? _userPersonId(AppStore store, String? userId) {
  if (userId == null) {
    return null;
  }
  for (final user in store.users) {
    if (user.id == userId) {
      return user.personId;
    }
  }
  return null;
}

String _checkoutAgingBucket(CheckoutRecord record, DateTime now) {
  final dueAt = record.dueAt;
  if (dueAt == null) {
    return 'No due date';
  }
  final dueDate = DateTime(dueAt.year, dueAt.month, dueAt.day);
  final today = DateTime(now.year, now.month, now.day);
  final daysOverdue = today.difference(dueDate).inDays;
  if (daysOverdue == 0) {
    return 'Due today';
  }
  if (daysOverdue < 0) {
    return 'Not overdue';
  }
  if (daysOverdue <= 7) {
    return '1-7 days overdue';
  }
  if (daysOverdue <= 30) {
    return '8-30 days overdue';
  }
  return '31+ days overdue';
}
