import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import 'cloud_adoption_models.dart';
import 'sync_models.dart';
import 'sync_reconciliation_service.dart';

class CloudAdoptionService {
  const CloudAdoptionService({
    required this.database,
    required this.reconciliationService,
  });

  final AppDatabase database;
  final SyncReconciliationService reconciliationService;

  Future<CloudAdoptionSummary> buildAdoptionSummary(
    String workspaceId, {
    String? workspaceName,
  }) async {
    try {
      final decision = await _readDecision(workspaceId);
      final localItemCount = await _localCount(CloudSyncEntity.item);
      final localBalanceCount = await _localCount(
        CloudSyncEntity.inventoryBalance,
      );
      final localTransactionCount = await _localCount(
        CloudSyncEntity.transaction,
      );
      final localCheckoutCount = await _localCount(CloudSyncEntity.checkout);
      final localSupplierCount = await _localCount(CloudSyncEntity.supplier);
      final localPurchasingCount = await _localCount(
        CloudSyncEntity.purchaseOrder,
      );
      final localCycleCountCount = await _localCycleCountTotal();

      final cloudItemCount = await _cloudCount(
        CloudSyncEntity.item,
        workspaceId,
      );
      final cloudBalanceCount = await _cloudCount(
        CloudSyncEntity.inventoryBalance,
        workspaceId,
      );
      final cloudTransactionCount = await _cloudCount(
        CloudSyncEntity.transaction,
        workspaceId,
      );
      final cloudCheckoutCount = await _cloudCount(
        CloudSyncEntity.checkout,
        workspaceId,
      );
      final cloudSupplierCount = await _cloudCount(
        CloudSyncEntity.supplier,
        workspaceId,
      );
      final cloudPurchasingCount = await _cloudCount(
        CloudSyncEntity.purchaseOrder,
        workspaceId,
      );
      final cloudCycleCountCount = await _cloudCycleCountTotal(workspaceId);

      final hasLocalBusinessData =
          localItemCount +
              localBalanceCount +
              localTransactionCount +
              localCheckoutCount +
              localSupplierCount +
              localPurchasingCount +
              localCycleCountCount >
          0;
      final hasCloudBusinessData =
          cloudItemCount +
              cloudBalanceCount +
              cloudTransactionCount +
              cloudCheckoutCount +
              cloudSupplierCount +
              cloudPurchasingCount +
              cloudCycleCountCount >
          0;
      final state = _stateFor(
        decision: decision,
        hasLocalBusinessData: hasLocalBusinessData,
        hasCloudBusinessData: hasCloudBusinessData,
      );
      return CloudAdoptionSummary(
        state: state,
        workspaceId: workspaceId,
        workspaceName: workspaceName,
        localItemCount: localItemCount,
        localBalanceCount: localBalanceCount,
        localTransactionCount: localTransactionCount,
        localCheckoutCount: localCheckoutCount,
        localSupplierCount: localSupplierCount,
        localPurchasingCount: localPurchasingCount,
        localCycleCountCount: localCycleCountCount,
        cloudItemCount: cloudItemCount,
        cloudBalanceCount: cloudBalanceCount,
        cloudTransactionCount: cloudTransactionCount,
        cloudCheckoutCount: cloudCheckoutCount,
        cloudSupplierCount: cloudSupplierCount,
        cloudPurchasingCount: cloudPurchasingCount,
        cloudCycleCountCount: cloudCycleCountCount,
        hasLocalBusinessData: hasLocalBusinessData,
        hasCloudBusinessData: hasCloudBusinessData,
        message: _messageFor(state),
        completedChoice: decision?.choice,
        completedAt: decision?.completedAt,
      );
    } catch (error) {
      return CloudAdoptionSummary(
        state: CloudAdoptionState.error,
        workspaceId: workspaceId,
        workspaceName: workspaceName,
        localItemCount: 0,
        localBalanceCount: 0,
        localTransactionCount: 0,
        localCheckoutCount: 0,
        localSupplierCount: 0,
        localPurchasingCount: 0,
        localCycleCountCount: 0,
        cloudItemCount: 0,
        cloudBalanceCount: 0,
        cloudTransactionCount: 0,
        cloudCheckoutCount: 0,
        cloudSupplierCount: 0,
        cloudPurchasingCount: 0,
        cloudCycleCountCount: 0,
        hasLocalBusinessData: false,
        hasCloudBusinessData: false,
        message: 'Cloud setup status could not be checked: $error',
      );
    }
  }

  Future<bool> hasCompletedAdoption(String workspaceId) async {
    final decision = await _readDecision(workspaceId);
    return decision != null &&
        decision.choice != CloudAdoptionChoice.cancel &&
        decision.choice != CloudAdoptionChoice.keepLocalOnly;
  }

  Future<CloudAdoptionChoice?> adoptionChoice(String workspaceId) async {
    return (await _readDecision(workspaceId))?.choice;
  }

  Future<DateTime?> adoptionCompletedAt(String workspaceId) async {
    return (await _readDecision(workspaceId))?.completedAt;
  }

