import 'package:flutter/material.dart';

import '../core/app_store.dart';
import '../core/cloud/supabase_config.dart';
import '../widgets/issued_brand_loading.dart';
import 'invite_acceptance_screen.dart';
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
      appBar: AppBar(title: const SizedBox.shrink()),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                24 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const IssuedBrandLogo(width: 260),
                        const SizedBox(height: 28),
                        if (!store.isCloudConfigured)
                          const _SignInNotConfiguredCard()
                        else if (_codeSent)
                          _CodeEntryState(
                            email: _emailController.text.trim(),
                            codeController: _codeController,
                            isBusy: _isBusy,
                            onVerify: () => _verifyCode(store),
                            onUseDifferentEmail: _useDifferentEmail,
                          )
                        else
                          _EmailEntryState(
                            emailController: _emailController,
                            hasPendingInvite: store.hasPendingInvite,
                            isBusy: _isBusy,
                            onLogIn: () => _sendCode(store),
                          ),
                      ],
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

  Future<void> _sendCode(AppStore store) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Enter your email address.');
      return;
    }
    setState(() => _isBusy = true);
    final result = await store.signInWithEmailOtp(email);
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
    if (_codeController.text.trim().isEmpty) {
      _showMessage('Enter the code we emailed to you.');
      return;
    }
    setState(() => _isBusy = true);
    final result = await store.verifyEmailOtp(
      _emailController.text.trim(),
      _codeController.text.trim(),
    );
    if (!mounted) {
      return;
    }
    setState(() => _isBusy = false);
    _showMessage(
      result.message ?? (result.success ? 'Signed in.' : 'Sign in failed.'),
    );
    if (result.success) {
      final destination = await store.completeSignInAndResolveDestination();
      if (!mounted) {
        return;
      }
      _openDestination(destination);
    }
  }

  void _openDestination(PostLoginDestination destination) {
    switch (destination) {
      case PostLoginDestination.dashboard:
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        return;
      case PostLoginDestination.chooseOrganization:
      case PostLoginDestination.createOrganization:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => const WorkspaceSelectionScreen(),
          ),
        );
        return;
      case PostLoginDestination.inviteAcceptance:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => const InviteAcceptanceScreen(),
          ),
        );
        return;
      case PostLoginDestination.signIn:
        return;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _useDifferentEmail() {
    setState(() {
      _codeSent = false;
      _codeController.clear();
    });
  }
}

class _EmailEntryState extends StatelessWidget {
  const _EmailEntryState({
    required this.emailController,
    required this.hasPendingInvite,
    required this.isBusy,
    required this.onLogIn,
  });

  final TextEditingController emailController;
  final bool hasPendingInvite;
  final bool isBusy;
  final VoidCallback onLogIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sign in to manage your inventory',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email and we\'ll send you a sign-in code.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (hasPendingInvite) ...[
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
                      "You've been invited. Sign in with the email that received the invite.",
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(labelText: 'Email'),
          onSubmitted: (_) {
            if (!isBusy) {
              onLogIn();
            }
          },
        ),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: isBusy ? null : onLogIn,
          child: _ButtonLabel(isBusy: isBusy, label: 'Log in'),
        ),
      ],
    );
  }
}

class _CodeEntryState extends StatelessWidget {
  const _CodeEntryState({
    required this.email,
    required this.codeController,
    required this.isBusy,
    required this.onVerify,
    required this.onUseDifferentEmail,
  });

  final String email;
  final TextEditingController codeController;
  final bool isBusy;
  final VoidCallback onVerify;
  final VoidCallback onUseDifferentEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Code sent to $email',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the code we emailed to you.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.oneTimeCode],
          decoration: const InputDecoration(labelText: 'Code'),
          onSubmitted: (_) {
            if (!isBusy) {
              onVerify();
            }
          },
        ),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: isBusy ? null : onVerify,
          child: _ButtonLabel(isBusy: isBusy, label: 'Verify code'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: isBusy ? null : onUseDifferentEmail,
          child: const Text('Use a different email'),
        ),
      ],
    );
  }
}

class _SignInNotConfiguredCard extends StatelessWidget {
  const _SignInNotConfiguredCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Account sign-in is not configured on this build.'),
            const SizedBox(height: 8),
            const Text('Expected dart-defines:'),
            const Text('SUPABASE_URL'),
            const Text('SUPABASE_ANON_KEY'),
            if (SupabaseConfig.missingConfigMessage != null) ...[
              const SizedBox(height: 12),
              Text(SupabaseConfig.missingConfigMessage!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({required this.isBusy, required this.label});

  final bool isBusy;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (!isBusy) {
      return Text(label);
    }
    return const SizedBox(
      height: 18,
      width: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}
