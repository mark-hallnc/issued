import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../models/checkout_models.dart';
import '../models/cloud_models.dart';
import '../models/cycle_count_models.dart';
import '../models/inventory_models.dart';
import '../models/item_location_balance_models.dart';
import '../models/reorder_models.dart';
import '../models/supplier_models.dart';
import 'cloud_auth_service.dart';
import 'cloud_checkout_service.dart';
import 'cloud_cycle_count_service.dart';
import 'cloud_inventory_balance_service.dart';
import 'cloud_inventory_transaction_service.dart';
import 'cloud_item_service.dart';
import 'cloud_purchasing_service.dart';
import 'cloud_supplier_service.dart';
import 'cloud_to_local_apply_service.dart';
import 'supabase_config.dart';
import 'sync_merge_models.dart';
import 'sync_models.dart';
import 'sync_outbox_service.dart';
import 'workspace_service.dart';

class CloudSyncService {
  CloudSyncService({
    required this.workspaceService,
    required this.database,
    this.authService = const CloudAuthService(),
    CloudCheckoutService? checkoutService,
    CloudInventoryBalanceService? balanceService,
    CloudInventoryTransactionService? transactionService,
    CloudItemService? itemService,
    CloudPurchasingService? purchasingService,
    CloudSupplierService? supplierService,
    CloudCycleCountService? cycleCountService,
    CloudToLocalApplyService? applyService,
    SyncOutboxService? outboxService,
    this.client,
  }) : checkoutService =
           checkoutService ?? CloudCheckoutService(authService: authService),
       cycleCountService =
           cycleCountService ??
           CloudCycleCountService(authService: authService),
       balanceService =
           balanceService ??
           CloudInventoryBalanceService(authService: authService),
       transactionService =
           transactionService ??
           CloudInventoryTransactionService(authService: authService),
       itemService = itemService ?? CloudItemService(authService: authService),
       purchasingService =
           purchasingService ??
           CloudPurchasingService(authService: authService),
       supplierService =
           supplierService ?? CloudSupplierService(authService: authService),
       applyService =
           applyService ?? CloudToLocalApplyService(database: database),
       outboxService = outboxService ?? SyncOutboxService(database: database);

  final WorkspaceService workspaceService;
  final AppDatabase database;
  final CloudAuthService authService;
  final CloudCheckoutService checkoutService;
  final CloudCycleCountService cycleCountService;
  final CloudInventoryBalanceService balanceService;
  final CloudInventoryTransactionService transactionService;
  final CloudItemService itemService;
  final CloudPurchasingService purchasingService;
  final CloudSupplierService supplierService;
  final CloudToLocalApplyService applyService;
  final SyncOutboxService outboxService;
  final SupabaseClient? client;

  CloudSyncSummary _summary = CloudSyncSummary.disabled();
  String? _activeWorkspaceId;
  String? _activeWorkspaceName;
  bool _paused = false;
  bool _isSyncing = false;
  bool _syncAgainAfterCurrent = false;
  final List<SyncMergeConflict> _mergeConflicts = [];
  final Map<String, DateTime> _lastPullAtByWorkspace = {};
  final Map<String, DateTime> _lastPushAtByWorkspace = {};
  final Map<String, DateTime> _lastFullSyncAtByWorkspace = {};

  SupabaseClient? get _client {
    if (!SupabaseConfig.isConfigured) {
      return null;
    }
    return client ?? Supabase.instance.client;
  }

  CloudSyncSummary getSyncSummary() => _summary;

  List<SyncMergeConflict> getMergeConflicts() =>
      List.unmodifiable(_mergeConflicts);

  DateTime? getLastPullAt([String? workspaceId]) {
    final id = workspaceId ?? _activeWorkspaceId;
    if (id == null) {
      return null;
    }
    return _lastPullAtByWorkspace[id];
  }

  DateTime? getLastPushAt([String? workspaceId]) {
    final id = workspaceId ?? _activeWorkspaceId;
    if (id == null) {
      return null;
    }
    return _lastPushAtByWorkspace[id];
  }

  DateTime? getLastFullSyncAt([String? workspaceId]) {
    final id = workspaceId ?? _activeWorkspaceId;
    if (id == null) {
      return null;
    }
    return _lastFullSyncAtByWorkspace[id];
  }

  void clearMergeConflicts() {
    _mergeConflicts.clear();
  }

  Future<int> getPendingUploadCount([String? workspaceId]) async {
    final id = workspaceId ?? _activeWorkspaceId;
    if (id == null || id.isEmpty) {
      return 0;
    }
    return outboxService.pendingCount(id);
  }

