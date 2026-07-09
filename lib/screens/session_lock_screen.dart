import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import '../core/permissions/app_permissions.dart';
import 'cloud_login_screen.dart';

class SessionLockScreen extends StatefulWidget {
  const SessionLockScreen({super.key});

  @override
  State<SessionLockScreen> createState() => _SessionLockScreenState();
}

class _SessionLockScreenState extends State<SessionLockScreen> {
  final _pinController = TextEditingController();
  String? _selectedUserId;
  bool _isUnlocking = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final activeUsers = store.users.where((user) => user.isActive).toList();
    _selectedUserId ??= store.currentUser?.id;
    if (_selectedUserId == null && activeUsers.isNotEmpty) {
      _selectedUserId = activeUsers.first.id;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;
            final minHeight = constraints.maxHeight > 48
                ? constraints.maxHeight - 48
                : 0.0;
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + keyboardBottom),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              size: 48,
                              color: Color(0xFF1E3A5F),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Issued',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Unlock Issued',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Use a local user PIN on this shared device.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            if (activeUsers.isEmpty)
                              const Text(
                                'No active local users are available. Finish setup or create an Admin user, or sign in with an account.',
                              )
                            else ...[
                              DropdownButtonFormField<String>(
                                initialValue: _selectedUserId,
                                decoration: const InputDecoration(
                                  labelText: 'User',
                                ),
                                items: [
                                  for (final user in activeUsers)
                                    DropdownMenuItem(
                                      value: user.id,
                                      child: Text(_userLabel(store, user)),
                                    ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedUserId = value;
                                    _pinController.clear();
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _pinController,
                                decoration: const InputDecoration(
                                  labelText: 'PIN',
                                ),
                                obscureText: true,
                                keyboardType: TextInputType.number,
                                onSubmitted: (_) => _unlock(store),
                              ),
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: _isUnlocking
                                    ? null
                                    : () => _unlock(store),
                                icon: _isUnlocking
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.lock_open),
                                label: const Text('Unlock'),
                              ),
                            ],
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 12),
                            const Text(
                              'Invited team members can sign in with their email account.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _isUnlocking ? null : _openCloudLogin,
                              icon: const Icon(Icons.cloud_outlined),
                              label: const Text('Sign in with Account'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openCloudLogin() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const CloudLoginScreen()),
    );
  }

  Future<void> _unlock(AppStore store) async {
    final userId = _selectedUserId;
    if (userId == null) {
      return;
    }
    setState(() {
      _isUnlocking = true;
    });
    final result = await store.unlockSession(userId, _pinController.text);
    if (!mounted) {
      return;
    }
    setState(() {
      _isUnlocking = false;
    });
    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Unable to unlock Issued.')),
      );
    }
  }

  String _userLabel(AppStore store, AppUser user) {
    final person = store.people.where((person) => person.id == user.personId);
    final name = person.isEmpty ? user.email : person.first.displayName;
    return '$name - ${roleLabel(user.role)}';
  }
}
