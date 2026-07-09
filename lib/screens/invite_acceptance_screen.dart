import 'package:flutter/material.dart';

import '../core/app_store.dart';
import 'cloud_login_screen.dart';

class InviteAcceptanceScreen extends StatefulWidget {
  const InviteAcceptanceScreen({super.key});

  @override
  State<InviteAcceptanceScreen> createState() => _InviteAcceptanceScreenState();
}

class _InviteAcceptanceScreenState extends State<InviteAcceptanceScreen> {
  bool _startedAccept = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = AppStoreScope.of(context);
    if (store.isCloudSignedIn &&
        store.hasPendingInvite &&
        !store.isAcceptingPendingInvite &&
        !_startedAccept) {
      _startedAccept = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          store.acceptPendingInviteAfterSignIn();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final message = store.inviteAcceptanceMessage;
    final error = store.inviteAcceptanceError;

    return Scaffold(
      appBar: AppBar(title: const Text('Workspace Invite')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        error == null
                            ? Icons.mark_email_unread_outlined
                            : Icons.error_outline,
                        size: 36,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _titleFor(store, message, error),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(_bodyFor(store, message, error)),
                      const SizedBox(height: 20),
                      _InviteAction(store: store),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _titleFor(AppStore store, String? message, String? error) {
    if (message != null) {
      return 'Workspace joined';
    }
    if (error != null) {
      return 'Invite could not be accepted';
    }
    if (store.isCloudSignedIn) {
      return 'Accepting invite...';
    }
    return "You've been invited to Issued";
  }

  String _bodyFor(AppStore store, String? message, String? error) {
    if (message != null) {
      final workspaceName = store.pendingInviteWorkspaceName;
      return workspaceName == null
          ? 'Workspace joined.'
          : 'You joined $workspaceName.';
    }
    if (error != null) {
      return error;
    }
    if (store.isCloudSignedIn) {
      return 'Issued is accepting your workspace invite.';
    }
    return 'Sign in with the invited email address to join the workspace.';
  }
}

class _InviteAction extends StatelessWidget {
  const _InviteAction({required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    if (store.inviteAcceptanceMessage != null) {
      return FilledButton(
        onPressed: () => store.clearPendingInvite(),
        child: const Text('Open workspace'),
      );
    }
    if (store.inviteAcceptanceError != null) {
      return Wrap(
        spacing: 8,
        children: [
          FilledButton(
            onPressed: store.hasPendingInvite
                ? () => store.acceptPendingInviteAfterSignIn()
                : null,
            child: const Text('Try again'),
          ),
          OutlinedButton(
            onPressed: () => store.clearPendingInvite(),
            child: const Text('Dismiss'),
          ),
        ],
      );
    }
    if (!store.isCloudSignedIn) {
      return FilledButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const CloudLoginScreen(),
            ),
          );
        },
        child: const Text('Sign in'),
      );
    }
    return const Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Text('Accepting invite...'),
      ],
    );
  }
}