  Future<int> getFailedUploadCount([String? workspaceId]) async {
    final id = workspaceId ?? _activeWorkspaceId;
    if (id == null || id.isEmpty) {
      return 0;
    }
    return outboxService.failedCount(id);
  }

  Future<List<SyncOutboxEntry>> getPendingOutboxEntries([
    String? workspaceId,
  ]) async {
    final id = workspaceId ?? _activeWorkspaceId;
    if (id == null || id.isEmpty) {
      return const [];
    }
    return outboxService.getPendingEntries(id, limit: 500);
  }

  Future<List<SyncOutboxEntry>> getOutboxEntries([String? workspaceId]) async {
    final id = workspaceId ?? _activeWorkspaceId;
    if (id == null || id.isEmpty) {
      return const [];
    }
    return outboxService.getEntriesForWorkspace(id);
  }

  Future<void> retryFailedUploads([String? workspaceId]) async {
    final id = workspaceId ?? _activeWorkspaceId;
    if (id == null || id.isEmpty) {
      return;
    }
    await outboxService.retryFailed(id);
    _summary = _summary.copyWith(
      pendingUploadCount: await outboxService.pendingCount(id),
      clearLastError: true,
    );
  }

  Future<void> clearCompletedQueue({Duration olderThan = Duration.zero}) {
    return outboxService.clearDone(olderThan: olderThan);
  }

  Future<CloudSyncSummary> initializeForWorkspace(
    String workspaceId, {
    String? workspaceName,
  }) async {
    _activeWorkspaceId = workspaceId;
    _activeWorkspaceName = workspaceName;
    _summary = _summary.copyWith(
      status: _paused ? CloudSyncStatus.disabled : CloudSyncStatus.ready,
      activeWorkspaceId: workspaceId,
      activeWorkspaceName: workspaceName,
      isCloudEnabled: SupabaseConfig.isConfigured,
      isWorkspaceSelected: workspaceId.isNotEmpty,
      pendingUploadCount: await outboxService.pendingCount(workspaceId),
      clearLastError: true,
    );
    return _summary;
  }

  Future<void> queueLocalChange({
    required CloudSyncEntity entity,
    required String entityId,
    required CloudSyncOperation operation,
    Map<String, Object?>? payload,
  }) async {
    if (_summary.status == CloudSyncStatus.disabled || _paused) {
      return;
    }
    final workspaceId =
        _activeWorkspaceId ?? workspaceService.getActiveWorkspace()?.id;
    if (workspaceId == null || workspaceId.isEmpty) {
      return;
    }
    await outboxService.enqueueUniqueChange(
      workspaceId: workspaceId,
      entity: entity,
      entityId: entityId,
      operation: operation,
      payload: payload,
    );
    final pendingCount = await outboxService.pendingCount(workspaceId);
    _summary = _summary.copyWith(pendingUploadCount: pendingCount);
  }

