import 'sync_qa_models.dart';

class SyncQaService {
  const SyncQaService();

  SyncQaSession buildChecklist(String workspaceId, {String? workspaceName}) {
    final now = DateTime.now();
    return SyncQaSession(
      workspaceId: workspaceId,
      workspaceName: workspaceName,
      startedAt: now,
      updatedAt: now,
      checks: _defaultChecks(),
    );
  }

  Future<SyncQaSession> runAutomatedChecks({
    required SyncQaSession session,
    required bool isSignedIn,
    required bool hasWorkspace,
    required bool hasMembership,
    required String? roleLabel,
    required bool hasSyncCoordinator,
    required String? latestFriendlyError,
    required Future<int> Function() readPendingOutboxCount,
    required Future<int> Function() readFailedOutboxCount,
    required Future<int> Function() readLocalItemCount,
    required Future<int?> Function() readCloudItemCount,
    required Future<void> Function() loadReconciliation,
  }) async {
    var next = _mark(
      session,
      'signed-in',
      _passFail(isSignedIn),
      isSignedIn ? 'Signed in.' : 'No cloud user is signed in.',
    );
    next = _mark(
      next,
      'workspace-selected',
      _passFail(hasWorkspace),
      hasWorkspace ? 'Workspace selected.' : 'No active workspace.',
    );
    next = _mark(
      next,
      'membership-loaded',
      _passFail(hasMembership),
      hasMembership ? 'Workspace role loaded.' : 'No active membership role.',
    );
    next = _mark(
      next,
      'role-loaded',
      roleLabel == null ? SyncQaCheckStatus.warning : SyncQaCheckStatus.passed,
      roleLabel ?? 'Role label unavailable.',
    );
    next = _mark(
      next,
      'sync-coordinator',
      _passFail(hasSyncCoordinator),
      hasSyncCoordinator ? 'Coordinator is available.' : 'Coordinator missing.',
    );
    next = _mark(
      next,
      'latest-error-readable',
      latestFriendlyError == null
          ? SyncQaCheckStatus.passed
          : SyncQaCheckStatus.warning,
      latestFriendlyError ?? 'No current sync error.',
    );

    next = await _runCountCheck(
      next,
      'pending-outbox-readable',
      readPendingOutboxCount,
      'Pending uploads can be read.',
    );
    next = await _runCountCheck(
      next,
      'failed-outbox-readable',
      readFailedOutboxCount,
      'Failed uploads can be read.',
    );
    next = await _runCountCheck(
      next,
      'local-item-count-loads',
      readLocalItemCount,
      'Local item count can be read.',
    );
    next = await _runNullableCountCheck(
      next,
      'cloud-item-count-loads',
      readCloudItemCount,
      'Cloud item count can be read.',
      hasWorkspace,
    );

    try {
      await loadReconciliation();
      next = _mark(
        next,
        'reconciliation-loads',
        SyncQaCheckStatus.passed,
        'Reconciliation summary loaded.',
      );
    } catch (error) {
      next = _mark(
        next,
        'reconciliation-loads',
        SyncQaCheckStatus.failed,
        'Could not load reconciliation: $error',
      );
    }

    return next.copyWith(updatedAt: DateTime.now());
  }

  SyncQaSession markCheckStatus(
    SyncQaSession session,
    String checkId,
    SyncQaCheckStatus status, {
    String? details,
  }) {
    return _mark(session, checkId, status, details);
  }

  SyncQaSession resetChecklist(SyncQaSession session) {
    return buildChecklist(
      session.workspaceId,
      workspaceName: session.workspaceName,
    );
  }

