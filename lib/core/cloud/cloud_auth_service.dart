import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

class CloudAuthResult {
  const CloudAuthResult({required this.success, this.message});

  const CloudAuthResult.success({this.message}) : success = true;

  const CloudAuthResult.failure(this.message) : success = false;

  final bool success;
  final String? message;
}

class CloudAuthService {
  const CloudAuthService();

  bool get isConfigured => SupabaseConfig.isConfigured;

  SupabaseClient? get _client {
    if (!isConfigured) {
      return null;
    }
    return Supabase.instance.client;
  }

  Session? get currentSession => _client?.auth.currentSession;

  User? get currentUser => _client?.auth.currentUser;

  Stream<dynamic> get authStateChanges {
    final client = _client;
    if (client == null) {
      return const Stream<dynamic>.empty();
    }
    return client.auth.onAuthStateChange;
  }

  Future<CloudAuthResult> signInWithEmailOtp(String email) async {
    final client = _client;
    final normalizedEmail = email.trim();
    if (client == null) {
      return CloudAuthResult.failure(SupabaseConfig.missingConfigMessage);
    }
    if (!_looksLikeEmail(normalizedEmail)) {
      return const CloudAuthResult.failure('Enter a valid email address.');
    }
    try {
      // Supabase Auth is the login-code flow. Its email template must include
      // {{ .Token }} so users can type the code shown in CloudLoginScreen.
      // Workspace invite emails are sent separately by the invite Edge Function.
      await client.auth.signInWithOtp(email: normalizedEmail);
      return const CloudAuthResult.success(message: 'Email code sent.');
    } on AuthException catch (error) {
      return CloudAuthResult.failure(error.message);
    } catch (_) {
      return const CloudAuthResult.failure('Could not send email code.');
    }
  }

  Future<CloudAuthResult> verifyOtp({
    required String email,
    required String token,
  }) async {
    final client = _client;
    final normalizedEmail = email.trim();
    final normalizedToken = token.trim();
    if (client == null) {
      return CloudAuthResult.failure(SupabaseConfig.missingConfigMessage);
    }
    if (!_looksLikeEmail(normalizedEmail) || normalizedToken.isEmpty) {
      return const CloudAuthResult.failure('Enter the email code.');
    }
    try {
      await client.auth.verifyOTP(
        type: OtpType.email,
        email: normalizedEmail,
        token: normalizedToken,
      );
      return const CloudAuthResult.success(message: 'Signed in.');
    } on AuthException catch (error) {
      return CloudAuthResult.failure(error.message);
    } catch (_) {
      return const CloudAuthResult.failure('Could not verify email code.');
    }
  }

  Future<CloudAuthResult> refreshSession() async {
    final client = _client;
    if (client == null) {
      return CloudAuthResult.failure(SupabaseConfig.missingConfigMessage);
    }
    try {
      await client.auth.refreshSession();
      return const CloudAuthResult.success();
    } on AuthException catch (error) {
      return CloudAuthResult.failure(error.message);
    } catch (_) {
      return const CloudAuthResult.failure('Could not refresh cloud session.');
    }
  }

  Future<CloudAuthResult> signOut() async {
    final client = _client;
    if (client == null) {
      return const CloudAuthResult.success();
    }
    try {
      await client.auth.signOut();
      return const CloudAuthResult.success(message: 'Signed out.');
    } on AuthException catch (error) {
      return CloudAuthResult.failure(error.message);
    } catch (_) {
      return const CloudAuthResult.failure('Could not sign out.');
    }
  }
}

bool _looksLikeEmail(String value) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
}