  Future<CloudSyncResult> syncNow({
    List<Item> localItems = const [],
    List<ItemLocationBalance> localBalances = const [],
    List<InventoryTransaction> localTransactions = const [],
    List<CheckoutRecord> localCheckouts = const [],
    List<Supplier> localSuppliers = const [],
    List<ReorderRequest> localPurchaseOrders = const [],
    List<CycleCountSession> localCycleCounts = const [],
    List<CycleCountLine> localCycleCountLines = const [],
    String? Function(ItemLocationBalance balance)? locationNameForBalance,
    String? Function(String? locationId)? transactionLocationNameForId,
    String? Function(InventoryTransaction transaction)?
    assignmentLabelForTransaction,
    String? Function(CheckoutRecord checkout)? checkedOutToLabelForCheckout,
    String? Function(String? personId)? personNameForCheckout,
    String? Function(String? userId)? performedByNameForTransaction,
    String? Function(String? userId)? performedByEmailForTransaction,
    String? Function(String locationId)? cycleCountLocationNameForId,
    double? Function(CycleCountLine line)? varianceValueForCycleCountLine,
    String? Function(Item item)? unitForItem,
    String defaultUnitOfMeasureId = 'uom-each',
    String defaultLocationId = 'loc-main',
    bool canUploadInventoryBalances = false,
    bool canUploadInventoryTransactions = false,
    bool canUploadCheckouts = false,
    bool canUploadPurchasing = false,
    bool canUploadCycleCounts = false,
    bool includeCostFields = false,
    bool canUploadItemCatalog = false,
  }) async {
    if (_isSyncing) {
      _syncAgainAfterCurrent = true;
      return const CloudSyncResult.failure(
        message: 'Cloud sync is already running. Another sync will be needed.',
      );
    }
    final client = _client;
    final user = authService.currentUser;
    final workspaceId =
        _activeWorkspaceId ?? workspaceService.getActiveWorkspace()?.id;
    final workspaceName =
        _activeWorkspaceName ??
        workspaceService.getActiveWorkspace()?.name ??
        'Selected workspace';

    if (client == null) {
      final message =
          SupabaseConfig.missingConfigMessage ?? 'Supabase is not configured.';

      _summary = CloudSyncSummary.disabled().copyWith(
        status: CloudSyncStatus.disabled,
        lastError: message,
      );

      return CloudSyncResult.failure(message: message);
    }
    if (user == null) {
      _setNeedsSetup('Sign in to use cloud sync.');
      return const CloudSyncResult.failure(
        message: 'Sign in to use cloud sync.',
      );
    }
    if (workspaceId == null || workspaceId.isEmpty) {
      _setNeedsSetup('Select a workspace before syncing.');
      return const CloudSyncResult.failure(
        message: 'Select a workspace before syncing.',
      );
    }
    final activeWorkspaceId = workspaceId;
    if (_paused) {
      _summary = _summary.copyWith(
        status: CloudSyncStatus.disabled,
        activeWorkspaceId: activeWorkspaceId,
        activeWorkspaceName: workspaceName,
        isCloudEnabled: true,
        isWorkspaceSelected: true,
      );
      return const CloudSyncResult.failure(message: 'Cloud sync is paused.');
    }

    _isSyncing = true;
    var pendingEntries = const <SyncOutboxEntry>[];
    final startedAt = DateTime.now();
    _summary = _summary.copyWith(
      status: CloudSyncStatus.syncing,
      lastSyncAt: startedAt,
      activeWorkspaceId: activeWorkspaceId,
      activeWorkspaceName: workspaceName,
      isCloudEnabled: true,
      isWorkspaceSelected: true,
      clearLastError: true,
    );

    try {
      await outboxService.resetStuckSyncingEntries();
      pendingEntries = await outboxService.getPendingEntries(activeWorkspaceId);
      await outboxService.markSyncing([
        for (final entry in pendingEntries) entry.id,
      ]);
      final members = await workspaceService.fetchMembersForWorkspace(
        activeWorkspaceId,
      );
      if (!members.success) {
        final message = members.message ?? 'Could not verify workspace access.';
        _summary = _summary.copyWith(
          status: _looksOffline(message)
              ? CloudSyncStatus.offline
              : CloudSyncStatus.error,
          lastError: message,
        );
        return CloudSyncResult.failure(message: message);
      }
      final hasMembership = (members.data ?? const <CloudWorkspaceMember>[])
          .any(
            (member) =>
                member.userId == user.id &&
                member.status == CloudWorkspaceMemberStatus.active,
          );
      if (!hasMembership) {
        const message = 'Your workspace membership is not active.';
        _summary = _summary.copyWith(
          status: CloudSyncStatus.needsSetup,
          lastError: message,
        );
        return const CloudSyncResult.failure(message: message);
      }

      await _recordSyncClientSeen(client, activeWorkspaceId, user.id);
      final itemCatalogResult = canUploadItemCatalog
          ? await itemService.pushItemCatalog(
              workspaceId: activeWorkspaceId,
              items: localItems,
              unitForItem: unitForItem,
            )
          : CloudItemCatalogSyncResult(
              uploadedCount: 0,
              downloadedCount: (await itemService.pullItemCatalog(
                activeWorkspaceId,
              )).length,
              skippedCount: localItems.length,
              isUploadOnly: true,
            );
      final cloudItems = await itemService.fetchWorkspaceItems(
        activeWorkspaceId,
      );
      final workspaceItemIdsByLocalItemId = {
        for (final item in cloudItems)
          if (item.localItemId != null) item.localItemId!: item.id,
      };
      final balanceResult = canUploadInventoryBalances
          ? await balanceService.pushLocalBalances(
              workspaceId: activeWorkspaceId,
              balances: localBalances,
              workspaceItemIdsByLocalItemId: workspaceItemIdsByLocalItemId,
              locationNameForBalance: locationNameForBalance,
            )
          : CloudInventoryBalanceSyncResult(
              uploadedCount: 0,
              downloadedCount: (await balanceService.pullWorkspaceBalances(
                activeWorkspaceId,
              )).length,
              skippedCount: localBalances.length,
              isUploadOnly: true,
            );
      final transactionResult = canUploadInventoryTransactions
          ? await transactionService.pushLocalTransactions(
              workspaceId: activeWorkspaceId,
              transactions: localTransactions,
              workspaceItemIdsByLocalItemId: workspaceItemIdsByLocalItemId,
              locationNameForId: transactionLocationNameForId,
              assignmentLabelFor: assignmentLabelForTransaction,
              performedByNameFor: performedByNameForTransaction,
              performedByEmailFor: performedByEmailForTransaction,
            )
          : CloudInventoryTransactionSyncResult(
              uploadedCount: 0,
              downloadedCount:
                  (await transactionService.pullWorkspaceTransactions(
                    activeWorkspaceId,
                  )).length,
              skippedCount: localTransactions.length,
              isUploadOnly: true,
            );
      final checkoutResult = canUploadCheckouts
          ? await checkoutService.pushLocalCheckouts(
              workspaceId: activeWorkspaceId,
              checkouts: localCheckouts,
              workspaceItemIdsByLocalItemId: workspaceItemIdsByLocalItemId,
              checkedOutToLabelFor: checkedOutToLabelForCheckout,
              personNameFor: personNameForCheckout,
              userNameFor: performedByNameForTransaction,
              userEmailFor: performedByEmailForTransaction,
            )
          : CloudCheckoutSyncResult(
              uploadedCount: 0,
              downloadedCount: (await checkoutService.pullWorkspaceCheckouts(
                activeWorkspaceId,
              )).length,
              skippedCount: localCheckouts.length,
              isUploadOnly: true,
            );
      final supplierResult = canUploadPurchasing
          ? await supplierService.pushLocalSuppliers(
              workspaceId: activeWorkspaceId,
              suppliers: localSuppliers,
              includeCosts: includeCostFields,
            )
          : CloudSupplierSyncResult(
              uploadedCount: 0,
              downloadedCount: (await supplierService.pullWorkspaceSuppliers(
                activeWorkspaceId,
              )).length,
              skippedCount: localSuppliers.length,
              isUploadOnly: true,
            );
      final cloudSuppliers = await supplierService.fetchWorkspaceSuppliers(
        activeWorkspaceId,
      );
      final workspaceSupplierIdsByLocalSupplierId = {
        for (final supplier in cloudSuppliers)
          supplier.localSupplierId: supplier.id,
      };
      final purchasingResult = canUploadPurchasing
          ? await purchasingService.pushLocalPurchaseOrders(
              workspaceId: activeWorkspaceId,
              reorders: localPurchaseOrders,
              workspaceItemIdsByLocalItemId: workspaceItemIdsByLocalItemId,
              workspaceSupplierIdsByLocalSupplierId:
                  workspaceSupplierIdsByLocalSupplierId,
              includeCosts: includeCostFields,
            )
          : CloudPurchasingSyncResult(
              uploadedCount: 0,
              downloadedCount:
                  (await purchasingService.pullWorkspacePurchaseOrders(
                    activeWorkspaceId,
                  )).length,
              skippedCount: localPurchaseOrders.length,
              isUploadOnly: true,
            );
      final cycleCountResult = canUploadCycleCounts
          ? await cycleCountService.pushLocalCycleCounts(
              workspaceId: activeWorkspaceId,
              sessions: localCycleCounts,
              lines: localCycleCountLines,
              workspaceItemIdsByLocalItemId: workspaceItemIdsByLocalItemId,
              locationNameFor: cycleCountLocationNameForId,
              userNameFor: performedByNameForTransaction,
              userEmailFor: performedByEmailForTransaction,
              varianceValueFor: varianceValueForCycleCountLine,
            )
          : await (() async {
              final pulled = await cycleCountService.pullWorkspaceCycleCounts(
                activeWorkspaceId,
              );
              return CloudCycleCountSyncResult(
                uploadedCount: 0,
                downloadedCount: pulled.counts.length + pulled.lines.length,
                skippedCount:
                    localCycleCounts.length + localCycleCountLines.length,
                isUploadOnly: true,
              );
            }());
      if (canUploadItemCatalog ||
          canUploadInventoryBalances ||
          canUploadInventoryTransactions ||
          canUploadCheckouts ||
          canUploadPurchasing ||
          canUploadCycleCounts) {
        _lastPushAtByWorkspace[activeWorkspaceId] = DateTime.now();
      }
      final mergeSummary = await _pullAndApplyCloud(
        workspaceId: activeWorkspaceId,
        localItems: localItems,
        localBalances: localBalances,
        localTransactions: localTransactions,
        localCheckouts: localCheckouts,
        localSuppliers: localSuppliers,
        localPurchaseOrders: localPurchaseOrders,
        localCycleCounts: localCycleCounts,
        localCycleCountLines: localCycleCountLines,
        defaultUnitOfMeasureId: defaultUnitOfMeasureId,
        defaultLocationId: defaultLocationId,
      );
      final finishedAt = DateTime.now();
      _lastPullAtByWorkspace[activeWorkspaceId] = finishedAt;
      _lastFullSyncAtByWorkspace[activeWorkspaceId] = finishedAt;
      _mergeConflicts
        ..clear()
        ..addAll(mergeSummary.conflicts);
      _summary = _summary.copyWith(
        status: CloudSyncStatus.ready,
        lastSyncAt: finishedAt,
        lastSuccessfulSyncAt: finishedAt,
        pendingUploadCount:
            (canUploadItemCatalog &&
                canUploadInventoryBalances &&
                canUploadInventoryTransactions &&
                canUploadCheckouts &&
                canUploadPurchasing &&
                canUploadCycleCounts)
            ? 0
            : await outboxService.pendingCount(activeWorkspaceId),
        pendingDownloadCount: 0,
        clearLastError: true,
      );
      await outboxService.markAllDone(pendingEntries);
      final finalPendingCount = await outboxService.pendingCount(
        activeWorkspaceId,
      );
      _summary = _summary.copyWith(pendingUploadCount: finalPendingCount);
      final conflictText = mergeSummary.conflictCount > 0
          ? ' ${mergeSummary.conflictCount} cloud records need review.'
          : '';
      return CloudSyncResult.success(
        message: canUploadCycleCounts
            ? 'Safe two-way sync completed. Some workflow records are fetch-only until conflict review is finished.$conflictText'
            : canUploadPurchasing
            ? 'Purchasing records uploaded. Safe cloud download applied where possible.$conflictText'
            : canUploadCheckouts
            ? 'Checkouts uploaded. Safe cloud download applied where possible.$conflictText'
            : canUploadInventoryTransactions
            ? 'Inventory transactions uploaded. Safe cloud download applied where possible.$conflictText'
            : canUploadInventoryBalances
            ? 'Inventory balances synced. Safe cloud download applied where possible.$conflictText'
            : canUploadItemCatalog
            ? 'Item catalog uploaded. Safe cloud download applied where possible.$conflictText'
            : 'Cloud changes pulled where safe. Your role cannot upload inventory changes.$conflictText',
        uploadedCount:
            itemCatalogResult.uploadedCount +
            balanceResult.uploadedCount +
            transactionResult.uploadedCount +
            checkoutResult.uploadedCount +
            supplierResult.uploadedCount +
            purchasingResult.uploadedCount +
            cycleCountResult.uploadedCount,
        downloadedCount:
            itemCatalogResult.downloadedCount +
            balanceResult.downloadedCount +
            transactionResult.downloadedCount +
            checkoutResult.downloadedCount +
            supplierResult.downloadedCount +
            purchasingResult.downloadedCount +
            cycleCountResult.downloadedCount,
        skippedCount:
            itemCatalogResult.skippedCount +
            balanceResult.skippedCount +
            transactionResult.skippedCount +
            checkoutResult.skippedCount +
            supplierResult.skippedCount +
            purchasingResult.skippedCount +
            cycleCountResult.skippedCount +
            mergeSummary.skippedCount +
            mergeSummary.unsupportedCount +
            mergeSummary.duplicateCount,
      );
    } on SocketException catch (error) {
      await outboxService.markAllFailed(pendingEntries, error);
      return _offlineResult(error);
    } on TimeoutException catch (error) {
      await outboxService.markAllFailed(pendingEntries, error);
      return _offlineResult(error);
    } on PostgrestException catch (error) {
      await outboxService.markAllFailed(pendingEntries, error);
      final message = _friendlySyncError(error.message);
      _summary = _summary.copyWith(
        status: _looksOffline(message)
            ? CloudSyncStatus.offline
            : CloudSyncStatus.error,
        lastError: message,
      );
      return CloudSyncResult.failure(message: message, error: error);
    } catch (error) {
      await outboxService.markAllFailed(pendingEntries, error);
      final message = _friendlySyncError(error.toString());
      _summary = _summary.copyWith(
        status: _looksOffline(message)
            ? CloudSyncStatus.offline
            : CloudSyncStatus.error,
        lastError: message,
      );
      return CloudSyncResult.failure(message: message, error: error);
    } finally {
      _isSyncing = false;
      if (_syncAgainAfterCurrent) {
        _syncAgainAfterCurrent = false;
      }
    }
  }

