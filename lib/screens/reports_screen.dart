import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_store.dart';
import '../core/data_health/data_health_service.dart';
import '../core/models/models.dart';
import '../core/reports/report_service.dart' as reports;
import 'checked_out_screen.dart';
import 'low_stock_screen.dart';
import 'plan_screens.dart';

enum _ReportKind {
  inventorySummary,
  inventoryValue,
  lowStock,
  outOfStock,
  stockByLocation,
  usageByItem,
  usageByPerson,
  usageByAssignmentTarget,
  recentActivity,
  openCheckouts,
  overdueCheckouts,
  checkoutAging,
  lostDamaged,
  openReorders,
  reordersBySupplier,
  reorderHistory,
  lowStockWithoutReorder,
  cycleCountVariance,
  dataHealth,
}

enum _DateRangeOption { sevenDays, thirtyDays, ninetyDays, yearToDate, allTime }

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canViewReports) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reports')),
        body: const Center(
          child: Text('Your current role does not allow this action.'),
        ),
      );
    }

    final snapshot = const reports.ReportService().build(
      store,
      _rangeFor(_DateRangeOption.thirtyDays),
    );
    final advancedEnabled = store.currentPlan.advancedReportsEnabled;
    final summary = snapshot.inventorySummary;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ReportGroup(
            title: 'Inventory',
            children: [
              _ReportCard(
                title: 'Inventory Summary',
                subtitle:
                    '${summary.activeItemCount} active, ${summary.lowStockCount} low, ${summary.outOfStockCount} out',
                icon: Icons.inventory_2_outlined,
                onTap: () => _openReport(context, _ReportKind.inventorySummary),
              ),
              _ReportCard(
                title: 'Inventory Value',
                subtitle: store.permissions.canViewCosts
                    ? 'Estimated value by item, category, supplier, and location'
                    : 'Cost report restricted by role',
                icon: Icons.attach_money,
                locked: !store.permissions.canViewCosts,
                onTap: () => _openReport(context, _ReportKind.inventoryValue),
              ),
              _ReportCard(
                title: 'Low Stock',
                subtitle:
                    '${store.getLowStockItems().length} items need attention',
                icon: Icons.warning_amber_outlined,
                onTap: () => _openReport(context, _ReportKind.lowStock),
              ),
              _ReportCard(
                title: 'Out of Stock',
                subtitle:
                    '${_outOfStockItems(store).length} active items are out',
                icon: Icons.remove_shopping_cart_outlined,
                onTap: () => _openReport(context, _ReportKind.outOfStock),
              ),
              _ReportCard(
                title: 'Stock by Location',
                subtitle:
                    '${snapshot.stockByLocationRows.length} stocked locations',
                icon: Icons.location_on_outlined,
                onTap: () => _openReport(context, _ReportKind.stockByLocation),
              ),
            ],
          ),
          _ReportGroup(
            title: 'Usage',
            children: [
              _ReportCard(
                title: 'Usage by Item',
                subtitle: 'Issued, received, adjusted, and checked out',
                icon: Icons.trending_up,
                locked: !advancedEnabled,
                onTap: () => _openReport(context, _ReportKind.usageByItem),
              ),
              _ReportCard(
                title: 'Usage by Person',
                subtitle: 'Performed By and Assigned To activity',
                icon: Icons.group_outlined,
                locked: !advancedEnabled,
                onTap: () => _openReport(context, _ReportKind.usageByPerson),
              ),
              _ReportCard(
                title: 'Usage by Assignment Target',
                subtitle: 'Jobs, trucks, departments, and job boxes',
                icon: Icons.assignment_ind_outlined,
                locked: !advancedEnabled,
                onTap: () =>
                    _openReport(context, _ReportKind.usageByAssignmentTarget),
              ),
              _ReportCard(
                title: 'Recent Inventory Activity',
                subtitle:
                    '${snapshot.recentActivityRows.length} rows in last 30 days',
                icon: Icons.history,
                onTap: () => _openReport(context, _ReportKind.recentActivity),
              ),
            ],
          ),
          _ReportGroup(
            title: 'Checkouts',
            children: [
              _ReportCard(
                title: 'Open Checkouts',
                subtitle: '${store.openCheckoutRecords.length} currently open',
                icon: Icons.assignment_return_outlined,
                onTap: () => _openReport(context, _ReportKind.openCheckouts),
              ),
              _ReportCard(
                title: 'Overdue Checkouts',
                subtitle: '${store.overdueCheckoutRecords.length} overdue',
                icon: Icons.schedule_outlined,
                onTap: () => _openReport(context, _ReportKind.overdueCheckouts),
              ),
              _ReportCard(
                title: 'Checkout Aging',
                subtitle: 'Due today, overdue buckets, and no due date',
                icon: Icons.hourglass_bottom_outlined,
                onTap: () => _openReport(context, _ReportKind.checkoutAging),
              ),
              _ReportCard(
                title: 'Lost/Damaged Checkouts',
                subtitle: '${store.getLostDamagedActivity().length} records',
                icon: Icons.report_problem_outlined,
                locked: !advancedEnabled,
                onTap: () => _openReport(context, _ReportKind.lostDamaged),
              ),
            ],
          ),
          _ReportGroup(
            title: 'Purchasing',
            children: [
              _ReportCard(
                title: 'Open Reorders',
                subtitle: '${snapshot.openReorders.length} open requests',
                icon: Icons.shopping_cart_outlined,
                onTap: () => _openReport(context, _ReportKind.openReorders),
              ),
              _ReportCard(
                title: 'Reorders by Supplier',
                subtitle:
                    '${snapshot.reordersBySupplierRows.length} suppliers with open requests',
                icon: Icons.storefront_outlined,
                onTap: () =>
                    _openReport(context, _ReportKind.reordersBySupplier),
              ),
              _ReportCard(
                title: 'Reorder History',
                subtitle: '${store.reorderRequests.length} total requests',
                icon: Icons.receipt_long_outlined,
                onTap: () => _openReport(context, _ReportKind.reorderHistory),
              ),
              _ReportCard(
                title: 'Low Stock Without Reorder',
                subtitle:
                    '${snapshot.lowStockWithoutReorder.length} items need requests',
                icon: Icons.add_shopping_cart_outlined,
                onTap: () =>
                    _openReport(context, _ReportKind.lowStockWithoutReorder),
              ),
            ],
          ),
          _ReportGroup(
            title: 'Counts',
            children: [
              _ReportCard(
                title: 'Cycle Count Variance',
                subtitle:
                    '${store.getCycleCountVarianceRows().length} non-zero variance rows',
                icon: Icons.fact_check_outlined,
                locked: !advancedEnabled,
                onTap: () =>
                    _openReport(context, _ReportKind.cycleCountVariance),
              ),
              _ReportCard(
                title: 'Data Health Summary',
                subtitle:
                    '${snapshot.dataHealthReport.errorCount} errors, ${snapshot.dataHealthReport.warningCount} warnings',
                icon: Icons.health_and_safety_outlined,
                onTap: () => _openReport(context, _ReportKind.dataHealth),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openReport(BuildContext context, _ReportKind kind) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _ReportDetailScreen(kind: kind),
      ),
    );
  }
}

