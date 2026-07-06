import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';

class WorkspaceMembersScreen extends StatefulWidget {
  const WorkspaceMembersScreen({super.key});

  @override
  State<WorkspaceMembersScreen> createState() => _WorkspaceMembersScreenState();
}

class _WorkspaceMembersScreenState extends State<WorkspaceMembersScreen> {
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final store = AppStoreScope.of(context);
      await store.loadWorkspaceMembers();
      await store.loadWorkspaceInvites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final workspace = store.activeWorkspace;
    final isCloudAdmin =
        store.currentCloudRole == CloudWorkspaceRole.owner ||
        store.currentCloudRole == CloudWorkspaceRole.admin;
    final canManage = store.permissions.isAdmin && isCloudAdmin;
    if (workspace == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Members')),
        body: const Center(child: Text('Select a workspace first.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: _isBusy ? null : () => _showInviteDialog(store),
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Invite Member'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          await store.loadWorkspaceMembers();
          await store.loadWorkspaceInvites();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(workspace.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _SectionTitle(
              title: 'Active Members',
              trailing: '${store.workspaceMembers.length}',
            ),
            if (store.workspaceMembers.isEmpty)
              const _EmptyCard(message: 'No members found.')
            else
              for (final member in store.workspaceMembers) ...[
                _MemberCard(
                  member: member,
                  isCurrentUser: member.userId == store.currentCloudUser?.id,
                  canManage: canManage,
                  isLastActiveOwner: _isLastActiveOwner(
                    member,
                    store.workspaceMembers,
                  ),
                  onRoleChanged: (role) => _runAction(
                    store.updateCloudMemberRole(
                      memberId: member.id,
                      role: role,
                    ),
                  ),
                  onDisable: () =>
                      _runAction(store.disableCloudMember(member.id)),
                  onEnable: () =>
                      _runAction(store.enableCloudMember(member.id)),
                ),
                const SizedBox(height: 10),
              ],
            const SizedBox(height: 12),
            _SectionTitle(
              title: 'Pending Invites',
              trailing:
                  '${store.workspaceInvites.where((invite) => invite.status == CloudWorkspaceInviteStatus.pending).length}',
            ),
            if (store.workspaceInvites.isEmpty)
              const _EmptyCard(message: 'No pending invites.')
            else
              for (final invite in store.workspaceInvites) ...[
                _InviteCard(
                  invite: invite,
                  canManage:
                      canManage &&
                      invite.status == CloudWorkspaceInviteStatus.pending,
                  onResend: () =>
                      _runAction(store.resendCloudWorkspaceInvite(invite.id)),
                  onRevoke: () =>
                      _runAction(store.revokeCloudWorkspaceInvite(invite.id)),
                ),
                const SizedBox(height: 10),
              ],
            const SizedBox(height: 72),
          ],
        ),
      ),
    );
  }

  bool _isLastActiveOwner(
    CloudWorkspaceMember member,
    List<CloudWorkspaceMember> members,
  ) {
    if (member.role != CloudWorkspaceRole.owner ||
        member.status != CloudWorkspaceMemberStatus.active) {
      return false;
    }
    final activeOwnerCount = members
        .where(
          (item) =>
              item.role == CloudWorkspaceRole.owner &&
              item.status == CloudWorkspaceMemberStatus.active,
        )
        .length;
    return activeOwnerCount <= 1;
  }

  Future<void> _runAction(Future<AppActionResult> action) async {
    setState(() => _isBusy = true);
    final result = await action;
    if (!mounted) {
      return;
    }
    setState(() => _isBusy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'Workspace updated.')),
    );
  }

  Future<void> _showInviteDialog(AppStore store) async {
    final result = await showDialog<AppActionResult>(
      context: context,
      builder: (dialogContext) {
        return _InviteWorkspaceMemberDialog(
          onInvite: ({required email, required role, displayName}) {
            return store.inviteCloudWorkspaceMember(
              email: email,
              role: role,
              displayName: displayName,
            );
          },
        );
      },
    );
    if (!mounted || result == null) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message ?? 'Invite sent.')));
  }
}

