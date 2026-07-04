import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import '../core/permissions/app_permissions.dart';
import 'plan_screens.dart';

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final company = store.company;
    final canEdit = store.permissions.canManageSettings;

    return _SettingsScaffold(
      title: 'Company',
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company?.name ?? 'No workspace set',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Industry: ${company?.industry ?? 'Not set'}'),
                Text(
                  'Setup: ${company?.setupCompleted ?? false ? 'Complete' : 'Not complete'}',
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: canEdit ? _showEditCompanyDialog : null,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Company'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Development/testing tool',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Show setup again resets onboarding only. Inventory data is not deleted.',
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: canEdit ? _resetOnboarding : null,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Show setup again'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showEditCompanyDialog() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canManageSettings) {
      _showPermissionDenied(context);
      return;
    }

    final company = store.company;
    final nameController = TextEditingController(text: company?.name ?? '');
    final industryController = TextEditingController(
      text: company?.industry ?? '',
    );
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<_CompanyEditResult>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Company'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Workspace name'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: industryController,
                decoration: const InputDecoration(labelText: 'Industry'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) {
                return;
              }
              Navigator.of(context).pop(
                _CompanyEditResult(
                  name: nameController.text,
                  industry: industryController.text,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    nameController.dispose();
    industryController.dispose();

    if (result == null) {
      return;
    }

    await store.updateCompany(name: result.name, industry: result.industry);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _resetOnboarding() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canManageSettings) {
      _showPermissionDenied(context);
      return;
    }

    await store.resetOnboardingForTesting();
  }
}

class _CompanyEditResult {
  const _CompanyEditResult({required this.name, required this.industry});

  final String name;
  final String? industry;
}

