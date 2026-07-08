import 'dart:convert';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'sync_models.dart';

enum SyncOutboxStatus { pending, syncing, failed, done, skipped }

enum SyncOutboxOperation { create, update, delete, upsert }

class SyncOutboxEntry {
  const SyncOutboxEntry({
    required this.id,
    required this.workspaceId,
    required this.entity,
    required this.entityId,
    required this.operation,
    this.payload,
    required this.status,
    required this.attempts,
    this.lastError,
    this.nextAttemptAt,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });

  final String id;
  final String workspaceId;
  final CloudSyncEntity entity;
  final String entityId;
  final CloudSyncOperation operation;
  final Map<String, Object?>? payload;
  final SyncOutboxStatus status;
  final int attempts;
  final String? lastError;
  final DateTime? nextAttemptAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  factory SyncOutboxEntry.fromRecord(SyncOutboxRecord record) {
    return SyncOutboxEntry(
      id: record.id,
      workspaceId: record.workspaceId,
      entity: _enumByName(CloudSyncEntity.values, record.entityType),
      entityId: record.entityId,
      operation: _enumByName(CloudSyncOperation.values, record.operation),
      payload: _decodePayload(record.payloadJson),
      status: _enumByName(SyncOutboxStatus.values, record.status),
      attempts: record.attempts,
      lastError: record.lastError,
      nextAttemptAt: record.nextAttemptAt,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      syncedAt: record.syncedAt,
    );
  }
}

class SyncOutboxService {
  const SyncOutboxService({required this.database});

  final AppDatabase database;

  Future<SyncOutboxEntry> enqueueChange({
    required String workspaceId,
    required CloudSyncEntity entity,
    required String entityId,
    required CloudSyncOperation operation,
    Map<String, Object?>? payload,
  }) async {
    final now = DateTime.now();
    final id =
        'outbox-${now.microsecondsSinceEpoch}-${entity.name}-${entityId.hashCode.abs()}';
    final companion = SyncOutboxCompanion.insert(
      id: id,
      workspaceId: workspaceId,
      entityType: entity.name,
      entityId: entityId,
      operation: operation.name,
      payloadJson: Value(_encodePayload(payload)),
      status: const Value('pending'),
      attempts: const Value(0),
      createdAt: now,
      updatedAt: now,
    );
    await database.upsertSyncOutboxEntry(companion);
    final record = await database.getOpenSyncOutboxEntry(
      workspaceId: workspaceId,
      entityType: entity.name,
      entityId: entityId,
    );
    if (record == null) {
      return SyncOutboxEntry(
        id: id,
        workspaceId: workspaceId,
        entity: entity,
        entityId: entityId,
        operation: operation,
        payload: payload,
        status: SyncOutboxStatus.pending,
        attempts: 0,
        createdAt: now,
        updatedAt: now,
      );
    }
    return SyncOutboxEntry.fromRecord(record);
  }

  Future<SyncOutboxEntry> enqueueUniqueChange({
    required String workspaceId,
    required CloudSyncEntity entity,
    required String entityId,
    required CloudSyncOperation operation,
    Map<String, Object?>? payload,
  }) async {
    final existing = await database.getOpenSyncOutboxEntry(
      workspaceId: workspaceId,
      entityType: entity.name,
      entityId: entityId,
    );
    if (existing == null) {
      return enqueueChange(
        workspaceId: workspaceId,
        entity: entity,
        entityId: entityId,
        operation: operation,
        payload: payload,
      );
    }

    final now = DateTime.now();
    final nextOperation = _coalescedOperation(
      existing.operation,
      operation.name,
    );
    if (nextOperation == 'skipped') {
      await markSkipped(
        existing.id,
        'Create was deleted before it reached cloud sync.',
      );
    } else {
      await database.updateSyncOutboxEntry(
        existing.id,
        SyncOutboxCompanion(
          operation: Value(nextOperation),
          payloadJson: Value(_encodePayload(payload)),
          status: const Value('pending'),
          lastError: const Value(null),
          nextAttemptAt: const Value(null),
          updatedAt: Value(now),
        ),
      );
    }
    final record = await database.getOpenSyncOutboxEntry(
      workspaceId: workspaceId,
      entityType: entity.name,
      entityId: entityId,
    );
    if (record == null) {
      return SyncOutboxEntry(
        id: existing.id,
        workspaceId: workspaceId,
        entity: entity,
        entityId: entityId,
        operation: operation,
        status: SyncOutboxStatus.skipped,
        attempts: existing.attempts,
        createdAt: existing.createdAt,
        updatedAt: now,
      );
    }
    return SyncOutboxEntry.fromRecord(record);
  }

  Future<List<SyncOutboxEntry>> getPendingEntries(
    String workspaceId, {
    int limit = 100,
  }) async {
    final records = await database.getPendingSyncOutboxEntries(
      workspaceId,
      limit: limit,
    );
    return records.map(SyncOutboxEntry.fromRecord).toList();
  }

