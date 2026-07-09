import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/cloud/supabase_config.dart';
import 'workspace_selection_screen.dart';

class CloudLoginScreen extends StatefulWidget {
  const CloudLoginScreen({super.key});

  @override
  State<CloudLoginScreen> createState() => _CloudLoginScreenState();
}

class _CloudLoginScreenState extends State<CloudLoginScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSent = false;
  bool _isBusy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in to Issued')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!store.isCloudConfigured) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Cloud sign-in is not configured on this build.'),
                    SizedBox(height: 8),
                    Text('Expected dart-defines:'),
                    Text('SUPABASE_URL'),
                    Text('SUPABASE_ANON_KEY'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            if (store.hasPendingInvite) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.mark_email_unread_outlined),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You have an invitation waiting. Sign in with the invited email to continue.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isBusy ? null : () => _sendCode(store),
              child: const Text('Send login code'),
            ),
            if (_codeSent) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Email Code'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _isBusy ? null : () => _verifyCode(store),
                child: const Text('Verify code'),
              ),
            ],
          ],
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              store.disableCloudModeAndUseLocalOnly();
              Navigator.of(context).pop();
            },
            child: const Text('Use this device without cloud'),
          ),
          if (!store.isCloudConfigured &&
              SupabaseConfig.missingConfigMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(SupabaseConfig.missingConfigMessage!),
            ),
        ],
      ),
    );
  }

  Future<void> _sendCode(AppStore store) async {
    setState(() => _isBusy = true);
    final result = await store.signInWithEmailOtp(_emailController.text);
    if (!mounted) {
      return;
    }
    setState(() {
      _isBusy = false;
      _codeSent = result.success || _codeSent;
    });
    _showMessage(result.message ?? 'Email code sent.');
  }

  Future<void> _verifyCode(AppStore store) async {
    setState(() => _isBusy = true);
    final result = await store.verifyEmailOtp(
      _emailController.text,
      _codeController.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isBusy = false);
    _showMessage(
      result.message ?? (result.success ? 'Signed in.' : 'Sign in failed.'),
    );
    if (result.success) {
      if (store.shouldShowInviteAcceptance) {
        Navigator.of(context).pop();
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => const WorkspaceSelectionScreen(),
        ),
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