class UsersRolesSettingsScreen extends StatelessWidget {
  const UsersRolesSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canManageUsers) {
      return const _PermissionScaffold(title: 'Users & Roles');
    }

    return _SettingsScaffold(
      title: 'Users & Roles',
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current User',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${store.currentPerson?.displayName ?? 'Local User'} - ${roleLabel(store.currentRole)}',
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _showUserSwitcher(context, store),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Switch User - Local testing only'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
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

    return 'Login user - ${roleLabel(user.role)}';
  }

  AppUser? _userForPerson(AppStore store, String personId) {
    for (final user in store.users) {
      if (user.personId == personId) {
        return user;
      }
    }

    return null;
  }

  Future<void> _showUserSwitcher(BuildContext context, AppStore store) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch current user'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final user in store.users.where((user) => user.isActive))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_personNameForUser(store, user)),
                subtitle: Text(roleLabel(user.role)),
                onTap: () {
                  store.setCurrentUserForTesting(user.id);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  String _personNameForUser(AppStore store, AppUser user) {
    for (final person in store.people) {
      if (person.id == user.personId) {
        return person.displayName;
      }
    }

    return user.email;
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
      action: store.permissions.canManageSettings
          ? FilledButton.icon(
              onPressed: _showAddLocationForm,
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Add Location'),
            )
          : null,
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
    final store = AppStoreScope.of(context);
    if (!store.permissions.canManageSettings) {
      _showPermissionDenied(context);
      return;
    }

    if (!store.canAddLocation) {
      final action = await showPlanLimitDialog(
        context,
        title: 'Location limit reached',
        message:
            'Your ${store.currentPlan.name} plan includes up to ${store.currentPlan.locationLimit} active locations.',
        recommendedPlanCode: store
            .getLimitWarningForLocations()
            ?.recommendedPlanCode,
      );

      if (!mounted || action != PlanLimitDialogAction.upgrade) {
        return;
      }

      await openComparePlans(
        context,
        recommendedPlanCode: store
            .getLimitWarningForLocations()
            ?.recommendedPlanCode,
      );
      return;
    }

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
      action: store.permissions.canManageSettings
          ? FilledButton.icon(
              onPressed: _showAddUomForm,
              icon: const Icon(Icons.add),
              label: const Text('Add UOM'),
            )
          : null,
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
    final store = AppStoreScope.of(context);
    if (!store.permissions.canManageSettings) {
      _showPermissionDenied(context);
      return;
    }

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

    store.addUnitOfMeasure(unit);
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
      action: store.permissions.canManageSettings
          ? FilledButton.icon(
              onPressed: _showAddCustomFieldForm,
              icon: const Icon(Icons.add),
              label: const Text('Add Custom Field'),
            )
          : null,
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
                '${_entityLabel(field.entityType)} - ${_fieldTypeLabel(field.fieldType)}${field.isRequired ? ' - Required' : ''}${field.isActive ? '' : ' - Archived'}',
              ),
              trailing: store.permissions.canManageSettings
                  ? PopupMenuButton<String>(
                      onSelected: (action) => _handleFieldAction(action, field),
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'archive', child: Text('Archive')),
                      ],
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Future<void> _showAddCustomFieldForm() async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canManageSettings) {
      _showPermissionDenied(context);
      return;
    }

    final field = await showDialog<CustomFieldDefinition>(
      context: context,
      builder: (context) => _CustomFieldDialog(categories: _categories(store)),
    );

    if (field == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    store.addCustomFieldDefinition(field);
  }

  Future<void> _handleFieldAction(
    String action,
    CustomFieldDefinition field,
  ) async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canManageSettings) {
      _showPermissionDenied(context);
      return;
    }

    if (action == 'archive') {
      store.archiveCustomFieldDefinition(field.id);
      return;
    }

    final updatedField = await showDialog<CustomFieldDefinition>(
      context: context,
      builder: (context) =>
          _CustomFieldDialog(field: field, categories: _categories(store)),
    );
    if (updatedField != null) {
      store.updateCustomFieldDefinition(updatedField);
    }
  }

  List<String> _categories(AppStore store) {
    return store.items
        .map((item) => item.category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
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
    final plan = store.currentPlan;
    final usage = store.currentUsage;
    final canManagePlan = store.permissions.canManagePlan;

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
                  '${plan.name} plan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF17212F),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  plan.code == 'free'
                      ? 'Free forever for solo and small-shop use.'
                      : 'Billing is not connected yet. This plan is selected locally for testing.',
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
          label: 'Active items',
          used: usage.activeItemCount,
          limit: plan.itemLimit,
        ),
        _UsageBar(label: 'Users', used: usage.userCount, limit: plan.userLimit),
        _UsageBar(
          label: 'Locations',
          used: usage.locationCount,
          limit: plan.locationLimit,
        ),
        _UsageBar(
          label: 'Photos',
          used: usage.photoCount,
          limit: plan.photoLimit,
        ),
        _UsageBar(
          label: 'Label exports this month',
          used: usage.labelExportCount,
          limit: plan.labelExportLimit,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Included Features',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                _FeatureRow(
                  label: 'CSV import',
                  value: plan.csvImportEnabled ? 'Included' : 'Upgrade',
                ),
                _FeatureRow(
                  label: 'Advanced reports',
                  value: _advancedReportsLabel(plan),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: () => openComparePlans(context),
              icon: const Icon(Icons.compare_arrows),
              label: const Text('Compare Plans'),
            ),
            FilledButton.icon(
              onPressed: canManagePlan
                  ? () => openComparePlans(
                      context,
                      recommendedPlanCode: _recommendedPlanCode(store),
                    )
                  : () => _showPermissionDenied(context),
              icon: const Icon(Icons.upgrade),
              label: const Text('Upgrade Plan'),
            ),
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.credit_card),
              label: const Text('Manage Billing - Coming soon'),
            ),
          ],
        ),
      ],
    );
  }

  String _advancedReportsLabel(Plan plan) {
    if (plan.code == 'starter') {
      return 'Basic only';
    }

    return plan.advancedReportsEnabled ? 'Included' : 'Upgrade';
  }

  String? _recommendedPlanCode(AppStore store) {
    final warnings = store.getLimitWarnings();
    return warnings.isEmpty ? null : warnings.first.recommendedPlanCode;
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

class _CustomFieldDialog extends StatefulWidget {
  const _CustomFieldDialog({this.field, required this.categories});

  @override
  State<_CustomFieldDialog> createState() => _CustomFieldDialogState();

  final CustomFieldDefinition? field;
  final List<String> categories;
}

class _CustomFieldDialogState extends State<_CustomFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _optionsController = TextEditingController();
  CustomFieldEntityType _entityType = CustomFieldEntityType.item;
  CustomFieldType _fieldType = CustomFieldType.text;
  ItemType? _appliesToItemType;
  String? _appliesToCategory;
  bool _isRequired = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final field = widget.field;
    if (field != null) {
      _nameController.text = field.name;
      _optionsController.text = field.options.join(', ');
      _entityType = field.entityType;
      _fieldType = field.fieldType;
      _appliesToItemType = field.appliesToItemType;
      _appliesToCategory = field.appliesToCategory;
      _isRequired = field.isRequired;
      _isActive = field.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.field == null ? 'Add Custom Field' : 'Edit Custom Field',
      ),
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
              DropdownButtonFormField<ItemType?>(
                initialValue: _appliesToItemType,
                decoration: const InputDecoration(
                  labelText: 'Applies to item type',
                ),
                items: [
                  const DropdownMenuItem<ItemType?>(
                    value: null,
                    child: Text('Any'),
                  ),
                  for (final type in ItemType.values)
                    DropdownMenuItem<ItemType?>(
                      value: type,
                      child: Text(_itemTypeLabel(type)),
                    ),
                ],
                onChanged: (type) {
                  setState(() {
                    _appliesToItemType = type;
                  });
                },
              ),
              DropdownButtonFormField<String?>(
                initialValue: _appliesToCategory,
                decoration: const InputDecoration(
                  labelText: 'Applies to category',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Any'),
                  ),
                  for (final category in widget.categories)
                    DropdownMenuItem<String?>(
                      value: category,
                      child: Text(category),
                    ),
                ],
                onChanged: (category) {
                  setState(() {
                    _appliesToCategory = category;
                  });
                },
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
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
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
        id:
            widget.field?.id ??
            'field-${DateTime.now().microsecondsSinceEpoch}',
        entityType: _entityType,
        name: _nameController.text.trim(),
        fieldType: _fieldType,
        isRequired: _isRequired,
        options: _optionsController.text
            .split(',')
            .map((option) => option.trim())
            .where((option) => option.isNotEmpty)
            .toList(),
        appliesToItemType: _appliesToItemType,
        appliesToCategory: _appliesToCategory,
        sortOrder: widget.field?.sortOrder ?? 0,
        isActive: _isActive,
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

  String _itemTypeLabel(ItemType type) {
    return switch (type) {
      ItemType.consumable => 'Consumable',
      ItemType.returnable => 'Returnable',
      ItemType.asset => 'Asset',
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

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF5C6672)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF17212F),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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

class _PermissionScaffold extends StatelessWidget {
  const _PermissionScaffold({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: title,
      children: const [
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Your current role does not allow this action.'),
          ),
        ),
      ],
    );
  }
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }

  return null;
}

void _showPermissionDenied(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Your current role does not allow this action.'),
    ),
  );
}
