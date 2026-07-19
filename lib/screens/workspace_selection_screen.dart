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
  bool _isBusy = false;
  bool _hasRefreshed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final store = AppStoreScope.of(context);
      await store.completeSignInAndResolveDestination();
      if (!mounted) {
        return;
      }
      if (store.activeWorkspace != null) {
        _openDashboard();
        return;
      }
      if (store.hasLocalWorkspace &&
          store.availableWorkspaces.isEmpty &&
          store.localWorkspaceName.isNotEmpty) {
        _nameController.text = store.localWorkspaceName;
      }
      setState(() => _hasRefreshed = true);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Choose organization')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                  subtitle: Text(cloudWorkspaceRoleLabel(invite.role)),
                  trailing: FilledButton(
                    onPressed: _isBusy
                        ? null
                        : () => _acceptInvite(store, invite.id),
                    child: const Text('Accept'),
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
          else if (store.availableWorkspaces.isEmpty)
            const _EmptyOrganizationCard()
          else ...[
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
          if (store.pendingCloudInvites.isEmpty)
            _CreateOrganizationCard(
              controller: _nameController,
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
    );
  }

  Future<void> _openOrganization(
    AppStore store,
    CloudWorkspace workspace,
  ) async {
    setState(() => _isBusy = true);
    store.setActiveCloudWorkspace(workspace);
    await store.completeSignInAndResolveDestination();
    if (!mounted) {
      return;
    }
    setState(() => _isBusy = false);
    _openDashboard();
  }

  Future<void> _createOrganization(AppStore store) async {
    if (_nameController.text.trim().isEmpty && !store.hasLocalWorkspace) {
      _showMessage('Enter an organization name.');
      return;
    }
    setState(() => _isBusy = true);
    final result = await store.createCloudWorkspace(_nameController.text);
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
            Text(store.currentDisplayUserName),
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
    required this.controller,
    required this.isBusy,
    required this.onCreate,
  });

  final TextEditingController controller;
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
              'Create your organization',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('This is usually your company, shop, or tool room.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Organization name'),
            ),
            const SizedBox(height: 12),
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
