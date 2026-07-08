import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/checkout_models.dart';
import 'cloud_auth_service.dart';
import 'cloud_checkout_models.dart';
import 'supabase_config.dart';

class CloudCheckoutSyncResult {
  const CloudCheckoutSyncResult({
    required this.uploadedCount,
    required this.downloadedCount,
    required this.skippedCount,
    required this.isUploadOnly,
  });

  final int uploadedCount;
  final int downloadedCount;
  final int skippedCount;
  final bool isUploadOnly;
}

class CloudCheckoutService {
  const CloudCheckoutService({
    this.authService = const CloudAuthService(),
    this.client,
  });

  final CloudAuthService authService;
  final SupabaseClient? client;

  SupabaseClient? get _client {
    if (!SupabaseConfig.isConfigured) {
      return null;
    }
    return client ?? Supabase.instance.client;
  }

  Future<List<CloudCheckout>> fetchWorkspaceCheckouts(
    String workspaceId, {
    String? status,
    DateTime? since,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    final rows = status == null && since == null
        ? await client
              .from('workspace_checkouts')
              .select()
              .eq('workspace_id', workspaceId)
              .order('checked_out_at', ascending: false)
        : status != null && since == null
        ? await client
              .from('workspace_checkouts')
              .select()
              .eq('workspace_id', workspaceId)
              .eq('status', status)
              .order('checked_out_at', ascending: false)
        : status == null && since != null
        ? await client
              .from('workspace_checkouts')
              .select()
              .eq('workspace_id', workspaceId)
              .gte('updated_at', since.toUtc().toIso8601String())
              .order('checked_out_at', ascending: false)
        : await client
              .from('workspace_checkouts')
              .select()
              .eq('workspace_id', workspaceId)
              .eq('status', status!)
              .gte('updated_at', since!.toUtc().toIso8601String())
              .order('checked_out_at', ascending: false);
    return [
      for (final row in rows as List<dynamic>)
        CloudCheckout.fromJson(row as Map<String, dynamic>),
    ];
  }

  Future<List<CloudCheckout>> fetchOpenWorkspaceCheckouts(
    String workspaceId,
  ) async {
    final checkouts = await fetchWorkspaceCheckouts(workspaceId);
    final open = checkouts.where((checkout) {
      return checkout.status == 'open' ||
          checkout.status == 'checkedOut' ||
          checkout.status == 'partiallyReturned';
    }).toList();
    open.sort((left, right) {
      final leftDue = left.dueAt;
      final rightDue = right.dueAt;
      if (leftDue == null && rightDue == null) {
        return right.checkedOutAt.compareTo(left.checkedOutAt);
      }
      if (leftDue == null) {
        return 1;
      }
      if (rightDue == null) {
        return -1;
      }
      return leftDue.compareTo(rightDue);
    });
    return open;
  }

  Future<CloudCheckout> upsertWorkspaceCheckout(
    CloudCheckout checkout,
  ) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(checkout.workspaceId);
    final row = await client
        .from('workspace_checkouts')
        .upsert(
          checkout.toUpsertJson(),
          onConflict: 'workspace_id,local_checkout_id',
        )
        .select()
        .single();
    return CloudCheckout.fromJson(row);
  }

  Future<int> upsertWorkspaceCheckouts(List<CloudCheckout> checkouts) async {
    if (checkouts.isEmpty) {
      return 0;
    }
    final client = _requireClient();
    _requireUser();
    final workspaceId = checkouts.first.workspaceId;
    _requireWorkspaceId(workspaceId);
    for (final checkout in checkouts) {
      if (checkout.workspaceId != workspaceId) {
        throw ArgumentError('All checkouts must belong to the same workspace.');
      }
    }
    await client.from('workspace_checkouts').upsert([
      for (final checkout in checkouts) checkout.toUpsertJson(),
    ], onConflict: 'workspace_id,local_checkout_id');
    return checkouts.length;
  }

  Future<CloudCheckout?> findCloudCheckoutByLocalId({
    required String workspaceId,
    required String localCheckoutId,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    final row = await client
        .from('workspace_checkouts')
        .select()
        .eq('workspace_id', workspaceId)
        .eq('local_checkout_id', localCheckoutId)
        .maybeSingle();
    if (row == null) {
      return null;
    }
    return CloudCheckout.fromJson(row);
  }

  Future<void> softDeleteWorkspaceCheckout({
    required String workspaceId,
    required String localCheckoutId,
  }) async {
    final client = _requireClient();
    _requireUser();
    _requireWorkspaceId(workspaceId);
    await client
        .from('workspace_checkouts')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('workspace_id', workspaceId)
        .eq('local_checkout_id', localCheckoutId);
  }

  Future<CloudCheckoutSyncResult> pushLocalCheckouts({
    required String workspaceId,
    required List<CheckoutRecord> checkouts,
    Map<String, String?> workspaceItemIdsByLocalItemId = const {},
    String? Function(CheckoutRecord checkout)? checkedOutToLabelFor,
    String? Function(String? personId)? personNameFor,
    String? Function(String? userId)? userNameFor,
    String? Function(String? userId)? userEmailFor,
  }) async {
    _requireWorkspaceId(workspaceId);
    final cloudCheckouts = [
      for (final checkout in checkouts)
        CloudCheckout.fromLocalCheckout(
          workspaceId: workspaceId,
          checkout: checkout,
          workspaceItemId: workspaceItemIdsByLocalItemId[checkout.itemId],
          checkedOutToLabelFor: checkedOutToLabelFor,
          personNameFor: personNameFor,
          userNameFor: userNameFor,
          userEmailFor: userEmailFor,
        ),
    ];
    final uploadedCount = await upsertWorkspaceCheckouts(cloudCheckouts);
    final downloaded = await pullWorkspaceCheckouts(workspaceId);
    return CloudCheckoutSyncResult(
      uploadedCount: uploadedCount,
      downloadedCount: downloaded.length,
      skippedCount: 0,
      isUploadOnly: true,
    );
  }

  Future<List<CloudCheckout>> pullWorkspaceCheckouts(
    String workspaceId, {
    String? status,
    DateTime? since,
  }) {
    return fetchWorkspaceCheckouts(
      workspaceId,
      status: status,
      since: since,
    );
  }

  SupabaseClient _requireClient() {
    final client = _client;
    if (client == null) {
      throw StateError(
        SupabaseConfig.missingConfigMessage ?? 'Supabase is not configured.',
      );
    }
    return client;
  }

  User _requireUser() {
    final user = authService.currentUser;
    if (user == null) {
      throw StateError('Sign in to sync checkouts.');
    }
    return user;
  }

  void _requireWorkspaceId(String workspaceId) {
    if (workspaceId.trim().isEmpty) {
      throw ArgumentError('A workspace is required.');
    }
  }
}
