import 'sync_models.dart';
import 'sync_conflict_resolution_models.dart';

enum SyncMergeMode { uploadOnly, downloadOnly, twoWaySafe }

enum SyncMergeDecision {
  createLocal,
  updateLocal,
  skipLocalNewer,
  skipCloudNewerButUnsafe,
  conflict,
  duplicate,
  unsupported,
  deletedOrArchived,
}

class SyncMergeConflict {
  const SyncMergeConflict({
    String? id,
    required this.entityType,
    this.localId,
    this.cloudId,
    this.field,
    this.localValue,
    this.cloudValue,
    this.localUpdatedAt,
    this.cloudUpdatedAt,
    required this.message,
    this.severity = SyncConflictSeverity.warning,
    required this.createdAt,
    this.reviewedAt,
    this.resolvedAt,
    this.resolutionAction,
  }) : id =
           id ??
           '${entityType.name}:${localId ?? ''}:${cloudId ?? ''}:${field ?? ''}:${createdAt.microsecondsSinceEpoch}';

  final String id;
  final CloudSyncEntity entityType;
  final String? localId;
  final String? cloudId;
  final String? field;
  final String? localValue;
  final String? cloudValue;
  final DateTime? localUpdatedAt;
  final DateTime? cloudUpdatedAt;
  final String message;
  final SyncConflictSeverity severity;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final DateTime? resolvedAt;
  final SyncConflictResolutionAction? resolutionAction;

  SyncMergeConflict copyWith({
    DateTime? reviewedAt,
    DateTime? resolvedAt,
    SyncConflictResolutionAction? resolutionAction,
  }) {
    return SyncMergeConflict(
      id: id,
      entityType: entityType,
      localId: localId,
      cloudId: cloudId,
      field: field,
      localValue: localValue,
      cloudValue: cloudValue,
      localUpdatedAt: localUpdatedAt,
      cloudUpdatedAt: cloudUpdatedAt,
      message: message,
      severity: severity,
      createdAt: createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionAction: resolutionAction ?? this.resolutionAction,
    );
  }
}

class SyncMergeSummary {
  const SyncMergeSummary({
    this.createdLocalCount = 0,
    this.updatedLocalCount = 0,
    this.skippedCount = 0,
    this.conflictCount = 0,
    this.duplicateCount = 0,
    this.unsupportedCount = 0,
    this.messages = const [],
    this.conflicts = const [],
  });

  final int createdLocalCount;
  final int updatedLocalCount;
  final int skippedCount;
  final int conflictCount;
  final int duplicateCount;
  final int unsupportedCount;
  final List<String> messages;
  final List<SyncMergeConflict> conflicts;

  int get changedLocalCount => createdLocalCount + updatedLocalCount;

  int get reviewedCount =>
      createdLocalCount +
      updatedLocalCount +
      skippedCount +
      conflictCount +
      duplicateCount +
      unsupportedCount;

  SyncMergeSummary copyWith({
    int? createdLocalCount,
    int? updatedLocalCount,
    int? skippedCount,
    int? conflictCount,
    int? duplicateCount,
    int? unsupportedCount,
    List<String>? messages,
    List<SyncMergeConflict>? conflicts,
  }) {
    return SyncMergeSummary(
      createdLocalCount: createdLocalCount ?? this.createdLocalCount,
      updatedLocalCount: updatedLocalCount ?? this.updatedLocalCount,
      skippedCount: skippedCount ?? this.skippedCount,
      conflictCount: conflictCount ?? this.conflictCount,
      duplicateCount: duplicateCount ?? this.duplicateCount,
      unsupportedCount: unsupportedCount ?? this.unsupportedCount,
      messages: messages ?? this.messages,
      conflicts: conflicts ?? this.conflicts,
    );
  }

  SyncMergeSummary addMessage(String message) {
    return copyWith(messages: [...messages, message]);
  }

  SyncMergeSummary addConflict(SyncMergeConflict conflict) {
    return copyWith(
      conflictCount: conflictCount + 1,
      conflicts: [...conflicts, conflict],
      messages: [...messages, conflict.message],
    );
  }

  SyncMergeSummary increment(SyncMergeDecision decision, {String? message}) {
    final nextMessages = message == null ? messages : [...messages, message];
    return switch (decision) {
      SyncMergeDecision.createLocal => copyWith(
        createdLocalCount: createdLocalCount + 1,
        messages: nextMessages,
      ),
      SyncMergeDecision.updateLocal => copyWith(
        updatedLocalCount: updatedLocalCount + 1,
        messages: nextMessages,
      ),
      SyncMergeDecision.duplicate => copyWith(
        duplicateCount: duplicateCount + 1,
        messages: nextMessages,
      ),
      SyncMergeDecision.unsupported => copyWith(
        unsupportedCount: unsupportedCount + 1,
        messages: nextMessages,
      ),
      SyncMergeDecision.conflict => copyWith(
        conflictCount: conflictCount + 1,
        messages: nextMessages,
      ),
      _ => copyWith(skippedCount: skippedCount + 1, messages: nextMessages),
    };
  }

  SyncMergeSummary merge(SyncMergeSummary other) {
    return SyncMergeSummary(
      createdLocalCount: createdLocalCount + other.createdLocalCount,
      updatedLocalCount: updatedLocalCount + other.updatedLocalCount,
      skippedCount: skippedCount + other.skippedCount,
      conflictCount: conflictCount + other.conflictCount,
      duplicateCount: duplicateCount + other.duplicateCount,
      unsupportedCount: unsupportedCount + other.unsupportedCount,
      messages: [...messages, ...other.messages],
      conflicts: [...conflicts, ...other.conflicts],
    );
  }
}
