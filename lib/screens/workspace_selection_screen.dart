import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import 'cloud_login_screen.dart';

class WorkspaceSelectionScreen extends StatefulWidget {
  const WorkspaceSelectionScreen({super.key});

  @override
  State<WorkspaceSelectionScreen> createState() =>
      _WorkspaceSelectionScreenState();
}

class _WorkspaceSelectionScreenState extends State<WorkspaceSelectionScreen> {
  final _nameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  bool _isBusy = false;
  bool _hasRefreshed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final store = AppStoreScope.of(context);
      final destination = await store.completeSignInAndResolveDestination();
      if (!mounted) {
        return;
      }
      if (destination == PostLoginDestination.dashboard) {
        _openDashboard();
        return;
      }
      setState(() => _hasRefreshed = true);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final isFirstOrganization =
        _hasRefreshed &&
        store.availableWorkspaces.isEmpty &&
        store.pendingCloudInvites.isEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isFirstOrganization
              ? 'Set up your organization'
              : 'Choose organization',
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          children: [
            if (isFirstOrganization) ...[
              Text(
                'Set up your organization',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Create the organization you’ll use to manage inventory, tools, and stock.',
              ),
              const SizedBox(height: 16),
            ],
            _AccountCard(store: store),
            const SizedBox(height: 12),
            if (store.pendingCloudInvites.isNotEmpty) ...[
              Text(
                store.pendingCloudInvites.length == 1
                    ? "You've been invited to ${store.pendingCloudInvites.single.workspaceName ?? 'an organization'}. Join now?"
                    : 'Choose invitation to accept.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final invite in store.pendingCloudInvites) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.mark_email_unread_outlined),
                    title: Text(
                      invite.workspaceName ?? 'Organization invitation',
                    ),
                      subtitle: Text(
                        'Invited as ${cloudWorkspaceRoleLabel(invite.role)}',
                      ),
                    trailing: FilledButton(
                      onPressed: _isBusy
                          ? null
                          : () => _acceptInvite(store, invite.id),
                      child: const Text('Join'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 12),
            ],
            if (!_hasRefreshed)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Checking organizations...'),
                    ],
                  ),
                ),
              )
            else if (store.availableWorkspaces.isEmpty && !isFirstOrganization)
              const _EmptyOrganizationCard()
            else if (store.availableWorkspaces.isNotEmpty) ...[
              Text(
                'Your organizations',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final workspace in store.availableWorkspaces) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.business_outlined),
                    title: Text(workspace.name),
                    subtitle: Text(
                      store.roleForWorkspace(workspace.id) == null
                          ? 'Role unavailable'
                          : cloudWorkspaceRoleLabel(
                              store.roleForWorkspace(workspace.id)!,
                            ),
                    ),
                    trailing: FilledButton(
                      onPressed: _isBusy
                          ? null
                          : () => _openOrganization(store, workspace),
                      child: const Text('Open'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
            const SizedBox(height: 12),
            if (isFirstOrganization)
              _CreateOrganizationCard(
                organizationController: _nameController,
                ownerNameController: _ownerNameController,
                showOwnerSetup: store.availableWorkspaces.isEmpty,
                isBusy: _isBusy,
                onCreate: () => _createOrganization(store),
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _isBusy ? null : () => _confirmSignOut(store),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openOrganization(
    AppStore store,
    CloudWorkspace workspace,
  ) async {
    setState(() => _isBusy = true);
    final result = await store.selectCloudWorkspace(workspace);
    if (!mounted) {
      return;
    }
    setState(() => _isBusy = false);
    if (!result.success) {
      _showMessage(result.message ?? 'Could not open organization.');
      return;
    }
    _openDashboard();
  }

  Future<void> _createOrganization(AppStore store) async {
    if (_nameController.text.trim().isEmpty) {
      _showMessage('Enter an organization name.');
      return;
    }
    final isFirstOrganization = store.availableWorkspaces.isEmpty;
    if (isFirstOrganization && _ownerNameController.text.trim().isEmpty) {
      _showMessage('Enter your name so other people know who you are.');
      return;
    }
    setState(() => _isBusy = true);
    final result = await store.createCloudWorkspace(
      _nameController.text,
      ownerDisplayName: isFirstOrganization ? _ownerNameController.text : null,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isBusy = false);
    _showMessage(result.message ?? 'Organization created.');
    if (result.success) {
      _openDashboard();
    }
  }

  Future<void> _acceptInvite(AppStore store, String inviteId) async {
    setState(() => _isBusy = true);
    final result = await store.acceptCloudWorkspaceInvite(inviteId);
    if (!mounted) {
      return;
    }
    setState(() => _isBusy = false);
    _showMessage(result.message ?? 'Invitation accepted.');
    if (result.success) {
      _openDashboard();
    }
  }

  Future<void> _confirmSignOut(AppStore store) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'This will sign out of this device. Inventory saved on this device will remain available after signing back in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (shouldSignOut != true || !mounted) {
      return;
    }
    final result = await store.signOutAndResetSession();
    if (!mounted) {
      return;
    }
    if (!result.success) {
      _showMessage(result.message ?? 'Could not sign out.');
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (context) => const CloudLoginScreen()),
      (route) => false,
    );
  }

  void _openDashboard() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(store.currentUserDisplayName),
            if (store.currentUserDisplayEmail.isNotEmpty)
              Text(store.currentUserDisplayEmail),
            if (store.activeWorkspace != null)
              Text('Current organization: ${store.activeWorkspace!.name}'),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrganizationCard extends StatelessWidget {
  const _EmptyOrganizationCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('You do not have an organization yet.'),
      ),
    );
  }
}