  Future<CloudSyncResult> pullFromCloud({
    List<Item> localItems = const [],
    List<ItemLocationBalance> localBalances = const [],
    List<InventoryTransaction> localTransactions = const [],
    List<CheckoutRecord> localCheckouts = const [],
    List<Supplier> localSuppliers = const [],
    List<ReorderRequest> localPurchaseOrders = const [],
    List<CycleCountSession> localCycleCounts = const [],
    List<CycleCountLine> localCycleCountLines = const [],
    String defaultUnitOfMeasureId = 'uom-each',
    String defaultLocationId = 'loc-main',
  }) {
    return syncNow(
      localItems: localItems,
      localBalances: localBalances,
      localTransactions: localTransactions,
      localCheckouts: localCheckouts,
      localSuppliers: localSuppliers,
      localPurchaseOrders: localPurchaseOrders,
      localCycleCounts: localCycleCounts,
      localCycleCountLines: localCycleCountLines,
      defaultUnitOfMeasureId: defaultUnitOfMeasureId,
      defaultLocationId: defaultLocationId,
      canUploadItemCatalog: false,
      canUploadInventoryBalances: false,
      canUploadInventoryTransactions: false,
      canUploadCheckouts: false,
      canUploadPurchasing: false,
      canUploadCycleCounts: false,
    );
  }