  Future<void> markAdoptionCompleted(
    String workspaceId,
    CloudAdoptionChoice choice,
  ) {
    return _writeDecision(workspaceId, choice);
  }

  Future<void> clearAdoptionFlagForDebug(String workspaceId) async {
    final file = await _decisionFile(workspaceId);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<bool> shouldShowAdoptionWizard(String workspaceId) async {
    final summary = await buildAdoptionSummary(workspaceId);
    return summary.state == CloudAdoptionState.needsDecision ||
        summary.state == CloudAdoptionState.blocked;
  }

  Future<void> uploadLocalDataToWorkspace(String workspaceId) {
    return _writeDecision(workspaceId, CloudAdoptionChoice.uploadLocalData);
  }

  Future<void> startFreshCloudWorkspace(String workspaceId) {
    return _writeDecision(workspaceId, CloudAdoptionChoice.startFreshCloud);
  }

  Future<int> _localCount(CloudSyncEntity entity) async {
    return await reconciliationService.getLocalEntityCount(entity) ?? 0;
  }

  Future<int> _cloudCount(CloudSyncEntity entity, String workspaceId) async {
    return await reconciliationService.getCloudEntityCount(
          entity,
          workspaceId,
        ) ??
        0;
  }

  Future<int> _localCycleCountTotal() async {
    final sessions = await _localCount(CloudSyncEntity.count);
    final lines = await _localCount(CloudSyncEntity.countLine);
    return sessions + lines;
  }

  Future<int> _cloudCycleCountTotal(String workspaceId) async {
    final sessions = await _cloudCount(CloudSyncEntity.count, workspaceId);
    final lines = await _cloudCount(CloudSyncEntity.countLine, workspaceId);
    return sessions + lines;
  }

  CloudAdoptionState _stateFor({
    required _CloudAdoptionDecision? decision,
    required bool hasLocalBusinessData,
    required bool hasCloudBusinessData,
  }) {
    if (decision != null) {
      return switch (decision.choice) {
        CloudAdoptionChoice.uploadLocalData => CloudAdoptionState.completed,
        CloudAdoptionChoice.startFreshCloud =>
          CloudAdoptionState.startFreshSelected,
        CloudAdoptionChoice.keepLocalOnly =>
          CloudAdoptionState.localOnlySelected,
        CloudAdoptionChoice.cancel => CloudAdoptionState.needsDecision,
      };
    }
    if (!hasLocalBusinessData && !hasCloudBusinessData) {
      return CloudAdoptionState.notNeeded;
    }
    return CloudAdoptionState.needsDecision;
  }

  String _messageFor(CloudAdoptionState state) {
    return switch (state) {
      CloudAdoptionState.notNeeded =>
        'No existing business data needs a setup decision.',
      CloudAdoptionState.needsDecision =>
        'Choose how this device should use the selected workspace.',
      CloudAdoptionState.localOnlySelected =>
        'This device is staying local-only for this workspace.',
      CloudAdoptionState.uploadSelected =>
        'This device is uploading local data.',
      CloudAdoptionState.startFreshSelected =>
        'Existing local data will not be uploaded to this workspace.',
      CloudAdoptionState.completed => 'Cloud setup is complete.',
      CloudAdoptionState.blocked =>
        'Ask an admin or manager to set up this workspace first.',
      CloudAdoptionState.error => 'Cloud setup status could not be checked.',
    };
  }

  Future<_CloudAdoptionDecision?> _readDecision(String workspaceId) async {
    try {
      final file = await _decisionFile(workspaceId);
      if (!await file.exists()) {
        return null;
      }
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final choiceName = decoded['choice']?.toString();
      final completedAtText = decoded['completedAt']?.toString();
      final choice = _choiceByName(choiceName);
      final completedAt = completedAtText == null
          ? null
          : DateTime.tryParse(completedAtText);
      if (choice == null || completedAt == null) {
        return null;
      }
      return _CloudAdoptionDecision(choice: choice, completedAt: completedAt);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeDecision(
    String workspaceId,
    CloudAdoptionChoice choice,
  ) async {
    final file = await _decisionFile(workspaceId);
    await file.writeAsString(
      jsonEncode({
        'workspaceId': workspaceId,
        'choice': choice.name,
        'completedAt': DateTime.now().toUtc().toIso8601String(),
      }),
      flush: true,
    );
  }

  Future<File> _decisionFile(String workspaceId) async {
    final directory = await getApplicationSupportDirectory();
    final safeId = workspaceId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return File(p.join(directory.path, 'issued_cloud_adoption_$safeId.json'));
  }
}

CloudAdoptionChoice? _choiceByName(String? name) {
  for (final choice in CloudAdoptionChoice.values) {
    if (choice.name == name) {
      return choice;
    }
  }
  return null;
}

class _CloudAdoptionDecision {
  const _CloudAdoptionDecision({
    required this.choice,
    required this.completedAt,
  });

  final CloudAdoptionChoice choice;
  final DateTime completedAt;
}