class _CreateOrganizationCard extends StatelessWidget {
  const _CreateOrganizationCard({
    required this.organizationController,
    required this.ownerNameController,
    required this.showOwnerSetup,
    required this.isBusy,
    required this.onCreate,
  });

  final TextEditingController organizationController;
  final TextEditingController ownerNameController;
  final bool showOwnerSetup;
  final bool isBusy;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Organization details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 16),
            TextField(
              controller: organizationController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Organization name',
                hintText: 'Example: Acme Tool Room',
                border: OutlineInputBorder(),
              ),
            ),
            if (showOwnerSetup) ...[
              const SizedBox(height: 16),
              TextField(
                controller: ownerNameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Your name',
                  hintText: 'Example: Jane Doe',
                  helperText:
                      'This is how your name will appear to other people in this organization.',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) {
                  if (!isBusy) onCreate();
                },
              ),
              const SizedBox(height: 20),
              Text('Your role', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              const Card(
                child: ListTile(
                  leading: Icon(Icons.verified_user_outlined),
                  title: Text('Owner'),
                  subtitle: Text(
                    'You’ll be the owner of this organization. Owners can manage the organization, users, roles, settings, and billing.',
                  ),
                  trailing: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Other roles you can assign later',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              const Text(
                'You can invite people later and choose one of these roles for them.',
              ),
              const SizedBox(height: 10),
              const _RoleInfo(
                role: 'Admin',
                description: 'Helps manage users and settings',
              ),
              const _RoleInfo(
                role: 'Manager',
                description: 'Manages inventory and daily operations',
              ),
              const _RoleInfo(
                role: 'Worker',
                description: 'Handles assigned inventory tasks',
              ),
              const _RoleInfo(
                role: 'View-only',
                description: 'Can look up information without making changes',
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: isBusy ? null : onCreate,
              child: const Text('Create organization'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleInfo extends StatelessWidget {
  const _RoleInfo({required this.role, required this.description});

  final String role;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8),
          const SizedBox(width: 8),
          Expanded(child: Text('$role — $description')),
        ],
      ),
    );
  }
}