  Future<CloudSyncResult> pushToCloud({
    List<Item> localItems = const [],
    List<ItemLocationBalance> localBalances = const [],
    List<InventoryTransaction> localTransactions = const [],
    List<CheckoutRecord> localCheckouts = const [],
    List<Supplier> localSuppliers = const [],
    List<ReorderRequest> localPurchaseOrders = const [],
    List<CycleCountSession> localCycleCounts = const [],
    List<CycleCountLine> localCycleCountLines = const [],
    String? Function(ItemLocationBalance balance)? locationNameForBalance,
    String? Function(String? locationId)? transactionLocationNameForId,
    String? Function(InventoryTransaction transaction)?
    assignmentLabelForTransaction,
    String? Function(CheckoutRecord checkout)? checkedOutToLabelForCheckout,
    String? Function(String? personId)? personNameForCheckout,
    String? Function(String? userId)? performedByNameForTransaction,
    String? Function(String? userId)? performedByEmailForTransaction,
    String? Function(String locationId)? cycleCountLocationNameForId,
    double? Function(CycleCountLine line)? varianceValueForCycleCountLine,
    String? Function(Item item)? unitForItem,
    String defaultUnitOfMeasureId = 'uom-each',
    String defaultLocationId = 'loc-main',
    bool canUploadInventoryBalances = false,
    bool canUploadInventoryTransactions = false,
    bool canUploadCheckouts = false,
    bool canUploadPurchasing = false,
    bool canUploadCycleCounts = false,
    bool includeCostFields = false,
    bool canUploadItemCatalog = false,
  }) {
    return syncNow(
      localItems: localItems,
      localBalances: localBalances,
      localTransactions: localTransactions,
      localCheckouts: localCheckouts,
      localSuppliers: localSuppliers,
      localPurchaseOrders: localPurchaseOrders,
      localCycleCounts: localCycleCounts,
      localCycleCountLines: localCycleCountLines,
      locationNameForBalance: locationNameForBalance,
      transactionLocationNameForId: transactionLocationNameForId,
      assignmentLabelForTransaction: assignmentLabelForTransaction,
      checkedOutToLabelForCheckout: checkedOutToLabelForCheckout,
      personNameForCheckout: personNameForCheckout,
      performedByNameForTransaction: performedByNameForTransaction,
      performedByEmailForTransaction: performedByEmailForTransaction,
      cycleCountLocationNameForId: cycleCountLocationNameForId,
      varianceValueForCycleCountLine: varianceValueForCycleCountLine,
      unitForItem: unitForItem,
      defaultUnitOfMeasureId: defaultUnitOfMeasureId,
      defaultLocationId: defaultLocationId,
      canUploadInventoryBalances: canUploadInventoryBalances,
      canUploadInventoryTransactions: canUploadInventoryTransactions,
      canUploadCheckouts: canUploadCheckouts,
      canUploadPurchasing: canUploadPurchasing,
      canUploadCycleCounts: canUploadCycleCounts,
      includeCostFields: includeCostFields,
      canUploadItemCatalog: canUploadItemCatalog,
    );
  }

