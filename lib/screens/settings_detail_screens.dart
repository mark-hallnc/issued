import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';

class CompanySettingsScreen extends StatelessWidget {
  const CompanySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsScaffold(
      title: 'Company',
      children: [
        _InfoCard(
          icon: Icons.business_outlined,
          title: 'Issued Demo Company',
          subtitle: 'Company profile settings will be configured here.',
        ),
      ],
    );
  }
}

class UsersRolesSettingsScreen extends StatelessWidget {
  const UsersRolesSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);

    return _SettingsScaffold(
      title: 'Users & Roles',
      children: [
        for (final person in store.people) ...[
          Card(
            child: ListTile(
              leading: Icon(
                person.isLoginUser
                    ? Icons.account_circle_outlined
                    : Icons.badge_outlined,
                color: const Color(0xFF1E3A5F),
              ),
              title: Text(person.displayName),
              subtitle: Text(_personSubtitle(store, person)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  String _personSubtitle(AppStore store, Person person) {
    final user = _userForPerson(store, person.id);
    if (user == null) {
      return 'Non-login assignee';
    }

    return 'Login user - ${_roleLabel(user.role)}';
  }

  AppUser? _userForPerson(AppStore store, String personId) {
    for (final user in store.users) {
      if (user.personId == personId) {
        return user;
      }
    }

    return null;
  }

  String _roleLabel(UserRole role) {
    return switch (role) {
      UserRole.admin => 'Admin',
      UserRole.manager => 'Manager',
      UserRole.worker => 'Worker',
      UserRole.viewOnly => 'View only',
    };
  }
}

class LocationsSettingsScreen extends StatefulWidget {
  const LocationsSettingsScreen({super.key});

  @override
  State<LocationsSettingsScreen> createState() =>
      _LocationsSettingsScreenState();
}

class _LocationsSettingsScreenState extends State<LocationsSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);

    return _SettingsScaffold(
      title: 'Locations',
      action: FilledButton.icon(
        onPressed: _showAddLocationForm,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Add Location'),
      ),
      children: [
        for (final location in store.locations) ...[
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF1E3A5F),
              ),
              title: Text(location.name),
              subtitle: Text('Type: ${location.type}'),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Future<void> _showAddLocationForm() async {
    final location = await showDialog<Location>(
      context: context,
      builder: (context) => const _AddLocationDialog(),
    );

    if (location == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    AppStoreScope.of(context).addLocation(location);
  }
}

class UnitsOfMeasureSettingsScreen extends StatefulWidget {
  const UnitsOfMeasureSettingsScreen({super.key});

  @override
  State<UnitsOfMeasureSettingsScreen> createState() =>
      _UnitsOfMeasureSettingsScreenState();
}

class _UnitsOfMeasureSettingsScreenState
    extends State<UnitsOfMeasureSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);

    return _SettingsScaffold(
      title: 'Units of Measure',
      action: FilledButton.icon(
        onPressed: _showAddUomForm,
        icon: const Icon(Icons.add),
        label: const Text('Add UOM'),
      ),
      children: [
        for (final unit in store.unitsOfMeasure) ...[
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.straighten_outlined,
                color: Color(0xFF1E3A5F),
              ),
              title: Text(unit.name),
              subtitle: Text(
                '${unit.abbreviation} - ${unit.allowsDecimal ? 'Decimals allowed' : 'Whole numbers only'}',
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Future<void> _showAddUomForm() async {
    final unit = await showDialog<UnitOfMeasure>(
      context: context,
      builder: (context) => const _AddUomDialog(),
    );

    if (unit == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    AppStoreScope.of(context).addUnitOfMeasure(unit);
  }
}

class CustomFieldsSettingsScreen extends StatefulWidget {
  const CustomFieldsSettingsScreen({super.key});

  @override
  State<CustomFieldsSettingsScreen> createState() =>
      _CustomFieldsSettingsScreenState();
}

class _CustomFieldsSettingsScreenState
    extends State<CustomFieldsSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);

    return _SettingsScaffold(
      title: 'Custom Fields',
      action: FilledButton.icon(
        onPressed: _showAddCustomFieldForm,
        icon: const Icon(Icons.add),
        label: const Text('Add Custom Field'),
      ),
      children: [
        for (final field in store.customFieldDefinitions) ...[
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.tune_outlined,
                color: Color(0xFF1E3A5F),
              ),
              title: Text(field.name),
              subtitle: Text(
                '${_entityLabel(field.entityType)} - ${_fieldTypeLabel(field.fieldType)}${field.isRequired ? ' - Required' : ''}',
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Future<void> _showAddCustomFieldForm() async {
    final field = await showDialog<CustomFieldDefinition>(
      context: context,
      builder: (context) => const _AddCustomFieldDialog(),
    );

    if (field == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    AppStoreScope.of(context).addCustomFieldDefinition(field);
  }

  String _entityLabel(CustomFieldEntityType entityType) {
    return switch (entityType) {
      CustomFieldEntityType.item => 'Item',
      CustomFieldEntityType.location => 'Location',
      CustomFieldEntityType.person => 'Person',
      CustomFieldEntityType.transaction => 'Transaction',
    };
  }

  String _fieldTypeLabel(CustomFieldType fieldType) {
    return switch (fieldType) {
      CustomFieldType.text => 'Text',
      CustomFieldType.number => 'Number',
      CustomFieldType.date => 'Date',
      CustomFieldType.boolean => 'Yes/No',
      CustomFieldType.select => 'Dropdown',
    };
  }
}

class PlanUsageSettingsScreen extends StatelessWidget {
  const PlanUsageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    const itemLimit = 25;
    const userLimit = 3;
    const locationLimit = 5;
    const photoLimit = 25;
    const labelExportLimit = 20;

    return _SettingsScaffold(
      title: 'Plan & Usage',
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free plan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF17212F),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Basic in-memory workspace limits for the mock app.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5C6672),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _UsageBar(
          label: 'Items',
          used: store.items.where((item) => item.isActive).length,
          limit: itemLimit,
        ),
        _UsageBar(label: 'Users', used: store.users.length, limit: userLimit),
        _UsageBar(
          label: 'Locations',
          used: store.locations.length,
          limit: locationLimit,
        ),
        const _UsageBar(label: 'Photos', used: 0, limit: photoLimit),
        _UsageBar(
          label: 'Label exports',
          used: store.companyUsage.labelExportCount,
          limit: labelExportLimit,
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: null,
          icon: const Icon(Icons.upgrade),
          label: const Text('Upgrade'),
        ),
      ],
    );
  }
}

class _AddUomDialog extends StatefulWidget {
  const _AddUomDialog();

  @override
  State<_AddUomDialog> createState() => _AddUomDialogState();
}

class _AddUomDialogState extends State<_AddUomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _abbreviationController = TextEditingController();
  bool _allowsDecimal = false;

  @override
  void dispose() {
    _nameController.dispose();
    _abbreviationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add UOM'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: _required,
              ),
              TextFormField(
                controller: _abbreviationController,
                decoration: const InputDecoration(labelText: 'Abbreviation'),
                validator: _required,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Allow decimals'),
                value: _allowsDecimal,
                onChanged: (value) {
                  setState(() {
                    _allowsDecimal = value ?? false;
                  });
                },
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

    Navigator.of(context).pop(
      UnitOfMeasure(
        id: 'uom-${DateTime.now().microsecondsSinceEpoch}',
        name: _nameController.text.trim(),
        abbreviation: _abbreviationController.text.trim(),
        allowsDecimal: _allowsDecimal,
        isActive: true,
      ),
    );
  }
}

class _AddLocationDialog extends StatefulWidget {
  const _AddLocationDialog();

  @override
  State<_AddLocationDialog> createState() => _AddLocationDialogState();
}

class _AddLocationDialogState extends State<_AddLocationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Location'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: _required,
              ),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Type'),
                validator: _required,
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

    Navigator.of(context).pop(
      Location(
        id: 'loc-${DateTime.now().microsecondsSinceEpoch}',
        name: _nameController.text.trim(),
        type: _typeController.text.trim(),
        parentLocationId: null,
        isActive: true,
      ),
    );
  }
}

class _AddCustomFieldDialog extends StatefulWidget {
  const _AddCustomFieldDialog();

  @override
  State<_AddCustomFieldDialog> createState() => _AddCustomFieldDialogState();
}

class _AddCustomFieldDialogState extends State<_AddCustomFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _optionsController = TextEditingController();
  CustomFieldEntityType _entityType = CustomFieldEntityType.item;
  CustomFieldType _fieldType = CustomFieldType.text;
  bool _isRequired = false;

  @override
  void dispose() {
    _nameController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Field'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: _required,
              ),
              DropdownButtonFormField<CustomFieldEntityType>(
                initialValue: _entityType,
                decoration: const InputDecoration(labelText: 'Entity'),
                items: CustomFieldEntityType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_entityLabel(type)),
                      ),
                    )
                    .toList(),
                onChanged: (type) {
                  if (type == null) {
                    return;
                  }

                  setState(() {
                    _entityType = type;
                  });
                },
              ),
              DropdownButtonFormField<CustomFieldType>(
                initialValue: _fieldType,
                decoration: const InputDecoration(labelText: 'Field type'),
                items: CustomFieldType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_fieldTypeLabel(type)),
                      ),
                    )
                    .toList(),
                onChanged: (type) {
                  if (type == null) {
                    return;
                  }

                  setState(() {
                    _fieldType = type;
                  });
                },
              ),
              if (_fieldType == CustomFieldType.select)
                TextFormField(
                  controller: _optionsController,
                  decoration: const InputDecoration(
                    labelText: 'Dropdown options',
                    helperText: 'Separate options with commas',
                  ),
                ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Required'),
                value: _isRequired,
                onChanged: (value) {
                  setState(() {
                    _isRequired = value ?? false;
                  });
                },
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

    Navigator.of(context).pop(
      CustomFieldDefinition(
        id: 'field-${DateTime.now().microsecondsSinceEpoch}',
        entityType: _entityType,
        name: _nameController.text.trim(),
        fieldType: _fieldType,
        isRequired: _isRequired,
        options: _optionsController.text
            .split(',')
            .map((option) => option.trim())
            .where((option) => option.isNotEmpty)
            .toList(),
        isActive: true,
      ),
    );
  }

  String _entityLabel(CustomFieldEntityType entityType) {
    return switch (entityType) {
      CustomFieldEntityType.item => 'Item',
      CustomFieldEntityType.location => 'Location',
      CustomFieldEntityType.person => 'Person',
      CustomFieldEntityType.transaction => 'Transaction',
    };
  }

  String _fieldTypeLabel(CustomFieldType fieldType) {
    return switch (fieldType) {
      CustomFieldType.text => 'Text',
      CustomFieldType.number => 'Number',
      CustomFieldType.date => 'Date',
      CustomFieldType.boolean => 'Yes/No',
      CustomFieldType.select => 'Dropdown',
    };
  }
}

class _UsageBar extends StatelessWidget {
  const _UsageBar({
    required this.label,
    required this.used,
    required this.limit,
  });

  final String label;
  final int used;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final progress = limit == 0 ? 0.0 : (used / limit).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text('$used / $limit'),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress),
          ],
        ),
      ),
    );
  }
}

class _SettingsScaffold extends StatelessWidget {
  const _SettingsScaffold({
    required this.title,
    required this.children,
    this.action,
  });

  final String title;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (action != null) ...[
            Align(alignment: Alignment.centerLeft, child: action),
            const SizedBox(height: 16),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1E3A5F)),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }

  return null;
}
