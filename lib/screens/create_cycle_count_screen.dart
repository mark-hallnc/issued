import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import 'cycle_count_detail_screen.dart';

enum CountScope { allItems, location, category, lowStock }

class CreateCycleCountScreen extends StatefulWidget {
  const CreateCycleCountScreen({super.key});

  @override
  State<CreateCycleCountScreen> createState() => _CreateCycleCountScreenState();
}

class _CreateCycleCountScreenState extends State<CreateCycleCountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  CountScope _scope = CountScope.allItems;
  Location? _selectedLocation;
  String? _selectedCategory;
  bool _blindCount = true;
  DateTime? _dueAt;

  List<String> _categories(AppStore store) {
    final categories = store.items
        .map((item) => item.category)
        .where((category) => category.trim().isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    return categories.isEmpty ? ['Uncategorized'] : categories;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final categories = _categories(store);
    _selectedLocation ??= store.locations.first;
    _selectedCategory ??= categories.first;

    return Scaffold(
      appBar: AppBar(title: const Text('New Cycle Count')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _createSession,
            icon: const Icon(Icons.add_task),
            label: const Text('Create Count'),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CountScope>(
              initialValue: _scope,
              decoration: const InputDecoration(
                labelText: 'Count scope',
                border: OutlineInputBorder(),
              ),
              items: CountScope.values
                  .map(
                    (scope) => DropdownMenuItem(
                      value: scope,
                      child: Text(_scopeLabel(scope)),
                    ),
                  )
                  .toList(),
              onChanged: (scope) {
                if (scope == null) {
                  return;
                }

                setState(() {
                  _scope = scope;
                });
              },
            ),
            if (_scope == CountScope.location) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<Location>(
                initialValue: _selectedLocation,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                items: store.locations
                    .map(
                      (location) => DropdownMenuItem(
                        value: location,
                        child: Text(location.name),
                      ),
                    )
                    .toList(),
                onChanged: (location) {
                  if (location == null) {
                    return;
                  }

                  setState(() {
                    _selectedLocation = location;
                  });
                },
              ),
            ],
            if (_scope == CountScope.category) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (category) {
                  if (category == null) {
                    return;
                  }

                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),
            ],
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Blind count'),
              subtitle: const Text('Hide expected quantities while counting'),
              value: _blindCount,
              onChanged: (value) {
                setState(() {
                  _blindCount = value;
                });
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDueDate,
              icon: const Icon(Icons.event),
              label: Text(
                _dueAt == null ? 'Add due date' : 'Due ${_formatDate(_dueAt!)}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueAt ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      _dueAt = pickedDate;
    });
  }

  void _createSession() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final store = AppStoreScope.of(context);
    final now = DateTime.now();
    final session = CycleCountSession(
      id: 'count-${now.microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      status: CycleCountStatus.assigned,
      assignedToUserId: store.users.isEmpty ? null : store.users.first.id,
      blindCount: _blindCount,
      dueAt: _dueAt,
      createdAt: now,
      submittedAt: null,
      approvedAt: null,
    );
    final lines = _matchingItems(store).map((item) {
      return CycleCountLine(
        id: 'line-${session.id}-${item.id}',
        sessionId: session.id,
        itemId: item.id,
        locationId: item.locationId,
        expectedQuantity: item.quantityOnHand,
        countedQuantity: null,
        varianceQuantity: null,
        unitOfMeasureId: item.unitOfMeasureId,
        notes: null,
      );
    }).toList();

    store.addCycleCountSession(session);
    store.addCycleCountLines(lines);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => CycleCountDetailScreen(session: session),
      ),
    );
  }

  Iterable<Item> _matchingItems(AppStore store) {
    return store.items.where((item) {
      if (!item.isActive) {
        return false;
      }

      return switch (_scope) {
        CountScope.allItems => true,
        CountScope.location => item.locationId == _selectedLocation!.id,
        CountScope.category => item.category == _selectedCategory,
        CountScope.lowStock => item.quantityOnHand <= item.minimumQuantity,
      };
    });
  }

  String _scopeLabel(CountScope scope) {
    return switch (scope) {
      CountScope.allItems => 'All Items',
      CountScope.location => 'Location',
      CountScope.category => 'Category',
      CountScope.lowStock => 'Low Stock',
    };
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