  Future<CloudSyncResult> syncTwoWay({
    List<Item> localItems = const [],
    List<ItemLocationBalance> localBalances = const [],
    List<InventoryTransaction> localTransactions = const [],
    List<CheckoutRecord> localCheckouts = const [],
    List<Supplier> localSuppliers = const [],
    List<ReorderRequest> localPurchaseOrders = const [],
    List<CycleCountSession> localCycleCounts = const [],
    List<CycleCountLine> localCycleCountLines = const [],
    String? Function(ItemLocationBalance balance)? locationNameForBalance,
    String? Function(String? locationId)? transactionLocationNameForId,
    String? Function(InventoryTransaction transaction)?
    assignmentLabelForTransaction,
    String? Function(CheckoutRecord checkout)? checkedOutToLabelForCheckout,
    String? Function(String? personId)? personNameForCheckout,
    String? Function(String? userId)? performedByNameForTransaction,
    String? Function(String? userId)? performedByEmailForTransaction,
    String? Function(String locationId)? cycleCountLocationNameForId,
    double? Function(CycleCountLine line)? varianceValueForCycleCountLine,
    String? Function(Item item)? unitForItem,
    String defaultUnitOfMeasureId = 'uom-each',
    String defaultLocationId = 'loc-main',
    bool canUploadInventoryBalances = false,
    bool canUploadInventoryTransactions = false,
    bool canUploadCheckouts = false,
    bool canUploadPurchasing = false,
    bool canUploadCycleCounts = false,
    bool includeCostFields = false,
    bool canUploadItemCatalog = false,
  }) {
    return pushToCloud(
      localItems: localItems,
      localBalances: localBalances,
      localTransactions: localTransactions,
      localCheckouts: localCheckouts,
      localSuppliers: localSuppliers,
      localPurchaseOrders: localPurchaseOrders,
      localCycleCounts: localCycleCounts,
      localCycleCountLines: localCycleCountLines,
      locationNameForBalance: locationNameForBalance,
      transactionLocationNameForId: transactionLocationNameForId,
      assignmentLabelForTransaction: assignmentLabelForTransaction,
      checkedOutToLabelForCheckout: checkedOutToLabelForCheckout,
      personNameForCheckout: personNameForCheckout,
      performedByNameForTransaction: performedByNameForTransaction,
      performedByEmailForTransaction: performedByEmailForTransaction,
      cycleCountLocationNameForId: cycleCountLocationNameForId,
      varianceValueForCycleCountLine: varianceValueForCycleCountLine,
      unitForItem: unitForItem,
      defaultUnitOfMeasureId: defaultUnitOfMeasureId,
      defaultLocationId: defaultLocationId,
      canUploadInventoryBalances: canUploadInventoryBalances,
      canUploadInventoryTransactions: canUploadInventoryTransactions,
      canUploadCheckouts: canUploadCheckouts,
      canUploadPurchasing: canUploadPurchasing,
      canUploadCycleCounts: canUploadCycleCounts,
      includeCostFields: includeCostFields,
      canUploadItemCatalog: canUploadItemCatalog,
    );
  }

