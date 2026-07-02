import 'package:flutter/material.dart';

import '../core/models/models.dart';
import '../core/sample_data.dart';

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
    _session = _freshSession(widget.session);
    for (final line in _lines()) {
      _quantityControllers[line.id] = TextEditingController(
        text: line.countedQuantity == null
            ? ''
            : _formatQuantity(line.countedQuantity!),
      );
      _notesControllers[line.id] = TextEditingController(
        text: line.notes ?? '',
      );
    }
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
    final isSubmitted = _session.status == CycleCountStatus.submitted;
    final isApproved = _session.status == CycleCountStatus.approved;

    return Scaffold(
      appBar: AppBar(title: const Text('Cycle Count')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isSubmitted
              ? FilledButton.icon(
                  onPressed: _approveCount,
                  icon: const Icon(Icons.verified),
                  label: const Text('Approve Count'),
                )
              : FilledButton.icon(
                  onPressed: isApproved ? null : _submitCount,
                  icon: const Icon(Icons.send),
                  label: Text(isApproved ? 'Approved' : 'Submit Count'),
                ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _session.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF17212F),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoPill(label: _statusLabel(_session.status)),
                      _InfoPill(
                        label: _session.blindCount
                            ? 'Blind count'
                            : 'Expected shown',
                      ),
                      _InfoPill(label: '${_lines().length} lines'),
                      if (_session.dueAt != null)
                        _InfoPill(label: 'Due ${_formatDate(_session.dueAt!)}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final line in _lines()) ...[
            _CountLineCard(
              line: line,
              session: _session,
              quantityController: _quantityControllers[line.id]!,
              notesController: _notesControllers[line.id]!,
              enabled: !isSubmitted && !isApproved,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  void _submitCount() {
    final updatedLines = <CycleCountLine>[];

    for (final line in _lines()) {
      final countText = _quantityControllers[line.id]!.text.trim();
      final countedQuantity = double.tryParse(countText);

      if (countedQuantity == null) {
        _showMessage('Enter a counted quantity for every line.');
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

    for (final updatedLine in updatedLines) {
      _replaceLine(updatedLine);
    }

    _replaceSession(
      CycleCountSession(
        id: _session.id,
        name: _session.name,
        status: CycleCountStatus.submitted,
        assignedToUserId: _session.assignedToUserId,
        blindCount: _session.blindCount,
        dueAt: _session.dueAt,
        createdAt: _session.createdAt,
        submittedAt: DateTime.now(),
        approvedAt: _session.approvedAt,
      ),
    );
  }

  void _approveCount() {
    final now = DateTime.now();

    for (final line in _lines()) {
      final variance = line.varianceQuantity ?? 0;
      if (variance == 0) {
        continue;
      }

      final itemIndex = sampleItems.indexWhere(
        (item) => item.id == line.itemId,
      );
      if (itemIndex == -1) {
        continue;
      }

      final item = sampleItems[itemIndex];
      sampleItems[itemIndex] = item.copyWith(
        quantityOnHand: line.countedQuantity ?? item.quantityOnHand,
        updatedAt: now,
      );
      sampleTransactions.add(
        InventoryTransaction(
          id: 'txn-cycle-${now.microsecondsSinceEpoch}-${line.id}',
          itemId: item.id,
          transactionType: InventoryTransactionType.cycleCountAdjustment,
          quantityDelta: variance,
          unitOfMeasureId: line.unitOfMeasureId,
          fromLocationId: variance < 0 ? line.locationId : null,
          toLocationId: variance > 0 ? line.locationId : null,
          assignedToPersonId: null,
          performedByUserId: sampleUsers.isEmpty ? null : sampleUsers.first.id,
          notes: 'Cycle count adjustment: ${_session.name}',
          createdAt: now,
        ),
      );
    }

    _replaceSession(
      CycleCountSession(
        id: _session.id,
        name: _session.name,
        status: CycleCountStatus.approved,
        assignedToUserId: _session.assignedToUserId,
        blindCount: _session.blindCount,
        dueAt: _session.dueAt,
        createdAt: _session.createdAt,
        submittedAt: _session.submittedAt,
        approvedAt: now,
      ),
    );
  }

  CycleCountSession _freshSession(CycleCountSession session) {
    return sampleCycleCountSessions.firstWhere(
      (storedSession) => storedSession.id == session.id,
      orElse: () => session,
    );
  }

  List<CycleCountLine> _lines() {
    return sampleCycleCountLines
        .where((line) => line.sessionId == _session.id)
        .toList();
  }

  void _replaceLine(CycleCountLine updatedLine) {
    final lineIndex = sampleCycleCountLines.indexWhere(
      (line) => line.id == updatedLine.id,
    );

    if (lineIndex != -1) {
      sampleCycleCountLines[lineIndex] = updatedLine;
    }
  }

  void _replaceSession(CycleCountSession updatedSession) {
    final sessionIndex = sampleCycleCountSessions.indexWhere(
      (session) => session.id == updatedSession.id,
    );

    if (sessionIndex != -1) {
      sampleCycleCountSessions[sessionIndex] = updatedSession;
    }

    setState(() {
      _session = updatedSession;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CountLineCard extends StatelessWidget {
  const _CountLineCard({
    required this.line,
    required this.session,
    required this.quantityController,
    required this.notesController,
    required this.enabled,
  });

  final CycleCountLine line;
  final CycleCountSession session;
  final TextEditingController quantityController;
  final TextEditingController notesController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final item = _itemById(line.itemId);
    final location = _locationById(line.locationId);
    final unit = _unitById(line.unitOfMeasureId);
    final showReview =
        session.status == CycleCountStatus.submitted ||
        session.status == CycleCountStatus.approved;

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
                _InfoPill(label: location?.name ?? 'Unknown location'),
                _InfoPill(label: unit?.abbreviation ?? 'uom'),
                if (!session.blindCount || showReview)
                  _InfoPill(
                    label: 'Expected ${_formatQuantity(line.expectedQuantity)}',
                  ),
                if (showReview)
                  _InfoPill(
                    label:
                        'Counted ${_formatQuantity(line.countedQuantity ?? 0)}',
                  ),
                if (showReview)
                  _InfoPill(
                    label:
                        'Variance ${_formatQuantity(line.varianceQuantity ?? 0)}',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: quantityController,
              enabled: enabled,
              decoration: const InputDecoration(
                labelText: 'Counted quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: notesController,
              enabled: enabled,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Item? _itemById(String itemId) {
    for (final item in sampleItems) {
      if (item.id == itemId) {
        return item;
      }
    }

    return null;
  }

  Location? _locationById(String locationId) {
    for (final location in sampleLocations) {
      if (location.id == locationId) {
        return location;
      }
    }

    return null;
  }

  UnitOfMeasure? _unitById(String unitId) {
    for (final unit in sampleUnitsOfMeasure) {
      if (unit.id == unitId) {
        return unit;
      }
    }

    return null;
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE1E6EC)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: const Color(0xFF394554)),
        ),
      ),
    );
  }
}

String? _emptyToNull(String value) {
  final trimmedValue = value.trim();
  return trimmedValue.isEmpty ? null : trimmedValue;
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
