import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';

class AssignmentTargetsScreen extends StatelessWidget {
  const AssignmentTargetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final canManage = store.permissions.canManageSettings;
    final targets = store.assignmentTargets.toList()
      ..sort((left, right) {
        final activeCompare = (right.isActive ? 1 : 0).compareTo(
          left.isActive ? 1 : 0,
        );
        if (activeCompare != 0) {
          return activeCompare;
        }
        return left.name.toLowerCase().compareTo(right.name.toLowerCase());
      });

    return Scaffold(
      appBar: AppBar(title: const Text('Assignment Targets')),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _showTargetForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Target'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Create jobs, trucks, departments, job boxes, and other destinations for issuing and checking out inventory.',
          ),
          if (!canManage) ...[
            const SizedBox(height: 12),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Your current role does not allow this action.'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (targets.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No assignment targets yet.'),
              ),
            )
          else
            for (final target in targets) ...[
              Card(
                child: ListTile(
                  leading: Icon(_targetIcon(target.targetType)),
                  title: Text(target.name),
                  subtitle: Text(_subtitle(store, target)),
                  trailing: canManage
                      ? PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showTargetForm(context, target: target);
                            } else if (value == 'archive') {
                              _archiveTarget(context, target);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            if (target.isActive)
                              const PopupMenuItem(
                                value: 'archive',
                                child: Text('Archive'),
                              ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }

  static String _subtitle(AppStore store, AssignmentTarget target) {
    final parts = [
      assignmentTargetTypeLabel(target.targetType),
      if (!target.isActive) 'Archived',
      if ((target.code ?? '').trim().isNotEmpty) 'Code: ${target.code}',
      if ((target.description ?? '').trim().isNotEmpty)
        target.description!.trim(),
      if (store.resolveLocationName(target.locationId) != null)
        'Location: ${store.resolveLocationName(target.locationId)}',
    ];
    return parts.join(' - ');
  }

  static IconData _targetIcon(AssignmentTargetType type) {
    return switch (type) {
      AssignmentTargetType.job => Icons.work_outline,
      AssignmentTargetType.truck => Icons.local_shipping_outlined,
      AssignmentTargetType.department => Icons.apartment_outlined,
      AssignmentTargetType.jobBox => Icons.inventory_2_outlined,
      AssignmentTargetType.workOrder => Icons.receipt_long_outlined,
      AssignmentTargetType.other => Icons.label_outline,
    };
  }

  static Future<void> _archiveTarget(
    BuildContext context,
    AssignmentTarget target,
  ) async {
    final store = AppStoreScope.of(context);
    if (store.hasOpenCheckoutForAssignmentTarget(target.id)) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Archive Assignment Target'),
          content: const Text(
            'This target has open checkouts. History will keep showing the target name, but workers will not be able to pick it for new actions.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Archive'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) {
        return;
      }
    }
    final archived = store.archiveAssignmentTarget(target.id);
    _showMessage(
      context,
      archived ? 'Assignment target archived.' : 'Could not archive target.',
    );
  }

  static Future<void> _showTargetForm(
    BuildContext context, {
    AssignmentTarget? target,
  }) async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canManageSettings) {
      _showMessage(context, 'Your current role does not allow this action.');
      return;
    }

    final result = await showDialog<AssignmentTarget>(
      context: context,
      builder: (context) => _AssignmentTargetDialog(target: target),
    );
    if (result == null || !context.mounted) {
      return;
    }

    final saved = target == null
        ? store.addAssignmentTarget(result)
        : store.updateAssignmentTarget(result);
    _showMessage(
      context,
      saved
          ? 'Assignment target saved.'
          : 'Could not save target. Check for a duplicate active name and type.',
    );
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AssignmentTargetDialog extends StatefulWidget {
  const _AssignmentTargetDialog({this.target});

  final AssignmentTarget? target;

  @override
  State<_AssignmentTargetDialog> createState() =>
      _AssignmentTargetDialogState();
}

class _AssignmentTargetDialogState extends State<_AssignmentTargetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _descriptionController;
  late AssignmentTargetType _type;
  String? _locationId;

  @override
  void initState() {
    super.initState();
    final target = widget.target;
    _nameController = TextEditingController(text: target?.name ?? '');
    _codeController = TextEditingController(text: target?.code ?? '');
    _descriptionController = TextEditingController(
      text: target?.description ?? '',
    );
    _type = target?.targetType ?? AssignmentTargetType.job;
    _locationId = target?.locationId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);

    return AlertDialog(
      title: Text(widget.target == null ? 'Add Target' : 'Edit Target'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  return value == null || value.trim().isEmpty
                      ? 'Enter a name.'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AssignmentTargetType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: AssignmentTargetType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(assignmentTargetTypeLabel(type)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _type = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Code'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _locationId,
                decoration: const InputDecoration(
                  labelText: 'Related location',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No related location'),
                  ),
                  for (final location in store.locations)
                    DropdownMenuItem<String?>(
                      value: location.id,
                      child: Text(location.name),
                    ),
                ],
                onChanged: (value) => setState(() => _locationId = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final now = DateTime.now();
    final existing = widget.target;
    Navigator.of(context).pop(
      AssignmentTarget(
        id: existing?.id ?? 'target-${now.microsecondsSinceEpoch}',
        name: _nameController.text.trim(),
        targetType: _type,
        code: _codeController.text.trim().isEmpty
            ? null
            : _codeController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        locationId: _locationId,
        isActive: existing?.isActive ?? true,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }
}