class _ReportDetailScreen extends StatefulWidget {
  const _ReportDetailScreen({required this.kind});

  final _ReportKind kind;

  @override
  State<_ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<_ReportDetailScreen> {
  _DateRangeOption _dateRange = _DateRangeOption.thirtyDays;
  final reports.ReportService _reportService = const reports.ReportService();

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final range = _rangeFor(_dateRange);
    final snapshot = _reportService.build(store, range);
    final isAdvanced = _isAdvanced(widget.kind);

    return Scaffold(
      appBar: AppBar(title: Text(_reportTitle(widget.kind))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isAdvanced && !store.currentPlan.advancedReportsEnabled)
            _PlanLockedCard(reportName: _reportTitle(widget.kind))
          else if (_requiresCost(widget.kind) &&
              !store.permissions.canViewCosts)
            const _MessageCard(
              message: 'Your current role does not allow this action.',
            )
          else ...[
            if (_usesDateRange(widget.kind)) ...[
              _DateRangeChips(
                selected: _dateRange,
                onSelected: (range) => setState(() => _dateRange = range),
              ),
              const SizedBox(height: 12),
            ],
            ..._reportContent(store, snapshot),
          ],
        ],
      ),
    );
  }

  List<Widget> _reportContent(
    AppStore store,
    reports.ReportsSnapshot snapshot,
  ) {
    return switch (widget.kind) {
      _ReportKind.inventorySummary => _inventorySummary(store, snapshot),
      _ReportKind.inventoryValue => _inventoryValue(store, snapshot),
      _ReportKind.lowStock => _lowStock(store, store.getLowStockItems()),
      _ReportKind.outOfStock => _lowStock(store, _outOfStockItems(store)),
      _ReportKind.stockByLocation => _stockByLocation(store, snapshot),
      _ReportKind.usageByItem => _usageByItem(store, snapshot),
      _ReportKind.usageByPerson => _usageByPerson(snapshot),
      _ReportKind.usageByAssignmentTarget => _usageByAssignmentTarget(snapshot),
      _ReportKind.recentActivity => _recentActivity(store, snapshot),
      _ReportKind.openCheckouts => _checkouts(
        store,
        store.openCheckoutRecords,
        'No open checkouts.',
      ),
      _ReportKind.overdueCheckouts => _checkouts(
        store,
        store.overdueCheckoutRecords,
        'No overdue checkouts.',
      ),
      _ReportKind.checkoutAging => _checkoutAging(store, snapshot),
      _ReportKind.lostDamaged => _lostDamaged(store),
      _ReportKind.openReorders => _openReorders(store, snapshot.openReorders),
      _ReportKind.reordersBySupplier => _reordersBySupplier(store, snapshot),
      _ReportKind.reorderHistory => _reorderHistory(store),
      _ReportKind.lowStockWithoutReorder => _lowStock(
        store,
        snapshot.lowStockWithoutReorder,
      ),
      _ReportKind.cycleCountVariance => _cycleCountVariance(store, snapshot),
      _ReportKind.dataHealth => _dataHealth(snapshot),
    };
  }

  List<Widget> _inventorySummary(
    AppStore store,
    reports.ReportsSnapshot snapshot,
  ) {
    final summary = snapshot.inventorySummary;
    return [
      _ExportButton(
        label: 'Export CSV',
        onPressed: store.permissions.canExportReports
            ? () => _shareCsv(
                context,
                _filename('issued_inventory_summary'),
                _inventorySummaryCsv(summary),
              )
            : null,
      ),
      const SizedBox(height: 12),
      _MetricGrid(
        metrics: [
          _Metric('Active items', '${summary.activeItemCount}'),
          _Metric('Archived items', '${summary.archivedItemCount}'),
          _Metric('Total quantity', _quantity(summary.totalStockQuantity)),
          _Metric('Low stock', '${summary.lowStockCount}'),
          _Metric('Out of stock', '${summary.outOfStockCount}'),
          _Metric('Checked out', '${summary.checkedOutCount}'),
          _Metric('Open reorders', '${summary.openReorderCount}'),
          _Metric('Locations', '${summary.activeLocationCount}'),
          _Metric('Suppliers', '${summary.activeSupplierCount}'),
        ],
      ),
    ];
  }

  List<Widget> _inventoryValue(
    AppStore store,
    reports.ReportsSnapshot snapshot,
  ) {
    final rows = snapshot.inventoryValueRows;
    final total = rows.fold<double>(
      0,
      (sum, row) => sum + (row.estimatedValue ?? 0),
    );
    final missingCost = rows.where((row) => row.unitCost == null).length;
    final byCategory = <String, double>{};
    final bySupplier = <String, double>{};
    for (final row in rows) {
      final value = row.estimatedValue;
      if (value == null) {
        continue;
      }
      byCategory[row.category] = (byCategory[row.category] ?? 0) + value;
      bySupplier[row.supplierName ?? 'No supplier'] =
          (bySupplier[row.supplierName ?? 'No supplier'] ?? 0) + value;
    }

    return [
      _ExportButton(
        label: 'Export CSV',
        onPressed: store.permissions.canExportReports
            ? () => _shareCsv(
                context,
                _filename('issued_inventory_value_report'),
                _inventoryValueCsv(store, rows),
              )
            : null,
      ),
      const SizedBox(height: 12),
      _MetricGrid(
        metrics: [
          _Metric('Estimated value', _money(total)),
          _Metric('Missing cost', '$missingCost items'),
        ],
      ),
      const SizedBox(height: 12),
      _SectionCard(
        title: 'Value by Category',
        children: _sortedMoneyRows(byCategory),
      ),
      const SizedBox(height: 12),
      _SectionCard(
        title: 'Value by Supplier',
        children: _sortedMoneyRows(bySupplier),
      ),
      const SizedBox(height: 12),
      if (rows.every((row) => row.unitCost == null))
        const _MessageCard(message: 'No cost data entered.')
      else
        for (final row in rows.take(50)) ...[
          _ReportListCard(
            title: row.item.name,
            lines: [
              row.category,
              'On hand: ${_quantity(row.quantityOnHand)} ${store.resolveUomAbbreviation(row.item.unitOfMeasureId)}',
              'Unit cost: ${row.unitCost == null ? 'Not set' : _money(row.unitCost!)}',
              'Estimated value: ${row.estimatedValue == null ? 'Not set' : _money(row.estimatedValue!)}',
              'Supplier: ${row.supplierName ?? 'No supplier'}',
              'Location: ${row.locationName}',
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _lowStock(AppStore store, List<Item> items) {
    return [
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _ExportButton(
            label: 'Export CSV',
            onPressed: store.permissions.canExportReports
                ? () => _shareCsv(
                    context,
                    _filename('issued_low_stock_report'),
                    _lowStockCsv(store, items),
                  )
                : null,
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const LowStockScreen(),
              ),
            ),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open Low Stock'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (items.isEmpty)
        const _MessageCard(message: 'No low stock items.')
      else
        for (final item in items) ...[
          _ReportListCard(
            title: item.name,
            lines: [
              'Current: ${_quantity(item.quantityOnHand)} ${store.resolveUomAbbreviation(item.unitOfMeasureId)}',
              'Minimum: ${_quantity(item.minimumQuantity)} ${store.resolveUomAbbreviation(item.unitOfMeasureId)}',
              'Suggested reorder: ${_quantity(store.getReorderSuggestedQuantity(item))}',
              'Supplier: ${store.resolveSupplierName(item.supplierId, fallback: item.supplier) ?? 'No supplier'}',
              'Location: ${store.resolveLocationPath(item.locationId)}',
              'Open reorder: ${store.getActiveReorderForItem(item.id) == null ? 'None' : reorderStatusLabel(store.getActiveReorderForItem(item.id)!.status)}',
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _stockByLocation(
    AppStore store,
    reports.ReportsSnapshot snapshot,
  ) {
    final rows = snapshot.stockByLocationRows;
    return [
      _ExportButton(
        label: 'Export CSV',
        onPressed: store.permissions.canExportReports
            ? () => _shareCsv(
                context,
                _filename('issued_stock_by_location_report'),
                _stockByLocationCsv(
                  store,
                  rows,
                  store.permissions.canViewCosts,
                ),
              )
            : null,
      ),
      const SizedBox(height: 12),
      if (rows.isEmpty)
        const _MessageCard(message: 'No stocked locations.')
      else
        for (final row in rows) ...[
          _ReportListCard(
            title: row.locationPath,
            lines: [
              'Items: ${row.itemCount}',
              'Total quantity count: ${_quantity(row.totalQuantity)}',
              'Low stock items: ${row.lowStockItemCount}',
              if (store.permissions.canViewCosts)
                'Estimated value: ${_money(row.estimatedValue)}',
              if (row.missingCostCount > 0 && store.permissions.canViewCosts)
                'Missing cost: ${row.missingCostCount} items',
              for (final itemRow in row.items.take(5))
                '${itemRow.item.name}: ${_quantity(itemRow.quantityAtLocation)} ${store.resolveUomAbbreviation(itemRow.item.unitOfMeasureId)}',
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _usageByItem(AppStore store, reports.ReportsSnapshot snapshot) {
    final rows = snapshot.usageByItemRows;
    return [
      _ExportButton(
        label: 'Export CSV',
        onPressed: store.permissions.canExportReports
            ? () => _shareCsv(
                context,
                _filename('issued_usage_by_item'),
                _usageByItemCsv(store, rows),
              )
            : null,
      ),
      const SizedBox(height: 12),
      if (rows.isEmpty)
        const _MessageCard(message: 'No activity in this date range.')
      else
        for (final row in rows) ...[
          _ReportListCard(
            title: row.itemName,
            lines: [
              row.category,
              'Issued: ${_quantity(row.issuedQuantity)} ${store.resolveUomAbbreviation(row.unitOfMeasureId)}',
              'Received: ${_quantity(row.receivedQuantity)} ${store.resolveUomAbbreviation(row.unitOfMeasureId)}',
              'Checkouts: ${row.checkoutCount}',
              'Adjustments: ${row.adjustmentCount}',
              if (row.lostCount + row.damagedCount > 0)
                'Lost/damaged: ${row.lostCount + row.damagedCount}',
              if (row.lastActivity != null)
                'Last activity: ${_date(row.lastActivity!)}',
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _usageByPerson(reports.ReportsSnapshot snapshot) {
    final rows = snapshot.usageByPersonRows;
    return [
      if (rows.isEmpty)
        const _MessageCard(message: 'No person activity in this date range.')
      else
        for (final row in rows) ...[
          _ReportListCard(
            title: row.displayName,
            lines: [
              row.role,
              'Issued quantity: ${_quantity(row.issuedQuantity)}',
              'Checkouts: ${row.checkoutCount}',
              'Returns: ${row.returnCount}',
              'Open checkouts: ${row.openCheckoutCount}',
              'Overdue/open checkouts: ${row.overdueCheckoutCount}',
              if (row.topItemNames.isNotEmpty)
                'Top items: ${row.topItemNames.join(', ')}',
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _usageByAssignmentTarget(reports.ReportsSnapshot snapshot) {
    final rows = snapshot.usageByAssignmentTargetRows;
    return [
      if (rows.isEmpty)
        const _MessageCard(message: 'No target activity in this date range.')
      else
        for (final row in rows) ...[
          _ReportListCard(
            title: row.targetName,
            lines: [
              row.targetType,
              'Issued quantity: ${_quantity(row.issuedQuantity)}',
              'Checkouts: ${row.checkoutCount}',
              'Open checkouts: ${row.openCheckoutCount}',
              'Lost/damaged: ${row.lostDamagedCount}',
              if (row.topItemNames.isNotEmpty)
                'Top items: ${row.topItemNames.join(', ')}',
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _recentActivity(
    AppStore store,
    reports.ReportsSnapshot snapshot,
  ) {
    final rows = snapshot.recentActivityRows;
    return [
      _ExportButton(
        label: 'Export CSV',
        onPressed: store.permissions.canExportReports
            ? () => _shareCsv(
                context,
                _filename('issued_activity_report'),
                _activityCsv(store, rows),
              )
            : null,
      ),
      const SizedBox(height: 12),
      if (rows.isEmpty)
        const _MessageCard(message: 'No activity in this date range.')
      else
        for (final row in rows.take(100)) ...[
          _ReportListCard(
            title: row.itemName,
            lines: [
              '${_transactionTypeLabel(row.transaction.transactionType)}: ${_quantity(row.transaction.quantityDelta)} ${store.resolveUomAbbreviation(row.transaction.unitOfMeasureId)}',
              _dateTime(row.transaction.createdAt),
              if (row.fromLocationName != null) 'From: ${row.fromLocationName}',
              if (row.toLocationName != null) 'To: ${row.toLocationName}',
              if (row.assignedTo != null) 'Assigned to: ${row.assignedTo}',
              if (row.performedBy != null) 'Performed by: ${row.performedBy}',
              if ((row.transaction.notes ?? '').trim().isNotEmpty)
                'Notes: ${row.transaction.notes}',
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _checkouts(
    AppStore store,
    List<CheckoutRecord> records,
    String emptyMessage,
  ) {
    return [
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _ExportButton(
            label: 'Export CSV',
            onPressed: store.permissions.canExportReports
                ? () => _shareCsv(
                    context,
                    _filename('issued_open_checkouts'),
                    _checkoutsCsv(store, records),
                  )
                : null,
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const CheckedOutScreen(),
              ),
            ),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open Checkouts'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (records.isEmpty)
        _MessageCard(message: emptyMessage)
      else
        for (final record in records) ...[
          _ReportListCard(
            title: store.resolveItemName(record.itemId),
            lines: [
              'Assignee: ${store.resolveCheckoutAssigneeName(record)}',
              'Open quantity: ${_quantity(record.quantityOpen)} ${store.resolveUomAbbreviation(record.unitOfMeasureId)}',
              'Checked out: ${_date(record.checkedOutAt)}',
              'Due: ${record.dueAt == null ? 'No due date' : _date(record.dueAt!)}',
              if (record.dueAt != null &&
                  record.dueAt!.isBefore(DateTime.now()))
                'Overdue',
              'Source: ${record.sourceLocationId == null ? 'Unknown' : store.resolveLocationPath(record.sourceLocationId!)}',
              if ((record.notes ?? '').trim().isNotEmpty)
                'Notes: ${record.notes}',
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _checkoutAging(
    AppStore store,
    reports.ReportsSnapshot snapshot,
  ) {
    final rows = snapshot.checkoutAgingRows;
    return [
      if (rows.isEmpty)
        const _MessageCard(message: 'No open checkouts.')
      else
        for (final row in rows) ...[
          _SectionCard(
            title: '${row.bucket} (${row.records.length})',
            children: [
              for (final record in row.records)
                _SimpleRow(
                  store.resolveItemName(record.itemId),
                  '${store.resolveCheckoutAssigneeName(record)} - ${_quantity(record.quantityOpen)}',
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
    ];
  }

  List<Widget> _lostDamaged(AppStore store) {
    final range = _rangeFor(_dateRange);
    final rows = store
        .getLostDamagedActivity()
        .where((row) => range.contains(row.createdAt))
        .toList();
    return [
      if (rows.isEmpty)
        const _MessageCard(message: 'No lost or damaged activity.')
      else
        for (final row in rows) ...[
          _ReportListCard(
            title: store.resolveItemName(row.itemId),
            lines: [
              '${row.status}: ${_quantity(row.quantity)} ${store.resolveUomAbbreviation(row.unitOfMeasureId)}',
              _date(row.createdAt),
              if (store.resolvePersonName(row.assignedToPersonId) != null)
                'Assigned to: ${store.resolvePersonName(row.assignedToPersonId)}',
              if (row.locationId != null)
                'Location: ${store.resolveLocationPath(row.locationId!)}',
              if ((row.notes ?? '').trim().isNotEmpty) 'Notes: ${row.notes}',
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _openReorders(
    AppStore store,
    List<reports.ReorderReportRow> rows,
  ) {
    return [
      _ExportButton(
        label: 'Export CSV',
        onPressed: store.permissions.canExportReports
            ? () => _shareCsv(
                context,
                _filename('issued_open_reorders'),
                _reordersCsv(store, rows),
              )
            : null,
      ),
      const SizedBox(height: 12),
      if (rows.isEmpty)
        const _MessageCard(message: 'No open reorders.')
      else
        for (final row in rows) ...[
          _reorderCard(store, row),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _reordersBySupplier(
    AppStore store,
    reports.ReportsSnapshot snapshot,
  ) {
    final rows = snapshot.reordersBySupplierRows;
    return [
      if (rows.isEmpty)
        const _MessageCard(message: 'No open reorders by supplier.')
      else
        for (final row in rows) ...[
          _ReportListCard(
            title: row.supplierName,
            lines: [
              'Needed: ${row.neededCount}',
              'Ordered: ${row.orderedCount}',
              'Partially received: ${row.partiallyReceivedCount}',
              'Remaining quantity count: ${_quantity(row.remainingQuantity)}',
              for (final request in row.requests.take(5))
                '${store.resolveItemName(request.itemId)} - ${reorderStatusLabel(request.status)} - remaining ${_quantity(request.remainingQuantity)}',
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _reorderHistory(AppStore store) {
    final range = _rangeFor(_dateRange);
    final rows = _reportService.reorderRows(
      store,
      store.reorderRequests.where((request) {
        return range.contains(request.createdAt) ||
            (request.orderedAt != null && range.contains(request.orderedAt!)) ||
            (request.receivedAt != null &&
                range.contains(request.receivedAt!)) ||
            (request.cancelledAt != null &&
                range.contains(request.cancelledAt!));
      }),
    );
    return [
      if (rows.isEmpty)
        const _MessageCard(message: 'No reorder history yet.')
      else
        for (final row in rows.take(100)) ...[
          _reorderCard(store, row),
          const SizedBox(height: 10),
        ],
    ];
  }

  Widget _reorderCard(AppStore store, reports.ReorderReportRow row) {
    final request = row.request;
    return _ReportListCard(
      title: row.itemName,
      lines: [
        'Status: ${reorderStatusLabel(request.status)}',
        'Requested: ${_quantity(request.requestedQuantity)} ${store.resolveUomAbbreviation(request.unitOfMeasureId)}',
        'Received: ${_quantity(request.receivedQuantity)} ${store.resolveUomAbbreviation(request.unitOfMeasureId)}',
        'Remaining: ${_quantity(request.remainingQuantity)} ${store.resolveUomAbbreviation(request.unitOfMeasureId)}',
        'Supplier: ${row.supplierName ?? 'No supplier'}',
        'Destination: ${row.destinationLocationName ?? 'No destination'}',
        'Requested: ${_date(request.createdAt)}',
        if (request.orderedAt != null) 'Ordered: ${_date(request.orderedAt!)}',
        'Days open: ${row.daysOpen}',
        if ((request.orderNumber ?? '').trim().isNotEmpty)
          'Order Number: ${request.orderNumber}',
      ],
    );
  }

  List<Widget> _cycleCountVariance(
    AppStore store,
    reports.ReportsSnapshot snapshot,
  ) {
    final rows = snapshot.cycleCountVarianceRows;
    final totalVariance = rows.fold<double>(
      0,
      (sum, row) => sum + row.varianceQuantity.abs(),
    );
    return [
      _MetricGrid(
        metrics: [
          _Metric('Variance rows', '${rows.length}'),
          _Metric('Total variance', _quantity(totalVariance)),
        ],
      ),
      const SizedBox(height: 12),
      if (rows.isEmpty)
        const _MessageCard(
          message: 'No cycle count variance in this date range.',
        )
      else
        for (final row in rows) ...[
          _ReportListCard(
            title: store.resolveItemName(row.itemId),
            lines: [
              row.sessionName,
              'Location: ${store.resolveLocationPath(row.locationId)}',
              'Expected ${_quantity(row.expectedQuantity)}, counted ${_quantity(row.countedQuantity)}',
              'Variance: ${_quantity(row.varianceQuantity)} ${store.resolveUomAbbreviation(row.unitOfMeasureId)}',
              _date(row.sessionDate),
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _dataHealth(reports.ReportsSnapshot snapshot) {
    final report = snapshot.dataHealthReport;
    return [
      _MetricGrid(
        metrics: [
          _Metric('Errors', '${report.errorCount}'),
          _Metric('Warnings', '${report.warningCount}'),
          _Metric('Info', '${report.infoCount}'),
        ],
      ),
      const SizedBox(height: 12),
      if (report.issues.isEmpty)
        const _MessageCard(message: 'No data health issues found.')
      else
        for (final issue in report.issues.take(50)) ...[
          _ReportListCard(
            title: issue.title,
            lines: [
              _severityLabel(issue.severity),
              issue.description,
              '${issue.affectedRecordType}${issue.affectedRecordId == null ? '' : ': ${issue.affectedRecordId}'}',
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }
}

class _ReportGroup extends StatelessWidget {
  const _ReportGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.locked = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF1E3A5F)),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Icon(locked ? Icons.lock_outline : Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _PlanLockedCard extends StatelessWidget {
  const _PlanLockedCard({required this.reportName});

  final String reportName;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$reportName is an advanced report.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => openComparePlans(context),
              child: const Text('Compare Plans'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric {
  const _Metric(this.label, this.value);

  final String label;
  final String value;
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final List<_Metric> metrics;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.75,
      children: [
        for (final metric in metrics)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metric.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ReportListCard extends StatelessWidget {
  const _ReportListCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            for (final line in lines)
              if (line.trim().isNotEmpty) Text(line),
          ],
        ),
      ),
    );
  }
}

class _SimpleRow extends StatelessWidget {
  const _SimpleRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: Text(message)),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.download_outlined),
      label: Text(label),
    );
  }
}

class _DateRangeChips extends StatelessWidget {
  const _DateRangeChips({required this.selected, required this.onSelected});

  final _DateRangeOption selected;
  final ValueChanged<_DateRangeOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date Range'),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final range in _DateRangeOption.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_rangeLabel(range)),
                    selected: selected == range,
                    onSelected: (_) => onSelected(range),
                    showCheckmark: false,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> _shareCsv(
  BuildContext context,
  String filename,
  String csvText,
) async {
  try {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}${Platform.pathSeparator}$filename');
    await file.writeAsString(csvText, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        fileNameOverrides: [filename],
      ),
    );
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not share the CSV file.')),
      );
    }
  }
}

reports.ReportDateRange _rangeFor(_DateRangeOption option) {
  final now = DateTime.now();
  final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return switch (option) {
    _DateRangeOption.sevenDays => reports.ReportDateRange(
      label: 'Last 7 days',
      start: now.subtract(const Duration(days: 7)),
      end: todayEnd,
    ),
    _DateRangeOption.thirtyDays => reports.ReportDateRange(
      label: 'Last 30 days',
      start: now.subtract(const Duration(days: 30)),
      end: todayEnd,
    ),
    _DateRangeOption.ninetyDays => reports.ReportDateRange(
      label: 'Last 90 days',
      start: now.subtract(const Duration(days: 90)),
      end: todayEnd,
    ),
    _DateRangeOption.yearToDate => reports.ReportDateRange(
      label: 'Year to date',
      start: DateTime(now.year),
      end: todayEnd,
    ),
    _DateRangeOption.allTime => const reports.ReportDateRange(
      label: 'All time',
      start: null,
    ),
  };
}

List<Item> _outOfStockItems(AppStore store) {
  return store.items
      .where((item) => item.isActive && item.quantityOnHand <= 0)
      .toList()
    ..sort((left, right) => left.name.compareTo(right.name));
}

List<Widget> _sortedMoneyRows(Map<String, double> values) {
  final entries = values.entries.toList()
    ..sort((left, right) => right.value.compareTo(left.value));
  if (entries.isEmpty) {
    return const [_SimpleRow('No value', '')];
  }
  return [
    for (final entry in entries) _SimpleRow(entry.key, _money(entry.value)),
  ];
}

String _inventorySummaryCsv(reports.ReportsInventorySummary summary) {
  return const CsvEncoder().convert([
    ['metric', 'value'],
    ['active_items', summary.activeItemCount],
    ['archived_items', summary.archivedItemCount],
    ['total_stock_quantity', summary.totalStockQuantity],
    ['low_stock', summary.lowStockCount],
    ['out_of_stock', summary.outOfStockCount],
    ['checked_out', summary.checkedOutCount],
    ['open_reorders', summary.openReorderCount],
    ['active_locations', summary.activeLocationCount],
    ['active_suppliers', summary.activeSupplierCount],
  ]);
}

String _inventoryValueCsv(
  AppStore store,
  List<reports.InventoryValueRow> rows,
) {
  return const CsvEncoder().convert([
    [
      'item',
      'category',
      'quantity_on_hand',
      'uom',
      'unit_cost',
      'estimated_value',
      'supplier',
      'location',
    ],
    for (final row in rows)
      [
        row.item.name,
        row.category,
        row.quantityOnHand,
        store.resolveUomAbbreviation(row.item.unitOfMeasureId),
        row.unitCost ?? '',
        row.estimatedValue ?? '',
        row.supplierName ?? '',
        row.locationName,
      ],
  ]);
}

String _lowStockCsv(AppStore store, List<Item> items) {
  return const CsvEncoder().convert([
    [
      'item',
      'quantity_on_hand',
      'minimum_quantity',
      'uom',
      'location',
      'supplier',
      'suggested_reorder',
      'open_reorder_status',
    ],
    for (final item in items)
      [
        item.name,
        item.quantityOnHand,
        item.minimumQuantity,
        store.resolveUomAbbreviation(item.unitOfMeasureId),
        store.resolveLocationPath(item.locationId),
        store.resolveSupplierName(item.supplierId, fallback: item.supplier) ??
            '',
        store.getReorderSuggestedQuantity(item),
        store.getActiveReorderForItem(item.id) == null
            ? ''
            : reorderStatusLabel(
                store.getActiveReorderForItem(item.id)!.status,
              ),
      ],
  ]);
}

String _stockByLocationCsv(
  AppStore store,
  List<reports.StockByLocationRow> rows,
  bool includeCosts,
) {
  return const CsvEncoder().convert([
    [
      'location',
      'item',
      'quantity_at_location',
      'uom',
      'total_item_quantity',
      'minimum_quantity',
      'category',
      if (includeCosts) 'estimated_value',
    ],
    for (final row in rows)
      for (final itemRow in row.items)
        [
          row.locationPath,
          itemRow.item.name,
          itemRow.quantityAtLocation,
          store.resolveUomAbbreviation(itemRow.item.unitOfMeasureId),
          itemRow.item.quantityOnHand,
          itemRow.item.minimumQuantity,
          itemRow.item.category,
          if (includeCosts) itemRow.estimatedValue ?? '',
        ],
  ]);
}

String _usageByItemCsv(
  AppStore store,
  List<reports.UsageByItemReportRow> rows,
) {
  return const CsvEncoder().convert([
    [
      'item',
      'category',
      'issued_quantity',
      'received_quantity',
      'uom',
      'adjustment_count',
      'checkout_count',
      'lost_count',
      'damaged_count',
      'last_activity',
    ],
    for (final row in rows)
      [
        row.itemName,
        row.category,
        row.issuedQuantity,
        row.receivedQuantity,
        store.resolveUomAbbreviation(row.unitOfMeasureId),
        row.adjustmentCount,
        row.checkoutCount,
        row.lostCount,
        row.damagedCount,
        row.lastActivity?.toIso8601String() ?? '',
      ],
  ]);
}

String _activityCsv(AppStore store, List<reports.ActivityReportRow> rows) {
  return const CsvEncoder().convert([
    [
      'timestamp',
      'action',
      'item',
      'quantity',
      'uom',
      'from_location',
      'to_location',
      'assigned_to',
      'performed_by',
      'notes',
      'is_reversed',
      'reverses_transaction_id',
      'reversed_by_transaction_id',
      'correction_reason',
    ],
    for (final row in rows)
      [
        row.transaction.createdAt.toIso8601String(),
        _transactionTypeLabel(row.transaction.transactionType),
        row.itemName,
        row.transaction.quantityDelta,
        store.resolveUomAbbreviation(row.transaction.unitOfMeasureId),
        row.fromLocationName ?? '',
        row.toLocationName ?? '',
        row.assignedTo ?? '',
        row.performedBy ?? '',
        row.transaction.notes ?? '',
        row.transaction.isReversed,
        row.transaction.reversesTransactionId ?? '',
        row.transaction.reversedByTransactionId ?? '',
        row.transaction.correctionReason ?? '',
      ],
  ]);
}

String _checkoutsCsv(AppStore store, List<CheckoutRecord> records) {
  return const CsvEncoder().convert([
    [
      'item',
      'assignee',
      'quantity_open',
      'uom',
      'checked_out_at',
      'due_at',
      'status',
      'source_location',
      'notes',
    ],
    for (final record in records)
      [
        store.resolveItemName(record.itemId),
        store.resolveCheckoutAssigneeName(record),
        record.quantityOpen,
        store.resolveUomAbbreviation(record.unitOfMeasureId),
        record.checkedOutAt.toIso8601String(),
        record.dueAt?.toIso8601String() ?? '',
        checkoutStatusLabel(record.status),
        record.sourceLocationId == null
            ? ''
            : store.resolveLocationPath(record.sourceLocationId!),
        record.notes ?? '',
      ],
  ]);
}

String _reordersCsv(AppStore store, List<reports.ReorderReportRow> rows) {
  return const CsvEncoder().convert([
    [
      'item',
      'status',
      'requested_quantity',
      'received_quantity',
      'remaining_quantity',
      'uom',
      'supplier',
      'destination_location',
      'requested_date',
      'ordered_date',
      'days_open',
    ],
    for (final row in rows)
      [
        row.itemName,
        reorderStatusLabel(row.request.status),
        row.request.requestedQuantity,
        row.request.receivedQuantity,
        row.request.remainingQuantity,
        store.resolveUomAbbreviation(row.request.unitOfMeasureId),
        row.supplierName ?? '',
        row.destinationLocationName ?? '',
        row.request.createdAt.toIso8601String(),
        row.request.orderedAt?.toIso8601String() ?? '',
        row.daysOpen,
      ],
  ]);
}

bool _isAdvanced(_ReportKind kind) {
  return switch (kind) {
    _ReportKind.usageByItem ||
    _ReportKind.usageByPerson ||
    _ReportKind.usageByAssignmentTarget ||
    _ReportKind.lostDamaged ||
    _ReportKind.cycleCountVariance => true,
    _ => false,
  };
}

bool _requiresCost(_ReportKind kind) => kind == _ReportKind.inventoryValue;

bool _usesDateRange(_ReportKind kind) {
  return switch (kind) {
    _ReportKind.usageByItem ||
    _ReportKind.usageByPerson ||
    _ReportKind.usageByAssignmentTarget ||
    _ReportKind.recentActivity ||
    _ReportKind.reorderHistory ||
    _ReportKind.lostDamaged ||
    _ReportKind.cycleCountVariance => true,
    _ => false,
  };
}

String _reportTitle(_ReportKind kind) {
  return switch (kind) {
    _ReportKind.inventorySummary => 'Inventory Summary',
    _ReportKind.inventoryValue => 'Inventory Value',
    _ReportKind.lowStock => 'Low Stock',
    _ReportKind.outOfStock => 'Out of Stock',
    _ReportKind.stockByLocation => 'Stock by Location',
    _ReportKind.usageByItem => 'Usage by Item',
    _ReportKind.usageByPerson => 'Usage by Person',
    _ReportKind.usageByAssignmentTarget => 'Usage by Assignment Target',
    _ReportKind.recentActivity => 'Recent Inventory Activity',
    _ReportKind.openCheckouts => 'Open Checkouts',
    _ReportKind.overdueCheckouts => 'Overdue Checkouts',
    _ReportKind.checkoutAging => 'Checkout Aging',
    _ReportKind.lostDamaged => 'Lost/Damaged Checkouts',
    _ReportKind.openReorders => 'Open Reorders',
    _ReportKind.reordersBySupplier => 'Reorders by Supplier',
    _ReportKind.reorderHistory => 'Reorder History',
    _ReportKind.lowStockWithoutReorder => 'Low Stock Without Reorder',
    _ReportKind.cycleCountVariance => 'Cycle Count Variance',
    _ReportKind.dataHealth => 'Data Health Summary',
  };
}

String _rangeLabel(_DateRangeOption range) {
  return switch (range) {
    _DateRangeOption.sevenDays => 'Last 7 days',
    _DateRangeOption.thirtyDays => 'Last 30 days',
    _DateRangeOption.ninetyDays => 'Last 90 days',
    _DateRangeOption.yearToDate => 'Year to date',
    _DateRangeOption.allTime => 'All time',
  };
}

String _transactionTypeLabel(InventoryTransactionType type) {
  return switch (type) {
    InventoryTransactionType.receive => 'Receive',
    InventoryTransactionType.issue => 'Issue',
    InventoryTransactionType.checkout => 'Check Out',
    InventoryTransactionType.returnItem => 'Return',
    InventoryTransactionType.transfer => 'Transfer',
    InventoryTransactionType.adjustment => 'Adjustment',
    InventoryTransactionType.markLost => 'Lost',
    InventoryTransactionType.markDamaged => 'Damaged',
    InventoryTransactionType.cycleCountAdjustment => 'Cycle Count',
    InventoryTransactionType.correction => 'Correction',
  };
}

String _severityLabel(DataHealthSeverity severity) {
  return switch (severity) {
    DataHealthSeverity.error => 'Error',
    DataHealthSeverity.warning => 'Warning',
    DataHealthSeverity.info => 'Info',
  };
}

String _money(double value) {
  return '\$${value.toStringAsFixed(2)}';
}

String _quantity(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2);
}

String _date(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}

String _dateTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${_date(date)} $hour:$minute';
}

String _filename(String baseName) {
  final now = DateTime.now();
  final stamp =
      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  return '${baseName}_$stamp.csv';
}
