import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import '../core/permissions/app_permissions.dart';
import '../widgets/issued_empty_state.dart';
import '../widgets/issued_page_header.dart';
import '../widgets/issued_status_badge.dart';
import 'items_screen.dart';
import 'label_center_screen.dart';
import 'location_detail_screen.dart';
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

    await showDialog<bool>(
      context: context,
      builder: (_) => _EditCompanyDialog(
        store: store,
        company: store.company,
      ),
    );
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

class _EditCompanyDialog extends StatefulWidget {
  const _EditCompanyDialog({required this.store, required this.company});

  final AppStore store;
  final Company? company;

  @override
  State<_EditCompanyDialog> createState() => _EditCompanyDialogState();
}

class _EditCompanyDialogState extends State<_EditCompanyDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _industryController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.company?.name ?? '');
    _industryController = TextEditingController(
      text: widget.company?.industry ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving || _formKey.currentState?.validate() != true) {
      return;
    }

    setState(() => _isSaving = true);
    await widget.store.updateCompany(
      name: _nameController.text,
      industry: _industryController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Company'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Workspace name'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _industryController,
              decoration: const InputDecoration(labelText: 'Industry'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
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
                  '${store.currentDisplayUserName} - '
                  '${store.currentDisplayUserSubtitle}',
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => _showUserForm(context, store),
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('Add User'),
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
              trailing: _userForPerson(store, person.id)?.lastLoginAt == null
                  ? const Icon(Icons.edit_outlined)
                  : const Icon(Icons.manage_accounts_outlined),
              onTap: () {
                final user = _userForPerson(store, person.id);
                if (user != null) {
                  _showUserForm(context, store, user: user, person: person);
                }
              },
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

  Future<void> _showUserForm(
    BuildContext context,
    AppStore store, {
    AppUser? user,
    Person? person,
  }) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: person?.displayName);
    final emailController = TextEditingController(text: user?.email);
    final pinController = TextEditingController();
    final pinConfirmController = TextEditingController();
    var role = user?.role ?? UserRole.worker;
    var isActive = user?.isActive ?? true;

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(user == null ? 'Add User' : 'Edit User'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (value) => (value?.trim().isEmpty ?? true)
                            ? 'Name is required.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email optional',
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<UserRole>(
                        initialValue: role,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: [
                          for (final option in UserRole.values)
                            DropdownMenuItem(
                              value: option,
                              child: Text(roleLabel(option)),
                            ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            role = value ?? UserRole.worker;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: pinController,
                        decoration: InputDecoration(
                          labelText: user == null ? 'PIN' : 'New PIN optional',
                          helperText: 'Use 4-8 digits.',
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final pin = value?.trim() ?? '';
                          final needsPin =
                              user == null && role != UserRole.viewOnly;
                          if (needsPin && !RegExp(r'^\d{4,8}$').hasMatch(pin)) {
                            return 'Enter a 4-8 digit PIN.';
                          }
                          if (pin.isNotEmpty &&
                              !RegExp(r'^\d{4,8}$').hasMatch(pin)) {
                            return 'Enter a 4-8 digit PIN.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: pinConfirmController,
                        decoration: const InputDecoration(
                          labelText: 'Confirm PIN',
                        ),
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if ((pinController.text.trim()).isNotEmpty &&
                              value?.trim() != pinController.text.trim()) {
                            return 'PINs do not match.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Active'),
                        value: isActive,
                        onChanged: (value) {
                          setDialogState(() {
                            isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    final result = user == null
                        ? await store.createLocalUser(
                            displayName: nameController.text,
                            email: emailController.text,
                            role: role,
                            pin: pinController.text,
                          )
                        : await store.updateLocalUser(
                            userId: user.id,
                            displayName: nameController.text,
                            email: emailController.text,
                            role: role,
                            isActive: isActive,
                            pin: pinController.text,
                          );
                    if (!dialogContext.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text(result.message ?? 'User saved.')),
                    );
                    if (result.success) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      emailController.dispose();
      pinController.dispose();
      pinConfirmController.dispose();
    });
  }
}

class LocationsSettingsScreen extends StatefulWidget {
  const LocationsSettingsScreen({super.key});

  @override
  State<LocationsSettingsScreen> createState() =>
      _LocationsSettingsScreenState();
}

class _LocationsSettingsScreenState extends State<LocationsSettingsScreen> {
  final _searchController = TextEditingController();
  bool _showArchived = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final query = _searchController.text.trim().toLowerCase();
    final locations =
        store.locations.where((location) {
          if (!_showArchived && !location.isActive) {
            return false;
          }
          final haystack = [
            location.name,
            location.code,
            location.type,
            store.resolveLocationPath(location.id),
          ].whereType<String>().join(' ').toLowerCase();
          return query.isEmpty || haystack.contains(query);
        }).toList()..sort((left, right) {
          final activeCompare = (right.isActive ? 1 : 0).compareTo(
            left.isActive ? 1 : 0,
          );
          if (activeCompare != 0) {
            return activeCompare;
          }
          return store
              .resolveLocationPath(left.id)
              .compareTo(store.resolveLocationPath(right.id));
        });

    return _SettingsScaffold(
      title: 'Locations',
      action:
          store.permissions.canManageSettings ||
              store.locations.any((location) => location.isActive)
          ? Wrap(
              spacing: 8,
              children: [
                if (store.locations.any((location) => location.isActive))
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const LabelCenterScreen(
                            initialMode: LabelCenterMode.locations,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text('Print Location Labels'),
                  ),
                if (store.permissions.canManageSettings)
                  FilledButton.icon(
                    onPressed: _showAddLocationForm,
                    icon: const Icon(Icons.add_location_alt),
                    label: const Text('Add Location'),
                  ),
              ],
            )
          : null,
      children: [
        const IssuedPageHeader(title: 'Locations'),
        const SizedBox(height: 18),
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Search locations',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: _showArchived,
          title: const Text('Show archived locations'),
          onChanged: (value) => setState(() => _showArchived = value),
        ),
        const SizedBox(height: 12),
        if (locations.isEmpty)
          IssuedEmptyState(
            icon: Icons.location_on_outlined,
            title: 'No locations yet',
            message:
                'Create places like warehouses, shelves, bins, job boxes, or vehicles so stock can be tracked accurately.',
            actionLabel: store.permissions.canManageSettings
                ? 'Add location'
                : null,
            onAction: store.permissions.canManageSettings
                ? _showAddLocationForm
                : null,
          ),
        for (final location in locations) ...[
          _LocationCard(
            location: location,
            store: store,
            canManage: store.permissions.canManageSettings,
            onEdit: () => _showLocationForm(location: location),
            onArchive: () => _archiveLocation(location),
            onRestore: () => _restoreLocation(location),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Future<void> _showLocationForm({Location? location}) async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canManageSettings) {
      _showPermissionDenied(context);
      return;
    }

    if (location == null && !store.canAddLocation) {
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

    final result = await showDialog<Location>(
      context: context,
      builder: (context) => _LocationDialog(location: location, store: store),
    );

    if (result == null || !mounted) {
      return;
    }

    final saveResult = location == null
        ? store.addLocation(result)
        : store.updateLocation(result);
    _showMessage(saveResult.message ?? 'Location saved.');
  }

  Future<void> _archiveLocation(Location location) async {
    final store = AppStoreScope.of(context);
    if (!store.permissions.canManageSettings) {
      _showPermissionDenied(context);
      return;
    }
    if (!store.canArchiveLocation(location.id)) {
      final destination = await showDialog<Location>(
        context: context,
        builder: (context) => _TransferLocationDialog(source: location),
      );
      if (destination == null || !mounted) {
        return;
      }
      final transferResult = store.transferAllStockFromLocation(
        location.id,
        destination.id,
      );
      if (!transferResult.success) {
        _showMessage(transferResult.message ?? 'Could not transfer stock.');
        return;
      }
    }
    final result = store.archiveLocation(location.id);
    _showMessage(result.message ?? 'Location archived.');
  }

  void _restoreLocation(Location location) {
    final result = AppStoreScope.of(context).unarchiveLocation(location.id);
    _showMessage(result.message ?? 'Location restored.');
  }

  Future<void> _showAddLocationForm() => _showLocationForm();

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.location,
    required this.store,
    required this.canManage,
    required this.onEdit,
    required this.onArchive,
    required this.onRestore,
  });

  final Location location;
  final AppStore store;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final summary = store.getLocationStockSummary(location.id);
    final parentName = location.parentLocationId == null
        ? null
        : store.resolveLocationName(location.parentLocationId!);
    return Padding(
      padding: EdgeInsets.only(left: parentName == null ? 0 : 18),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) =>
                  LocationDetailScreen(locationId: location.id),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      _locationTypeIcon(location.type),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (parentName != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          'Inside $parentName',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFF64748B)),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          IssuedStatusBadge(
                            label: _locationTypeLabel(location.type),
                            icon: _locationTypeIcon(location.type),
                          ),
                          IssuedStatusBadge(
                            label:
                                '${summary.itemCount} ${summary.itemCount == 1 ? 'item' : 'items'}',
                            tone: IssuedStatusTone.info,
                          ),
                          IssuedStatusBadge(
                            label: location.isActive ? 'Active' : 'Archived',
                            tone: location.isActive
                                ? IssuedStatusTone.success
                                : IssuedStatusTone.neutral,
                          ),
                        ],
                      ),
                      if ((location.code ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 9),
                        Text(
                          'Code ${location.code}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'archive') {
                      onArchive();
                    } else if (value == 'restore') {
                      onRestore();
                    } else if (value == 'label') {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => LabelCenterScreen(
                            initialMode: LabelCenterMode.locations,
                            initialLocationIds: {location.id},
                          ),
                        ),
                      );
                    } else if (value == 'stock') {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              ItemsScreen(initialLocationId: location.id),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'stock',
                      child: Text('View Stock'),
                    ),
                    const PopupMenuItem(
                      value: 'label',
                      child: Text('Print Label'),
                    ),
                    if (canManage)
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    if (canManage && location.isActive)
                      const PopupMenuItem(
                        value: 'archive',
                        child: Text('Archive'),
                      ),
                    if (canManage && !location.isActive)
                      const PopupMenuItem(
                        value: 'restore',
                        child: Text('Restore'),
                      ),
                  ],
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TransferLocationDialog extends StatelessWidget {
  const _TransferLocationDialog({required this.source});

  final Location source;

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final destinations = store.activeLocations
        .where((location) => location.id != source.id)
        .toList();
    return AlertDialog(
      title: const Text('Transfer stock before archiving'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This location still has stock. Choose a destination.'),
            const SizedBox(height: 12),
            for (final location in destinations)
              ListTile(
                title: Text(store.resolveLocationPath(location.id)),
                onTap: () => Navigator.of(context).pop(location),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
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
                      : 'Billing is not connected yet. This plan is selected for the organization.',
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

class _LocationDialog extends StatefulWidget {
  const _LocationDialog({required this.store, this.location});

  final AppStore store;
  final Location? location;

  @override
  State<_LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<_LocationDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _descriptionController;
  late String _type;
  String? _parentLocationId;

  static const _types = [
    'stockroom',
    'shelf',
    'bin',
    'truck',
    'jobBox',
    'warehouse',
    'trailer',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    final location = widget.location;
    _nameController = TextEditingController(text: location?.name ?? '');
    _codeController = TextEditingController(text: location?.code ?? '');
    _descriptionController = TextEditingController(
      text: location?.description ?? '',
    );
    _type = _types.contains(location?.type) ? location!.type : 'other';
    _parentLocationId = location?.parentLocationId;
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
    final location = widget.location;
    final parentOptions =
        widget.store.locations.where((candidate) {
          return candidate.id != location?.id &&
              !widget.store.wouldCreateLocationCycle(
                location?.id ?? 'new-location',
                candidate.id,
              );
        }).toList()..sort(
          (left, right) => widget.store
              .resolveLocationPath(left.id)
              .compareTo(widget.store.resolveLocationPath(right.id)),
        );

    return AlertDialog(
      title: Text(location == null ? 'Add location' : 'Edit location'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Define where inventory is physically stored.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Location name',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Code (optional)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: 'Location type',
                  helperText: _locationTypeHelp(_type),
                ),
                items: [
                  for (final type in _types)
                    DropdownMenuItem(
                      value: type,
                      child: Text(_locationTypeLabel(type)),
                    ),
                ],
                onChanged: (value) => setState(() => _type = value ?? 'other'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _parentLocationId,
                decoration: const InputDecoration(
                  labelText: 'Parent location',
                  helperText:
                      'Use parent locations to organize places like Warehouse → Aisle 1 → Shelf 3.',
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Top-level location'),
                  ),
                  for (final parent in parentOptions)
                    DropdownMenuItem(
                      value: parent.id,
                      child: Text(widget.store.resolveLocationPath(parent.id)),
                    ),
                ],
                onChanged: (value) => setState(() => _parentLocationId = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Notes or details (optional)',
                  alignLabelWithHint: true,
                ),
                minLines: 2,
                maxLines: 4,
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
    final location = widget.location;
    final name = _nameController.text.trim();
    final code = _emptyToNull(_codeController.text);
    final description = _emptyToNull(_descriptionController.text);
    if (widget.store.isLocationNameInUseUnderParent(
      name,
      parentLocationId: _parentLocationId,
      excludingLocationId: location?.id,
    )) {
      _showDialogMessage('A location with this name already exists here.');
      return;
    }
    if (code != null &&
        widget.store.isLocationCodeInUse(
          code,
          excludingLocationId: location?.id,
        )) {
      _showDialogMessage('Another location already uses this code.');
      return;
    }
    if (location != null &&
        widget.store.wouldCreateLocationCycle(location.id, _parentLocationId)) {
      _showDialogMessage('Parent location cannot create a cycle.');
      return;
    }

    Navigator.of(context).pop(
      Location(
        id: location?.id ?? 'loc-${now.microsecondsSinceEpoch}',
        name: name,
        description: description,
        code: code,
        type: _type,
        parentLocationId: _parentLocationId,
        isActive: location?.isActive ?? true,
        createdAt: location?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  void _showDialogMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _locationTypeLabel(String value) {
  return switch (value) {
    'stockroom' => 'Stockroom',
    'shelf' => 'Shelf',
    'bin' => 'Bin',
    'truck' => 'Truck',
    'jobBox' => 'Job Box',
    'warehouse' => 'Warehouse',
    'trailer' => 'Trailer',
    _ => value.isEmpty ? 'Other' : value,
  };
}

String _locationTypeHelp(String value) {
  return switch (value) {
    'warehouse' => 'Main storage area',
    'stockroom' => 'Dedicated inventory room',
    'shelf' => 'Fixed storage spot',
    'bin' => 'Small container or slot',
    'jobBox' => 'Mobile job storage',
    'truck' => 'Service truck or vehicle',
    'trailer' => 'Mobile trailer storage',
    _ => 'Custom location',
  };
}

IconData _locationTypeIcon(String value) {
  return switch (value) {
    'warehouse' || 'stockroom' => Icons.warehouse_outlined,
    'shelf' => Icons.view_stream_outlined,
    'bin' => Icons.inventory_2_outlined,
    'jobBox' => Icons.handyman_outlined,
    'truck' => Icons.local_shipping_outlined,
    'trailer' => Icons.rv_hookup_outlined,
    _ => Icons.location_on_outlined,
  };
}

void _showPermissionDenied(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Your current role does not allow this action.'),
    ),
  );
}
