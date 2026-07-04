import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import 'cycle_count_detail_screen.dart';

class CreateCycleCountScreen extends StatefulWidget {
  const CreateCycleCountScreen({super.key});

  @override
  State<CreateCycleCountScreen> createState() => _CreateCycleCountScreenState();
}

class _CreateCycleCountScreenState extends State<CreateCycleCountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  CycleCountScope _scope = CycleCountScope.allItems;
  Location? _selectedLocation;
  String? _selectedCategory;
  ItemType? _selectedItemType = ItemType.consumable;
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
    if (_selectedLocation == null && store.locations.isNotEmpty) {
      _selectedLocation = store.locations.first;
    }
    _selectedCategory ??= categories.first;

    return Scaffold(
      appBar: AppBar(title: const Text('New Cycle Count')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: store.permissions.canManageCycleCounts
                ? _createSession
                : null,
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
            DropdownButtonFormField<CycleCountScope>(
              initialValue: _scope,
              decoration: const InputDecoration(
                labelText: 'Count scope',
                border: OutlineInputBorder(),
              ),
              items: CycleCountScope.values
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
            if (_scope == CycleCountScope.location) ...[
              const SizedBox(height: 12),
              if (store.locations.isEmpty)
                const Text(
                  'Create a location before starting a location count.',
                )
              else
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
            if (_scope == CycleCountScope.category) ...[
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
            if (_scope == CycleCountScope.itemType) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<ItemType>(
                initialValue: _selectedItemType,
                decoration: const InputDecoration(
                  labelText: 'Item type',
                  border: OutlineInputBorder(),
                ),
                items: ItemType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_itemTypeLabel(type)),
                      ),
                    )
                    .toList(),
                onChanged: (type) {
                  if (type == null) {
                    return;
                  }

                  setState(() {
                    _selectedItemType = type;
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
    final store = AppStoreScope.of(context);
    if (!store.permissions.canManageCycleCounts) {
      _showPermissionDenied();
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_scope == CycleCountScope.location && _selectedLocation == null) {
      _showMessage('Choose a location for this count.');
      return;
    }

    final session = store.createCycleCountSessionFromScope(
      name: _nameController.text.trim(),
      scope: _scope,
      blindCount: _blindCount,
      dueAt: _dueAt,
      locationId: _selectedLocation?.id,
      category: _selectedCategory,
      itemType: _selectedItemType,
    );
    if (session == null) {
      _showMessage('No count lines matched that scope.');
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => CycleCountDetailScreen(session: session),
      ),
    );
  }

  void _showPermissionDenied() {
    _showMessage('Your current role does not allow this action.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _scopeLabel(CycleCountScope scope) {
    return switch (scope) {
      CycleCountScope.allItems => 'All Items',
      CycleCountScope.location => 'Location',
      CycleCountScope.category => 'Category',
      CycleCountScope.lowStock => 'Low Stock',
      CycleCountScope.itemType => 'Item Type',
    };
  }

  String _itemTypeLabel(ItemType type) {
    return switch (type) {
      ItemType.consumable => 'Consumable',
      ItemType.returnable => 'Returnable',
      ItemType.asset => 'Asset',
    };
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