  Future<CloudSyncResult> syncEntityTwoWay(CloudSyncEntity entity) async {
    return CloudSyncResult.failure(
      message:
          '${entity.name} single-entity two-way sync is not enabled yet. Use full safe two-way sync.',
    );
  }

  Future<SyncMergeSummary> _pullAndApplyCloud({
    required String workspaceId,
    required List<Item> localItems,
    required List<ItemLocationBalance> localBalances,
    required List<InventoryTransaction> localTransactions,
    required List<CheckoutRecord> localCheckouts,
    required List<Supplier> localSuppliers,
    required List<ReorderRequest> localPurchaseOrders,
    required List<CycleCountSession> localCycleCounts,
    required List<CycleCountLine> localCycleCountLines,
    required String defaultUnitOfMeasureId,
    required String defaultLocationId,
  }) async {
    final since = _lastPullAtByWorkspace[workspaceId];
    final lastFullSyncAt = _lastFullSyncAtByWorkspace[workspaceId];
    final cloudItems = await itemService.pullItemCatalog(
      workspaceId,
      since: since,
    );
    final itemSummary = await applyService.applyCloudItems(
      cloudItems: cloudItems,
      localItems: localItems,
      defaultUnitOfMeasureId: defaultUnitOfMeasureId,
      defaultLocationId: defaultLocationId,
      lastFullSyncAt: lastFullSyncAt,
    );
    final cloudSuppliers = await supplierService.pullWorkspaceSuppliers(
      workspaceId,
      since: since,
    );
    final supplierSummary = await applyService.applyCloudSuppliers(
      cloudSuppliers: cloudSuppliers,
      localSuppliers: localSuppliers,
      lastFullSyncAt: lastFullSyncAt,
    );
    final cloudBalances = await balanceService.pullWorkspaceBalances(
      workspaceId,
      since: since,
    );
    final balanceSummary = await applyService.applyCloudInventoryBalances(
      cloudBalances: cloudBalances,
      localBalances: localBalances,
    );
    final cloudTransactions = await transactionService
        .pullWorkspaceTransactions(workspaceId, since: since);
    final transactionSummary = await applyService
        .applyCloudInventoryTransactions(
          cloudTransactions: cloudTransactions,
          localTransactions: localTransactions,
        );
    final cloudCheckouts = await checkoutService.pullWorkspaceCheckouts(
      workspaceId,
      since: since,
    );
    final checkoutSummary = await applyService.applyCloudCheckouts(
      cloudCheckouts: cloudCheckouts,
      localCheckouts: localCheckouts,
    );
    final cloudPurchaseOrders = await purchasingService
        .pullWorkspacePurchaseOrders(workspaceId, since: since);
    final purchasingSummary = await applyService.applyCloudPurchasing(
      cloudPurchaseOrders: cloudPurchaseOrders,
      localPurchaseOrders: localPurchaseOrders,
    );
    final cloudCounts = await cycleCountService.pullWorkspaceCycleCounts(
      workspaceId,
      since: since,
    );
    final cycleCountSummary = await applyService.applyCloudCycleCounts(
      cloudCycleCounts: cloudCounts.counts,
      cloudCycleCountLines: cloudCounts.lines,
      localCycleCounts: localCycleCounts,
      localCycleCountLines: localCycleCountLines,
    );

    return itemSummary
        .merge(supplierSummary)
        .merge(balanceSummary)
        .merge(transactionSummary)
        .merge(checkoutSummary)
        .merge(purchasingSummary)
        .merge(cycleCountSummary);
  }