  Future<List<SyncOutboxEntry>> getEntriesForWorkspace(
    String workspaceId,
  ) async {
    final records = await database.getAllSyncOutboxEntries();
    final entries = records
        .where((record) => record.workspaceId == workspaceId)
        .map(SyncOutboxEntry.fromRecord)
        .toList();
    entries.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return entries;
  }

  Future<void> markSyncing(List<String> ids) {
    return database.updateSyncOutboxEntries(
      ids,
      SyncOutboxCompanion(
        status: const Value('syncing'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markDone(String id) {
    final now = DateTime.now();
    return database.updateSyncOutboxEntry(
      id,
      SyncOutboxCompanion(
        status: const Value('done'),
        lastError: const Value(null),
        nextAttemptAt: const Value(null),
        updatedAt: Value(now),
        syncedAt: Value(now),
      ),
    );
  }

  Future<void> markSkipped(String id, String reason) {
    final now = DateTime.now();
    return database.updateSyncOutboxEntry(
      id,
      SyncOutboxCompanion(
        status: const Value('skipped'),
        lastError: Value(reason),
        nextAttemptAt: const Value(null),
        updatedAt: Value(now),
        syncedAt: Value(now),
      ),
    );
  }

  Future<void> markFailed(String id, Object error) async {
    final entries = await database.getAllSyncOutboxEntries();
    SyncOutboxRecord? record;
    for (final entry in entries) {
      if (entry.id == id) {
        record = entry;
        break;
      }
    }
    final attempts = (record?.attempts ?? 0) + 1;
    final now = DateTime.now();
    await database.updateSyncOutboxEntry(
      id,
      SyncOutboxCompanion(
        status: const Value('failed'),
        attempts: Value(attempts),
        lastError: Value(error.toString()),
        nextAttemptAt: Value(_nextAttemptAt(now, attempts)),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> markAllDone(List<SyncOutboxEntry> entries) async {
    for (final entry in entries) {
      await markDone(entry.id);
    }
  }

  Future<void> markAllFailed(
    List<SyncOutboxEntry> entries,
    Object error,
  ) async {
    for (final entry in entries) {
      await markFailed(entry.id, error);
    }
  }

  Future<void> retryFailed(String workspaceId) async {
    final entries = await database.getAllSyncOutboxEntries();
    final now = DateTime.now();
    final ids = entries
        .where(
          (entry) =>
              entry.workspaceId == workspaceId && entry.status == 'failed',
        )
        .map((entry) => entry.id)
        .toList();
    await database.updateSyncOutboxEntries(
      ids,
      SyncOutboxCompanion(
        status: const Value('pending'),
        nextAttemptAt: const Value(null),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> clearDone({Duration olderThan = const Duration(days: 7)}) {
    return database.clearDoneSyncOutboxEntries(
      DateTime.now().subtract(olderThan),
    );
  }

  Future<int> pendingCount(String workspaceId) async {
    final pending = await database.countSyncOutboxEntries(
      workspaceId,
      'pending',
    );
    final syncing = await database.countSyncOutboxEntries(
      workspaceId,
      'syncing',
    );
    return pending + syncing;
  }

  Future<int> failedCount(String workspaceId) {
    return database.countSyncOutboxEntries(workspaceId, 'failed');
  }

  Future<void> resetStuckSyncingEntries() {
    return database.resetStuckSyncOutboxEntries(
      DateTime.now().subtract(const Duration(minutes: 10)),
    );
  }
}

T _enumByName<T extends Enum>(List<T> values, String name) {
  return values.firstWhere(
    (value) => value.name == name,
    orElse: () => values.first,
  );
}

Map<String, Object?>? _decodePayload(String? payloadJson) {
  if (payloadJson == null || payloadJson.trim().isEmpty) {
    return null;
  }
  final decoded = jsonDecode(payloadJson);
  if (decoded is Map<String, dynamic>) {
    return decoded;
  }
  return null;
}

String? _encodePayload(Map<String, Object?>? payload) {
  if (payload == null) {
    return null;
  }
  return jsonEncode(payload);
}

String _coalescedOperation(String existing, String next) {
  if (existing == 'create' && next == 'delete') {
    return 'skipped';
  }
  if (next == 'delete') {
    return 'delete';
  }
  if (existing == 'create') {
    return 'create';
  }
  return next == 'create' ? 'upsert' : next;
}

DateTime _nextAttemptAt(DateTime now, int attempts) {
  return switch (attempts) {
    0 || 1 => now.add(const Duration(seconds: 10)),
    2 => now.add(const Duration(minutes: 1)),
    3 => now.add(const Duration(minutes: 5)),
    _ => now.add(const Duration(minutes: 15)),
  };
}