  String buildShareText(SyncQaSession session) {
    final buffer = StringBuffer()
      ..writeln('Sync QA Checklist')
      ..writeln('Workspace: ${session.workspaceName ?? session.workspaceId}')
      ..writeln('Updated: ${session.updatedAt.toIso8601String()}')
      ..writeln(
        'Passed ${session.passedCount}, warnings ${session.warningCount}, '
        'failed ${session.failedCount}, skipped ${session.skippedCount}, '
        'total ${session.totalCount}',
      )
      ..writeln();
    for (final category in SyncQaCheckCategory.values) {
      final checks = session.checks
          .where((check) => check.category == category)
          .toList();
      if (checks.isEmpty) continue;
      buffer.writeln(syncQaCheckCategoryLabel(category));
      for (final check in checks) {
        buffer.writeln(
          '- [${syncQaCheckStatusLabel(check.status)}] ${check.title}',
        );
        if (check.details != null && check.details!.isNotEmpty) {
          buffer.writeln('  ${check.details}');
        }
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  Future<SyncQaSession> _runCountCheck(
    SyncQaSession session,
    String checkId,
    Future<int> Function() readCount,
    String successMessage,
  ) async {
    try {
      final count = await readCount();
      return _mark(
        session,
        checkId,
        SyncQaCheckStatus.passed,
        '$successMessage Count: $count.',
      );
    } catch (error) {
      return _mark(
        session,
        checkId,
        SyncQaCheckStatus.failed,
        'Could not read count: $error',
      );
    }
  }

  Future<SyncQaSession> _runNullableCountCheck(
    SyncQaSession session,
    String checkId,
    Future<int?> Function() readCount,
    String successMessage,
    bool shouldRun,
  ) async {
    if (!shouldRun) {
      return _mark(
        session,
        checkId,
        SyncQaCheckStatus.skipped,
        'Skipped until a workspace is selected.',
      );
    }
    try {
      final count = await readCount();
      if (count == null) {
        return _mark(
          session,
          checkId,
          SyncQaCheckStatus.warning,
          'Count is unavailable.',
        );
      }
      return _mark(
        session,
        checkId,
        SyncQaCheckStatus.passed,
        '$successMessage Count: $count.',
      );
    } catch (error) {
      return _mark(
        session,
        checkId,
        SyncQaCheckStatus.failed,
        'Could not read count: $error',
      );
    }
  }

  SyncQaSession _mark(
    SyncQaSession session,
    String checkId,
    SyncQaCheckStatus status,
    String? details,
  ) {
    final now = DateTime.now();
    final checks = session.checks.map((check) {
      if (check.id != checkId) return check;
      return check.copyWith(status: status, details: details, lastRunAt: now);
    }).toList();
    return session.copyWith(updatedAt: now, checks: checks);
  }

  SyncQaCheckStatus _passFail(bool value) {
    return value ? SyncQaCheckStatus.passed : SyncQaCheckStatus.failed;
  }

  List<SyncQaCheck> _defaultChecks() {
    return const [
      SyncQaCheck(
        id: 'signed-in',
        category: SyncQaCheckCategory.auth,
        title: 'Cloud user is signed in',
        description: 'Verifies the current device has a cloud session.',
        expectedResult: 'A signed-in cloud user is available.',
        status: SyncQaCheckStatus.ready,
      ),
      SyncQaCheck(
        id: 'workspace-selected',
        category: SyncQaCheckCategory.workspace,
        title: 'Workspace is selected',
        description: 'Verifies the device has an active workspace.',
        expectedResult: 'The active workspace is loaded.',
        status: SyncQaCheckStatus.ready,
      ),
      SyncQaCheck(
        id: 'membership-loaded',
        category: SyncQaCheckCategory.workspace,
        title: 'Membership is active',
        description: 'Verifies the signed-in user has a workspace role.',
        expectedResult: 'The user has an active workspace membership.',
        status: SyncQaCheckStatus.ready,
      ),
      SyncQaCheck(
        id: 'role-loaded',
        category: SyncQaCheckCategory.permissions,
        title: 'Role is loaded',
        description: 'Checks whether the effective workspace role is visible.',
        expectedResult: 'Owner, admin, manager, worker, or view-only is shown.',
        status: SyncQaCheckStatus.ready,
      ),
      SyncQaCheck(
        id: 'sync-coordinator',
        category: SyncQaCheckCategory.setup,
        title: 'Automatic sync coordinator is available',
        description: 'Verifies automatic sync scheduling is wired.',
        expectedResult: 'Coordinator exists and can accept sync requests.',
        status: SyncQaCheckStatus.ready,
      ),
      SyncQaCheck(
        id: 'latest-error-readable',
        category: SyncQaCheckCategory.diagnostics,
        title: 'Friendly sync error state is readable',
        description: 'Checks whether the latest friendly error can be shown.',
        expectedResult: 'No crash when reading the current sync error.',
        status: SyncQaCheckStatus.ready,
      ),
      SyncQaCheck(
        id: 'pending-outbox-readable',
        category: SyncQaCheckCategory.diagnostics,
        title: 'Pending upload count is readable',
        description: 'Reads durable sync queue pending count.',
        expectedResult: 'A pending count is returned.',
        status: SyncQaCheckStatus.ready,
      ),
      SyncQaCheck(
        id: 'failed-outbox-readable',
        category: SyncQaCheckCategory.diagnostics,
        title: 'Failed upload count is readable',
        description: 'Reads durable sync queue failed count.',
        expectedResult: 'A failed count is returned.',
        status: SyncQaCheckStatus.ready,
      ),
      SyncQaCheck(
        id: 'local-item-count-loads',
        category: SyncQaCheckCategory.catalog,
        title: 'Local item count loads',
        description: 'Reads local item catalog count.',
        expectedResult: 'A local item count is returned.',
        status: SyncQaCheckStatus.ready,
      ),
      SyncQaCheck(
        id: 'cloud-item-count-loads',
        category: SyncQaCheckCategory.catalog,
        title: 'Cloud item count loads',
        description: 'Reads cloud item catalog count through RLS.',
        expectedResult:
            'A cloud item count is returned or permission fails clearly.',
        status: SyncQaCheckStatus.ready,
      ),
      SyncQaCheck(
        id: 'reconciliation-loads',
        category: SyncQaCheckCategory.diagnostics,
        title: 'Reconciliation summary loads',
        description: 'Loads the sync health summary.',
        expectedResult: 'The summary loads without crashing.',
        status: SyncQaCheckStatus.ready,
      ),
      SyncQaCheck(
        id: 'owner-create-item-device-a',
        category: SyncQaCheckCategory.catalog,
        title: 'Owner creates item on device A',
        description: 'Manual multi-device catalog creation test.',
        expectedResult: 'Device A saves the item and queues/syncs it.',
        status: SyncQaCheckStatus.notStarted,
        manualSteps: [
          'Sign in as owner on device A.',
          'Create an item named QA TEST - Item.',
          'Wait for the sync indicator to settle.',
        ],
        troubleshooting: [
          'If save is denied, check owner membership and item RLS policies.',
          'If sync stays pending, open Sync Health diagnostics.',
        ],
      ),
      SyncQaCheck(
        id: 'device-b-sees-item',
        category: SyncQaCheckCategory.catalog,
        title: 'Device B sees new item',
        description: 'Manual cloud-to-local item pull test.',
        expectedResult: 'Device B shows the item after sync.',
        status: SyncQaCheckStatus.notStarted,
        manualSteps: [
          'Sign in to the same workspace on device B.',
          'Let automatic sync run or use diagnostics Sync now.',
          'Confirm QA TEST - Item appears once.',
        ],
      ),
      SyncQaCheck(
        id: 'owner-edit-item',
        category: SyncQaCheckCategory.catalog,
        title: 'Item edits propagate',
        description: 'Manual catalog update test.',
        expectedResult: 'Device B receives the edited item name or SKU.',
        status: SyncQaCheckStatus.notStarted,
        manualSteps: [
          'Edit the QA TEST item on device A.',
          'Confirm device B receives the same metadata.',
        ],
      ),
      SyncQaCheck(
        id: 'owner-receive-stock',
        category: SyncQaCheckCategory.inventory,
        title: 'Owner receives stock',
        description: 'Manual balance and movement sync test.',
        expectedResult: 'Quantity and movement history sync to cloud.',
        status: SyncQaCheckStatus.notStarted,
        manualSteps: [
          'Receive or adjust stock for the QA TEST item on device A.',
          'Confirm device A shows the new quantity.',
        ],
      ),
      SyncQaCheck(
        id: 'device-b-sees-quantity',
        category: SyncQaCheckCategory.inventory,
        title: 'Device B sees quantity',
        description: 'Manual inventory balance download test.',
        expectedResult: 'Device B shows the updated current quantity.',
        status: SyncQaCheckStatus.notStarted,
      ),
      SyncQaCheck(
        id: 'worker-checkout',
        category: SyncQaCheckCategory.checkout,
        title: 'Worker checks out item',
        description: 'Manual role-aware checkout sync test.',
        expectedResult:
            'Allowed worker checkout syncs; denied worker sees friendly error.',
        status: SyncQaCheckStatus.notStarted,
      ),
      SyncQaCheck(
        id: 'owner-sees-checkout',
        category: SyncQaCheckCategory.checkout,
        title: 'Owner sees checkout',
        description: 'Manual checkout visibility test.',
        expectedResult: 'Owner can see the worker checkout record.',
        status: SyncQaCheckStatus.notStarted,
      ),
      SyncQaCheck(
        id: 'worker-return',
        category: SyncQaCheckCategory.checkout,
        title: 'Worker returns item',
        description: 'Manual return status sync test.',
        expectedResult: 'Returned status appears on owner device.',
        status: SyncQaCheckStatus.notStarted,
      ),
      SyncQaCheck(
        id: 'offline-edit',
        category: SyncQaCheckCategory.offline,
        title: 'Offline edit stays local',
        description: 'Manual offline durability test.',
        expectedResult: 'Change is saved locally and waits to sync later.',
        status: SyncQaCheckStatus.notStarted,
        manualSteps: [
          'Turn off network on one device.',
          'Make a small QA TEST metadata edit.',
          'Confirm the app remains usable and shows a waiting/offline status.',
        ],
      ),
      SyncQaCheck(
        id: 'reconnect-catches-up',
        category: SyncQaCheckCategory.offline,
        title: 'Reconnect catches up',
        description: 'Manual retry and recovery test.',
        expectedResult: 'Pending offline change syncs after reconnect.',
        status: SyncQaCheckStatus.notStarted,
      ),
      SyncQaCheck(
        id: 'restricted-costs',
        category: SyncQaCheckCategory.permissions,
        title: 'Restricted users cannot see costs',
        description: 'Manual cost privacy smoke test.',
        expectedResult:
            'Worker/view-only users do not see cost values or cost exports.',
        status: SyncQaCheckStatus.notStarted,
      ),
      SyncQaCheck(
        id: 'view-only-readonly',
        category: SyncQaCheckCategory.permissions,
        title: 'View-only user cannot edit',
        description: 'Manual permission enforcement test.',
        expectedResult:
            'Edit controls are hidden/disabled and writes are denied.',
        status: SyncQaCheckStatus.notStarted,
      ),
      SyncQaCheck(
        id: 'invite-new-user',
        category: SyncQaCheckCategory.auth,
        title: 'Invite flow works',
        description: 'Manual invite and membership test.',
        expectedResult: 'New user accepts invite and sees correct role.',
        status: SyncQaCheckStatus.notStarted,
      ),
      SyncQaCheck(
        id: 'last-owner-protected',
        category: SyncQaCheckCategory.permissions,
        title: 'Last owner cannot be removed',
        description: 'Manual owner safety test.',
        expectedResult: 'Demoting/disabling the last owner is blocked.',
        status: SyncQaCheckStatus.notStarted,
      ),
      SyncQaCheck(
        id: 'supplier-purchasing-sync',
        category: SyncQaCheckCategory.purchasing,
        title: 'Supplier and purchasing records sync',
        description: 'Manual purchasing workflow sync test.',
        expectedResult:
            'Supplier and reorder changes appear on another admin device.',
        status: SyncQaCheckStatus.notStarted,
      ),
      SyncQaCheck(
        id: 'cycle-count-sync',
        category: SyncQaCheckCategory.counts,
        title: 'Cycle count session syncs',
        description: 'Manual count session and line sync test.',
        expectedResult:
            'Count status and lines appear on another admin device.',
        status: SyncQaCheckStatus.notStarted,
      ),
      SyncQaCheck(
        id: 'conflict-review',
        category: SyncQaCheckCategory.conflicts,
        title: 'Conflict can be reviewed',
        description: 'Manual conflict visibility and resolution test.',
        expectedResult:
            'Conflict appears in diagnostics and can be marked reviewed.',
        status: SyncQaCheckStatus.notStarted,
      ),
      SyncQaCheck(
        id: 'failed-retry',
        category: SyncQaCheckCategory.diagnostics,
        title: 'Failed sync entry can retry',
        description: 'Manual recovery action test.',
        expectedResult:
            'Retry failed returns entries to pending or syncs them.',
        status: SyncQaCheckStatus.notStarted,
      ),
      SyncQaCheck(
        id: 'permission-denied-friendly',
        category: SyncQaCheckCategory.diagnostics,
        title: 'Permission denied is friendly',
        description: 'Manual error messaging test.',
        expectedResult: 'Normal UI shows a friendly permission message.',
        status: SyncQaCheckStatus.notStarted,
      ),
      SyncQaCheck(
        id: 'missing-migration-friendly',
        category: SyncQaCheckCategory.diagnostics,
        title: 'Missing migration error is friendly',
        description: 'Manual setup failure messaging test.',
        expectedResult:
            'Diagnostics show technical detail; normal UI stays simple.',
        status: SyncQaCheckStatus.notStarted,
      ),
    ];
  }
}
