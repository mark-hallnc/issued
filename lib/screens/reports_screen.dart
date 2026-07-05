import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import 'checked_out_screen.dart';
import 'low_stock_screen.dart';
import 'plan_screens.dart';

enum _ReportKind {
  inventorySummary,
  inventoryValue,
  lowStock,
  checkedOut,
  usageByItem,
  usageByPerson,
  usageByAssignmentTarget,
  lostDamaged,
  reorderStatus,
  cycleCountVariance,
}

enum _UsageRange { sevenDays, thirtyDays, ninetyDays, allTime }

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final summary = store.getInventorySummary();
    final reorderSummary = store.getReorderStatusSummary();
    final advancedEnabled = store.currentPlan.advancedReportsEnabled;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ReportCard(
            title: 'Inventory Summary',
            subtitle:
                '${summary.activeItemCount} active, ${summary.lowStockCount} low stock',
            icon: Icons.inventory_2_outlined,
            onTap: () => _openReport(context, _ReportKind.inventorySummary),
          ),
          _ReportCard(
            title: 'Inventory Value',
            subtitle: store.permissions.canViewCosts
                ? 'Estimated value by type and location'
                : 'Cost report restricted by role',
            icon: Icons.attach_money,
            locked: !store.permissions.canViewCosts,
            onTap: () => _openReport(context, _ReportKind.inventoryValue),
          ),
          _ReportCard(
            title: 'Low Stock',
            subtitle: '${summary.lowStockCount} items need attention',
            icon: Icons.warning_amber_outlined,
            onTap: () => _openReport(context, _ReportKind.lowStock),
          ),
          _ReportCard(
            title: 'Checked Out & Overdue',
            subtitle:
                '${summary.openCheckoutCount} checked out, ${store.overdueCheckoutRecords.length} overdue',
            icon: Icons.assignment_return_outlined,
            onTap: () => _openReport(context, _ReportKind.checkedOut),
          ),
          _ReportCard(
            title: 'Usage by Item',
            subtitle: 'Most used items from activity',
            icon: Icons.trending_up,
            locked: !advancedEnabled,
            onTap: () => _openReport(context, _ReportKind.usageByItem),
          ),
          _ReportCard(
            title: 'Usage by Person',
            subtitle: 'Person-assigned issue and checkout activity',
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
            title: 'Lost/Damaged',
            subtitle: '${store.getLostDamagedActivity().length} records',
            icon: Icons.report_problem_outlined,
            locked: !advancedEnabled,
            onTap: () => _openReport(context, _ReportKind.lostDamaged),
          ),
          _ReportCard(
            title: 'Reorder Status',
            subtitle:
                '${reorderSummary.needed} needed, ${reorderSummary.ordered} ordered',
            icon: Icons.shopping_cart_outlined,
            onTap: () => _openReport(context, _ReportKind.reorderStatus),
          ),
          _ReportCard(
            title: 'Cycle Count Variance',
            subtitle:
                '${store.getCycleCountVarianceRows().length} variance rows',
            icon: Icons.fact_check_outlined,
            locked: !advancedEnabled,
            onTap: () => _openReport(context, _ReportKind.cycleCountVariance),
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
  _UsageRange _usageRange = _UsageRange.thirtyDays;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final isAdvanced = _isAdvanced(widget.kind);

    return Scaffold(
      appBar: AppBar(title: Text(_reportTitle(widget.kind))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isAdvanced && !store.currentPlan.advancedReportsEnabled)
            _PlanLockedCard(reportName: _reportTitle(widget.kind))
          else
            ..._reportContent(store),
        ],
      ),
    );
  }

  List<Widget> _reportContent(AppStore store) {
    return switch (widget.kind) {
      _ReportKind.inventorySummary => _inventorySummary(store),
      _ReportKind.inventoryValue => _inventoryValue(store),
      _ReportKind.lowStock => _lowStock(store),
      _ReportKind.checkedOut => _checkedOut(store),
      _ReportKind.usageByItem => _usageByItem(store),
      _ReportKind.usageByPerson => _usageByPerson(store),
      _ReportKind.usageByAssignmentTarget => _usageByAssignmentTarget(store),
      _ReportKind.lostDamaged => _lostDamaged(store),
      _ReportKind.reorderStatus => _reorderStatus(store),
      _ReportKind.cycleCountVariance => _cycleCountVariance(store),
    };
  }

  List<Widget> _inventorySummary(AppStore store) {
    final summary = store.getInventorySummary();
    return [
      _ExportButton(
        label: 'Export Inventory Summary CSV',
        onPressed: store.permissions.canImportExport
            ? () => _shareCsv(
                context,
                'issued_inventory_summary.csv',
                _inventorySummaryCsv(summary),
              )
            : null,
      ),
      _MetricGrid(
        metrics: [
          _Metric('Active items', '${summary.activeItemCount}'),
          _Metric('Archived items', '${summary.archivedItemCount}'),
          _Metric('Consumables', '${summary.consumableCount}'),
          _Metric('Returnables', '${summary.returnableCount}'),
          _Metric('Assets', '${summary.assetCount}'),
          _Metric('Locations', '${summary.locationCount}'),
          _Metric('Low stock', '${summary.lowStockCount}'),
          _Metric('On reorder', '${summary.activeReorderCount}'),
          _Metric('Checked out', '${summary.openCheckoutCount}'),
        ],
      ),
    ];
  }

  List<Widget> _inventoryValue(AppStore store) {
    if (!store.permissions.canViewCosts) {
      return const [
        _MessageCard(
          message: 'Your current role does not allow viewing cost reports.',
        ),
      ];
    }

    final report = store.getInventoryValueReport();
    return [
      _MetricGrid(
        metrics: [
          _Metric('Estimated value', _money(report.totalValue)),
          _Metric('Missing cost', '${report.missingCostCount} items'),
        ],
      ),
      const SizedBox(height: 12),
      _SectionCard(
        title: 'Value by Item Type',
        children: [
          for (final entry in report.valueByType.entries)
            _SimpleRow(_itemTypeLabel(entry.key), _money(entry.value)),
        ],
      ),
      const SizedBox(height: 12),
      _SectionCard(
        title: 'Value by Location',
        children: [
          for (final entry in report.valueByLocation.entries)
            _SimpleRow(
              store.resolveLocationName(entry.key) ?? 'Unknown',
              _money(entry.value),
            ),
        ],
      ),
    ];
  }

  List<Widget> _lowStock(AppStore store) {
    final items = store.getLowStockItems();
    return [
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _ExportButton(
            label: 'Export Low Stock CSV',
            onPressed: store.permissions.canImportExport
                ? () => _shareCsv(
                    context,
                    'issued_low_stock.csv',
                    _lowStockCsv(store, items),
                  )
                : null,
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const LowStockScreen(),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open Low Stock'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (items.isEmpty)
        const _MessageCard(message: 'No low-stock items right now.')
      else
        for (final item in items) ...[
          _ReportListCard(
            title: item.name,
            lines: [
              'On hand: ${_quantity(item.quantityOnHand)} ${store.resolveUomAbbreviation(item.unitOfMeasureId)}',
              'Minimum: ${_quantity(item.minimumQuantity)} ${store.resolveUomAbbreviation(item.unitOfMeasureId)}',
              'Location: ${store.resolveLocationName(item.locationId) ?? 'Unknown'}',
              if ((item.supplier ?? '').isNotEmpty)
                'Supplier: ${item.supplier}',
              'Suggested reorder: ${_quantity(store.getSuggestedReorderQuantity(item))}',
              'Reorder: ${store.getActiveReorderForItem(item.id)?.status.name ?? 'none'}',
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _checkedOut(AppStore store) {
    final open = store.openCheckoutRecords;
    final overdue = store.overdueCheckoutRecords;
    final byPerson = <String, int>{};
    final byLocation = <String, int>{};
    final byTarget = <String, int>{};
    for (final record in open) {
      final person = store.resolvePersonName(record.assignedToPersonId);
      if (person != null) {
        byPerson[person] = (byPerson[person] ?? 0) + 1;
      }
      final location = store.resolveLocationName(record.assignedToLocationId);
      if (location != null) {
        byLocation[location] = (byLocation[location] ?? 0) + 1;
      }
      final target = store.resolveAssignmentTargetName(
        record.assignedToTargetId,
      );
      if (target != null) {
        byTarget[target] = (byTarget[target] ?? 0) + 1;
      }
    }

    return [
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _ExportButton(
            label: 'Export Checked Out CSV',
            onPressed: store.permissions.canImportExport
                ? () => _shareCsv(
                    context,
                    'issued_checked_out.csv',
                    _checkedOutCsv(store, open),
                  )
                : null,
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const CheckedOutScreen(),
                ),
              );
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open Checked Out'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _MetricGrid(
        metrics: [
          _Metric('Open checkouts', '${open.length}'),
          _Metric('Overdue', '${overdue.length}'),
        ],
      ),
      const SizedBox(height: 12),
      _SectionCard(
        title: 'By Target',
        children: byTarget.isEmpty
            ? const [Text('No target-assigned checkouts.')]
            : [
                for (final entry in byTarget.entries)
                  _SimpleRow(entry.key, '${entry.value}'),
              ],
      ),
      const SizedBox(height: 12),
      _SectionCard(
        title: 'By Person',
        children: byPerson.isEmpty
            ? const [Text('No person-assigned checkouts.')]
            : [
                for (final entry in byPerson.entries)
                  _SimpleRow(entry.key, '${entry.value}'),
              ],
      ),
      const SizedBox(height: 12),
      _SectionCard(
        title: 'Overdue',
        children: overdue.isEmpty
            ? const [Text('Nothing is overdue.')]
            : [
                for (final record in overdue)
                  _SimpleRow(
                    store.resolveItemName(record.itemId),
                    record.dueAt == null ? '' : _date(record.dueAt!),
                  ),
              ],
      ),
    ];
  }

  List<Widget> _usageByItem(AppStore store) {
    final rows = store.getUsageByItem(_rangeStart());
    return [
      _UsageRangeChips(
        selected: _usageRange,
        onSelected: (range) => setState(() => _usageRange = range),
      ),
      const SizedBox(height: 12),
      _ExportButton(
        label: 'Export Usage by Item CSV',
        onPressed: store.permissions.canImportExport
            ? () => _shareCsv(
                context,
                'issued_usage_by_item.csv',
                _usageByItemCsv(store, rows),
              )
            : null,
      ),
      const SizedBox(height: 12),
      if (rows.isEmpty)
        const _MessageCard(message: 'No usage activity for this range.')
      else
        for (final row in rows) ...[
          _ReportListCard(
            title: store.resolveItemName(row.itemId),
            lines: [
              'Quantity used: ${_quantity(row.quantity)} ${store.resolveUomAbbreviation(row.unitOfMeasureId)}',
              'Transactions: ${row.transactionCount}',
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _usageByPerson(AppStore store) {
    final rows = store.getUsageByPerson(_rangeStart());
    return [
      _UsageRangeChips(
        selected: _usageRange,
        onSelected: (range) => setState(() => _usageRange = range),
      ),
      const SizedBox(height: 12),
      if (rows.isEmpty)
        const _MessageCard(message: 'No person-assigned activity yet.')
      else
        for (final row in rows) ...[
          _ReportListCard(
            title: store.resolvePersonName(row.personId) ?? 'Unknown',
            lines: [
              'Transactions: ${row.transactionCount}',
              'Total quantity: ${_quantity(row.quantity)}',
              if (row.topItemIds.isNotEmpty)
                'Top items: ${row.topItemIds.map(store.resolveItemName).join(', ')}',
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _usageByAssignmentTarget(AppStore store) {
    final rows = store.getUsageByAssignmentTarget(_rangeStart());
    return [
      _UsageRangeChips(
        selected: _usageRange,
        onSelected: (range) => setState(() => _usageRange = range),
      ),
      const SizedBox(height: 12),
      if (rows.isEmpty)
        const _MessageCard(message: 'No target-assigned activity yet.')
      else
        for (final row in rows) ...[
          _ReportListCard(
            title:
                store.resolveAssignmentTargetName(row.targetId) ??
                'Unknown target',
            lines: [
              if (store.assignmentTargetById(row.targetId) != null)
                assignmentTargetTypeLabel(
                  store.assignmentTargetById(row.targetId)!.targetType,
                ),
              'Transactions: ${row.transactionCount}',
              'Total quantity: ${_quantity(row.quantity)}',
              if (row.topItemIds.isNotEmpty)
                'Top items: ${row.topItemIds.map(store.resolveItemName).join(', ')}',
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _lostDamaged(AppStore store) {
    final rows = store.getLostDamagedActivity();
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
              if (store.resolveLocationName(row.locationId) != null)
                'Location: ${store.resolveLocationName(row.locationId)}',
              if ((row.notes ?? '').isNotEmpty) 'Notes: ${row.notes}',
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _reorderStatus(AppStore store) {
    final summary = store.getReorderStatusSummary();
    final active = store.reorderRequests.where((request) {
      return request.status == ReorderStatus.needed ||
          request.status == ReorderStatus.ordered;
    }).toList();

    return [
      _MetricGrid(
        metrics: [
          _Metric('Needed', '${summary.needed}'),
          _Metric('Ordered', '${summary.ordered}'),
          _Metric('Received', '${summary.received}'),
          _Metric('Canceled', '${summary.canceled}'),
        ],
      ),
      const SizedBox(height: 12),
      if (store.reorderRequests.isEmpty)
        const _MessageCard(message: 'Reorder tracking has not been set up yet.')
      else if (active.isEmpty)
        const _MessageCard(message: 'No active reorder requests.')
      else
        for (final request in active) ...[
          _ReportListCard(
            title: store.resolveItemName(request.itemId),
            lines: [
              'Requested: ${_quantity(request.requestedQuantity)} ${store.resolveUomAbbreviation(request.unitOfMeasureId)}',
              if ((request.supplier ?? '').isNotEmpty)
                'Supplier: ${request.supplier}',
              'Created: ${_date(request.createdAt)}',
              if (request.orderedAt != null)
                'Ordered: ${_date(request.orderedAt!)}',
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  List<Widget> _cycleCountVariance(AppStore store) {
    final rows = store.getCycleCountVarianceRows();
    final submittedOrApproved = store.cycleCountSessions.where((session) {
      return session.status == CycleCountStatus.submitted ||
          session.status == CycleCountStatus.approved;
    }).length;
    final totalVariance = rows.fold<double>(
      0,
      (sum, row) => sum + row.varianceQuantity.abs(),
    );

    return [
      _MetricGrid(
        metrics: [
          _Metric('Submitted/approved', '$submittedOrApproved'),
          _Metric('Total variance', _quantity(totalVariance)),
        ],
      ),
      const SizedBox(height: 12),
      if (rows.isEmpty)
        const _MessageCard(message: 'No cycle count variance yet.')
      else
        for (final row in rows) ...[
          _ReportListCard(
            title: store.resolveItemName(row.itemId),
            lines: [
              row.sessionName,
              'Location: ${store.resolveLocationName(row.locationId) ?? 'Unknown'}',
              'Expected ${_quantity(row.expectedQuantity)}, counted ${_quantity(row.countedQuantity)}',
              'Variance: ${_quantity(row.varianceQuantity)} ${store.resolveUomAbbreviation(row.unitOfMeasureId)}',
              _date(row.sessionDate),
            ],
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  DateTime? _rangeStart() {
    final now = DateTime.now();
    return switch (_usageRange) {
      _UsageRange.sevenDays => now.subtract(const Duration(days: 7)),
      _UsageRange.thirtyDays => now.subtract(const Duration(days: 30)),
      _UsageRange.ninetyDays => now.subtract(const Duration(days: 90)),
      _UsageRange.allTime => null,
    };
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
                  ),
                  const SizedBox(height: 4),
                  Text(metric.label),
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
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

class _UsageRangeChips extends StatelessWidget {
  const _UsageRangeChips({required this.selected, required this.onSelected});

  final _UsageRange selected;
  final ValueChanged<_UsageRange> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final range in _UsageRange.values)
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

String _inventorySummaryCsv(InventorySummaryReport summary) {
  return const CsvEncoder().convert([
    ['metric', 'value'],
    ['active_items', summary.activeItemCount],
    ['archived_items', summary.archivedItemCount],
    ['consumables', summary.consumableCount],
    ['returnables', summary.returnableCount],
    ['assets', summary.assetCount],
    ['locations', summary.locationCount],
    ['low_stock', summary.lowStockCount],
    ['active_reorders', summary.activeReorderCount],
    ['open_checkouts', summary.openCheckoutCount],
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
    ],
    for (final item in items)
      [
        item.name,
        item.quantityOnHand,
        item.minimumQuantity,
        store.resolveUomAbbreviation(item.unitOfMeasureId),
        store.resolveLocationName(item.locationId) ?? '',
        item.supplier ?? '',
        store.getSuggestedReorderQuantity(item),
      ],
  ]);
}

String _checkedOutCsv(AppStore store, List<CheckoutRecord> records) {
  return const CsvEncoder().convert([
    [
      'item',
      'quantity',
      'uom',
      'assigned_person',
      'assigned_target',
      'assigned_target_type',
      'assigned_text',
      'due_at',
      'notes',
    ],
    for (final record in records)
      [
        store.resolveItemName(record.itemId),
        record.quantity,
        store.resolveUomAbbreviation(record.unitOfMeasureId),
        store.resolvePersonName(record.assignedToPersonId) ?? '',
        store.resolveAssignmentTargetName(record.assignedToTargetId) ?? '',
        _assignmentTargetTypeLabel(store, record.assignedToTargetId),
        record.assignedToText ?? '',
        record.dueAt?.toIso8601String() ?? '',
        record.notes ?? '',
      ],
  ]);
}

String _assignmentTargetTypeLabel(AppStore store, String? targetId) {
  if (targetId == null) {
    return '';
  }
  final target = store.assignmentTargetById(targetId);
  return target == null ? '' : assignmentTargetTypeLabel(target.targetType);
}

String _usageByItemCsv(AppStore store, List<UsageByItemRow> rows) {
  return const CsvEncoder().convert([
    ['item', 'quantity', 'uom', 'transaction_count'],
    for (final row in rows)
      [
        store.resolveItemName(row.itemId),
        row.quantity,
        store.resolveUomAbbreviation(row.unitOfMeasureId),
        row.transactionCount,
      ],
  ]);
}

bool _isAdvanced(_ReportKind kind) {
  return switch (kind) {
    _ReportKind.inventoryValue ||
    _ReportKind.usageByItem ||
    _ReportKind.usageByPerson ||
    _ReportKind.usageByAssignmentTarget ||
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
    _ReportKind.checkedOut => 'Checked Out & Overdue',
    _ReportKind.usageByItem => 'Usage by Item',
    _ReportKind.usageByPerson => 'Usage by Person',
    _ReportKind.usageByAssignmentTarget => 'Usage by Assignment Target',
    _ReportKind.lostDamaged => 'Lost/Damaged',
    _ReportKind.reorderStatus => 'Reorder Status',
    _ReportKind.cycleCountVariance => 'Cycle Count Variance',
  };
}

String _rangeLabel(_UsageRange range) {
  return switch (range) {
    _UsageRange.sevenDays => '7 days',
    _UsageRange.thirtyDays => '30 days',
    _UsageRange.ninetyDays => '90 days',
    _UsageRange.allTime => 'All time',
  };
}

String _itemTypeLabel(ItemType type) {
  return switch (type) {
    ItemType.consumable => 'Consumables',
    ItemType.returnable => 'Returnables',
    ItemType.asset => 'Assets',
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