class _InviteWorkspaceMemberDialog extends StatefulWidget {
  const _InviteWorkspaceMemberDialog({required this.onInvite});

  final Future<AppActionResult> Function({
    required String email,
    required CloudWorkspaceRole role,
    String? displayName,
  })
  onInvite;

  @override
  State<_InviteWorkspaceMemberDialog> createState() =>
      _InviteWorkspaceMemberDialogState();
}

class _InviteWorkspaceMemberDialogState
    extends State<_InviteWorkspaceMemberDialog> {
  late final TextEditingController _emailController;
  late final TextEditingController _nameController;
  CloudWorkspaceRole _role = CloudWorkspaceRole.worker;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Invite Member'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Display name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CloudWorkspaceRole>(
              value: _role,
              decoration: const InputDecoration(labelText: 'Role'),
              items:
                  const [
                    CloudWorkspaceRole.admin,
                    CloudWorkspaceRole.manager,
                    CloudWorkspaceRole.worker,
                    CloudWorkspaceRole.viewOnly,
                  ].map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(cloudWorkspaceRoleLabel(item)),
                    );
                  }).toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _role = value);
                      }
                    },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send Invite'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final result = await widget.onInvite(
      email: _emailController.text,
      role: _role,
      displayName: _nameController.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    Navigator.of(context).pop(result);
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.isCurrentUser,
    required this.canManage,
    required this.isLastActiveOwner,
    required this.onRoleChanged,
    required this.onDisable,
    required this.onEnable,
  });

  final CloudWorkspaceMember member;
  final bool isCurrentUser;
  final bool canManage;
  final bool isLastActiveOwner;
  final ValueChanged<CloudWorkspaceRole> onRoleChanged;
  final VoidCallback onDisable;
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    final canChangeRole = canManage && member.role != CloudWorkspaceRole.owner;
    final canChangeStatus = canManage && !isLastActiveOwner;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    member.displayName?.isNotEmpty == true
                        ? member.displayName!
                        : member.email,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (isCurrentUser) const Chip(label: Text('You')),
              ],
            ),
            Text(member.email),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(label: Text(cloudWorkspaceRoleLabel(member.role))),
                Chip(label: Text(member.status.name)),
              ],
            ),
            if (canManage) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: canChangeRole
                        ? DropdownButton<CloudWorkspaceRole>(
                            isExpanded: true,
                            value: member.role,
                            items:
                                const [
                                      CloudWorkspaceRole.admin,
                                      CloudWorkspaceRole.manager,
                                      CloudWorkspaceRole.worker,
                                      CloudWorkspaceRole.viewOnly,
                                    ]
                                    .map(
                                      (role) => DropdownMenuItem(
                                        value: role,
                                        child: Text(
                                          cloudWorkspaceRoleLabel(role),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null) onRoleChanged(value);
                            },
                          )
                        : const Text('Owner role is protected.'),
                  ),
                  const SizedBox(width: 8),
                  if (member.status == CloudWorkspaceMemberStatus.disabled)
                    OutlinedButton(
                      onPressed: canChangeStatus ? onEnable : null,
                      child: const Text('Enable'),
                    )
                  else
                    OutlinedButton(
                      onPressed: canChangeStatus ? onDisable : null,
                      child: const Text('Disable'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard({
    required this.invite,
    required this.canManage,
    required this.onResend,
    required this.onRevoke,
  });

  final CloudWorkspaceInvite invite;
  final bool canManage;
  final VoidCallback onResend;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(invite.email, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(cloudWorkspaceRoleLabel(invite.role)),
            Text('Status: ${cloudWorkspaceInviteStatusLabel(invite.status)}'),
            if (invite.expiresAt != null)
              Text('Expires: ${_shortDate(invite.expiresAt!)}'),
            if (canManage) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: onResend,
                    child: const Text('Resend'),
                  ),
                  OutlinedButton(
                    onPressed: onRevoke,
                    child: const Text('Revoke Invite'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          Text(trailing),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: Text(message)),
    );
  }
}

String _shortDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
