import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/models/models.dart';
import '../core/permissions/app_permissions.dart';

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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                        'Unlock to continue.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (activeUsers.isEmpty)
                        const Text(
                          'No active local users are available. Finish setup or create an Admin user.',
                        )
                      else ...[
                        DropdownButtonFormField<String>(
                          initialValue: _selectedUserId,
                          decoration: const InputDecoration(labelText: 'User'),
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
                          decoration: const InputDecoration(labelText: 'PIN'),
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          onSubmitted: (_) => _unlock(store),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _isUnlocking ? null : () => _unlock(store),
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
                      const SizedBox(height: 12),
                      const Text(
                        'Local PIN protection is for shared-device accountability. Cloud login will be added later.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
