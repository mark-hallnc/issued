import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import 'cloud_adoption_wizard_screen.dart';

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
  WorkspaceNavigationDecision? _decision;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final store = AppStoreScope.of(context);
      final decision = await store.getWorkspaceNavigationDecision();
      if (!mounted) {
        return;
      }
      setState(() {
        _decision = decision;
        _hasRefreshed = true;
      });
      await _showAdoptionWizardIfNeeded(store);
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
    final email = store.currentCloudUser?.email ?? 'Not signed in';
    final decision = _decision;
    return Scaffold(
      appBar: AppBar(title: const Text('Workspace')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(email),
                  if (store.activeWorkspace != null)
                    Text('Active workspace: ${store.activeWorkspace!.name}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (store.pendingCloudInvites.isNotEmpty) ...[
            Text(
              'Pending Invites',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final invite in store.pendingCloudInvites) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.mark_email_unread_outlined),
                  title: Text(invite.workspaceName ?? 'Workspace invitation'),
                  subtitle: Text(
                    '${invite.email} - ${cloudWorkspaceRoleLabel(invite.role)}',
                  ),
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
                    Text('Checking workspaces...'),
                  ],
                ),
              ),
            )
          else if (store.activeWorkspace == null && store.hasLocalWorkspace)
            _SetupSyncCard(
              workspaceName: store.localWorkspaceName,
              isBusy: _isBusy,
              onConnect: () => _connectLocalWorkspace(store),
              onNotNow: () => Navigator.of(context).pop(),
            )
          else if (store.availableWorkspaces.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No workspaces yet. Create one to continue.'),
              ),
            ),
          if (_hasRefreshed && store.availableWorkspaces.isNotEmpty) ...[
            if (store.activeWorkspace == null) ...[
              const SizedBox(height: 12),
              Text(
                'Choose existing workspace',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
            ],
            for (final workspace in store.availableWorkspaces) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.business_outlined),
                  title: Text(workspace.name),
                  subtitle: workspace.slug == null
                      ? null
                      : Text(workspace.slug!),
                  trailing: store.activeWorkspace?.id == workspace.id
                      ? const Icon(Icons.check_circle)
                      : null,
                  onTap: () async {
                    store.setActiveCloudWorkspace(workspace);
                    _showMessage('Workspace selected.');
                    await _showAdoptionWizardIfNeeded(store);
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
          const SizedBox(height: 12),
          if (decision == WorkspaceNavigationDecision.createCloudWorkspace ||
              !store.hasLocalWorkspace)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Workspace',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Workspace name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _isBusy ? null : () => _createWorkspace(store),
                      child: const Text('Create Workspace'),
                    ),
                  ],
                ),
              ),
            ),
          if (decision == WorkspaceNavigationDecision.chooseCloudWorkspace)
            const Text('Choose a workspace above to continue syncing.'),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _isBusy
                ? null
                : () async {
                    final result = await store.signOutCloud();
                    if (!context.mounted) {
                      return;
                    }
                    _showMessage(result.message ?? 'Signed out.');
                    Navigator.of(context).pop();
                  },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _createWorkspace(AppStore store) async {
    final workspaceName = _nameController.text.trim();
    if (store.hasLocalWorkspace &&
        (workspaceName.isEmpty ||
            workspaceName.toLowerCase() !=
                store.localWorkspaceName.toLowerCase())) {
      final confirmed = await _confirmCreateAnotherWorkspace(store);
      if (confirmed != true) {
        return;
      }
    }
    setState(() => _isBusy = true);
    final result = await store.createCloudWorkspace(workspaceName);
    if (!mounted) {
      return;
    }
    setState(() => _isBusy = false);
    _showMessage(result.message ?? 'Workspace request complete.');
    if (result.success) {
      _nameController.clear();
      final decision = await store.getWorkspaceNavigationDecision(
        refresh: false,
      );
      if (!mounted) {
        return;
      }
      setState(() => _decision = decision);
      await _showAdoptionWizardIfNeeded(store);
    }
  }

  Future<void> _connectLocalWorkspace(AppStore store) async {
    setState(() => _isBusy = true);
    final result = await store.connectLocalWorkspaceToCloud();
    if (!mounted) {
      return;
    }
    setState(() => _isBusy = false);
    _showMessage(result.message ?? 'Workspace connected.');
    if (result.success) {
      final decision = await store.getWorkspaceNavigationDecision(
        refresh: false,
      );
      if (!mounted) {
        return;
      }
      setState(() => _decision = decision);
      await _showAdoptionWizardIfNeeded(store);
    }
  }

  Future<void> _acceptInvite(AppStore store, String inviteId) async {
    setState(() => _isBusy = true);
    final result = await store.acceptCloudWorkspaceInvite(inviteId);
    if (!mounted) {
      return;
    }
    setState(() => _isBusy = false);
    _showMessage(result.message ?? 'Invite request complete.');
    if (result.success) {
      await _showAdoptionWizardIfNeeded(store);
    }
  }

  Future<void> _showAdoptionWizardIfNeeded(AppStore store) async {
    await store.refreshCloudAdoptionSummary();
    if (!mounted || !store.shouldShowCloudAdoptionWizard) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const CloudAdoptionWizardScreen(),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool?> _confirmCreateAnotherWorkspace(AppStore store) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create another workspace?'),
        content: Text(
          'You already created ${store.localWorkspaceName} on this device. Creating another workspace may duplicate your setup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _SetupSyncCard extends StatelessWidget {
  const _SetupSyncCard({
    required this.workspaceName,
    required this.isBusy,
    required this.onConnect,
    required this.onNotNow,
  });

  final String workspaceName;
  final bool isBusy;
  final VoidCallback onConnect;
  final VoidCallback onNotNow;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set up sync for this workspace',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'You already created $workspaceName on this device. You can connect it to your account so it syncs across devices.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: isBusy ? null : onConnect,
                  child: const Text('Connect this workspace'),
                ),
                OutlinedButton(
                  onPressed: isBusy ? null : onNotNow,
                  child: const Text('Not now'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'If you already belong to a workspace, choose it from the list.',
            ),
          ],
        ),
      ),
    );
  }
}
