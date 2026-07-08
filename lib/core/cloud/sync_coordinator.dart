import 'dart:async';

import 'cloud_sync_service.dart';
import 'sync_outbox_service.dart';

enum SyncTrigger {
  login,
  workspaceSelected,
  appResume,
  localChange,
  manual,
  retry,
  startup,
  connectivityRestored,
}

class SyncCoordinator {
  SyncCoordinator({
    required this.syncService,
    required this.outboxService,
    required this.canSync,
    required this.performSync,
    this.debounceDelay = const Duration(seconds: 3),
    this.resumeInterval = const Duration(seconds: 60),
  });

  final CloudSyncService syncService;
  final SyncOutboxService outboxService;
  final bool Function() canSync;
  final Future<void> Function(SyncTrigger trigger) performSync;
  final Duration debounceDelay;
  final Duration resumeInterval;

  bool isSyncing = false;
  bool syncRequestedWhileRunning = false;
  DateTime? lastSyncStartedAt;
  DateTime? lastSyncCompletedAt;
  String? lastSyncError;
  SyncTrigger? lastTrigger;
  int consecutiveFailures = 0;
  Timer? _debounceTimer;

  Future<void> requestSync({
    required SyncTrigger trigger,
    bool immediate = false,
  }) {
    if (immediate) {
      return syncNow(trigger: trigger);
    }
    scheduleDebouncedSync(trigger: trigger);
    return Future.value();
  }

  Future<void> syncNow({required SyncTrigger trigger}) async {
    if (!canSync()) {
      return;
    }
    if (isSyncing) {
      syncRequestedWhileRunning = true;
      return;
    }

    isSyncing = true;
    lastTrigger = trigger;
    lastSyncStartedAt = DateTime.now();
    lastSyncError = null;
    try {
      await performSync(trigger);
      consecutiveFailures = 0;
      lastSyncCompletedAt = DateTime.now();
    } catch (error) {
      consecutiveFailures += 1;
      lastSyncError = _friendlyError(error);
    } finally {
      isSyncing = false;
    }

    if (syncRequestedWhileRunning) {
      syncRequestedWhileRunning = false;
      await syncNow(trigger: trigger);
    }
  }

  void scheduleDebouncedSync({required SyncTrigger trigger}) {
    if (!canSync()) {
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDelay, () {
      unawaited(syncNow(trigger: trigger));
    });
  }

  Future<void> onLogin() {
    return requestSync(trigger: SyncTrigger.login, immediate: true);
  }

  Future<void> onWorkspaceSelected() {
    return requestSync(trigger: SyncTrigger.workspaceSelected, immediate: true);
  }

  Future<void> onAppResumed() {
    final completedAt = lastSyncCompletedAt;
    if (completedAt != null &&
        DateTime.now().difference(completedAt) < resumeInterval) {
      return Future.value();
    }
    return requestSync(trigger: SyncTrigger.appResume, immediate: true);
  }

  void onLocalChange() {
    scheduleDebouncedSync(trigger: SyncTrigger.localChange);
  }

  Future<void> onConnectivityLikelyRestored() {
    return requestSync(
      trigger: SyncTrigger.connectivityRestored,
      immediate: true,
    );
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}

String _friendlyError(Object error) {
  final text = error.toString().toLowerCase();
  if (text.contains('permission') ||
      text.contains('rls') ||
      text.contains('row-level')) {
    return 'You do not have permission to sync this change.';
  }
  if (text.contains('socket') ||
      text.contains('network') ||
      text.contains('offline') ||
      text.contains('failed host lookup')) {
    return 'Offline - changes will sync later.';
  }
  if (text.contains('relation') ||
      text.contains('does not exist') ||
      text.contains('schema')) {
    return 'Sync setup needs attention.';
  }
  if (text.contains('function') && text.contains('not found')) {
    return 'Invite service is not deployed.';
  }
  return 'Sync problem - tap to review.';
}
