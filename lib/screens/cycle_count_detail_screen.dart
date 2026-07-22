import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import '../widgets/issued_metric_card.dart';
import '../widgets/issued_page_header.dart';
import '../widgets/issued_status_badge.dart';

class CycleCountDetailScreen extends StatefulWidget {
  const CycleCountDetailScreen({super.key, required this.session});

  final CycleCountSession session;

  @override
  State<CycleCountDetailScreen> createState() => _CycleCountDetailScreenState();
}

class _CycleCountDetailScreenState extends State<CycleCountDetailScreen> {
  late CycleCountSession _session;
  final _quantityControllers = <String, TextEditingController>{};
  final _notesControllers = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _session = widget.session;
  }

  @override
  void dispose() {
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    for (final controller in _notesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    _session = _freshSession(store, _session);
    final lines = _lines(store);
    for (final line in lines) {
      _ensureControllers(line);
    }
    final isSubmitted = _session.status == CycleCountStatus.submitted;
    final isApproved = _session.status == CycleCountStatus.approved;
    final canSubmit = store.permissions.canPerformInventoryActions;
    final canApprove = store.permissions.canApproveCycleCounts;
    final countedLineCount = lines
        .where((line) => line.countedQuantity != null)
        .length;
    final varianceLineCount = lines
        .where((line) => (line.varianceQuantity ?? 0) != 0)
        .length;
    final assignedUser = _assignedUserName(store, _session.assignedToUserId);

    return Scaffold(
      appBar: AppBar(title: const Text('Cycle Count')),
      bottomNavigationBar:
          (isSubmitted && !canApprove) ||
              (!isSubmitted && (isApproved || !canSubmit))
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: isSubmitted
                    ? FilledButton.icon(
                        onPressed: canApprove ? _approveCount : null,
                        icon: const Icon(Icons.verified),
                        label: const Text('Approve count'),
                      )
                    : FilledButton.icon(
                        onPressed: isApproved || !canSubmit
                            ? null
                            : _submitCount,
                        icon: const Icon(Icons.send),
                        label: Text(isApproved ? 'Approved' : 'Submit count'),
                      ),
              ),
            ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          IssuedPageHeader(title: _session.name),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      IssuedStatusBadge(
                        label: _statusLabel(_session.status),
                        tone: _statusTone(_session.status),
                      ),
                      IssuedStatusBadge(
                        label: _session.blindCount
                            ? 'Blind count'
                            : 'Visible count',
                        icon: _session.blindCount
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      IssuedStatusBadge(
                        label: '${lines.length} lines',
                        icon: Icons.format_list_numbered,
                      ),
                      if (assignedUser != null)
                        IssuedStatusBadge(
                          label: assignedUser,
                          icon: Icons.person_outline,
                        ),
                      if (_session.dueAt != null)
                        IssuedStatusBadge(
                          label: 'Due ${_formatDate(_session.dueAt!)}',
                          icon: Icons.event_outlined,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: IssuedMetricCard(
                  label: 'Total lines',
                  value: '${lines.length}',
                  icon: Icons.list_alt_outlined,
                  tone: IssuedStatusTone.info,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: IssuedMetricCard(
                  label: 'Counted',
                  value: '$countedLineCount',
                  icon: Icons.fact_check_outlined,
                  tone: IssuedStatusTone.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          IssuedMetricCard(
            label: 'Variances',
            value: '$varianceLineCount',
            icon: Icons.compare_arrows,
            tone: varianceLineCount == 0
                ? IssuedStatusTone.success
                : IssuedStatusTone.warning,
          ),
          const SizedBox(height: 18),
          Text(
            'Items to count',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (isSubmitted || isApproved) ...[
            _VarianceSummaryCard(lines: lines),
            const SizedBox(height: 12),
          ],
          for (final line in lines) ...[
            _CountLineCard(
              line: line,
              session: _session,
              store: store,
              quantityController: _quantityControllers[line.id]!,
              notesController: _notesControllers[line.id]!,
              enabled: canSubmit && !isSubmitted && !isApproved,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  String? _assignedUserName(AppStore store, String? userId) {
    if (userId == null) return null;
    for (final user in store.users) {
      if (user.id == userId) {
        for (final person in store.people) {
          if (person.id == user.personId) return person.displayName;
        }
      }
    }
    return null;
  }

  void _submitCount() {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canPerformInventoryActions) {
      _showMessage('Your current role does not allow this action.');
      return;
    }

    final updatedLines = <CycleCountLine>[];

    for (final line in _lines(store)) {
      final countText = _quantityControllers[line.id]!.text.trim();
      final countedQuantity = double.tryParse(countText);

      if (countedQuantity == null) {
        _showMessage('Enter a counted quantity for every line.');
        return;
      }
      if (countedQuantity < 0) {
        _showMessage('Counted quantity cannot be negative.');
        return;
      }
      if (!_allowsCountQuantity(store, line, countedQuantity)) {
        _showMessage('Whole quantities are required for one or more lines.');
        return;
      }

      final variance = countedQuantity - line.expectedQuantity;
      updatedLines.add(
        CycleCountLine(
          id: line.id,
          sessionId: line.sessionId,
          itemId: line.itemId,
          locationId: line.locationId,
          expectedQuantity: line.expectedQuantity,
          countedQuantity: countedQuantity,
          varianceQuantity: variance,
          unitOfMeasureId: line.unitOfMeasureId,
          notes: _emptyToNull(_notesControllers[line.id]!.text),
        ),
      );
    }

    final result = store.submitCycleCount(_session.id, updatedLines);
    if (!result.success) {
      _showMessage(result.message ?? 'Could not submit cycle count.');
      return;
    }
    setState(() {
      _session = result.data is CycleCountSession
          ? result.data! as CycleCountSession
          : _freshSession(store, _session);
    });
  }

  void _approveCount() {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canApproveCycleCounts) {
      _showMessage('Your current role does not allow this action.');
      return;
    }

    store.approveCycleCount(_session.id);
    setState(() {
      _session = _freshSession(store, _session);
    });
  }

  CycleCountSession _freshSession(AppStore store, CycleCountSession session) {
    return store.cycleCountSessions.firstWhere(
      (storedSession) => storedSession.id == session.id,
      orElse: () => session,
    );
  }

  List<CycleCountLine> _lines(AppStore store) {
    final lines = store.cycleCountLines
        .where((line) => line.sessionId == _session.id)
        .toList();
    lines.sort((left, right) {
      final locationCompare = (store.resolveLocationName(left.locationId) ?? '')
          .compareTo(store.resolveLocationName(right.locationId) ?? '');
      if (locationCompare != 0) {
        return locationCompare;
      }
      return store
          .resolveItemName(left.itemId)
          .compareTo(store.resolveItemName(right.itemId));
    });
    return lines;
  }

  void _ensureControllers(CycleCountLine line) {
    _quantityControllers.putIfAbsent(
      line.id,
      () => TextEditingController(
        text: line.countedQuantity == null
            ? ''
            : _formatQuantity(line.countedQuantity!),
      ),
    );
    _notesControllers.putIfAbsent(
      line.id,
      () => TextEditingController(text: line.notes ?? ''),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _allowsCountQuantity(
    AppStore store,
    CycleCountLine line,
    double quantity,
  ) {
    final item = store.items.cast<Item?>().firstWhere(
      (item) => item!.id == line.itemId,
      orElse: () => null,
    );
    if (item?.allowFractionalQuantity == true) {
      return true;
    }

    final unit = store.unitsOfMeasure.cast<UnitOfMeasure?>().firstWhere(
      (unit) => unit!.id == line.unitOfMeasureId,
      orElse: () => null,
    );
    if (unit?.allowsDecimal == true) {
      return true;
    }
    return quantity == quantity.roundToDouble();
  }
}

class _VarianceSummaryCard extends StatelessWidget {
  const _VarianceSummaryCard({required this.lines});

  final List<CycleCountLine> lines;

  @override
  Widget build(BuildContext context) {
    final countedLines = lines
        .where((line) => line.countedQuantity != null)
        .toList();
    final varianceLines = countedLines.where((line) {
      return (line.varianceQuantity ?? 0) != 0;
    }).toList();
    final positive = varianceLines.where((line) {
      return (line.varianceQuantity ?? 0) > 0;
    }).length;
    final negative = varianceLines.where((line) {
      return (line.varianceQuantity ?? 0) < 0;
    }).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            IssuedStatusBadge(label: '${lines.length} total lines'),
            IssuedStatusBadge(
              label: '${countedLines.length - varianceLines.length} matched',
              tone: IssuedStatusTone.success,
            ),
            IssuedStatusBadge(
              label: '${varianceLines.length} variance',
              tone: varianceLines.isEmpty
                  ? IssuedStatusTone.success
                  : IssuedStatusTone.warning,
            ),
            IssuedStatusBadge(
              label: '$positive over',
              tone: positive == 0
                  ? IssuedStatusTone.neutral
                  : IssuedStatusTone.warning,
            ),
            IssuedStatusBadge(
              label: '$negative under',
              tone: negative == 0
                  ? IssuedStatusTone.neutral
                  : IssuedStatusTone.warning,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountLineCard extends StatelessWidget {
  const _CountLineCard({
    required this.line,
    required this.session,
    required this.store,
    required this.quantityController,
    required this.notesController,
    required this.enabled,
  });

  final CycleCountLine line;
  final CycleCountSession session;
  final AppStore store;
  final TextEditingController quantityController;
  final TextEditingController notesController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final item = _itemById(line.itemId);
    final locationName =
        _locationById(line.locationId)?.name ??
        store.primaryLocationForItem(line.itemId)?.name ??
        'Unknown location';
    final unit = _unitById(line.unitOfMeasureId);
    final showReview =
        session.status == CycleCountStatus.submitted ||
        session.status == CycleCountStatus.approved;
    final variance = line.varianceQuantity ?? 0;
    final wasCounted = line.countedQuantity != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item?.name ?? 'Unknown item',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF17212F),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                IssuedStatusBadge(
                  label: locationName,
                  icon: Icons.location_on_outlined,
                ),
                IssuedStatusBadge(label: unit?.abbreviation ?? 'UOM'),
                if (!session.blindCount || showReview)
                  IssuedStatusBadge(
                    label: 'Expected ${_formatQuantity(line.expectedQuantity)}',
                  ),
                if (showReview)
                  IssuedStatusBadge(
                    label:
                        'Counted ${_formatQuantity(line.countedQuantity ?? 0)}',
                  ),
                if (showReview)
                  IssuedStatusBadge(
                    label:
                        'Variance ${_formatQuantity(line.varianceQuantity ?? 0)}',
                    tone: variance == 0
                        ? IssuedStatusTone.success
                        : IssuedStatusTone.warning,
                  ),
                IssuedStatusBadge(
                  label: !wasCounted
                      ? 'Not counted'
                      : variance == 0
                      ? 'Counted'
                      : 'Variance',
                  tone: !wasCounted
                      ? IssuedStatusTone.neutral
                      : variance == 0
                      ? IssuedStatusTone.success
                      : IssuedStatusTone.warning,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: quantityController,
              enabled: enabled,
              decoration: const InputDecoration(labelText: 'Counted quantity'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: notesController,
              enabled: enabled,
              decoration: const InputDecoration(labelText: 'Notes optional'),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Item? _itemById(String itemId) {
    for (final item in store.items) {
      if (item.id == itemId) {
        return item;
      }
    }

    return null;
  }

  Location? _locationById(String locationId) {
    for (final location in store.locations) {
      if (location.id == locationId) {
        return location;
      }
    }

    return null;
  }

  UnitOfMeasure? _unitById(String unitId) {
    for (final unit in store.unitsOfMeasure) {
      if (unit.id == unitId) {
        return unit;
      }
    }

    return null;
  }
}

String? _emptyToNull(String value) {
  final trimmedValue = value.trim();
  return trimmedValue.isEmpty ? null : trimmedValue;
}

IssuedStatusTone _statusTone(CycleCountStatus status) {
  return switch (status) {
    CycleCountStatus.draft => IssuedStatusTone.neutral,
    CycleCountStatus.assigned => IssuedStatusTone.info,
    CycleCountStatus.submitted => IssuedStatusTone.warning,
    CycleCountStatus.approved => IssuedStatusTone.success,
  };
}

String _statusLabel(CycleCountStatus status) {
  return switch (status) {
    CycleCountStatus.draft => 'Draft',
    CycleCountStatus.assigned => 'Assigned',
    CycleCountStatus.submitted => 'Submitted',
    CycleCountStatus.approved => 'Approved',
  };
}

String _formatDate(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}

String _formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toStringAsFixed(0);
  }

  return quantity.toStringAsFixed(2);
}
