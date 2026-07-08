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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final store = AppStoreScope.of(context);
      await store.refreshCloudWorkspaceState();
      if (!mounted) {
        return;
      }
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
          if (store.availableWorkspaces.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No workspaces yet. Create one to continue.'),
              ),
            )
          else
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
          const SizedBox(height: 12),
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
    setState(() => _isBusy = true);
    final result = await store.createCloudWorkspace(_nameController.text);
    if (!mounted) {
      return;
    }
    setState(() => _isBusy = false);
    _showMessage(result.message ?? 'Workspace request complete.');
    if (result.success) {
      _nameController.clear();
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
}