  void pauseSync() {
    _paused = true;
    _summary = _summary.copyWith(status: CloudSyncStatus.disabled);
  }

  Future<CloudSyncSummary> resumeSync() async {
    _paused = false;
    final workspaceId = _activeWorkspaceId;
    if (workspaceId == null || workspaceId.isEmpty) {
      _summary = _summary.copyWith(status: CloudSyncStatus.needsSetup);
      return _summary;
    }
    _summary = _summary.copyWith(status: CloudSyncStatus.ready);
    return _summary;
  }

  void clearSyncError() {
    final nextStatus = _activeWorkspaceId == null
        ? CloudSyncStatus.needsSetup
        : CloudSyncStatus.ready;
    _summary = _summary.copyWith(status: nextStatus, clearLastError: true);
  }

  bool isCloudSyncReady() {
    return _summary.status == CloudSyncStatus.ready &&
        _summary.isCloudEnabled &&
        _summary.isWorkspaceSelected &&
        !_paused;
  }

  void clearWorkspaceState() {
    _activeWorkspaceId = null;
    _activeWorkspaceName = null;
    _paused = false;
    _mergeConflicts.clear();
    _summary = CloudSyncSummary.disabled();
  }

  void _setNeedsSetup(String message) {
    _summary = _summary.copyWith(
      status: CloudSyncStatus.needsSetup,
      lastError: message,
      isCloudEnabled: SupabaseConfig.isConfigured,
      isWorkspaceSelected: _activeWorkspaceId != null,
    );
  }

  Future<void> _recordSyncClientSeen(
    SupabaseClient client,
    String workspaceId,
    String userId,
  ) async {
    await client.from('sync_clients').upsert({
      'workspace_id': workspaceId,
      'user_id': userId,
      'device_name': 'Issued Flutter client',
      'platform': Platform.operatingSystem,
      'last_seen_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'workspace_id,user_id,device_name');
  }

  CloudSyncResult _offlineResult(Object error) {
    const message = 'Cloud sync is offline. Local inventory remains available.';
    _summary = _summary.copyWith(
      status: CloudSyncStatus.offline,
      lastError: message,
    );
    return CloudSyncResult.failure(message: message, error: error);
  }
}

String _friendlySyncError(String message) {
  final lower = message.toLowerCase();
  if (lower.contains('does not exist') || lower.contains('schema cache')) {
    return 'Cloud sync tables are not ready yet. Run the sync SQL migration in Supabase.';
  }
  if (lower.contains('failed host lookup') ||
      lower.contains('network') ||
      lower.contains('connection')) {
    return 'Cloud sync is offline. Local inventory remains available.';
  }
  if (lower.contains('permission') ||
      lower.contains('forbidden') ||
      lower.contains('not allowed')) {
    return 'You do not have permission to sync this workspace.';
  }
  return message.isEmpty ? 'Cloud sync request failed.' : message;
}

bool _looksOffline(String message) {
  final lower = message.toLowerCase();
  return lower.contains('offline') ||
      lower.contains('network') ||
      lower.contains('connection') ||
      lower.contains('host lookup');
}
