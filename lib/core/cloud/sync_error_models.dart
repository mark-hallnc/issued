enum SyncErrorKind {
  offline,
  signedOut,
  noWorkspace,
  setupRequired,
  permissionDenied,
  missingMigration,
  missingFunction,
  rlsDenied,
  duplicateRecord,
  conflict,
  validation,
  timeout,
  unknown,
}

class SyncUserError {
  const SyncUserError({
    required this.kind,
    required this.title,
    required this.message,
    this.technicalDetails,
    this.recoveryActionLabel,
    required this.canRetry,
    required this.canOpenDiagnostics,
    required this.createdAt,
  });

  final SyncErrorKind kind;
  final String title;
  final String message;
  final String? technicalDetails;
  final String? recoveryActionLabel;
  final bool canRetry;
  final bool canOpenDiagnostics;
  final DateTime createdAt;

  factory SyncUserError.fromException(
    Object error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    final details = [
      if (context != null && context.trim().isNotEmpty) context,
      error.toString(),
      if (stackTrace != null) stackTrace.toString(),
    ].join('\n');
    final text = details.toLowerCase();

    if (_containsAny(text, [
      'socket',
      'network',
      'offline',
      'failed host lookup',
      'connection',
      'clientexception',
    ])) {
      return SyncUserError(
        kind: SyncErrorKind.offline,
        title: 'You appear to be offline',
        message:
            'You can keep working. Changes will sync when you are online again.',
        technicalDetails: details,
        recoveryActionLabel: 'Try again',
        canRetry: true,
        canOpenDiagnostics: true,
        createdAt: DateTime.now(),
      );
    }
    if (_containsAny(text, ['timeout', 'timed out'])) {
      return SyncUserError(
        kind: SyncErrorKind.timeout,
        title: 'Sync timed out',
        message:
            'You can keep working. Changes will sync when the connection is better.',
        technicalDetails: details,
        recoveryActionLabel: 'Try again',
        canRetry: true,
        canOpenDiagnostics: true,
        createdAt: DateTime.now(),
      );
    }
    if (_containsAny(text, ['not authenticated', 'signed out', 'jwt'])) {
      return SyncUserError(
        kind: SyncErrorKind.signedOut,
        title: 'Sign in to sync',
        message: 'Sign in again before syncing workspace changes.',
        technicalDetails: details,
        recoveryActionLabel: 'Sign in',
        canRetry: false,
        canOpenDiagnostics: false,
        createdAt: DateTime.now(),
      );
    }
    if (_containsAny(text, ['select a workspace', 'workspace is required'])) {
      return SyncUserError(
        kind: SyncErrorKind.noWorkspace,
        title: 'Choose a workspace',
        message: 'Select or create a workspace before syncing.',
        technicalDetails: details,
        recoveryActionLabel: 'Choose workspace',
        canRetry: false,
        canOpenDiagnostics: false,
        createdAt: DateTime.now(),
      );
    }
    if (_containsAny(text, ['setup decision', 'workspace setup'])) {
      return SyncUserError(
        kind: SyncErrorKind.setupRequired,
        title: 'Workspace setup needed',
        message: 'Finish workspace setup before syncing inventory.',
        technicalDetails: details,
        recoveryActionLabel: 'Finish setup',
        canRetry: false,
        canOpenDiagnostics: false,
        createdAt: DateTime.now(),
      );
    }
    if (_containsAny(text, ['rls', 'row-level'])) {
      return SyncUserError(
        kind: SyncErrorKind.rlsDenied,
        title: 'You do not have permission',
        message: 'This workspace does not allow your role to make that change.',
        technicalDetails: details,
        recoveryActionLabel: 'Ask an admin',
        canRetry: false,
        canOpenDiagnostics: true,
        createdAt: DateTime.now(),
      );
    }
    if (_containsAny(text, ['permission denied', 'not allowed', '403'])) {
      return SyncUserError(
        kind: SyncErrorKind.permissionDenied,
        title: 'You do not have permission',
        message: 'This workspace does not allow your role to make that change.',
        technicalDetails: details,
        recoveryActionLabel: 'Ask an admin',
        canRetry: false,
        canOpenDiagnostics: true,
        createdAt: DateTime.now(),
      );
    }
    if (_containsAny(text, [
      'relation',
      'does not exist',
      'schema',
      'column',
      'table',
    ])) {
      return SyncUserError(
        kind: SyncErrorKind.missingMigration,
        title: 'Sync setup needs attention',
        message: 'The cloud database is missing part of the sync setup.',
        technicalDetails: details,
        recoveryActionLabel: 'Open diagnostics',
        canRetry: false,
        canOpenDiagnostics: true,
        createdAt: DateTime.now(),
      );
    }
    if (text.contains('edge function') ||
        text.contains('function not found') ||
        text.contains('function') && text.contains('not found')) {
      return SyncUserError(
        kind: SyncErrorKind.missingFunction,
        title: 'Invite service is not deployed',
        message:
            'The invite service needs to be deployed before invites can be sent.',
        technicalDetails: details,
        recoveryActionLabel: 'Open diagnostics',
        canRetry: false,
        canOpenDiagnostics: true,
        createdAt: DateTime.now(),
      );
    }
    if (_containsAny(text, ['duplicate', 'unique constraint', '23505'])) {
      return SyncUserError(
        kind: SyncErrorKind.duplicateRecord,
        title: 'Duplicate record found',
        message: 'A matching cloud record already exists.',
        technicalDetails: details,
        recoveryActionLabel: 'Open diagnostics',
        canRetry: false,
        canOpenDiagnostics: true,
        createdAt: DateTime.now(),
      );
    }
    if (_containsAny(text, ['conflict', 'needs review'])) {
      return SyncUserError(
        kind: SyncErrorKind.conflict,
        title: 'Sync needs review',
        message: 'Some records changed in more than one place.',
        technicalDetails: details,
        recoveryActionLabel: 'Review conflicts',
        canRetry: true,
        canOpenDiagnostics: true,
        createdAt: DateTime.now(),
      );
    }
    if (_containsAny(text, ['validation', 'invalid', 'required'])) {
      return SyncUserError(
        kind: SyncErrorKind.validation,
        title: 'Sync could not save one change',
        message: 'One change needs to be corrected before it can sync.',
        technicalDetails: details,
        recoveryActionLabel: 'Open diagnostics',
        canRetry: false,
        canOpenDiagnostics: true,
        createdAt: DateTime.now(),
      );
    }

    return SyncUserError(
      kind: SyncErrorKind.unknown,
      title: 'Something went wrong',
      message: 'The app saved what it could. Try again or open diagnostics.',
      technicalDetails: details,
      recoveryActionLabel: 'Try again',
      canRetry: true,
      canOpenDiagnostics: true,
      createdAt: DateTime.now(),
    );
  }
}

bool _containsAny(String text, List<String> needles) {
  return needles.any(text.contains);
}
