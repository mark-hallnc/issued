import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'backup/backup_service.dart';
import 'cloud/cloud_adoption_models.dart';
import 'cloud/cloud_adoption_service.dart';
import 'cloud/cloud_auth_service.dart';
import 'cloud/cloud_sync_service.dart';
import 'cloud/sync_coordinator.dart';
import 'cloud/sync_status_models.dart';
import 'cloud/supabase_config.dart';
import 'cloud/sync_conflict_resolution_models.dart';
import 'cloud/sync_conflict_resolution_service.dart';
import 'cloud/sync_reconciliation_models.dart';
import 'cloud/sync_reconciliation_service.dart';
import 'cloud/sync_outbox_service.dart';
import 'cloud/workspace_service.dart';
import 'database/app_database.dart';
import 'database/model_mappers.dart';
import 'data_health/data_health_service.dart';
import 'models/models.dart';
import 'permissions/app_permissions.dart';
import 'permissions/effective_permissions.dart';
import 'sample_data.dart';
import 'security/pin_hash_service.dart';

class AppStore extends ChangeNotifier with WidgetsBindingObserver {
  AppStore({AppDatabase? database}) : _database = database ?? AppDatabase();

  final AppDatabase _database;

  final List<Item> _items = [];
  final List<UnitOfMeasure> _unitsOfMeasure = [];
  final List<Location> _locations = [];
  final List<Person> _people = [];
  final List<AppUser> _users = [];
  final List<InventoryTransaction> _transactions = [];
  final List<ItemLocationBalance> _itemLocationBalances = [];
  final List<CheckoutRecord> _checkoutRecords = [];
  final List<AssignmentTarget> _assignmentTargets = [];
  final List<Supplier> _suppliers = [];
  final List<ReorderRequest> _reorderRequests = [];
  final List<CycleCountSession> _cycleCountSessions = [];
  final List<CycleCountLine> _cycleCountLines = [];
  final List<CustomFieldDefinition> _customFieldDefinitions = [];
  final List<CustomFieldValue> _customFieldValues = [];
  Company? _company;
  Plan _plan = samplePlan;
  CompanyUsage _companyUsage = sampleCompanyUsage;
  String? _currentUserId;
  bool _isLocked = true;
  DateTime? _lastActivityAt;
  int _sessionTimeoutMinutes = 10;
  bool _isInitialized = false;
  final PinHashService _pinHashService = PinHashService();
  final CloudAuthService cloudAuthService = const CloudAuthService();
  late final WorkspaceService workspaceService = WorkspaceService(
    cloudAuthService,
  );
  late final CloudSyncService cloudSyncService = CloudSyncService(
    workspaceService: workspaceService,
    database: _database,
    authService: cloudAuthService,
  );
  late final SyncCoordinator syncCoordinator = SyncCoordinator(
    syncService: cloudSyncService,
    outboxService: cloudSyncService.outboxService,
    canSync: _canRunAutomaticSync,
    performSync: _performAutomaticSync,
  );
  late final SyncReconciliationService syncReconciliationService =
      SyncReconciliationService(
        database: _database,
        syncService: cloudSyncService,
        outboxService: cloudSyncService.outboxService,
        itemService: cloudSyncService.itemService,
        balanceService: cloudSyncService.balanceService,
        transactionService: cloudSyncService.transactionService,
        checkoutService: cloudSyncService.checkoutService,
        supplierService: cloudSyncService.supplierService,
        purchasingService: cloudSyncService.purchasingService,
        cycleCountService: cloudSyncService.cycleCountService,
      );
  late final CloudAdoptionService cloudAdoptionService = CloudAdoptionService(
    database: _database,
    reconciliationService: syncReconciliationService,
  );
  late final SyncConflictResolutionService syncConflictResolutionService =
      SyncConflictResolutionService(
        syncService: cloudSyncService,
        applyService: cloudSyncService.applyService,
        outboxService: cloudSyncService.outboxService,
      );
  supabase.User? _currentCloudUser;
  final List<CloudWorkspace> _availableWorkspaces = [];
  final List<CloudWorkspaceMember> _workspaceMembers = [];
  final List<CloudWorkspaceInvite> _workspaceInvites = [];
  final List<CloudWorkspaceInvite> _pendingCloudInvites = [];
  CloudWorkspace? _activeWorkspace;
  CloudWorkspaceRole? _currentCloudRole;
  bool _cloudModeEnabled = false;
  CloudSyncSummary _cloudSyncSummary = CloudSyncSummary.disabled();
  SyncReconciliationSummary? _syncReconciliationSummary;
  CloudAdoptionSummary? _cloudAdoptionSummary;
  int _failedSyncUploadCount = 0;
  StreamSubscription<dynamic>? _cloudAuthSubscription;

  bool get isInitialized => _isInitialized;
  bool get isCloudConfigured => SupabaseConfig.isConfigured;
  bool get isCloudSignedIn => _currentCloudUser != null;
  bool get cloudModeEnabled => _cloudModeEnabled;
  CloudSyncSummary get cloudSyncSummary => _cloudSyncSummary;
  SyncReconciliationSummary? get syncReconciliationSummary =>
      _syncReconciliationSummary;
  CloudAdoptionSummary? get cloudAdoptionSummary => _cloudAdoptionSummary;
  int get failedSyncUploadCount => _failedSyncUploadCount;
  List<SyncMergeConflict> get syncMergeConflicts =>
      cloudSyncService.getMergeConflicts();
  bool get hasSyncConflicts => syncMergeConflicts.isNotEmpty;
  bool get hasSyncHealthProblems =>
      _syncReconciliationSummary?.overallStatus != SyncHealthStatus.healthy;
  int get syncConflictCount => syncMergeConflicts.length;
  int get unresolvedSyncConflictCount => syncMergeConflicts.length;
  String get syncHealthStatusLabel => syncHealthStatusLabelFor(
    _syncReconciliationSummary?.overallStatus ?? SyncHealthStatus.unknown,
  );
  bool get shouldShowCloudAdoptionWizard =>
      _cloudAdoptionSummary?.state == CloudAdoptionState.needsDecision ||
      _cloudAdoptionSummary?.state == CloudAdoptionState.blocked;
  String get cloudAdoptionStatusLabel {
    final summary = _cloudAdoptionSummary;
    if (summary == null) {
      return 'Not checked';
    }
    return switch (summary.state) {
      CloudAdoptionState.notNeeded => 'Not needed',
      CloudAdoptionState.needsDecision => 'Needs setup decision',
      CloudAdoptionState.localOnlySelected => 'Local-only',
      CloudAdoptionState.uploadSelected => 'Upload selected',
      CloudAdoptionState.startFreshSelected => 'Started fresh',
      CloudAdoptionState.completed => 'Uploaded local data',
      CloudAdoptionState.blocked => 'Blocked',
      CloudAdoptionState.error => 'Error',
    };
  }

  DateTime? get lastCloudPullAt => cloudSyncService.getLastPullAt();
  DateTime? get lastCloudPushAt => cloudSyncService.getLastPushAt();
  DateTime? get lastCloudFullSyncAt => cloudSyncService.getLastFullSyncAt();
  String? get lastAutoSyncReason =>
      _syncTriggerLabel(syncCoordinator.lastTrigger);
  bool get isAutomaticSyncRunning => syncCoordinator.isSyncing;
  bool get canOpenSyncDiagnostics =>
      kDebugMode || permissions.isAdmin || permissions.isManager;
  SyncUserStatusSummary get syncUserStatus => _buildSyncUserStatus();
  bool get isCloudSyncReady => cloudSyncService.isCloudSyncReady();
  String get cloudSyncStatusLabel =>
      cloudSyncStatusLabelForSummary(_cloudSyncSummary);
  String get cloudItemCatalogSyncStatus => isCloudWorkspaceActive
      ? 'Item catalog upload enabled'
      : 'Item catalog sync disabled';
  DateTime? get lastItemCatalogSyncAt => _cloudSyncSummary.lastSuccessfulSyncAt;
  String get cloudBalanceSyncStatus => isCloudWorkspaceActive
      ? 'Inventory balance upload enabled'
      : 'Inventory balance sync disabled';
  DateTime? get lastBalanceSyncAt => _cloudSyncSummary.lastSuccessfulSyncAt;
  String get cloudTransactionSyncStatus => isCloudWorkspaceActive
      ? 'Transaction history upload enabled'
      : 'Transaction history sync disabled';
  DateTime? get lastTransactionSyncAt => _cloudSyncSummary.lastSuccessfulSyncAt;
  String get cloudCheckoutSyncStatus => isCloudWorkspaceActive
      ? 'Checkout upload enabled'
      : 'Checkout sync disabled';
  DateTime? get lastCheckoutSyncAt => _cloudSyncSummary.lastSuccessfulSyncAt;
  String get cloudSupplierSyncStatus => isCloudWorkspaceActive
      ? 'Supplier upload enabled'
      : 'Supplier sync disabled';
  String get cloudPurchasingSyncStatus => isCloudWorkspaceActive
      ? 'Purchasing upload enabled'
      : 'Purchasing sync disabled';
  DateTime? get lastPurchasingSyncAt => _cloudSyncSummary.lastSuccessfulSyncAt;
  String get cloudCycleCountSyncStatus => isCloudWorkspaceActive
      ? 'Cycle count upload enabled'
      : 'Cycle count sync disabled';
  DateTime? get lastCycleCountSyncAt => _cloudSyncSummary.lastSuccessfulSyncAt;
  bool get isCloudWorkspaceActive =>
      _cloudModeEnabled &&
      _currentCloudUser != null &&
      _activeWorkspace != null;
  bool get shouldShowCloudWorkspaceStartup => _currentCloudUser != null;
  supabase.User? get currentCloudUser => _currentCloudUser;
  List<CloudWorkspace> get availableWorkspaces =>
      List.unmodifiable(_availableWorkspaces);
  List<CloudWorkspaceMember> get workspaceMembers =>
      List.unmodifiable(_workspaceMembers);
  List<CloudWorkspaceInvite> get workspaceInvites =>
      List.unmodifiable(_workspaceInvites);
  List<CloudWorkspaceInvite> get pendingCloudInvites =>
      List.unmodifiable(_pendingCloudInvites);
  CloudWorkspace? get activeWorkspace => _activeWorkspace;
  CloudWorkspaceRole? get currentCloudRole => _currentCloudRole;
  List<Item> get items => List.unmodifiable(_items);
  List<UnitOfMeasure> get unitsOfMeasure => List.unmodifiable(_unitsOfMeasure);
  List<Location> get locations => List.unmodifiable(_locations);
  List<Person> get people => List.unmodifiable(_people);
  List<AppUser> get users => List.unmodifiable(_users);
  List<InventoryTransaction> get transactions =>
      List.unmodifiable(_transactions);
  List<ItemLocationBalance> get itemLocationBalances =>
      List.unmodifiable(_itemLocationBalances);
  List<CheckoutRecord> get checkoutRecords =>
      List.unmodifiable(_checkoutRecords);
  List<AssignmentTarget> get assignmentTargets =>
      List.unmodifiable(_assignmentTargets);
  List<AssignmentTarget> get activeAssignmentTargets =>
      List.unmodifiable(_assignmentTargets.where((target) => target.isActive));
  List<Supplier> get suppliers => List.unmodifiable(_suppliers);
  List<Supplier> get activeSuppliers =>
      List.unmodifiable(_suppliers.where((supplier) => supplier.isActive));
  List<ReorderRequest> get reorderRequests =>
      List.unmodifiable(_reorderRequests);
  List<CycleCountSession> get cycleCountSessions =>
      List.unmodifiable(_cycleCountSessions);
  List<CycleCountLine> get cycleCountLines =>
      List.unmodifiable(_cycleCountLines);
  List<CustomFieldDefinition> get customFieldDefinitions =>
      List.unmodifiable(_customFieldDefinitions);
  List<CustomFieldValue> get customFieldValues =>
      List.unmodifiable(_customFieldValues);
  Company? get company => _company;
  bool get isSetupComplete => _company?.setupCompleted ?? false;
  Plan get plan => _plan;
  CompanyUsage get companyUsage => _companyUsage;
  Plan get currentPlan => _plan;
  bool get isLocked =>
      !isCloudWorkspaceActive && (_isLocked || currentUser == null);
  DateTime? get lastActivityAt => _lastActivityAt;
  int get sessionTimeoutMinutes => _sessionTimeoutMinutes;
  AppUser? get currentUser {
    final requestedUserId = _currentUserId;
    if (_users.isEmpty || requestedUserId == null) {
      return null;
    }

    for (final user in _users) {
      if (user.id == requestedUserId && user.isActive) {
        return user;
      }
    }

    return null;
  }

  Person? get currentPerson {
    final personId = currentUser?.personId;
    if (personId == null) {
      return null;
    }

    for (final person in _people) {
      if (person.id == personId) {
        return person;
      }
    }

    return null;
  }

  UserRole get currentRole {
    if (isLocked) {
      return UserRole.viewOnly;
    }
    return currentUser?.role ?? UserRole.viewOnly;
  }

  UserRole get currentEffectiveRole {
    if (_cloudModeEnabled &&
        _activeWorkspace != null &&
        _currentCloudRole != null) {
      return localRoleForCloudWorkspaceRole(_currentCloudRole!);
    }
    if (isLocked) {
      return UserRole.viewOnly;
    }
    return currentRole;
  }

  AppPermissions get effectivePermissions =>
      effectivePermissionsForRole(currentEffectiveRole);
  AppPermissions get permissions => effectivePermissions;
  bool get isCloudWorkspaceMode => isCloudWorkspaceActive;
  bool get canManageWorkspaceMembers => permissions.canManageMembers;
  bool get canViewCosts => permissions.canViewCosts;
  bool get canIssueItems => permissions.canIssueItems;
  String get currentEffectiveRoleLabel => effectiveRoleLabel(
    localRole: currentRole,
    cloudRole: currentCloudRole,
    isCloudWorkspaceMode: isCloudWorkspaceMode,
  );
  List<Plan> get availablePlans => List.unmodifiable(samplePlans);
  CompanyUsage get currentUsage {
    return CompanyUsage(
      activeItemCount: _items.where((item) => item.isActive).length,
      userCount: _users.where((user) => user.isActive).length,
      locationCount: _locations.where((location) => location.isActive).length,
      photoCount: _items.where((item) {
        if (!item.isActive) {
          return false;
        }

        final photoPath = item.photoPath?.trim();
        return photoPath != null && photoPath.isNotEmpty;
      }).length,
      labelExportCount: _companyUsage.labelExportCount,
    );
  }

  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);
    await _loadFromDatabase();
    await _ensureBasePlanData();
    await _ensureCompanyForExistingData();
    await _backfillItemLocationBalances();
    if (isSetupComplete) {
      await _ensureLocalTestUsers();
      await _ensurePinsForMigratedLocalUsers();
    }
    await _seedAssignmentTargetsIfNeeded();
    initializeCloud();
    if (_currentCloudUser != null) {
      await refreshCloudWorkspaceState();
    }
    _isInitialized = true;
    notifyListeners();
    _requestAutomaticSync(trigger: SyncTrigger.startup);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(syncCoordinator.onAppResumed());
    }
  }

  void initializeCloud() {
    if (!isCloudConfigured) {
      _currentCloudUser = null;
      _availableWorkspaces.clear();
      _workspaceMembers.clear();
      _workspaceInvites.clear();
      _pendingCloudInvites.clear();
      _activeWorkspace = null;
      _currentCloudRole = null;
      _cloudModeEnabled = false;
      _clearCloudSyncState();
      return;
    }
    _currentCloudUser = cloudAuthService.currentUser;
    _cloudModeEnabled = _currentCloudUser != null;
    _cloudAuthSubscription ??= cloudAuthService.authStateChanges.listen((
      authState,
    ) {
      _currentCloudUser = authState.session?.user;
      if (_currentCloudUser == null) {
        _availableWorkspaces.clear();
        _workspaceMembers.clear();
        _workspaceInvites.clear();
        _pendingCloudInvites.clear();
        _activeWorkspace = null;
        _currentCloudRole = null;
        _cloudModeEnabled = false;
        workspaceService.clearActiveWorkspace();
        _clearCloudSyncState();
      } else {
        _cloudModeEnabled = true;
        unawaited(loadMyWorkspaces().then((_) => syncCoordinator.onLogin()));
      }
      notifyListeners();
    });
  }

  Future<AppActionResult> refreshCloudSession() async {
    if (!isCloudConfigured) {
      return AppActionResult.failure(SupabaseConfig.missingConfigMessage);
    }
    final result = await cloudAuthService.refreshSession();
    _currentCloudUser = cloudAuthService.currentUser;
    _cloudModeEnabled = _currentCloudUser != null;
    notifyListeners();
    return result.success
        ? AppActionResult.success(message: result.message)
        : AppActionResult.failure(result.message);
  }

  Future<AppActionResult> signInWithEmailOtp(String email) async {
    final result = await cloudAuthService.signInWithEmailOtp(email);
    return result.success
        ? AppActionResult.success(message: result.message)
        : AppActionResult.failure(result.message);
  }

  Future<AppActionResult> verifyEmailOtp(String email, String token) async {
    final result = await cloudAuthService.verifyOtp(email: email, token: token);
    _currentCloudUser = cloudAuthService.currentUser;
    _cloudModeEnabled = _currentCloudUser != null;
    if (_cloudModeEnabled) {
      await refreshCloudWorkspaceState();
      unawaited(syncCoordinator.onLogin());
    } else {
      notifyListeners();
    }
    return result.success
        ? AppActionResult.success(message: result.message)
        : AppActionResult.failure(result.message);
  }

  Future<AppActionResult> signOutCloud() async {
    final result = await cloudAuthService.signOut();
    _currentCloudUser = null;
    _availableWorkspaces.clear();
    _workspaceMembers.clear();
    _workspaceInvites.clear();
    _pendingCloudInvites.clear();
    _activeWorkspace = null;
    _currentCloudRole = null;
    _cloudModeEnabled = false;
    workspaceService.clearActiveWorkspace();
    _clearCloudSyncState();
    notifyListeners();
    return result.success
        ? AppActionResult.success(message: result.message)
        : AppActionResult.failure(result.message);
  }

  Future<AppActionResult> loadMyWorkspaces() async {
    final result = await workspaceService.fetchMyWorkspaces();
    if (!result.success) {
      return AppActionResult.failure(result.message);
    }
    _availableWorkspaces
      ..clear()
      ..addAll(result.data ?? const []);
    final active = workspaceService.getActiveWorkspace();
    final storedActiveWorkspaceId = await workspaceService
        .getStoredActiveWorkspaceId();
    if (active != null &&
        _availableWorkspaces.any((workspace) => workspace.id == active.id)) {
      _activeWorkspace = active;
    } else if (storedActiveWorkspaceId != null &&
        _availableWorkspaces.any(
          (workspace) => workspace.id == storedActiveWorkspaceId,
        )) {
      _activeWorkspace = _availableWorkspaces.firstWhere(
        (workspace) => workspace.id == storedActiveWorkspaceId,
      );
      workspaceService.setActiveWorkspace(_activeWorkspace!);
    } else if (_availableWorkspaces.length == 1) {
      _activeWorkspace = _availableWorkspaces.first;
      workspaceService.setActiveWorkspace(_activeWorkspace!);
    } else {
      _activeWorkspace = null;
      if (storedActiveWorkspaceId != null) {
        workspaceService.clearActiveWorkspace();
      }
    }
    await loadPendingCloudInvites(notify: false);
    if (_activeWorkspace != null) {
      await loadWorkspaceMembers(notify: false);
      await loadWorkspaceInvites(notify: false);
      await initializeCloudSyncForActiveWorkspace(notify: false);
      await _refreshSyncQueueCounts();
      await refreshCloudAdoptionSummary(notify: false);
    } else {
      _workspaceMembers.clear();
      _workspaceInvites.clear();
      _currentCloudRole = null;
      _clearCloudSyncState();
    }
    notifyListeners();
    if (!shouldShowCloudAdoptionWizard) {
      _requestAutomaticSync(trigger: SyncTrigger.workspaceSelected);
    }
    return const AppActionResult.success();
  }

  Future<AppActionResult> refreshCloudWorkspaceState() async {
    _currentCloudUser = cloudAuthService.currentUser;
    _cloudModeEnabled = _currentCloudUser != null;
    if (_currentCloudUser == null) {
      _clearCloudSyncState();
      return const AppActionResult.success();
    }
    return loadMyWorkspaces();
  }

  Future<AppActionResult> loadWorkspaceMembers({bool notify = true}) async {
    final workspace = _activeWorkspace;
    if (workspace == null) {
      _workspaceMembers.clear();
      _currentCloudRole = null;
      if (notify) notifyListeners();
      return const AppActionResult.failure('Select a workspace first.');
    }
    final result = await workspaceService.fetchMembersForWorkspace(
      workspace.id,
    );
    if (!result.success) {
      return AppActionResult.failure(result.message);
    }
    _workspaceMembers
      ..clear()
      ..addAll(result.data ?? const []);
    _currentCloudRole = _roleForCurrentCloudUser();
    if (notify) notifyListeners();
    return const AppActionResult.success();
  }

  Future<AppActionResult> loadWorkspaceInvites({bool notify = true}) async {
    final workspace = _activeWorkspace;
    if (workspace == null) {
      _workspaceInvites.clear();
      if (notify) notifyListeners();
      return const AppActionResult.failure('Select a workspace first.');
    }
    final result = await workspaceService.fetchInvitesForWorkspace(
      workspace.id,
    );
    if (!result.success) {
      return AppActionResult.failure(result.message);
    }
    _workspaceInvites
      ..clear()
      ..addAll(result.data ?? const []);
    if (notify) notifyListeners();
    return const AppActionResult.success();
  }

  Future<AppActionResult> loadPendingCloudInvites({bool notify = true}) async {
    final result = await workspaceService.fetchPendingInvitesForCurrentUser();
    if (!result.success) {
      return AppActionResult.failure(result.message);
    }
    _pendingCloudInvites
      ..clear()
      ..addAll(result.data ?? const []);
    if (notify) notifyListeners();
    return const AppActionResult.success();
  }

  Future<AppActionResult> inviteCloudWorkspaceMember({
    required String email,
    required CloudWorkspaceRole role,
    String? displayName,
  }) async {
    final workspace = _activeWorkspace;
    if (workspace == null) {
      return const AppActionResult.failure('Select a workspace first.');
    }
    final normalizedEmail = email.trim().toLowerCase();
    if (_workspaceMembers.any(
      (member) =>
          member.email.toLowerCase() == normalizedEmail &&
          member.status == CloudWorkspaceMemberStatus.active,
    )) {
      return const AppActionResult.failure(
        'That person is already a workspace member.',
      );
    }
    final result = await workspaceService.inviteWorkspaceMember(
      workspaceId: workspace.id,
      email: normalizedEmail,
      role: role,
      displayName: displayName,
    );
    if (result.success) {
      await loadWorkspaceInvites(notify: false);
      notifyListeners();
      return AppActionResult.success(message: result.message);
    }
    return AppActionResult.failure(result.message);
  }

  Future<AppActionResult> resendCloudWorkspaceInvite(String inviteId) async {
    final result = await workspaceService.resendWorkspaceInvite(inviteId);
    if (result.success) {
      await loadWorkspaceInvites(notify: false);
      notifyListeners();
      return AppActionResult.success(message: result.message);
    }
    return AppActionResult.failure(result.message);
  }

  Future<AppActionResult> revokeCloudWorkspaceInvite(String inviteId) async {
    final result = await workspaceService.revokeWorkspaceInvite(inviteId);
    if (result.success) {
      await loadWorkspaceInvites(notify: false);
      await loadPendingCloudInvites(notify: false);
      notifyListeners();
      return AppActionResult.success(message: result.message);
    }
    return AppActionResult.failure(result.message);
  }

  Future<AppActionResult> acceptCloudWorkspaceInvite(String inviteId) async {
    final result = await workspaceService.acceptWorkspaceInvite(inviteId);
    if (!result.success || result.data == null) {
      return AppActionResult.failure(result.message);
    }
    final workspace = result.data!;
    if (!_availableWorkspaces.any((item) => item.id == workspace.id)) {
      _availableWorkspaces.add(workspace);
    }
    _activeWorkspace = workspace;
    _cloudModeEnabled = true;
    workspaceService.setActiveWorkspace(workspace);
    await loadPendingCloudInvites(notify: false);
    await loadWorkspaceMembers(notify: false);
    await loadWorkspaceInvites(notify: false);
    await initializeCloudSyncForActiveWorkspace(notify: false);
    await refreshCloudAdoptionSummary(notify: false);
    notifyListeners();
    if (!shouldShowCloudAdoptionWizard) {
      _requestAutomaticSync(trigger: SyncTrigger.workspaceSelected);
    }
    return AppActionResult.success(message: result.message);
  }

  Future<AppActionResult> updateCloudMemberRole({
    required String memberId,
    required CloudWorkspaceRole role,
  }) async {
    final result = await workspaceService.updateWorkspaceMemberRole(
      memberId: memberId,
      role: role,
    );
    if (result.success) {
      await loadWorkspaceMembers(notify: false);
      notifyListeners();
      return AppActionResult.success(message: result.message);
    }
    return AppActionResult.failure(result.message);
  }

  Future<AppActionResult> disableCloudMember(String memberId) async {
    final result = await workspaceService.disableWorkspaceMember(memberId);
    if (result.success) {
      await loadWorkspaceMembers(notify: false);
      notifyListeners();
      return AppActionResult.success(message: result.message);
    }
    return AppActionResult.failure(result.message);
  }

  Future<AppActionResult> enableCloudMember(String memberId) async {
    final result = await workspaceService.enableWorkspaceMember(memberId);
    if (result.success) {
      await loadWorkspaceMembers(notify: false);
      notifyListeners();
      return AppActionResult.success(message: result.message);
    }
    return AppActionResult.failure(result.message);
  }

  Future<AppActionResult> clearLocalInventoryTestDataForDevelopment() async {
    await _database.clearLocalInventoryTestData();
    await _loadFromDatabase();
    notifyListeners();
    return const AppActionResult.success(
      message: 'Local inventory/test data cleared from this device.',
    );
  }

  Future<AppActionResult> clearLocalDataAndSignOutForDevelopment() async {
    await signOutCloud();
    await _database.clearAllLocalData();
    _currentUserId = null;
    _isLocked = true;
    _lastActivityAt = null;
    _company = null;
    await _loadFromDatabase();
    await _ensureBasePlanData();
    await _loadFromDatabase();
    notifyListeners();
    return const AppActionResult.success(
      message: 'Local app data cleared and cloud account signed out.',
    );
  }

  Future<AppActionResult> createCloudWorkspace(String name) async {
    final result = await workspaceService.createWorkspace(name);
    if (!result.success || result.data == null) {
      return AppActionResult.failure(result.message);
    }
    _activeWorkspace = result.data;
    if (!_availableWorkspaces.any(
      (workspace) => workspace.id == result.data!.id,
    )) {
      _availableWorkspaces.add(result.data!);
    }
    _cloudModeEnabled = true;
    await loadWorkspaceMembers(notify: false);
    await loadWorkspaceInvites(notify: false);
    await initializeCloudSyncForActiveWorkspace(notify: false);
    await refreshCloudAdoptionSummary(notify: false);
    notifyListeners();
    if (!shouldShowCloudAdoptionWizard) {
      _requestAutomaticSync(trigger: SyncTrigger.workspaceSelected);
    }
    return AppActionResult.success(message: result.message);
  }

  void setActiveCloudWorkspace(CloudWorkspace workspace) {
    _activeWorkspace = workspace;
    _cloudModeEnabled = true;
    workspaceService.setActiveWorkspace(workspace);
    notifyListeners();
    unawaited(_finishWorkspaceSelectionSetup());
  }

  Future<void> _finishWorkspaceSelectionSetup() async {
    await loadWorkspaceMembers(notify: false);
    await loadWorkspaceInvites(notify: false);
    await initializeCloudSyncForActiveWorkspace(notify: false);
    await refreshCloudAdoptionSummary(notify: false);
    notifyListeners();
    if (!shouldShowCloudAdoptionWizard) {
      _requestAutomaticSync(trigger: SyncTrigger.workspaceSelected);
    }
  }

  void disableCloudModeAndUseLocalOnly() {
    _cloudModeEnabled = false;
    _activeWorkspace = null;
    _currentCloudRole = null;
    _workspaceMembers.clear();
    _workspaceInvites.clear();
    _pendingCloudInvites.clear();
    workspaceService.clearActiveWorkspace();
    _clearCloudSyncState();
    notifyListeners();
  }

  Future<AppActionResult> initializeCloudSyncForActiveWorkspace({
    bool notify = true,
  }) async {
    final workspace = _activeWorkspace;
    if (!isCloudConfigured) {
      _clearCloudSyncState();
      if (notify) notifyListeners();
      return AppActionResult.failure(SupabaseConfig.missingConfigMessage);
    }
    if (_currentCloudUser == null || workspace == null) {
      _cloudSyncSummary = CloudSyncSummary.disabled().copyWith(
        status: CloudSyncStatus.needsSetup,
        isCloudEnabled: isCloudConfigured,
        isWorkspaceSelected: workspace != null,
        activeWorkspaceId: workspace?.id,
        activeWorkspaceName: workspace?.name,
      );
      if (notify) notifyListeners();
      return const AppActionResult.failure(
        'Sign in and select a workspace before syncing.',
      );
    }
    _cloudSyncSummary = await cloudSyncService.initializeForWorkspace(
      workspace.id,
      workspaceName: workspace.name,
    );
    await _refreshSyncQueueCounts();
    await refreshCloudAdoptionSummary(notify: false);
    if (notify) notifyListeners();
    return const AppActionResult.success(
      message: 'Cloud sync foundation is ready.',
    );
  }

  Future<AppActionResult> syncNow() async {
    return syncTwoWayNow();
  }

  Future<AppActionResult> syncTwoWayNow() async {
    return _runCloudInventorySync(
      uploadBalances: true,
      uploadTransactions: true,
      uploadCheckouts: true,
      uploadPurchasing: true,
      uploadCycleCounts: true,
    );
  }

  Future<AppActionResult> pullCloudChangesNow() async {
    final result = await cloudSyncService.pullFromCloud(
      localItems: _items,
      localBalances: _itemLocationBalances,
      localTransactions: _transactions,
      localCheckouts: _checkoutRecords,
      localSuppliers: _suppliers,
      localPurchaseOrders: _reorderRequests,
      localCycleCounts: _cycleCountSessions,
      localCycleCountLines: _cycleCountLines,
      defaultUnitOfMeasureId: _defaultUnitOfMeasureId,
      defaultLocationId: _defaultLocationId,
    );
    _cloudSyncSummary = cloudSyncService.getSyncSummary();
    await _loadFromDatabase();
    notifyListeners();
    return result.success
        ? AppActionResult.success(message: result.message)
        : AppActionResult.failure(result.message, data: result.error);
  }

  Future<AppActionResult> retryFailedUploadsNow() async {
    await cloudSyncService.retryFailedUploads();
    await _refreshSyncQueueCounts();
    notifyListeners();
    _requestAutomaticSync(trigger: SyncTrigger.retry);
    return const AppActionResult.success(message: 'Failed uploads queued.');
  }

  Future<AppActionResult> clearCompletedSyncQueueNow() async {
    await cloudSyncService.clearCompletedQueue();
    await _refreshSyncQueueCounts();
    notifyListeners();
    return const AppActionResult.success(
      message: 'Completed sync history cleared.',
    );
  }

  Future<AppActionResult> syncItemCatalogNow() async {
    return _runCloudInventorySync(
      uploadBalances: false,
      uploadTransactions: false,
      uploadCheckouts: false,
      uploadPurchasing: false,
      uploadCycleCounts: false,
    );
  }

  Future<AppActionResult> syncInventoryBalancesNow() async {
    return _runCloudInventorySync(
      uploadBalances: true,
      uploadTransactions: false,
      uploadCheckouts: false,
      uploadPurchasing: false,
      uploadCycleCounts: false,
    );
  }

  Future<AppActionResult> syncInventoryTransactionsNow() async {
    return _runCloudInventorySync(
      uploadBalances: true,
      uploadTransactions: true,
      uploadCheckouts: false,
      uploadPurchasing: false,
      uploadCycleCounts: false,
    );
  }

  Future<AppActionResult> syncCheckoutsNow() async {
    return _runCloudInventorySync(
      uploadBalances: true,
      uploadTransactions: true,
      uploadCheckouts: true,
      uploadPurchasing: false,
      uploadCycleCounts: false,
    );
  }

  Future<AppActionResult> syncSuppliersNow() async {
    return _runCloudInventorySync(
      uploadBalances: false,
      uploadTransactions: false,
      uploadCheckouts: false,
      uploadPurchasing: true,
      uploadCycleCounts: false,
    );
  }

  Future<AppActionResult> syncPurchasingNow() async {
    return _runCloudInventorySync(
      uploadBalances: true,
      uploadTransactions: true,
      uploadCheckouts: true,
      uploadPurchasing: true,
      uploadCycleCounts: false,
    );
  }

  Future<AppActionResult> syncCycleCountsNow() async {
    return _runCloudInventorySync(
      uploadBalances: true,
      uploadTransactions: true,
      uploadCheckouts: true,
      uploadPurchasing: true,
      uploadCycleCounts: true,
    );
  }

  Future<AppActionResult> _runCloudInventorySync({
    required bool uploadBalances,
    required bool uploadTransactions,
    required bool uploadCheckouts,
    required bool uploadPurchasing,
    required bool uploadCycleCounts,
    bool forceUploadExistingLocalData = false,
    bool bypassAdoptionGate = false,
  }) async {
    final adoptionSummary = await _ensureCloudAdoptionSummary();
    final adoptionState = adoptionSummary?.state;
    if (!bypassAdoptionGate &&
        (adoptionState == CloudAdoptionState.needsDecision ||
            adoptionState == CloudAdoptionState.blocked ||
            adoptionState == CloudAdoptionState.localOnlySelected)) {
      return const AppActionResult.failure(
        'Choose how this device should use the cloud workspace before syncing.',
      );
    }
    final adoptionCutoff = forceUploadExistingLocalData
        ? null
        : _localUploadCutoffFor(adoptionSummary);
    final localItems = _itemsForCloudUpload(adoptionCutoff);
    final localBalances = _balancesForCloudUpload(adoptionCutoff);
    final localTransactions = _transactionsForCloudUpload(adoptionCutoff);
    final localCheckouts = _checkoutsForCloudUpload(adoptionCutoff);
    final localSuppliers = _suppliersForCloudUpload(adoptionCutoff);
    final localPurchaseOrders = _purchaseOrdersForCloudUpload(adoptionCutoff);
    final localCycleCounts = _cycleCountsForCloudUpload(adoptionCutoff);
    final localCycleCountLines = _cycleCountLinesForCloudUpload(adoptionCutoff);
    final result = await cloudSyncService.syncNow(
      localItems: localItems,
      localBalances: localBalances,
      localTransactions: localTransactions,
      localCheckouts: localCheckouts,
      localSuppliers: localSuppliers,
      localPurchaseOrders: localPurchaseOrders,
      localCycleCounts: localCycleCounts,
      localCycleCountLines: localCycleCountLines,
      defaultUnitOfMeasureId: _defaultUnitOfMeasureId,
      defaultLocationId: _defaultLocationId,
      unitForItem: (item) => resolveUomAbbreviation(item.unitOfMeasureId),
      locationNameForBalance: (balance) =>
          resolveLocationName(balance.locationId),
      transactionLocationNameForId: resolveLocationName,
      assignmentLabelForTransaction: (transaction) => resolveAssignedTo(
        personId: transaction.assignedToPersonId,
        targetId: transaction.assignedToTargetId,
        locationId: transaction.assignedToLocationId,
        text: transaction.assignedToText,
      ),
      checkedOutToLabelForCheckout: resolveCheckoutAssigneeName,
      personNameForCheckout: resolvePersonName,
      performedByNameForTransaction: resolveUserName,
      performedByEmailForTransaction: _resolveUserEmail,
      cycleCountLocationNameForId: resolveLocationName,
      varianceValueForCycleCountLine: permissions.canViewCosts
          ? _varianceValueForCycleCountLine
          : null,
      canUploadItemCatalog: permissions.canManageItems,
      canUploadInventoryBalances: uploadBalances && _canUploadInventoryBalances,
      canUploadInventoryTransactions:
          uploadTransactions && _canUploadInventoryTransactions,
      canUploadCheckouts: uploadCheckouts && _canUploadCheckouts,
      canUploadPurchasing: uploadPurchasing && _canUploadPurchasing,
      canUploadCycleCounts: uploadCycleCounts && _canUploadCycleCounts,
      includeCostFields: permissions.canViewCosts,
    );
    _cloudSyncSummary = cloudSyncService.getSyncSummary();
    await _loadFromDatabase();
    notifyListeners();
    return result.success
        ? AppActionResult.success(message: result.message)
        : AppActionResult.failure(result.message, data: result.error);
  }

  void clearCloudSyncError() {
    cloudSyncService.clearSyncError();
    _cloudSyncSummary = cloudSyncService.getSyncSummary();
    notifyListeners();
  }

  List<SyncMergeConflict> getSyncMergeConflicts() => syncMergeConflicts;

  void clearSyncMergeConflicts() {
    cloudSyncService.clearMergeConflicts();
    notifyListeners();
  }

  Future<List<SyncMergeConflict>> refreshSyncConflicts() async {
    return getSyncMergeConflicts();
  }

  Future<AppActionResult> resolveSyncConflict(
    SyncMergeConflict conflict,
    SyncConflictResolutionAction action,
  ) async {
    final workspace = _activeWorkspace;
    if (workspace == null) {
      return const AppActionResult.failure('Select a workspace first.');
    }
    try {
      final result = await syncConflictResolutionService.resolveConflict(
        conflict,
        action,
        workspaceId: workspace.id,
        localItems: _items,
        localSuppliers: _suppliers,
        defaultUnitOfMeasureId: _defaultUnitOfMeasureId,
        defaultLocationId: _defaultLocationId,
      );
      _cloudSyncSummary = cloudSyncService.getSyncSummary();
      await _loadFromDatabase();
      await _refreshSyncQueueCounts();
      notifyListeners();
      return result.success
          ? AppActionResult.success(message: result.message, data: result)
          : AppActionResult.failure(result.message, data: result.error);
    } catch (error) {
      return AppActionResult.failure(
        'Could not resolve sync conflict.',
        data: error,
      );
    }
  }

  Future<AppActionResult> markSyncConflictReviewed(SyncMergeConflict conflict) {
    return resolveSyncConflict(
      conflict,
      SyncConflictResolutionAction.markReviewed,
    );
  }

  Future<AppActionResult> retrySyncAfterConflictResolution() {
    return syncNow();
  }

  Future<List<SyncOutboxEntry>> getSyncQueueEntries() {
    return cloudSyncService.getOutboxEntries();
  }

  Future<SyncReconciliationSummary> refreshSyncReconciliation() async {
    final workspace = _activeWorkspace;
    if (!isCloudWorkspaceActive || workspace == null) {
      final summary = SyncReconciliationSummary(
        workspaceId: workspace?.id ?? '',
        workspaceName: workspace?.name,
        checkedAt: DateTime.now(),
        overallStatus: SyncHealthStatus.unsupported,
        entities: const [],
        messages: const [
          'Sign in and select a workspace to view cloud sync health.',
        ],
      );
      _syncReconciliationSummary = summary;
      notifyListeners();
      return summary;
    }
    final summary = await syncReconciliationService.buildSummary(
      workspace.id,
      workspaceName: workspace.name,
    );
    _syncReconciliationSummary = summary;
    _failedSyncUploadCount = summary.totalFailed;
    notifyListeners();
    return summary;
  }

  Future<CloudAdoptionSummary> refreshCloudAdoptionSummary({
    bool notify = true,
  }) async {
    final workspace = _activeWorkspace;
    if (!isCloudWorkspaceActive || workspace == null) {
      final summary = CloudAdoptionSummary(
        state: CloudAdoptionState.notNeeded,
        workspaceId: workspace?.id ?? '',
        workspaceName: workspace?.name,
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
        message: 'Select a cloud workspace to set up sync.',
      );
      _cloudAdoptionSummary = summary;
      if (notify) notifyListeners();
      return summary;
    }
    final summary = await cloudAdoptionService.buildAdoptionSummary(
      workspace.id,
      workspaceName: workspace.name,
    );
    _cloudAdoptionSummary = _summaryWithPermissionGate(summary);
    if (notify) notifyListeners();
    return _cloudAdoptionSummary!;
  }

  Future<AppActionResult> completeCloudAdoption(
    CloudAdoptionChoice choice,
  ) async {
    final workspace = _activeWorkspace;
    if (workspace == null) {
      return const AppActionResult.failure('Select a workspace first.');
    }
    if (choice == CloudAdoptionChoice.cancel) {
      await refreshCloudAdoptionSummary();
      return const AppActionResult.success(message: 'Cloud setup paused.');
    }
    if (choice == CloudAdoptionChoice.keepLocalOnly) {
      await cloudAdoptionService.markAdoptionCompleted(workspace.id, choice);
      disableCloudModeAndUseLocalOnly();
      return const AppActionResult.success(
        message: 'This device will stay local-only for now.',
      );
    }
    if (choice == CloudAdoptionChoice.startFreshCloud) {
      await cloudAdoptionService.startFreshCloudWorkspace(workspace.id);
      await refreshCloudAdoptionSummary();
      return const AppActionResult.success(
        message:
            'Cloud setup saved. Existing local data will not be uploaded automatically.',
      );
    }
    if (!permissions.isAdmin && !permissions.isManager) {
      await refreshCloudAdoptionSummary();
      return const AppActionResult.failure(
        'Ask an admin or manager to set up this workspace first.',
      );
    }
    final result = await _runCloudInventorySync(
      uploadBalances: true,
      uploadTransactions: true,
      uploadCheckouts: true,
      uploadPurchasing: true,
      uploadCycleCounts: true,
      forceUploadExistingLocalData: true,
      bypassAdoptionGate: true,
    );
    if (!result.success) {
      await refreshCloudAdoptionSummary();
      return result;
    }
    await cloudAdoptionService.uploadLocalDataToWorkspace(workspace.id);
    await refreshCloudAdoptionSummary();
    return AppActionResult.success(
      message:
          '${result.message ?? 'Local data uploaded.'} Cloud setup is complete.',
      data: result.data,
    );
  }

  Future<AppActionResult> resetCloudAdoptionDecisionForDebug() async {
    final workspace = _activeWorkspace;
    if (workspace == null) {
      return const AppActionResult.failure('Select a workspace first.');
    }
    await cloudAdoptionService.clearAdoptionFlagForDebug(workspace.id);
    await refreshCloudAdoptionSummary();
    return const AppActionResult.success(
      message: 'Cloud setup decision reset for this workspace on this device.',
    );
  }

  Future<void> _refreshSyncQueueCounts() async {
    final workspace = _activeWorkspace;
    if (workspace == null) {
      _failedSyncUploadCount = 0;
      _cloudSyncSummary = cloudSyncService.getSyncSummary();
      return;
    }
    final pending = await cloudSyncService.getPendingUploadCount(workspace.id);
    _failedSyncUploadCount = await cloudSyncService.getFailedUploadCount(
      workspace.id,
    );
    _cloudSyncSummary = cloudSyncService.getSyncSummary().copyWith(
      pendingUploadCount: pending,
    );
  }

  void _requestAutomaticSync({required SyncTrigger trigger}) {
    unawaited(
      syncCoordinator.requestSync(
        trigger: trigger,
        immediate: trigger != SyncTrigger.startup,
      ),
    );
  }

  bool _canRunAutomaticSync() {
    if (!_isInitialized || !isCloudWorkspaceActive) {
      return false;
    }
    final adoptionState = _cloudAdoptionSummary?.state;
    return adoptionState != CloudAdoptionState.needsDecision &&
        adoptionState != CloudAdoptionState.localOnlySelected &&
        adoptionState != CloudAdoptionState.blocked;
  }

  Future<void> _performAutomaticSync(SyncTrigger trigger) async {
    if (!_canRunAutomaticSync()) {
      return;
    }
    final result = await syncTwoWayNow();
    if (!result.success) {
      throw result.data ?? result.message ?? 'Sync failed.';
    }
    await _refreshSyncQueueCounts();
  }

  void _clearCloudSyncState() {
    cloudSyncService.clearWorkspaceState();
    _cloudSyncSummary = cloudSyncService.getSyncSummary();
    _cloudAdoptionSummary = null;
  }

  void _queueItemCatalogChange(String itemId, CloudSyncOperation operation) {
    if (!isCloudWorkspaceActive || !permissions.canManageItems) {
      return;
    }
    unawaited(
      cloudSyncService.queueLocalChange(
        entity: CloudSyncEntity.item,
        entityId: itemId,
        operation: operation,
      ),
    );
    _cloudSyncSummary = cloudSyncService.getSyncSummary();
    syncCoordinator.onLocalChange();
  }

  void queueBalanceForSync(String balanceId) {
    if (!isCloudWorkspaceActive || !_canUploadInventoryBalances) {
      return;
    }
    unawaited(
      cloudSyncService.queueLocalChange(
        entity: CloudSyncEntity.inventoryBalance,
        entityId: balanceId,
        operation: CloudSyncOperation.update,
      ),
    );
    _cloudSyncSummary = cloudSyncService.getSyncSummary();
    syncCoordinator.onLocalChange();
  }

  void queueTransactionForSync(String transactionId) {
    if (!isCloudWorkspaceActive || !_canUploadInventoryTransactions) {
      return;
    }
    unawaited(
      cloudSyncService.queueLocalChange(
        entity: CloudSyncEntity.transaction,
        entityId: transactionId,
        operation: CloudSyncOperation.create,
      ),
    );
    _cloudSyncSummary = cloudSyncService.getSyncSummary();
    syncCoordinator.onLocalChange();
  }

  void queueCheckoutForSync(String checkoutId) {
    if (!isCloudWorkspaceActive || !_canUploadCheckouts) {
      return;
    }
    unawaited(
      cloudSyncService.queueLocalChange(
        entity: CloudSyncEntity.checkout,
        entityId: checkoutId,
        operation: CloudSyncOperation.update,
      ),
    );
    _cloudSyncSummary = cloudSyncService.getSyncSummary();
    syncCoordinator.onLocalChange();
  }

  void queueSupplierForSync(String supplierId) {
    if (!isCloudWorkspaceActive || !_canUploadPurchasing) {
      return;
    }
    unawaited(
      cloudSyncService.queueLocalChange(
        entity: CloudSyncEntity.supplier,
        entityId: supplierId,
        operation: CloudSyncOperation.update,
      ),
    );
    _cloudSyncSummary = cloudSyncService.getSyncSummary();
    syncCoordinator.onLocalChange();
  }

  void queuePurchaseOrderForSync(String purchaseOrderId) {
    if (!isCloudWorkspaceActive || !_canUploadPurchasing) {
      return;
    }
    unawaited(
      cloudSyncService.queueLocalChange(
        entity: CloudSyncEntity.purchaseOrder,
        entityId: purchaseOrderId,
        operation: CloudSyncOperation.update,
      ),
    );
    _cloudSyncSummary = cloudSyncService.getSyncSummary();
    syncCoordinator.onLocalChange();
  }

  void queueCycleCountForSync(String countId) {
    if (!isCloudWorkspaceActive || !_canUploadCycleCounts) {
      return;
    }
    unawaited(
      cloudSyncService.queueLocalChange(
        entity: CloudSyncEntity.count,
        entityId: countId,
        operation: CloudSyncOperation.update,
      ),
    );
    _cloudSyncSummary = cloudSyncService.getSyncSummary();
    syncCoordinator.onLocalChange();
  }

  void queueCycleCountLineForSync(String countLineId) {
    if (!isCloudWorkspaceActive || !_canUploadCycleCounts) {
      return;
    }
    unawaited(
      cloudSyncService.queueLocalChange(
        entity: CloudSyncEntity.countLine,
        entityId: countLineId,
        operation: CloudSyncOperation.update,
      ),
    );
    _cloudSyncSummary = cloudSyncService.getSyncSummary();
    syncCoordinator.onLocalChange();
  }

  bool get _canUploadInventoryBalances =>
      permissions.canAdjustInventory ||
      permissions.canReceiveStock ||
      permissions.canIssueItems ||
      permissions.canTransferStock;

  bool get _canUploadInventoryTransactions => _canUploadInventoryBalances;

  bool get _canUploadCheckouts => permissions.canIssueItems;

  bool get _canUploadPurchasing =>
      permissions.canManageSuppliers || permissions.canManagePurchasing;

  bool get _canUploadCycleCounts =>
      permissions.canManageCycleCounts || permissions.canApproveCycleCounts;

  String get _defaultUnitOfMeasureId {
    for (final unit in _unitsOfMeasure) {
      if (unit.isActive) {
        return unit.id;
      }
    }
    return 'uom-each';
  }

  String get _defaultLocationId {
    for (final location in _locations) {
      if (location.isActive) {
        return location.id;
      }
    }
    return 'loc-main';
  }

  double? _varianceValueForCycleCountLine(CycleCountLine line) {
    final item = _itemById(line.itemId);
    final unitCost = item?.unitCost;
    final variance = line.varianceQuantity;
    if (unitCost == null || variance == null) {
      return null;
    }
    return variance * unitCost;
  }

  List<CheckoutRecord> get _checkoutsAllowedForCloudUpload {
    if (!_canUploadCheckouts) {
      return const [];
    }
    return _checkoutRecords;
  }

  Future<CloudAdoptionSummary?> _ensureCloudAdoptionSummary() async {
    if (!isCloudWorkspaceActive || _activeWorkspace == null) {
      return null;
    }
    final summary = _cloudAdoptionSummary;
    if (summary != null && summary.workspaceId == _activeWorkspace!.id) {
      return summary;
    }
    return refreshCloudAdoptionSummary(notify: false);
  }

  CloudAdoptionSummary _summaryWithPermissionGate(
    CloudAdoptionSummary summary,
  ) {
    if (summary.state != CloudAdoptionState.needsDecision ||
        permissions.isAdmin ||
        permissions.isManager ||
        summary.hasCloudBusinessData) {
      return summary;
    }
    return CloudAdoptionSummary(
      state: CloudAdoptionState.blocked,
      workspaceId: summary.workspaceId,
      workspaceName: summary.workspaceName,
      localItemCount: summary.localItemCount,
      localBalanceCount: summary.localBalanceCount,
      localTransactionCount: summary.localTransactionCount,
      localCheckoutCount: summary.localCheckoutCount,
      localSupplierCount: summary.localSupplierCount,
      localPurchasingCount: summary.localPurchasingCount,
      localCycleCountCount: summary.localCycleCountCount,
      cloudItemCount: summary.cloudItemCount,
      cloudBalanceCount: summary.cloudBalanceCount,
      cloudTransactionCount: summary.cloudTransactionCount,
      cloudCheckoutCount: summary.cloudCheckoutCount,
      cloudSupplierCount: summary.cloudSupplierCount,
      cloudPurchasingCount: summary.cloudPurchasingCount,
      cloudCycleCountCount: summary.cloudCycleCountCount,
      hasLocalBusinessData: summary.hasLocalBusinessData,
      hasCloudBusinessData: summary.hasCloudBusinessData,
      message: 'Ask an admin or manager to set up this workspace first.',
      completedChoice: summary.completedChoice,
      completedAt: summary.completedAt,
    );
  }

  DateTime? _localUploadCutoffFor(CloudAdoptionSummary? summary) {
    if (summary == null) {
      return null;
    }
    return summary.shouldProtectExistingLocalData ? summary.completedAt : null;
  }

  List<Item> _itemsForCloudUpload(DateTime? cutoff) {
    if (cutoff == null) {
      return _items;
    }
    return _items.where((item) => item.updatedAt.isAfter(cutoff)).toList();
  }

  List<ItemLocationBalance> _balancesForCloudUpload(DateTime? cutoff) {
    if (cutoff == null) {
      return _itemLocationBalances;
    }
    return _itemLocationBalances
        .where((balance) => balance.updatedAt.isAfter(cutoff))
        .toList();
  }

  List<InventoryTransaction> _transactionsForCloudUpload(DateTime? cutoff) {
    final allowed = _transactionsAllowedForCloudUpload;
    if (cutoff == null) {
      return allowed;
    }
    return allowed
        .where((transaction) => transaction.createdAt.isAfter(cutoff))
        .toList();
  }

  List<CheckoutRecord> _checkoutsForCloudUpload(DateTime? cutoff) {
    final allowed = _checkoutsAllowedForCloudUpload;
    if (cutoff == null) {
      return allowed;
    }
    return allowed.where((checkout) {
      final changedAt = checkout.returnedAt ?? checkout.checkedOutAt;
      return changedAt.isAfter(cutoff);
    }).toList();
  }

  List<Supplier> _suppliersForCloudUpload(DateTime? cutoff) {
    if (cutoff == null) {
      return _suppliers;
    }
    return _suppliers
        .where((supplier) => supplier.updatedAt.isAfter(cutoff))
        .toList();
  }

  List<ReorderRequest> _purchaseOrdersForCloudUpload(DateTime? cutoff) {
    if (cutoff == null) {
      return _reorderRequests;
    }
    return _reorderRequests.where((request) {
      final changedAt =
          request.receivedAt ??
          request.cancelledAt ??
          request.orderedAt ??
          request.createdAt;
      return changedAt.isAfter(cutoff);
    }).toList();
  }

  List<CycleCountSession> _cycleCountsForCloudUpload(DateTime? cutoff) {
    if (cutoff == null) {
      return _cycleCountSessions;
    }
    return _cycleCountSessions.where((session) {
      final changedAt =
          session.approvedAt ?? session.submittedAt ?? session.createdAt;
      return changedAt.isAfter(cutoff);
    }).toList();
  }

  List<CycleCountLine> _cycleCountLinesForCloudUpload(DateTime? cutoff) {
    if (cutoff == null) {
      return _cycleCountLines;
    }
    final eligibleSessionIds = _cycleCountsForCloudUpload(
      cutoff,
    ).map((session) => session.id).toSet();
    return _cycleCountLines
        .where((line) => eligibleSessionIds.contains(line.sessionId))
        .toList();
  }

  List<InventoryTransaction> get _transactionsAllowedForCloudUpload {
    if (permissions.isAdmin || permissions.isManager) {
      return _transactions;
    }
    if (!permissions.canIssueItems) {
      return const [];
    }
    return _transactions.where(_isWorkerWritableCloudTransaction).toList();
  }

  bool _isWorkerWritableCloudTransaction(InventoryTransaction transaction) {
    return switch (transaction.transactionType) {
      InventoryTransactionType.issue ||
      InventoryTransactionType.checkout ||
      InventoryTransactionType.returnItem ||
      InventoryTransactionType.markLost ||
      InventoryTransactionType.markDamaged => true,
      _ => false,
    };
  }

  CloudWorkspaceRole? _roleForCurrentCloudUser() {
    final userId = _currentCloudUser?.id;
    if (userId == null) {
      return null;
    }
    for (final member in _workspaceMembers) {
      if (member.userId == userId &&
          member.status == CloudWorkspaceMemberStatus.active) {
        return member.role;
      }
    }
    return null;
  }

  Future<void> _ensureBasePlanData() async {
    if ((await _database.getAllPlans()).isEmpty) {
      await _database.upsertPlan(samplePlan.toCompanion());
      _plan = samplePlan;
    }

    if ((await _database.getAllCompanyUsage()).isEmpty) {
      await _database.upsertCompanyUsage(sampleCompanyUsage.toCompanion());
      _companyUsage = sampleCompanyUsage;
    }
  }

  Future<void> _ensureCompanyForExistingData() async {
    if (_company != null || _items.isEmpty) {
      return;
    }

    final now = DateTime.now();
    _company = Company(
      id: 'company-local',
      name: 'Issued Demo Shop',
      industry: null,
      createdAt: now,
      updatedAt: now,
      setupCompleted: true,
    );
    await _database.upsertCompany(_company!.toCompanion());
  }

  Future<void> _ensureLocalTestUsers() async {
    var addedUsers = false;
    for (final person in samplePeople) {
      if (_people.any((storedPerson) => storedPerson.id == person.id)) {
        continue;
      }

      _people.add(person);
      await _database.upsertPerson(person.toCompanion());
      addedUsers = true;
    }
    for (final user in sampleUsers) {
      if (_users.any((storedUser) => storedUser.id == user.id)) {
        continue;
      }

      final userWithPin = _withPin(user, '1234');
      _users.add(userWithPin);
      await _database.upsertAppUser(userWithPin.toCompanion());
      addedUsers = true;
    }

    if (addedUsers) {
      await _loadFromDatabase();
    }
  }

  Future<void> _ensurePinsForMigratedLocalUsers() async {
    var changed = false;
    final seedUserIds = {
      for (final user in sampleUsers) user.id,
      'user-first-admin',
    };
    for (final user in List<AppUser>.from(_users)) {
      if (!seedUserIds.contains(user.id)) {
        continue;
      }
      final hasPin =
          (user.pinHash?.isNotEmpty ?? false) &&
          (user.pinSalt?.isNotEmpty ?? false);
      if (hasPin) {
        continue;
      }
      final userWithPin = _withPin(user, '1234');
      _upsertUserInMemory(userWithPin);
      await _database.upsertAppUser(userWithPin.toCompanion());
      changed = true;
    }
    if (changed) {
      await _loadFromDatabase();
    }
  }

  Future<void> _seedAssignmentTargetsIfNeeded() async {
    if (_assignmentTargets.isNotEmpty) {
      return;
    }
    final now = DateTime.now();
    final targets = [
      AssignmentTarget(
        id: 'target-service-truck-1',
        name: 'Service Truck 1',
        targetType: AssignmentTargetType.truck,
        code: 'TRUCK-1',
        description: null,
        locationId: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      AssignmentTarget(
        id: 'target-job-1001',
        name: 'Job 1001',
        targetType: AssignmentTargetType.job,
        code: 'JOB-1001',
        description: null,
        locationId: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      AssignmentTarget(
        id: 'target-maintenance-department',
        name: 'Maintenance Department',
        targetType: AssignmentTargetType.department,
        code: null,
        description: null,
        locationId: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      AssignmentTarget(
        id: 'target-job-box-a',
        name: 'Job Box A',
        targetType: AssignmentTargetType.jobBox,
        code: 'BOX-A',
        description: null,
        locationId: null,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    _assignmentTargets.addAll(targets);
    for (final target in targets) {
      await _database.upsertAssignmentTarget(target.toCompanion());
    }
  }

  bool addAssignmentTarget(AssignmentTarget target) {
    if (!permissions.canManageSettings) {
      return false;
    }
    if (_hasDuplicateActiveAssignmentTarget(target)) {
      return false;
    }
    _assignmentTargets.add(target);
    unawaited(_database.upsertAssignmentTarget(target.toCompanion()));
    notifyListeners();
    return true;
  }

  bool updateAssignmentTarget(AssignmentTarget target) {
    if (!permissions.canManageSettings) {
      return false;
    }
    final index = _assignmentTargets.indexWhere(
      (stored) => stored.id == target.id,
    );
    if (index == -1) {
      return false;
    }
    if (_hasDuplicateActiveAssignmentTarget(target)) {
      return false;
    }
    _assignmentTargets[index] = target.copyWith(updatedAt: DateTime.now());
    unawaited(
      _database.upsertAssignmentTarget(_assignmentTargets[index].toCompanion()),
    );
    notifyListeners();
    return true;
  }

  bool archiveAssignmentTarget(String targetId) {
    final target = _assignmentTargetById(targetId);
    if (target == null) {
      return false;
    }
    return updateAssignmentTarget(
      target.copyWith(isActive: false, updatedAt: DateTime.now()),
    );
  }

  bool hasOpenCheckoutForAssignmentTarget(String targetId) {
    return openCheckoutRecords.any(
      (record) => record.assignedToTargetId == targetId,
    );
  }

  bool _hasDuplicateActiveAssignmentTarget(AssignmentTarget target) {
    if (!target.isActive) {
      return false;
    }
    final normalizedName = target.name.trim().toLowerCase();
    return _assignmentTargets.any((existing) {
      return existing.id != target.id &&
          existing.isActive &&
          existing.targetType == target.targetType &&
          existing.name.trim().toLowerCase() == normalizedName;
    });
  }

  Future<void> _seedSampleDataIfNeeded() async {
    for (final unit in sampleUnitsOfMeasure) {
      await _ensureUnitOfMeasure(unit);
    }
    for (final location in sampleLocations) {
      await _ensureLocation(location.name, location.type, id: location.id);
    }
    for (final person in samplePeople) {
      await _ensurePerson(person);
    }
    for (final user in sampleUsers) {
      await _ensureUser(user);
    }
    for (final item in sampleItems) {
      if (_items.any((storedItem) => storedItem.id == item.id)) {
        continue;
      }
      _items.add(item);
      await _database.upsertItem(item.toCompanion());
    }
    for (final transaction in sampleTransactions) {
      if (_transactions.any(
        (storedTransaction) => storedTransaction.id == transaction.id,
      )) {
        continue;
      }
      _transactions.add(transaction);
      await _database.upsertTransaction(transaction.toCompanion());
    }
    for (final session in sampleCycleCountSessions) {
      if (_cycleCountSessions.any(
        (storedSession) => storedSession.id == session.id,
      )) {
        continue;
      }
      _cycleCountSessions.add(session);
      await _database.upsertCycleCountSession(session.toCompanion());
    }
    for (final line in sampleCycleCountLines) {
      if (_cycleCountLines.any((storedLine) => storedLine.id == line.id)) {
        continue;
      }
      _cycleCountLines.add(line);
      await _database.upsertCycleCountLine(line.toCompanion());
    }
    for (final field in sampleCustomFieldDefinitions) {
      if (_customFieldDefinitions.any(
        (storedField) => storedField.id == field.id,
      )) {
        continue;
      }
      _customFieldDefinitions.add(field);
      await _database.upsertCustomFieldDefinition(field.toCompanion());
    }
    for (final value in sampleCustomFieldValues) {
      if (_customFieldValues.any((storedValue) => storedValue.id == value.id)) {
        continue;
      }
      _customFieldValues.add(value);
      await _database.upsertCustomFieldValue(value.toCompanion());
    }
  }

  Future<void> _ensureDefaultUnitsOfMeasure() async {
    const defaultUnits = [
      UnitOfMeasure(
        id: 'uom-each',
        name: 'Each',
        abbreviation: 'ea',
        allowsDecimal: false,
        isActive: true,
      ),
      UnitOfMeasure(
        id: 'uom-box',
        name: 'Box',
        abbreviation: 'box',
        allowsDecimal: false,
        isActive: true,
      ),
      UnitOfMeasure(
        id: 'uom-case',
        name: 'Case',
        abbreviation: 'case',
        allowsDecimal: false,
        isActive: true,
      ),
      UnitOfMeasure(
        id: 'uom-pair',
        name: 'Pair',
        abbreviation: 'pair',
        allowsDecimal: false,
        isActive: true,
      ),
      UnitOfMeasure(
        id: 'uom-foot',
        name: 'Foot',
        abbreviation: 'ft',
        allowsDecimal: true,
        isActive: true,
      ),
      UnitOfMeasure(
        id: 'uom-gallon',
        name: 'Gallon',
        abbreviation: 'gal',
        allowsDecimal: true,
        isActive: true,
      ),
      UnitOfMeasure(
        id: 'uom-quart',
        name: 'Quart',
        abbreviation: 'qt',
        allowsDecimal: true,
        isActive: true,
      ),
      UnitOfMeasure(
        id: 'uom-pound',
        name: 'Pound',
        abbreviation: 'lb',
        allowsDecimal: true,
        isActive: true,
      ),
      UnitOfMeasure(
        id: 'uom-set',
        name: 'Set',
        abbreviation: 'set',
        allowsDecimal: false,
        isActive: true,
      ),
      UnitOfMeasure(
        id: 'uom-kit',
        name: 'Kit',
        abbreviation: 'kit',
        allowsDecimal: false,
        isActive: true,
      ),
    ];

    for (final unit in defaultUnits) {
      await _ensureUnitOfMeasure(unit);
    }
  }

  Future<void> _ensureUnitOfMeasure(UnitOfMeasure unit) async {
    final exists = _unitsOfMeasure.any((storedUnit) {
      return storedUnit.id == unit.id ||
          storedUnit.name.toLowerCase() == unit.name.toLowerCase() ||
          storedUnit.abbreviation.toLowerCase() ==
              unit.abbreviation.toLowerCase();
    });
    if (exists) {
      return;
    }

    _unitsOfMeasure.add(unit);
    await _database.upsertUnitOfMeasure(unit.toCompanion());
  }

  Future<void> _ensureLocation(String name, String type, {String? id}) async {
    final normalizedName = name.trim();
    final existing = _locations.any((location) {
      return location.id == id ||
          location.name.toLowerCase() == normalizedName.toLowerCase();
    });
    if (existing) {
      return;
    }

    final location = Location(
      id: id ?? 'loc-${DateTime.now().microsecondsSinceEpoch}',
      name: normalizedName,
      description: null,
      code: null,
      type: type,
      parentLocationId: null,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _locations.add(location);
    await _database.upsertLocation(location.toCompanion());
  }

  Future<void> _ensureAdminUser(
    String displayName,
    String? email,
    String pin,
    DateTime now,
  ) async {
    final person = Person(
      id: 'person-first-admin',
      displayName: displayName,
      email: email,
      phone: null,
      isActive: true,
      isLoginUser: true,
    );
    await _ensurePerson(person);

    final user = AppUser(
      id: 'user-first-admin',
      personId: person.id,
      email: email ?? 'admin@issued.local',
      role: UserRole.admin,
      isActive: true,
      pinHash: null,
      pinSalt: null,
      createdAt: now,
      updatedAt: now,
      lastLoginAt: null,
    );
    await _ensureUser(_withPin(user, pin));
    _currentUserId = user.id;
    _isLocked = false;
    _lastActivityAt = now;
  }

  Future<void> _ensurePerson(Person person) async {
    final exists = _people.any((storedPerson) {
      final emailMatches =
          person.email != null &&
          storedPerson.email?.toLowerCase() == person.email!.toLowerCase();
      return storedPerson.id == person.id || emailMatches;
    });
    if (exists) {
      return;
    }

    _people.add(person);
    await _database.upsertPerson(person.toCompanion());
  }

  Future<void> _ensureUser(AppUser user) async {
    final existingIndex = _users.indexWhere((storedUser) {
      return storedUser.id == user.id ||
          storedUser.email.toLowerCase() == user.email.toLowerCase();
    });
    if (existingIndex != -1) {
      final existing = _users[existingIndex];
      final existingHasPin =
          (existing.pinHash?.isNotEmpty ?? false) &&
          (existing.pinSalt?.isNotEmpty ?? false);
      final incomingHasPin =
          (user.pinHash?.isNotEmpty ?? false) &&
          (user.pinSalt?.isNotEmpty ?? false);
      if (!existingHasPin && incomingHasPin) {
        final updated = existing.copyWith(
          pinHash: user.pinHash,
          pinSalt: user.pinSalt,
          updatedAt: DateTime.now(),
        );
        _users[existingIndex] = updated;
        await _database.upsertAppUser(updated.toCompanion());
      }
      return;
    }

    _users.add(user);
    await _database.upsertAppUser(user.toCompanion());
  }

  AppUser _withPin(AppUser user, String pin) {
    final salt = _pinHashService.generateSalt();
    return user.copyWith(
      pinSalt: salt,
      pinHash: _pinHashService.hashPin(pin, salt),
      updatedAt: DateTime.now(),
    );
  }

  void _upsertUserInMemory(AppUser user) {
    final index = _users.indexWhere((storedUser) => storedUser.id == user.id);
    if (index == -1) {
      _users.add(user);
    } else {
      _users[index] = user;
    }
  }

  Future<void> _loadFromDatabase() async {
    _unitsOfMeasure
      ..clear()
      ..addAll(
        (await _database.getAllUnitsOfMeasure()).map((row) => row.toDomain()),
      );
    _locations
      ..clear()
      ..addAll(
        (await _database.getAllLocations()).map((row) => row.toDomain()),
      );
    _people
      ..clear()
      ..addAll((await _database.getAllPeople()).map((row) => row.toDomain()));
    _users
      ..clear()
      ..addAll((await _database.getAllAppUsers()).map((row) => row.toDomain()));
    _items
      ..clear()
      ..addAll((await _database.getAllItems()).map((row) => row.toDomain()));
    _transactions
      ..clear()
      ..addAll(
        (await _database.getAllTransactions()).map((row) => row.toDomain()),
      );
    _itemLocationBalances
      ..clear()
      ..addAll(
        (await _database.getAllItemLocationBalances()).map(
          (row) => row.toDomain(),
        ),
      );
    _checkoutRecords
      ..clear()
      ..addAll(
        (await _database.getAllCheckoutRecords()).map((row) => row.toDomain()),
      );
    _assignmentTargets
      ..clear()
      ..addAll(
        (await _database.getAllAssignmentTargets()).map(
          (row) => row.toDomain(),
        ),
      );
    _suppliers
      ..clear()
      ..addAll(
        (await _database.getAllSuppliers()).map((row) => row.toDomain()),
      );
    _reorderRequests
      ..clear()
      ..addAll(
        (await _database.getAllReorderRequests()).map((row) => row.toDomain()),
      );
    _cycleCountSessions
      ..clear()
      ..addAll(
        (await _database.getAllCycleCountSessions()).map(
          (row) => row.toDomain(),
        ),
      );
    _cycleCountLines
      ..clear()
      ..addAll(
        (await _database.getAllCycleCountLines()).map((row) => row.toDomain()),
      );
    _customFieldDefinitions
      ..clear()
      ..addAll(
        (await _database.getAllCustomFieldDefinitions()).map(
          (row) => row.toDomain(),
        ),
      );
    _customFieldValues
      ..clear()
      ..addAll(
        (await _database.getAllCustomFieldValues()).map(
          (row) => row.toDomain(),
        ),
      );

    final companies = await _database.getAllCompanies();
    _company = companies.isEmpty ? null : companies.first.toDomain();
    final plans = await _database.getAllPlans();
    _plan = plans.isEmpty ? samplePlan : plans.first.toDomain();
    final usages = await _database.getAllCompanyUsage();
    _companyUsage = usages.isEmpty
        ? sampleCompanyUsage
        : usages.first.toDomain();
  }

  AppActionResult addItem(Item item) {
    if (!permissions.canManageItems) {
      return AppActionResult.denied();
    }
    if (item.isActive && !canAddItem) {
      return AppActionResult.failure(
        'Your ${currentPlan.name} plan includes up to ${currentPlan.itemLimit} active items.',
      );
    }
    _items.add(item);
    unawaited(_database.upsertItem(item.toCompanion()));
    _queueItemCatalogChange(item.id, CloudSyncOperation.create);
    notifyListeners();
    return const AppActionResult.success(message: 'Item added.');
  }

  AppActionResult addItemWithInitialBalance(
    Item item,
    String locationId, {
    String? initialTransactionNotes,
  }) {
    if (!permissions.canManageItems) {
      return AppActionResult.denied();
    }
    if (item.isActive && !canAddItem) {
      return AppActionResult.failure(
        'Your ${currentPlan.name} plan includes up to ${currentPlan.itemLimit} active items.',
      );
    }
    _items.add(item);
    unawaited(_database.upsertItem(item.toCompanion()));
    _queueItemCatalogChange(item.id, CloudSyncOperation.create);
    final balance = ItemLocationBalance(
      id: _balanceId(item.id, locationId),
      itemId: item.id,
      locationId: locationId,
      quantityOnHand: item.quantityOnHand,
      minimumQuantity: 0,
      updatedAt: item.updatedAt,
    );
    _upsertBalanceInMemory(balance);
    unawaited(_database.upsertItemLocationBalance(balance.toCompanion()));
    queueBalanceForSync(balance.id);
    if (item.quantityOnHand > 0) {
      _appendInventoryTransaction(
        itemId: item.id,
        type: InventoryTransactionType.receive,
        quantityDelta: item.quantityOnHand,
        toLocationId: locationId,
        notes: initialTransactionNotes ?? 'Starting quantity',
      );
    }
    notifyListeners();
    return const AppActionResult.success(message: 'Item added.');
  }

  AppActionResult updateItem(Item item) {
    if (!permissions.canManageItems) {
      return AppActionResult.denied();
    }
    final itemIndex = _items.indexWhere(
      (storedItem) => storedItem.id == item.id,
    );
    if (itemIndex == -1) {
      return AppActionResult.failure('Item not found.');
    }

    final savedItem = item.copyWith(
      quantityOnHand: _items[itemIndex].quantityOnHand,
    );
    _items[itemIndex] = savedItem;
    unawaited(_database.upsertItem(savedItem.toCompanion()));
    _queueItemCatalogChange(savedItem.id, CloudSyncOperation.update);
    notifyListeners();
    return const AppActionResult.success(message: 'Item updated.');
  }

  AppActionResult archiveItem(String itemId) {
    if (!permissions.canArchiveItems) {
      return AppActionResult.denied();
    }
    final item = _itemById(itemId);
    if (item == null) {
      return AppActionResult.failure('Item not found.');
    }
    return updateItem(
      item.copyWith(isActive: false, updatedAt: DateTime.now()),
    );
  }

  AppActionResult unarchiveItem(String itemId) {
    if (!permissions.canArchiveItems) {
      return AppActionResult.denied();
    }
    if (!canAddItem) {
      return AppActionResult.failure(
        'Your ${currentPlan.name} plan includes up to ${currentPlan.itemLimit} active items.',
      );
    }
    final item = _itemById(itemId);
    if (item == null) {
      return AppActionResult.failure('Item not found.');
    }
    return updateItem(item.copyWith(isActive: true, updatedAt: DateTime.now()));
  }

  void recordLabelExport() {
    _companyUsage = _companyUsage.copyWith(
      labelExportCount: _companyUsage.labelExportCount + 1,
    );
    unawaited(_database.upsertCompanyUsage(_companyUsage.toCompanion()));
    notifyListeners();
  }

  bool get canAddItem => currentUsage.activeItemCount < currentPlan.itemLimit;
  bool get canAddLocation =>
      currentUsage.locationCount < currentPlan.locationLimit;
  bool get canAddUser => currentUsage.userCount < currentPlan.userLimit;
  bool get canExportLabel =>
      currentUsage.labelExportCount < currentPlan.labelExportLimit;
  bool get canAddPhoto => currentUsage.photoCount < currentPlan.photoLimit;

  PlanLimitWarning? getLimitWarningForItems() {
    return _limitWarning(
      kind: PlanLimitKind.items,
      used: currentUsage.activeItemCount,
      limit: currentPlan.itemLimit,
      unitLabel: 'item slots',
    );
  }

  PlanLimitWarning? getLimitWarningForLocations() {
    return _limitWarning(
      kind: PlanLimitKind.locations,
      used: currentUsage.locationCount,
      limit: currentPlan.locationLimit,
      unitLabel: 'location slots',
    );
  }

  PlanLimitWarning? getLimitWarningForUsers() {
    return _limitWarning(
      kind: PlanLimitKind.users,
      used: currentUsage.userCount,
      limit: currentPlan.userLimit,
      unitLabel: 'login user slots',
    );
  }

  PlanLimitWarning? getLimitWarningForLabels() {
    return _limitWarning(
      kind: PlanLimitKind.labels,
      used: currentUsage.labelExportCount,
      limit: currentPlan.labelExportLimit,
      unitLabel: 'monthly label exports',
    );
  }

  PlanLimitWarning? getLimitWarningForPhotos() {
    return _limitWarning(
      kind: PlanLimitKind.photos,
      used: currentUsage.photoCount,
      limit: currentPlan.photoLimit,
      unitLabel: 'photo slots',
    );
  }

  List<PlanLimitWarning> getLimitWarnings() {
    final warnings = [
      getLimitWarningForItems(),
      getLimitWarningForLocations(),
      getLimitWarningForUsers(),
      getLimitWarningForLabels(),
      getLimitWarningForPhotos(),
    ].whereType<PlanLimitWarning>().toList();

    warnings.sort((left, right) {
      return _severityRank(
        right.severity,
      ).compareTo(_severityRank(left.severity));
    });

    return warnings;
  }

  void setCurrentPlanForTesting(String planCode) {
    final plan = samplePlans.firstWhere(
      (plan) => plan.code == planCode,
      orElse: () => samplePlan,
    );
    _plan = plan;
    unawaited(_database.upsertPlan(plan.toCompanion()));
    notifyListeners();
  }

  void setCurrentUserForTesting(String userId) {
    for (final user in _users) {
      if (user.id == userId && user.isActive) {
        _currentUserId = userId;
        _isLocked = false;
        _lastActivityAt = DateTime.now();
        notifyListeners();
        return;
      }
    }
  }

  Future<AppActionResult> signInLocalUser(String userId, String pin) async {
    final normalizedPin = pin.trim();
    if (!_pinHashService.isValidPin(normalizedPin)) {
      return const AppActionResult.failure('PIN must be 4-8 digits.');
    }

    AppUser? user;
    for (final candidate in _users) {
      if (candidate.id == userId) {
        user = candidate;
        break;
      }
    }
    if (user == null) {
      return const AppActionResult.failure('User not found.');
    }
    if (!user.isActive) {
      return const AppActionResult.failure('This user is inactive.');
    }
    final salt = user.pinSalt;
    final hash = user.pinHash;
    if (salt == null || hash == null || salt.isEmpty || hash.isEmpty) {
      return const AppActionResult.failure(
        'Your account is not set up with a PIN.',
      );
    }
    if (!_pinHashService.verifyPin(normalizedPin, salt, hash)) {
      return const AppActionResult.failure('Incorrect PIN.');
    }

    final now = DateTime.now();
    final signedInUser = user.copyWith(lastLoginAt: now, updatedAt: now);
    _upsertUserInMemory(signedInUser);
    await _database.upsertAppUser(signedInUser.toCompanion());
    _currentUserId = userId;
    _isLocked = false;
    _lastActivityAt = now;
    notifyListeners();
    return AppActionResult.success(
      message: 'Signed in as ${resolveUserName(userId)}.',
    );
  }

  Future<AppActionResult> switchUser(String userId, String pin) {
    return signInLocalUser(userId, pin);
  }

  Future<AppActionResult> unlockSession(String userId, String pin) {
    return signInLocalUser(userId, pin);
  }

  void lockSession({bool clearCurrentUser = false}) {
    _isLocked = true;
    if (clearCurrentUser) {
      _currentUserId = null;
    }
    notifyListeners();
  }

  void recordUserActivity() {
    if (!isLocked) {
      _lastActivityAt = DateTime.now();
    }
  }

  bool checkSessionTimeout() {
    if (isLocked || _sessionTimeoutMinutes <= 0 || _lastActivityAt == null) {
      return false;
    }
    final elapsed = DateTime.now().difference(_lastActivityAt!);
    if (elapsed.inMinutes >= _sessionTimeoutMinutes) {
      lockSession();
      return true;
    }
    return false;
  }

  void setSessionTimeoutMinutes(int minutes) {
    _sessionTimeoutMinutes = minutes;
    notifyListeners();
  }

  Future<AppActionResult> createLocalUser({
    required String displayName,
    required String? email,
    required UserRole role,
    required String? pin,
  }) async {
    if (!permissions.canManageUsers) {
      return AppActionResult.denied();
    }
    if (!canAddUser) {
      return AppActionResult.failure(
        'Your ${currentPlan.name} plan includes up to ${currentPlan.userLimit} login users.',
      );
    }

    final normalizedName = displayName.trim();
    if (normalizedName.isEmpty) {
      return const AppActionResult.failure('User name is required.');
    }
    final normalizedEmail = _emptyToNull(email) ?? '';
    final normalizedPin = pin?.trim() ?? '';
    if (_roleRequiresPin(role) && !_pinHashService.isValidPin(normalizedPin)) {
      return const AppActionResult.failure('PIN must be 4-8 digits.');
    }

    final now = DateTime.now();
    final idSuffix = now.microsecondsSinceEpoch;
    final person = Person(
      id: 'person-local-$idSuffix',
      displayName: normalizedName,
      email: normalizedEmail.isEmpty ? null : normalizedEmail,
      phone: null,
      isActive: true,
      isLoginUser: true,
    );
    var user = AppUser(
      id: 'user-local-$idSuffix',
      personId: person.id,
      email: normalizedEmail.isEmpty
          ? 'user-$idSuffix@issued.local'
          : normalizedEmail,
      role: role,
      isActive: true,
      pinHash: null,
      pinSalt: null,
      createdAt: now,
      updatedAt: now,
      lastLoginAt: null,
    );
    if (normalizedPin.isNotEmpty) {
      user = _withPin(user, normalizedPin);
    }

    _people.add(person);
    _users.add(user);
    await _database.upsertPerson(person.toCompanion());
    await _database.upsertAppUser(user.toCompanion());
    notifyListeners();
    return const AppActionResult.success(message: 'User added.');
  }

  Future<AppActionResult> updateLocalUser({
    required String userId,
    required String displayName,
    required String? email,
    required UserRole role,
    required bool isActive,
    String? pin,
  }) async {
    if (!permissions.canManageUsers) {
      return AppActionResult.denied();
    }
    final index = _users.indexWhere((user) => user.id == userId);
    if (index == -1) {
      return const AppActionResult.failure('User not found.');
    }
    final existing = _users[index];
    if (!_canChangeAdminStatus(existing, role, isActive)) {
      return const AppActionResult.failure(
        'Issued must keep at least one active Admin user.',
      );
    }

    final normalizedPin = pin?.trim() ?? '';
    if (_roleRequiresPin(role) &&
        existing.pinHash == null &&
        !_pinHashService.isValidPin(normalizedPin)) {
      return const AppActionResult.failure('PIN must be 4-8 digits.');
    }
    if (normalizedPin.isNotEmpty &&
        !_pinHashService.isValidPin(normalizedPin)) {
      return const AppActionResult.failure('PIN must be 4-8 digits.');
    }

    final normalizedEmail = _emptyToNull(email) ?? existing.email;
    final now = DateTime.now();
    var updated = existing.copyWith(
      email: normalizedEmail,
      role: role,
      isActive: isActive,
      updatedAt: now,
    );
    if (normalizedPin.isNotEmpty) {
      updated = _withPin(updated, normalizedPin);
    }
    _users[index] = updated;

    final personIndex = _people.indexWhere(
      (person) => person.id == existing.personId,
    );
    if (personIndex != -1) {
      final person = _people[personIndex].copyWith(
        displayName: displayName.trim(),
        email: normalizedEmail.isEmpty ? null : normalizedEmail,
        isActive: isActive,
        isLoginUser: true,
      );
      _people[personIndex] = person;
      await _database.upsertPerson(person.toCompanion());
    }
    await _database.upsertAppUser(updated.toCompanion());
    if (_currentUserId == updated.id && !updated.isActive) {
      lockSession(clearCurrentUser: true);
    } else {
      notifyListeners();
    }
    return const AppActionResult.success(message: 'User updated.');
  }

  bool _roleRequiresPin(UserRole role) {
    return role != UserRole.viewOnly;
  }

  bool _canChangeAdminStatus(AppUser user, UserRole newRole, bool isActive) {
    if (user.role != UserRole.admin) {
      return true;
    }
    if (newRole == UserRole.admin && isActive) {
      return true;
    }
    final otherActiveAdmins = _users.where((candidate) {
      return candidate.id != user.id &&
          candidate.isActive &&
          candidate.role == UserRole.admin;
    }).length;
    return otherActiveAdmins > 0;
  }

  Future<void> completeSetup({
    required String companyName,
    required String? industry,
    required String locationName,
    required String locationType,
    required String adminDisplayName,
    required String? adminEmail,
    required String adminPin,
    required bool includeSampleData,
  }) async {
    final now = DateTime.now();
    final normalizedCompanyName = companyName.trim();
    final normalizedIndustry = _emptyToNull(industry);
    final normalizedLocationName = locationName.trim();
    final normalizedAdminName = adminDisplayName.trim();
    final normalizedEmail = _emptyToNull(adminEmail);

    _company = Company(
      id: _company?.id ?? 'company-local',
      name: normalizedCompanyName,
      industry: normalizedIndustry,
      createdAt: _company?.createdAt ?? now,
      updatedAt: now,
      setupCompleted: true,
    );
    await _database.upsertCompany(_company!.toCompanion());

    await _ensureDefaultUnitsOfMeasure();
    await _ensureLocation(normalizedLocationName, locationType);
    await _ensureAdminUser(normalizedAdminName, normalizedEmail, adminPin, now);

    if (includeSampleData && _items.isEmpty) {
      await _seedSampleDataIfNeeded();
    }

    await _loadFromDatabase();
    _currentUserId = 'user-first-admin';
    _isLocked = false;
    _lastActivityAt = DateTime.now();
    notifyListeners();
  }

  Future<void> updateCompany({
    required String name,
    required String? industry,
  }) async {
    if (!permissions.canManageSettings) {
      return;
    }

    final now = DateTime.now();
    _company = Company(
      id: _company?.id ?? 'company-local',
      name: name.trim(),
      industry: _emptyToNull(industry),
      createdAt: _company?.createdAt ?? now,
      updatedAt: now,
      setupCompleted: _company?.setupCompleted ?? true,
    );
    await _database.upsertCompany(_company!.toCompanion());
    notifyListeners();
  }

  Future<void> resetOnboardingForTesting() async {
    if (!permissions.canManageSettings) {
      return;
    }

    final now = DateTime.now();
    _company = Company(
      id: _company?.id ?? 'company-local',
      name: _company?.name ?? 'Issued Workspace',
      industry: _company?.industry,
      createdAt: _company?.createdAt ?? now,
      updatedAt: now,
      setupCompleted: false,
    );
    await _database.upsertCompany(_company!.toCompanion());
    notifyListeners();
  }

  Future<BackupValidationResult> restoreFromBackupJson(String jsonText) async {
    if (!(currentRole == UserRole.admin ||
        (currentRole == UserRole.manager &&
            permissions.canImportExport &&
            permissions.canManageSettings))) {
      return const BackupValidationResult(
        isValid: false,
        message: 'Your current role does not allow this action.',
        errors: ['Your current role does not allow this action.'],
      );
    }

    final service = const BackupService();
    final validation = service.validateBackupJson(jsonText);
    if (!validation.isValid) {
      return validation;
    }

    final backup = service.parseBackupData(jsonText);
    if (backup == null) {
      return const BackupValidationResult(
        isValid: false,
        message: 'Could not read backup data.',
        errors: ['Could not read backup data.'],
      );
    }

    await _database.restoreWorkspaceData(
      unitRows: backup.unitsOfMeasure
          .map((unit) => unit.toCompanion())
          .toList(),
      locationRows: backup.locations
          .map((location) => location.toCompanion())
          .toList(),
      personRows: backup.people.map((person) => person.toCompanion()).toList(),
      userRows: backup.users.map((user) => user.toCompanion()).toList(),
      itemRows: backup.items.map((item) => item.toCompanion()).toList(),
      balanceRows: backup.itemLocationBalances
          .map((balance) => balance.toCompanion())
          .toList(),
      supplierRows: backup.suppliers
          .map((supplier) => supplier.toCompanion())
          .toList(),
      transactionRows: backup.transactions
          .map((transaction) => transaction.toCompanion())
          .toList(),
      checkoutRows: backup.checkoutRecords
          .map((record) => record.toCompanion())
          .toList(),
      assignmentTargetRows: backup.assignmentTargets
          .map((target) => target.toCompanion())
          .toList(),
      reorderRows: backup.reorderRequests
          .map((request) => request.toCompanion())
          .toList(),
      cycleSessionRows: backup.cycleCountSessions
          .map((session) => session.toCompanion())
          .toList(),
      cycleLineRows: backup.cycleCountLines
          .map((line) => line.toCompanion())
          .toList(),
      customFieldRows: backup.customFieldDefinitions
          .map((field) => field.toCompanion())
          .toList(),
      customValueRows: backup.customFieldValues
          .map((value) => value.toCompanion())
          .toList(),
      planRows: [if (backup.plan != null) backup.plan!.toCompanion()],
      usageRows: [
        if (backup.companyUsage != null) backup.companyUsage!.toCompanion(),
      ],
      companyRows: [if (backup.company != null) backup.company!.toCompanion()],
    );

    await _loadFromDatabase();
    _currentUserId = null;
    _isLocked = true;
    _lastActivityAt = null;
    await _ensureBasePlanData();
    await _loadFromDatabase();
    notifyListeners();

    return BackupValidationResult(
      isValid: true,
      message: 'Backup restored.',
      warnings: [...validation.warnings, ...backup.warnings],
      counts: validation.counts,
      companyName: validation.companyName,
      backupVersion: validation.backupVersion,
      createdAt: validation.createdAt,
    );
  }

  DataHealthReport runDataHealthCheck() {
    return const DataHealthService().run(this);
  }

  Future<bool> repairDataHealthIssue(String issueId) async {
    if (!_canRepairDataHealth) {
      return false;
    }

    final report = runDataHealthCheck();
    DataHealthIssue? issue;
    for (final candidate in report.issues) {
      if (candidate.id == issueId) {
        issue = candidate;
        break;
      }
    }
    if (issue == null || !issue.canRepair || issue.repairAction == null) {
      return false;
    }

    return _repairDataHealthIssue(issue);
  }

  Future<int> repairAllSafeDataHealthIssues() async {
    if (!_canRepairDataHealth) {
      return 0;
    }

    var repaired = 0;
    var report = runDataHealthCheck();
    while (true) {
      final safeIssues = report.issues.where((issue) {
        return issue.canRepair && issue.repairAction != null;
      }).toList();
      if (safeIssues.isEmpty) {
        return repaired;
      }

      var changed = false;
      for (final issue in safeIssues) {
        if (await _repairDataHealthIssue(issue)) {
          repaired += 1;
          changed = true;
        }
      }
      if (!changed) {
        return repaired;
      }
      report = runDataHealthCheck();
    }
  }

  bool get _canRepairDataHealth {
    return currentRole == UserRole.admin ||
        (currentRole == UserRole.manager &&
            permissions.canManageSettings &&
            permissions.canManageItems);
  }

  Future<bool> _repairDataHealthIssue(DataHealthIssue issue) {
    return switch (issue.repairAction) {
      DataHealthRepairAction.syncItemQuantityFromBalances =>
        syncItemQuantityFromBalances(issue.affectedRecordId ?? ''),
      DataHealthRepairAction.createMissingBalanceForItem =>
        createMissingBalanceForItem(issue.affectedRecordId ?? ''),
      DataHealthRepairAction.reassignBalanceToFallbackLocation =>
        reassignBalanceToFallbackLocation(issue.affectedRecordId ?? ''),
      DataHealthRepairAction.cancelOrphanReorderRequest =>
        cancelOrphanReorderRequest(issue.affectedRecordId ?? ''),
      DataHealthRepairAction.removeOrphanCustomFieldValue =>
        removeOrphanCustomFieldValue(issue.affectedRecordId ?? ''),
      DataHealthRepairAction.resetNegativeMinimumQuantity =>
        resetNegativeMinimumQuantity(issue.affectedRecordId ?? ''),
      DataHealthRepairAction.createMissingDefaultSetup =>
        createMissingDefaultSetup(),
      DataHealthRepairAction.clearInvalidLocationParent =>
        clearInvalidLocationParent(issue.affectedRecordId ?? ''),
      null => Future.value(false),
    };
  }

  Future<bool> syncItemQuantityFromBalances(String itemId) async {
    final itemIndex = _items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) {
      return false;
    }
    final now = DateTime.now();
    final updatedItem = _items[itemIndex].copyWith(
      quantityOnHand: totalQuantityForItem(itemId),
      updatedAt: now,
    );
    _items[itemIndex] = updatedItem;
    await _database.upsertItem(updatedItem.toCompanion());
    notifyListeners();
    return true;
  }

  Future<bool> createMissingBalanceForItem(String itemId) async {
    final item = _itemById(itemId);
    if (item == null || itemBalancesForItem(itemId).isNotEmpty) {
      return false;
    }
    final locationId =
        _locationById(item.locationId)?.id ?? _firstActiveLocationId();
    if (locationId == null) {
      return false;
    }

    final balance = ItemLocationBalance(
      id: _balanceId(itemId, locationId),
      itemId: itemId,
      locationId: locationId,
      quantityOnHand: item.quantityOnHand,
      minimumQuantity: 0,
      updatedAt: DateTime.now(),
    );
    _upsertBalanceInMemory(balance);
    await _database.upsertItemLocationBalance(balance.toCompanion());
    queueBalanceForSync(balance.id);
    notifyListeners();
    return true;
  }

  Future<bool> clearInvalidLocationParent(String locationId) async {
    final index = _locations.indexWhere(
      (location) => location.id == locationId,
    );
    if (index == -1) {
      return false;
    }
    final updated = _locations[index].copyWith(
      clearParentLocationId: true,
      updatedAt: DateTime.now(),
    );
    _locations[index] = updated;
    await _database.upsertLocation(updated.toCompanion());
    notifyListeners();
    return true;
  }

  Future<bool> reassignBalanceToFallbackLocation(String balanceId) async {
    final balanceIndex = _itemLocationBalances.indexWhere(
      (balance) => balance.id == balanceId,
    );
    if (balanceIndex == -1) {
      return false;
    }
    final balance = _itemLocationBalances[balanceIndex];
    final item = _itemById(balance.itemId);
    final fallbackLocationId =
        item != null && _locationById(item.locationId) != null
        ? item.locationId
        : _firstActiveLocationId();
    if (fallbackLocationId == null) {
      return false;
    }

    final existing = _balanceFor(balance.itemId, fallbackLocationId);
    final updated = (existing ?? balance).copyWith(
      id: existing?.id ?? _balanceId(balance.itemId, fallbackLocationId),
      locationId: fallbackLocationId,
      quantityOnHand: (existing?.quantityOnHand ?? 0) + balance.quantityOnHand,
      updatedAt: DateTime.now(),
    );
    if (existing == null) {
      _itemLocationBalances[balanceIndex] = updated;
    } else {
      _upsertBalanceInMemory(updated);
      _itemLocationBalances.removeWhere((stored) => stored.id == balance.id);
      await _database.deleteItemLocationBalance(balance.id);
      queueBalanceForSync(balance.id);
    }
    await _database.upsertItemLocationBalance(updated.toCompanion());
    queueBalanceForSync(updated.id);
    await syncItemQuantityFromBalances(balance.itemId);
    notifyListeners();
    return true;
  }

  Future<bool> cancelOrphanReorderRequest(String reorderId) async {
    final index = _reorderRequests.indexWhere(
      (request) => request.id == reorderId,
    );
    if (index == -1) {
      return false;
    }
    final request = _reorderRequests[index];
    if (request.status != ReorderStatus.needed &&
        request.status != ReorderStatus.ordered &&
        request.status != ReorderStatus.partiallyReceived) {
      return false;
    }
    final updated = request.copyWith(
      status: ReorderStatus.cancelled,
      cancelledAt: DateTime.now(),
      notes: [
        if (request.notes?.trim().isNotEmpty == true) request.notes!.trim(),
        'Cancelled by Data Health repair because the item is missing.',
      ].join(' '),
    );
    _reorderRequests[index] = updated;
    await _database.upsertReorderRequest(updated.toCompanion());
    queuePurchaseOrderForSync(updated.id);
    notifyListeners();
    return true;
  }

  Future<bool> removeOrphanCustomFieldValue(String valueId) async {
    final removed = _customFieldValues.any((value) => value.id == valueId);
    if (!removed) {
      return false;
    }
    _customFieldValues.removeWhere((value) => value.id == valueId);
    await _database.deleteCustomFieldValueById(valueId);
    notifyListeners();
    return true;
  }

  Future<bool> resetNegativeMinimumQuantity(String itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1 || _items[index].minimumQuantity >= 0) {
      return false;
    }
    final updated = _items[index].copyWith(
      minimumQuantity: 0,
      updatedAt: DateTime.now(),
    );
    _items[index] = updated;
    await _database.upsertItem(updated.toCompanion());
    notifyListeners();
    return true;
  }

  Future<bool> createMissingDefaultSetup() async {
    final now = DateTime.now();
    if (_company == null) {
      _company = Company(
        id: 'company-local',
        name: 'Issued Workspace',
        industry: null,
        createdAt: now,
        updatedAt: now,
        setupCompleted: true,
      );
      await _database.upsertCompany(_company!.toCompanion());
    }
    await _ensureDefaultUnitsOfMeasure();
    if (!_locations.any((location) => location.isActive)) {
      await _ensureLocation('Main Stockroom', 'Stockroom', id: 'loc-main');
    }
    if (!_users.any((user) => user.isActive && user.role == UserRole.admin)) {
      await _ensureAdminUser('Admin User', 'admin@issued.local', '0000', now);
    }
    await _loadFromDatabase();
    notifyListeners();
    return true;
  }

  String? _firstActiveLocationId() {
    for (final location in _locations) {
      if (location.isActive) {
        return location.id;
      }
    }
    return null;
  }

  bool updateItemDetails(
    Item updatedItem, {
    List<CustomFieldValue> customFieldValues = const [],
    String? activityNote,
  }) {
    if (!permissions.canManageItems) {
      return false;
    }

    final itemIndex = _items.indexWhere(
      (storedItem) => storedItem.id == updatedItem.id,
    );
    if (itemIndex == -1) {
      return false;
    }

    final existingItem = _items[itemIndex];
    final savedItem = Item(
      id: updatedItem.id,
      name: updatedItem.name,
      description: updatedItem.description,
      itemType: updatedItem.itemType,
      category: updatedItem.category,
      locationId: updatedItem.locationId,
      quantityOnHand: existingItem.quantityOnHand,
      minimumQuantity: updatedItem.minimumQuantity,
      unitOfMeasureId: updatedItem.unitOfMeasureId,
      purchaseUnitOfMeasureId: updatedItem.purchaseUnitOfMeasureId,
      purchaseToStockConversionFactor:
          updatedItem.purchaseToStockConversionFactor,
      purchaseUnitLabel: updatedItem.purchaseUnitLabel,
      barcode: updatedItem.barcode,
      sku: updatedItem.sku,
      supplierId: updatedItem.supplierId,
      supplier: updatedItem.supplier,
      unitCost: updatedItem.unitCost,
      photoPath: existingItem.photoPath,
      isActive: existingItem.isActive,
      allowFractionalQuantity: updatedItem.allowFractionalQuantity,
      createdAt: existingItem.createdAt,
      updatedAt: DateTime.now(),
    );
    _items[itemIndex] = savedItem;
    unawaited(_database.upsertItem(savedItem.toCompanion()));
    _queueItemCatalogChange(savedItem.id, CloudSyncOperation.update);

    for (final value in customFieldValues) {
      final valueIndex = _customFieldValues.indexWhere(
        (storedValue) => storedValue.id == value.id,
      );
      if (valueIndex == -1) {
        _customFieldValues.add(value);
      } else {
        _customFieldValues[valueIndex] = value;
      }
      unawaited(_database.upsertCustomFieldValue(value.toCompanion()));
    }

    final note = activityNote?.trim();
    if (note != null && note.isNotEmpty) {
      final transaction = InventoryTransaction(
        id: 'txn-item-edit-${DateTime.now().microsecondsSinceEpoch}',
        itemId: savedItem.id,
        transactionType: InventoryTransactionType.adjustment,
        quantityDelta: 0,
        unitOfMeasureId: savedItem.unitOfMeasureId,
        fromLocationId: null,
        toLocationId: null,
        assignedToPersonId: null,
        assignedToTargetId: null,
        assignedToText: null,
        performedByUserId: currentUser?.id,
        notes: note,
        createdAt: DateTime.now(),
      );
      _transactions.add(transaction);
      unawaited(_database.upsertTransaction(transaction.toCompanion()));
      queueTransactionForSync(transaction.id);
    }

    notifyListeners();
    return true;
  }

  bool hasTransactionsForItem(String itemId) {
    return _transactions.any((transaction) => transaction.itemId == itemId);
  }

  bool hasOpenCheckoutsForItem(String itemId) {
    return openCheckoutRecordsForItem(itemId).isNotEmpty;
  }

  bool isBarcodeInUse(String barcode, {String? excludingItemId}) {
    final normalized = barcode.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }
    return _items.any((item) {
      return item.isActive &&
          item.id != excludingItemId &&
          (item.barcode ?? '').trim().toLowerCase() == normalized;
    });
  }

  bool isSkuInUse(String sku, {String? excludingItemId}) {
    final normalized = sku.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }
    return _items.any((item) {
      return item.isActive &&
          item.id != excludingItemId &&
          (item.sku ?? '').trim().toLowerCase() == normalized;
    });
  }

  bool get canManageSuppliers => permissions.canManageSettings;

  Supplier? supplierById(String? supplierId) {
    if (supplierId == null) {
      return null;
    }
    for (final supplier in _suppliers) {
      if (supplier.id == supplierId) {
        return supplier;
      }
    }
    return null;
  }

  String? resolveSupplierName(String? supplierId, {String? fallback}) {
    final supplier = supplierById(supplierId);
    if (supplier != null) {
      return supplier.name;
    }
    final trimmed = fallback?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  List<Item> getItemsForSupplier(String supplierId) {
    final supplier = supplierById(supplierId);
    final supplierName = supplier?.name.trim().toLowerCase();
    return _items.where((item) {
      if (item.supplierId == supplierId) {
        return true;
      }
      if (supplierName == null || supplierName.isEmpty) {
        return false;
      }
      return item.supplier?.trim().toLowerCase() == supplierName;
    }).toList()..sort((left, right) => left.name.compareTo(right.name));
  }

  List<ReorderRequest> getReordersForSupplier(String supplierId) {
    final supplier = supplierById(supplierId);
    final supplierName = supplier?.name.trim().toLowerCase();
    return _sortedReorders(
      _reorderRequests.where((request) {
        if (request.supplierId == supplierId) {
          return true;
        }
        if (supplierName == null || supplierName.isEmpty) {
          return false;
        }
        return request.supplier?.trim().toLowerCase() == supplierName;
      }).toList(),
    );
  }

  bool isSupplierNameInUse(String name, {String? excludingSupplierId}) {
    final normalized = _normalizeSupplierName(name);
    if (normalized.isEmpty) {
      return false;
    }
    return _suppliers.any((supplier) {
      return supplier.isActive &&
          supplier.id != excludingSupplierId &&
          _normalizeSupplierName(supplier.name) == normalized;
    });
  }

  bool addSupplier(Supplier supplier) {
    if (!canManageSuppliers) {
      return false;
    }
    final name = supplier.name.trim();
    if (name.isEmpty || isSupplierNameInUse(name)) {
      return false;
    }
    final saved = supplier.copyWith(name: name);
    _suppliers.add(saved);
    unawaited(_database.upsertSupplier(saved.toCompanion()));
    queueSupplierForSync(saved.id);
    notifyListeners();
    return true;
  }

  bool updateSupplier(Supplier supplier) {
    if (!canManageSuppliers) {
      return false;
    }
    final supplierIndex = _suppliers.indexWhere(
      (storedSupplier) => storedSupplier.id == supplier.id,
    );
    final name = supplier.name.trim();
    if (supplierIndex == -1 ||
        name.isEmpty ||
        isSupplierNameInUse(name, excludingSupplierId: supplier.id)) {
      return false;
    }
    final saved = supplier.copyWith(name: name, updatedAt: DateTime.now());
    _suppliers[supplierIndex] = saved;
    unawaited(_database.upsertSupplier(saved.toCompanion()));
    queueSupplierForSync(saved.id);
    notifyListeners();
    return true;
  }

  bool archiveSupplier(String supplierId) {
    if (!canManageSuppliers) {
      return false;
    }
    final supplierIndex = _suppliers.indexWhere(
      (supplier) => supplier.id == supplierId,
    );
    if (supplierIndex == -1) {
      return false;
    }
    final archived = _suppliers[supplierIndex].copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );
    _suppliers[supplierIndex] = archived;
    unawaited(_database.upsertSupplier(archived.toCompanion()));
    queueSupplierForSync(archived.id);
    notifyListeners();
    return true;
  }

  Supplier? findOrCreateSupplierByName(String name) {
    final normalized = _normalizeSupplierName(name);
    if (normalized.isEmpty) {
      return null;
    }
    for (final supplier in _suppliers) {
      if (_normalizeSupplierName(supplier.name) == normalized) {
        return supplier;
      }
    }
    if (!canManageSuppliers) {
      return null;
    }
    final now = DateTime.now();
    final supplier = Supplier(
      id: 'supplier-${now.microsecondsSinceEpoch}',
      name: name.trim(),
      contactName: null,
      email: null,
      phone: null,
      website: null,
      address: null,
      accountNumber: null,
      notes: null,
      defaultLeadTimeDays: null,
      minimumOrderAmount: null,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
    _suppliers.add(supplier);
    unawaited(_database.upsertSupplier(supplier.toCompanion()));
    queueSupplierForSync(supplier.id);
    notifyListeners();
    return supplier;
  }

  String _normalizeSupplierName(String name) {
    return name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  AppActionResult addTransaction(InventoryTransaction transaction) {
    if (!permissions.canImportExport && !permissions.canManageItems) {
      return AppActionResult.denied();
    }
    _transactions.add(transaction);
    unawaited(_database.upsertTransaction(transaction.toCompanion()));
    queueTransactionForSync(transaction.id);
    notifyListeners();
    return const AppActionResult.success(message: 'Activity recorded.');
  }

  bool canReverseTransaction(InventoryTransaction transaction) {
    return !isLocked &&
        (permissions.isAdmin || permissions.isManager) &&
        !transaction.isReversed &&
        !transaction.isReversal &&
        transaction.transactionType != InventoryTransactionType.checkout &&
        transaction.transactionType != InventoryTransactionType.returnItem &&
        transaction.transactionType != InventoryTransactionType.correction &&
        !(transaction.transactionType == InventoryTransactionType.transfer &&
            transaction.quantityDelta == 0);
  }

  InventoryTransaction? getReversalForTransaction(String transactionId) {
    for (final transaction in _transactions) {
      if (transaction.reversesTransactionId == transactionId) {
        return transaction;
      }
    }
    return null;
  }

  InventoryTransaction? getOriginalTransactionForReversal(
    String transactionId,
  ) {
    final reversal = _transactionById(transactionId);
    final originalId = reversal?.reversesTransactionId;
    return originalId == null ? null : _transactionById(originalId);
  }

  bool isTransactionReversed(String transactionId) {
    final transaction = _transactionById(transactionId);
    return transaction?.isReversed ?? false;
  }

  AppActionResult reverseInventoryTransaction(
    String transactionId,
    String reason,
  ) {
    if (isLocked) {
      return const AppActionResult.failure('Unlock Issued to continue.');
    }
    if (!(permissions.isAdmin || permissions.isManager)) {
      return AppActionResult.denied();
    }

    final trimmedReason = reason.trim();
    if (trimmedReason.length < 3) {
      return const AppActionResult.failure('Correction reason is required.');
    }

    final originalIndex = _transactions.indexWhere(
      (transaction) => transaction.id == transactionId,
    );
    if (originalIndex == -1) {
      return const AppActionResult.failure('Transaction not found.');
    }
    final original = _transactions[originalIndex];
    if (original.isReversed) {
      return const AppActionResult.failure(
        'This transaction has already been reversed.',
      );
    }
    if (original.isReversal ||
        original.transactionType == InventoryTransactionType.correction) {
      return const AppActionResult.failure(
        'Correction transactions cannot be reversed.',
      );
    }
    if (original.transactionType == InventoryTransactionType.checkout) {
      return const AppActionResult.failure(
        'Checkout transactions must be corrected from the checkout record.',
      );
    }
    if (original.transactionType == InventoryTransactionType.returnItem) {
      return const AppActionResult.failure(
        'Return transactions must be corrected from the checkout record.',
      );
    }

    final item = _itemById(original.itemId);
    if (item == null) {
      return const AppActionResult.failure(
        'The item for this transaction is missing.',
      );
    }

    final impacts = _reversalLocationImpacts(original);
    if (impacts.isEmpty) {
      return const AppActionResult.failure(
        'This transaction does not include enough stock movement detail to reverse safely.',
      );
    }

    for (final impact in impacts.entries) {
      final location = _locationById(impact.key);
      if (location == null) {
        return const AppActionResult.failure(
          'A location for this transaction is missing.',
        );
      }
      final current =
          _balanceFor(original.itemId, impact.key)?.quantityOnHand ?? 0;
      final next = current + impact.value;
      if (next < 0) {
        return AppActionResult.failure(
          'Reversing this transaction would make ${location.name} negative.',
        );
      }
      if (!_isWholeQuantityAllowed(original.itemId, next)) {
        return const AppActionResult.failure(
          'This correction would create an invalid quantity.',
        );
      }
    }

    final now = DateTime.now();
    for (final impact in impacts.entries) {
      final current =
          _balanceFor(original.itemId, impact.key)?.quantityOnHand ?? 0;
      _setBalanceQuantity(
        original.itemId,
        impact.key,
        current + impact.value,
        now,
      );
    }
    _syncItemCachedQuantity(original.itemId, now);

    final reversal = InventoryTransaction(
      id: 'txn-correction-${now.microsecondsSinceEpoch}',
      itemId: original.itemId,
      transactionType: InventoryTransactionType.correction,
      quantityDelta: -original.quantityDelta,
      unitOfMeasureId: original.unitOfMeasureId,
      fromLocationId: original.toLocationId,
      toLocationId: original.fromLocationId,
      assignedToPersonId: original.assignedToPersonId,
      assignedToLocationId: original.assignedToLocationId,
      assignedToTargetId: original.assignedToTargetId,
      assignedToText: original.assignedToText,
      performedByUserId: currentUser?.id,
      notes: 'Correction for ${original.id}. This keeps history.',
      reversesTransactionId: original.id,
      correctionReason: trimmedReason,
      correctedAt: now,
      createdAt: now,
    );
    final markedOriginal = original.copyWith(
      reversedByTransactionId: reversal.id,
      correctionReason: trimmedReason,
      correctedAt: now,
    );
    _transactions[originalIndex] = markedOriginal;
    _transactions.add(reversal);
    unawaited(_database.upsertTransaction(markedOriginal.toCompanion()));
    unawaited(_database.upsertTransaction(reversal.toCompanion()));
    queueTransactionForSync(markedOriginal.id);
    queueTransactionForSync(reversal.id);
    notifyListeners();
    return const AppActionResult.success(message: 'Correction created.');
  }

  List<ItemLocationBalance> itemBalancesForItem(String itemId) {
    final balances = _itemLocationBalances
        .where((balance) => balance.itemId == itemId)
        .toList();
    balances.sort((left, right) {
      final leftQuantity = left.quantityOnHand;
      final rightQuantity = right.quantityOnHand;
      final quantityCompare = rightQuantity.compareTo(leftQuantity);
      if (quantityCompare != 0) {
        return quantityCompare;
      }
      return (resolveLocationName(left.locationId) ?? '').compareTo(
        resolveLocationName(right.locationId) ?? '',
      );
    });
    return balances;
  }

  double totalQuantityForItem(String itemId) {
    return itemBalancesForItem(
      itemId,
    ).fold<double>(0, (sum, balance) => sum + balance.quantityOnHand);
  }

  Location? primaryLocationForItem(String itemId) {
    final balances = itemBalancesForItem(
      itemId,
    ).where((balance) => balance.quantityOnHand > 0).toList();
    if (balances.isEmpty) {
      final item = _itemById(itemId);
      return item == null ? null : _locationById(item.locationId);
    }
    return _locationById(balances.first.locationId);
  }

  void updateItemCachedQuantity(String itemId) {
    final itemIndex = _items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) {
      return;
    }
    final item = _items[itemIndex];
    final updatedItem = item.copyWith(
      quantityOnHand: totalQuantityForItem(itemId),
      updatedAt: DateTime.now(),
    );
    _items[itemIndex] = updatedItem;
    unawaited(_database.upsertItem(updatedItem.toCompanion()));
    notifyListeners();
  }

  bool setItemLocationBalance(
    String itemId,
    String locationId,
    double quantity,
  ) {
    if (quantity < 0 || !_isWholeQuantityAllowed(itemId, quantity)) {
      return false;
    }
    final now = DateTime.now();
    final balance =
        _balanceFor(
          itemId,
          locationId,
        )?.copyWith(quantityOnHand: quantity, updatedAt: now) ??
        ItemLocationBalance(
          id: _balanceId(itemId, locationId),
          itemId: itemId,
          locationId: locationId,
          quantityOnHand: quantity,
          minimumQuantity: 0,
          updatedAt: now,
        );
    _upsertBalanceInMemory(balance);
    unawaited(_database.upsertItemLocationBalance(balance.toCompanion()));
    queueBalanceForSync(balance.id);
    _syncItemCachedQuantity(itemId, now);
    notifyListeners();
    return true;
  }

  bool adjustItemLocationBalance(
    String itemId,
    String locationId,
    double delta,
  ) {
    final current = _balanceFor(itemId, locationId)?.quantityOnHand ?? 0;
    return setItemLocationBalance(itemId, locationId, current + delta);
  }

  bool receiveItemToLocation({
    required String itemId,
    required String locationId,
    required double quantity,
    String? notes,
  }) {
    if (!permissions.canReceiveStock ||
        !_canMutateItemQuantity(itemId, quantity)) {
      return false;
    }
    if (!adjustItemLocationBalance(itemId, locationId, quantity)) {
      return false;
    }
    _appendInventoryTransaction(
      itemId: itemId,
      type: InventoryTransactionType.receive,
      quantityDelta: quantity,
      toLocationId: locationId,
      notes: notes,
    );
    return true;
  }

  bool issueItemFromLocation({
    required String itemId,
    required String locationId,
    required double quantity,
    String? assignedToPersonId,
    String? assignedToLocationId,
    String? assignedToTargetId,
    String? assignedToText,
    String? notes,
  }) {
    if (!permissions.canIssueItems ||
        !_canMutateItemQuantity(itemId, quantity)) {
      return false;
    }
    final current = _balanceFor(itemId, locationId)?.quantityOnHand ?? 0;
    if (current < quantity) {
      return false;
    }
    if (!adjustItemLocationBalance(itemId, locationId, -quantity)) {
      return false;
    }
    _appendInventoryTransaction(
      itemId: itemId,
      type: InventoryTransactionType.issue,
      quantityDelta: -quantity,
      fromLocationId: locationId,
      assignedToPersonId: assignedToPersonId,
      assignedToLocationId: assignedToLocationId,
      assignedToTargetId: assignedToTargetId,
      assignedToText: assignedToText,
      notes: notes,
    );
    return true;
  }

  bool transferItemBetweenLocations({
    required String itemId,
    required String fromLocationId,
    required String toLocationId,
    required double quantity,
    String? notes,
  }) {
    if (!permissions.canTransferStock ||
        fromLocationId == toLocationId ||
        !_canMutateItemQuantity(itemId, quantity)) {
      return false;
    }
    final current = _balanceFor(itemId, fromLocationId)?.quantityOnHand ?? 0;
    if (current < quantity) {
      return false;
    }
    final now = DateTime.now();
    _setBalanceQuantity(itemId, fromLocationId, current - quantity, now);
    final toCurrent = _balanceFor(itemId, toLocationId)?.quantityOnHand ?? 0;
    _setBalanceQuantity(itemId, toLocationId, toCurrent + quantity, now);
    _syncItemCachedQuantity(itemId, now);
    _appendInventoryTransaction(
      itemId: itemId,
      type: InventoryTransactionType.transfer,
      quantityDelta: quantity,
      fromLocationId: fromLocationId,
      toLocationId: toLocationId,
      notes: notes,
    );
    notifyListeners();
    return true;
  }

  bool adjustItemQuantityAtLocation({
    required String itemId,
    required String locationId,
    required double quantity,
    required bool setQuantity,
    String? notes,
  }) {
    if (!permissions.canAdjustQuantity) {
      return false;
    }
    final current = _balanceFor(itemId, locationId)?.quantityOnHand ?? 0;
    final newQuantity = setQuantity ? quantity : current + quantity;
    if (newQuantity < 0 || !_isWholeQuantityAllowed(itemId, newQuantity)) {
      return false;
    }
    if (!setItemLocationBalance(itemId, locationId, newQuantity)) {
      return false;
    }
    final delta = newQuantity - current;
    _appendInventoryTransaction(
      itemId: itemId,
      type: InventoryTransactionType.adjustment,
      quantityDelta: delta,
      fromLocationId: delta < 0 ? locationId : null,
      toLocationId: delta >= 0 ? locationId : null,
      notes: notes,
    );
    return true;
  }

  bool markItemDamagedAtLocation({
    required String itemId,
    required String locationId,
    required double quantity,
    String? notes,
  }) {
    if (!permissions.canAdjustQuantity ||
        !_canMutateItemQuantity(itemId, quantity)) {
      return false;
    }
    final current = _balanceFor(itemId, locationId)?.quantityOnHand ?? 0;
    if (current < quantity) {
      return false;
    }
    if (!adjustItemLocationBalance(itemId, locationId, -quantity)) {
      return false;
    }
    _appendInventoryTransaction(
      itemId: itemId,
      type: InventoryTransactionType.markDamaged,
      quantityDelta: -quantity,
      fromLocationId: locationId,
      notes: notes,
    );
    return true;
  }

  List<InventoryTransaction> transactionsForItem(String itemId) {
    final itemTransactions = _transactions
        .where((transaction) => transaction.itemId == itemId)
        .toList();

    itemTransactions.sort(
      (left, right) => right.createdAt.compareTo(left.createdAt),
    );
    return itemTransactions;
  }

  List<InventoryTransaction> recentTransactions({int limit = 10}) {
    final recentTransactions = _transactions.toList()
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));

    return recentTransactions.take(limit).toList();
  }

  String resolveItemName(String itemId) {
    return _itemById(itemId)?.name ?? 'Unknown item';
  }

  bool isItemLowStock(Item item) {
    return item.isActive &&
        item.minimumQuantity > 0 &&
        item.quantityOnHand <= item.minimumQuantity;
  }

  bool isItemCheckedOut(String itemId) {
    return openCheckoutRecords.any((record) => record.itemId == itemId);
  }

  bool isItemOnActiveReorder(String itemId) {
    return getActiveReorderForItem(itemId) != null;
  }

  List<CustomFieldDefinition> activeCustomFieldsForItem(Item item) {
    final fields = _customFieldDefinitions.where((field) {
      if (!field.isActive || field.entityType != CustomFieldEntityType.item) {
        return false;
      }
      final appliesToItemType = field.appliesToItemType;
      if (appliesToItemType != null && appliesToItemType != item.itemType) {
        return false;
      }
      final appliesToCategory = field.appliesToCategory?.trim();
      if (appliesToCategory != null &&
          appliesToCategory.isNotEmpty &&
          appliesToCategory.toLowerCase() != item.category.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();

    fields.sort((left, right) {
      final orderCompare = left.sortOrder.compareTo(right.sortOrder);
      if (orderCompare != 0) {
        return orderCompare;
      }
      return left.name.toLowerCase().compareTo(right.name.toLowerCase());
    });
    return fields;
  }

  List<CustomFieldValue> customFieldValuesForEntity(
    String entityType,
    String entityId,
  ) {
    return _customFieldValues
        .where((value) => value.entityId == entityId)
        .toList();
  }

  CustomFieldValue? getCustomFieldValue(
    String fieldDefinitionId,
    String entityId,
  ) {
    for (final value in _customFieldValues) {
      if (value.definitionId == fieldDefinitionId &&
          value.entityId == entityId) {
        return value;
      }
    }
    return null;
  }

  AppActionResult setCustomFieldValue(CustomFieldValue value) {
    if (!permissions.canManageItems && !permissions.canManageSettings) {
      return AppActionResult.denied();
    }
    final valueIndex = _customFieldValues.indexWhere(
      (storedValue) => storedValue.id == value.id,
    );
    if (valueIndex == -1) {
      _customFieldValues.add(value);
    } else {
      _customFieldValues[valueIndex] = value;
    }
    unawaited(_database.upsertCustomFieldValue(value.toCompanion()));
    notifyListeners();
    return const AppActionResult.success(message: 'Custom field saved.');
  }

  AppActionResult deleteCustomFieldValue(String valueId) {
    if (!permissions.canManageItems && !permissions.canManageSettings) {
      return AppActionResult.denied();
    }
    _customFieldValues.removeWhere((value) => value.id == valueId);
    unawaited(_database.deleteCustomFieldValueById(valueId));
    notifyListeners();
    return const AppActionResult.success(message: 'Custom field cleared.');
  }

  InventorySummaryReport getInventorySummary() {
    final activeItems = _items.where((item) => item.isActive).toList();

    return InventorySummaryReport(
      activeItemCount: activeItems.length,
      archivedItemCount: _items.where((item) => !item.isActive).length,
      consumableCount: activeItems
          .where((item) => item.itemType == ItemType.consumable)
          .length,
      returnableCount: activeItems
          .where((item) => item.itemType == ItemType.returnable)
          .length,
      assetCount: activeItems
          .where((item) => item.itemType == ItemType.asset)
          .length,
      locationCount: _locations.where((location) => location.isActive).length,
      lowStockCount: activeItems.where(isItemLowStock).length,
      activeReorderCount: _reorderRequests.where((request) {
        return request.isOpen;
      }).length,
      openCheckoutCount: openCheckoutRecords.length,
    );
  }

  DashboardSummary getDashboardSummary() {
    final activeItems = _items.where((item) => item.isActive).toList();
    final openCheckouts = openCheckoutRecords;
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final dueSoonCutoff = startOfToday.add(const Duration(days: 7));
    final recentTransactions = List<InventoryTransaction>.from(_transactions)
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));

    return DashboardSummary(
      totalActiveItems: activeItems.length,
      lowStockCount: activeItems.where(isItemLowStock).length,
      outOfStockCount: activeItems
          .where((item) => totalQuantityForItem(item.id) <= 0)
          .length,
      negativeStockCount: activeItems
          .where((item) => totalQuantityForItem(item.id) < 0)
          .length,
      missingLocationBalanceCount: activeItems
          .where((item) => itemBalancesForItem(item.id).isEmpty)
          .length,
      missingSetupDataCount: activeItems.where(_isMissingSetupData).length,
      checkedOutCount: openCheckouts.length,
      overdueCheckoutCount: overdueCheckoutRecords.length,
      dueSoonCheckoutCount: openCheckouts.where((record) {
        final dueAt = record.dueAt;
        return dueAt != null &&
            !dueAt.isBefore(startOfToday) &&
            dueAt.isBefore(dueSoonCutoff);
      }).length,
      pendingReorderCount: _reorderRequests
          .where((request) => request.status == ReorderStatus.needed)
          .length,
      orderedReorderCount: _reorderRequests
          .where(
            (request) =>
                request.status == ReorderStatus.ordered ||
                request.status == ReorderStatus.partiallyReceived,
          )
          .length,
      lowStockWithoutReorderCount: activeItems.where((item) {
        return isItemLowStock(item) && getActiveReorderForItem(item.id) == null;
      }).length,
      draftCycleCountCount: _cycleCountSessions
          .where(
            (session) =>
                session.status == CycleCountStatus.draft ||
                session.status == CycleCountStatus.assigned,
          )
          .length,
      submittedCycleCountCount: _cycleCountSessions
          .where((session) => session.status == CycleCountStatus.submitted)
          .length,
      cycleCountVarianceCount: _cycleCountLines
          .where((line) => (line.varianceQuantity ?? 0) != 0)
          .length,
      dataHealthErrorCount: null,
      dataHealthWarningCount: null,
      recentTransactions: recentTransactions.take(5).toList(),
    );
  }

  bool _isMissingSetupData(Item item) {
    final hasUnit = _unitById(item.unitOfMeasureId) != null;
    final hasLocation = _locationById(item.locationId) != null;
    return !hasUnit || !hasLocation;
  }

  InventoryValueReport getInventoryValueReport() {
    final byType = <ItemType, double>{};
    final byLocation = <String, double>{};
    var totalValue = 0.0;
    var missingCostCount = 0;
    var missingCostValue = 0.0;

    for (final item in _items.where((item) => item.isActive)) {
      final unitCost = item.unitCost;
      if (unitCost == null) {
        missingCostCount += 1;
        missingCostValue += item.quantityOnHand;
        continue;
      }

      final value = item.quantityOnHand * unitCost;
      totalValue += value;
      byType[item.itemType] = (byType[item.itemType] ?? 0) + value;
      byLocation[item.locationId] = (byLocation[item.locationId] ?? 0) + value;
    }

    return InventoryValueReport(
      totalValue: totalValue,
      valueByType: byType,
      valueByLocation: byLocation,
      missingCostCount: missingCostCount,
      missingCostQuantity: missingCostValue,
    );
  }

  Map<ItemType, double> getInventoryValueByType() {
    return getInventoryValueReport().valueByType;
  }

  Map<String, double> getInventoryValueByLocation() {
    return getInventoryValueReport().valueByLocation;
  }

  List<UsageByItemRow> getUsageByItem(DateTime? start) {
    final rowsByItem = <String, UsageByItemRow>{};
    for (final transaction in _usageTransactions(start)) {
      final quantity = transaction.quantityDelta.abs();
      final existing = rowsByItem[transaction.itemId];
      rowsByItem[transaction.itemId] = UsageByItemRow(
        itemId: transaction.itemId,
        quantity: (existing?.quantity ?? 0) + quantity,
        unitOfMeasureId: transaction.unitOfMeasureId,
        transactionCount: (existing?.transactionCount ?? 0) + 1,
      );
    }

    final rows = rowsByItem.values.toList();
    rows.sort((left, right) => right.quantity.compareTo(left.quantity));
    return rows;
  }

  List<UsageByPersonRow> getUsageByPerson(DateTime? start) {
    final rowsByPerson = <String, UsageByPersonRow>{};
    final itemCountsByPerson = <String, Map<String, int>>{};
    for (final transaction in _usageTransactions(start)) {
      final personId = transaction.assignedToPersonId;
      if (personId == null) {
        continue;
      }

      final existing = rowsByPerson[personId];
      rowsByPerson[personId] = UsageByPersonRow(
        personId: personId,
        quantity: (existing?.quantity ?? 0) + transaction.quantityDelta.abs(),
        transactionCount: (existing?.transactionCount ?? 0) + 1,
        topItemIds: const [],
      );
      final itemCounts = itemCountsByPerson.putIfAbsent(personId, () => {});
      itemCounts[transaction.itemId] =
          (itemCounts[transaction.itemId] ?? 0) + 1;
    }

    final rows = rowsByPerson.values.map((row) {
      final itemCounts = itemCountsByPerson[row.personId] ?? {};
      final topItemIds = itemCounts.entries.toList()
        ..sort((left, right) => right.value.compareTo(left.value));
      return UsageByPersonRow(
        personId: row.personId,
        quantity: row.quantity,
        transactionCount: row.transactionCount,
        topItemIds: topItemIds.take(3).map((entry) => entry.key).toList(),
      );
    }).toList();
    rows.sort(
      (left, right) => right.transactionCount.compareTo(left.transactionCount),
    );
    return rows;
  }

  List<UsageByAssignmentTargetRow> getUsageByAssignmentTarget(DateTime? start) {
    final rowsByTarget = <String, UsageByAssignmentTargetRow>{};
    final itemCountsByTarget = <String, Map<String, int>>{};
    for (final transaction in _usageTransactions(start)) {
      final targetId = transaction.assignedToTargetId;
      if (targetId == null) {
        continue;
      }

      final existing = rowsByTarget[targetId];
      rowsByTarget[targetId] = UsageByAssignmentTargetRow(
        targetId: targetId,
        quantity: (existing?.quantity ?? 0) + transaction.quantityDelta.abs(),
        transactionCount: (existing?.transactionCount ?? 0) + 1,
        topItemIds: const [],
      );
      final itemCounts = itemCountsByTarget.putIfAbsent(targetId, () => {});
      itemCounts[transaction.itemId] =
          (itemCounts[transaction.itemId] ?? 0) + 1;
    }

    final rows = rowsByTarget.values.map((row) {
      final itemCounts = itemCountsByTarget[row.targetId] ?? {};
      final topItemIds = itemCounts.entries.toList()
        ..sort((left, right) => right.value.compareTo(left.value));
      return UsageByAssignmentTargetRow(
        targetId: row.targetId,
        quantity: row.quantity,
        transactionCount: row.transactionCount,
        topItemIds: topItemIds.take(3).map((entry) => entry.key).toList(),
      );
    }).toList();
    rows.sort(
      (left, right) => right.transactionCount.compareTo(left.transactionCount),
    );
    return rows;
  }

  List<LostDamagedReportRow> getLostDamagedActivity() {
    final rows = <LostDamagedReportRow>[];
    for (final transaction in _transactions) {
      if (transaction.transactionType != InventoryTransactionType.markLost &&
          transaction.transactionType != InventoryTransactionType.markDamaged) {
        continue;
      }

      rows.add(
        LostDamagedReportRow(
          itemId: transaction.itemId,
          status:
              transaction.transactionType == InventoryTransactionType.markLost
              ? 'Lost'
              : 'Damaged',
          quantity: transaction.quantityDelta.abs(),
          unitOfMeasureId: transaction.unitOfMeasureId,
          createdAt: transaction.createdAt,
          notes: transaction.notes,
          assignedToPersonId: transaction.assignedToPersonId,
          locationId: transaction.fromLocationId ?? transaction.toLocationId,
        ),
      );
    }

    for (final record in _checkoutRecords) {
      if (record.status != CheckoutStatus.lost &&
          record.status != CheckoutStatus.damaged) {
        continue;
      }

      rows.add(
        LostDamagedReportRow(
          itemId: record.itemId,
          status: checkoutStatusLabel(record.status),
          quantity: record.quantity,
          unitOfMeasureId: record.unitOfMeasureId,
          createdAt: record.returnedAt ?? record.checkedOutAt,
          notes: record.notes,
          assignedToPersonId: record.assignedToPersonId,
          locationId: record.assignedToLocationId,
        ),
      );
    }

    rows.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return rows;
  }

  List<CycleCountVarianceRow> getCycleCountVarianceRows() {
    final rows = <CycleCountVarianceRow>[];
    for (final line in _cycleCountLines) {
      final counted = line.countedQuantity;
      final variance = line.varianceQuantity;
      if (counted == null || variance == null || variance == 0) {
        continue;
      }

      final session = _cycleCountSessionById(line.sessionId);
      rows.add(
        CycleCountVarianceRow(
          itemId: line.itemId,
          sessionName: session?.name ?? 'Unknown count',
          sessionDate:
              session?.approvedAt ??
              session?.submittedAt ??
              session?.createdAt ??
              DateTime.now(),
          expectedQuantity: line.expectedQuantity,
          countedQuantity: counted,
          varianceQuantity: variance,
          unitOfMeasureId: line.unitOfMeasureId,
          locationId: _cycleCountLineLocationId(line),
        ),
      );
    }

    rows.sort((left, right) => right.sessionDate.compareTo(left.sessionDate));
    return rows;
  }

  ReorderStatusSummary getReorderStatusSummary() {
    return ReorderStatusSummary(
      needed: _reorderRequests
          .where((request) => request.status == ReorderStatus.needed)
          .length,
      ordered: _reorderRequests
          .where((request) => request.status == ReorderStatus.ordered)
          .length,
      partiallyReceived: _reorderRequests
          .where((request) => request.status == ReorderStatus.partiallyReceived)
          .length,
      received: _reorderRequests
          .where((request) => request.status == ReorderStatus.received)
          .length,
      canceled: _reorderRequests.where((request) => request.isCancelled).length,
    );
  }

  Item? itemById(String itemId) {
    return _itemById(itemId);
  }

  Item? findItemById(String itemId) {
    return _itemById(itemId.trim());
  }

  Location? findLocationById(String locationId) {
    return _locationById(locationId.trim());
  }

  AssignmentTarget? findAssignmentTargetById(String targetId) {
    return _assignmentTargetById(targetId.trim());
  }

  CheckoutRecord? findCheckoutById(String checkoutId) {
    return _checkoutRecordById(checkoutId.trim());
  }

  ReorderRequest? findReorderById(String reorderId) {
    return reorderRequestById(reorderId.trim());
  }

  List<Item> findItemsByBarcodeOrSku(String code) {
    final normalized = code.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const [];
    }

    final barcodeMatches = _items.where((item) {
      return item.barcode?.trim().toLowerCase() == normalized;
    }).toList();
    if (barcodeMatches.isNotEmpty) {
      return barcodeMatches;
    }

    return _items.where((item) {
      return item.sku?.trim().toLowerCase() == normalized;
    }).toList();
  }

  List<Location> get activeLocations =>
      List.unmodifiable(_locations.where((location) => location.isActive));

  String resolveLocationPath(String locationId) {
    final names = <String>[];
    final seen = <String>{};
    var current = _locationById(locationId);
    while (current != null && seen.add(current.id)) {
      names.insert(0, current.name);
      final parentId = current.parentLocationId;
      current = parentId == null ? null : _locationById(parentId);
    }
    return names.isEmpty ? 'Unknown location' : names.join(' / ');
  }

  List<Location> getChildLocations(String parentLocationId) {
    return _locations
        .where((location) => location.parentLocationId == parentLocationId)
        .toList()
      ..sort((left, right) => left.name.compareTo(right.name));
  }

  List<ItemLocationBalance> getBalancesAtLocation(String locationId) {
    return _itemLocationBalances
        .where((balance) => balance.locationId == locationId)
        .toList()
      ..sort((left, right) => left.itemId.compareTo(right.itemId));
  }

  List<Item> getItemsAtLocation(String locationId) {
    final itemIds = {
      for (final balance in getBalancesAtLocation(locationId))
        if (balance.quantityOnHand > 0) balance.itemId,
      for (final item in _items)
        if (item.locationId == locationId) item.id,
    };
    return _items.where((item) => itemIds.contains(item.id)).toList()
      ..sort((left, right) => left.name.compareTo(right.name));
  }

  LocationStockSummary getLocationStockSummary(String locationId) {
    final balances = getBalancesAtLocation(locationId);
    final positiveBalances = balances
        .where((balance) => balance.quantityOnHand > 0)
        .toList();
    final itemIds = {for (final balance in positiveBalances) balance.itemId};
    final totalQuantity = positiveBalances.fold<double>(
      0,
      (sum, balance) => sum + balance.quantityOnHand,
    );
    return LocationStockSummary(
      itemCount: itemIds.length,
      positiveBalanceCount: positiveBalances.length,
      totalQuantity: totalQuantity,
    );
  }

  bool canArchiveLocation(String locationId) {
    final activeLocations = _locations
        .where((location) => location.isActive && location.id != locationId)
        .length;
    if (activeLocations == 0) {
      return false;
    }
    return !getBalancesAtLocation(
      locationId,
    ).any((balance) => balance.quantityOnHand > 0);
  }

  bool isLocationCodeInUse(String code, {String? excludingLocationId}) {
    final normalized = code.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }
    return _locations.any((location) {
      return location.id != excludingLocationId &&
          (location.code ?? '').trim().toLowerCase() == normalized;
    });
  }

  bool isLocationNameInUseUnderParent(
    String name, {
    String? parentLocationId,
    String? excludingLocationId,
  }) {
    final normalized = name.trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }
    return _locations.any((location) {
      return location.isActive &&
          location.id != excludingLocationId &&
          location.parentLocationId == parentLocationId &&
          location.name.trim().toLowerCase() == normalized;
    });
  }

  bool wouldCreateLocationCycle(String locationId, String? parentLocationId) {
    if (parentLocationId == null || parentLocationId.isEmpty) {
      return false;
    }
    if (locationId == parentLocationId) {
      return true;
    }
    final seen = <String>{locationId};
    var current = _locationById(parentLocationId);
    while (current != null) {
      if (!seen.add(current.id)) {
        return true;
      }
      final parentId = current.parentLocationId;
      current = parentId == null ? null : _locationById(parentId);
    }
    return false;
  }

  String resolveUomAbbreviation(String uomId) {
    return _unitById(uomId)?.abbreviation ?? '';
  }

  UnitOfMeasure? getStockUom(Item item) {
    return _unitById(item.unitOfMeasureId);
  }

  UnitOfMeasure? getPurchaseUom(Item item) {
    final purchaseUomId = item.purchaseUnitOfMeasureId;
    if (purchaseUomId == null || purchaseUomId.trim().isEmpty) {
      return null;
    }
    return _unitById(purchaseUomId);
  }

  bool hasPurchaseConversion(Item item) {
    final purchaseUom = getPurchaseUom(item);
    final factor = item.purchaseToStockConversionFactor;
    return purchaseUom != null &&
        purchaseUom.id != item.unitOfMeasureId &&
        factor != null &&
        factor > 0;
  }

  double convertPurchaseToStock(Item item, double purchaseQuantity) {
    final factor = item.purchaseToStockConversionFactor;
    if (!hasPurchaseConversion(item) || factor == null) {
      return purchaseQuantity;
    }
    return purchaseQuantity * factor;
  }

  String formatStockQuantity(Item item, double quantity) {
    final unit = getStockUom(item);
    return '${_formatQuantity(quantity)} ${unit?.abbreviation ?? ''}'.trim();
  }

  String formatPurchaseQuantity(Item item, double quantity) {
    final unit = getPurchaseUom(item);
    return '${_formatQuantity(quantity)} ${unit?.abbreviation ?? item.purchaseUnitLabel ?? ''}'
        .trim();
  }

  String? validatePurchaseReceiveQuantity(Item item, double purchaseQuantity) {
    if (purchaseQuantity <= 0) {
      return 'Enter a quantity greater than 0.';
    }
    final purchaseUom = getPurchaseUom(item);
    if (purchaseUom != null &&
        !purchaseUom.allowsDecimal &&
        purchaseQuantity != purchaseQuantity.roundToDouble()) {
      return 'Purchase quantity must be a whole number.';
    }
    final stockQuantity = convertPurchaseToStock(item, purchaseQuantity);
    final stockUom = getStockUom(item);
    if (!item.allowFractionalQuantity &&
        stockUom?.allowsDecimal != true &&
        stockQuantity != stockQuantity.roundToDouble()) {
      return 'Converted stock quantity must be a whole number.';
    }
    return null;
  }

  String? purchaseConversionPreview(Item item) {
    if (!hasPurchaseConversion(item)) {
      return null;
    }
    final purchaseUom = getPurchaseUom(item);
    final stockUom = getStockUom(item);
    final factor = item.purchaseToStockConversionFactor!;
    return '1 ${purchaseUom?.abbreviation ?? item.purchaseUnitLabel ?? 'purchase unit'} = ${_formatQuantity(factor)} ${stockUom?.abbreviation ?? ''}'
        .trim();
  }

  String? resolveLocationName(String? locationId) {
    if (locationId == null) {
      return null;
    }

    for (final location in _locations) {
      if (location.id == locationId) {
        return location.name;
      }
    }

    return 'Unknown';
  }

  String? resolveAssignmentTargetName(String? targetId) {
    if (targetId == null) {
      return null;
    }

    for (final target in _assignmentTargets) {
      if (target.id == targetId) {
        final archived = target.isActive ? '' : ' (archived)';
        return '${target.name}$archived';
      }
    }

    return 'Unknown target';
  }

  AssignmentTarget? assignmentTargetById(String targetId) {
    return _assignmentTargetById(targetId);
  }

  String? resolveAssignmentTargetType(String? targetId) {
    if (targetId == null) {
      return null;
    }
    final target = _assignmentTargetById(targetId);
    return target == null
        ? 'Unknown target'
        : assignmentTargetTypeLabel(target.targetType);
  }

  String? resolveAssignmentTargetCode(String? targetId) {
    if (targetId == null) {
      return null;
    }
    return _assignmentTargetById(targetId)?.code;
  }

  String? resolveAssignedTo({
    String? personId,
    String? targetId,
    String? locationId,
    String? text,
  }) {
    final person = resolvePersonName(personId);
    if (person != null) {
      return person;
    }
    final target = resolveAssignmentTargetName(targetId);
    if (target != null) {
      final type = resolveAssignmentTargetType(targetId);
      return type == null ? target : '$target - $type';
    }
    final location = resolveLocationName(locationId);
    if (location != null) {
      return location;
    }
    final assignedText = text?.trim();
    return assignedText == null || assignedText.isEmpty ? null : assignedText;
  }

  List<AssignableDestination> getAssignableDestinations() {
    final destinations = <AssignableDestination>[
      for (final person in _people.where((person) => person.isActive))
        AssignableDestination(
          id: person.id,
          type: AssignableDestinationType.person,
          displayName: person.displayName,
          subtitle: 'Person',
        ),
      for (final location in _locations.where((location) => location.isActive))
        AssignableDestination(
          id: location.id,
          type: AssignableDestinationType.location,
          displayName: location.name,
          subtitle: 'Location',
        ),
      for (final target in activeAssignmentTargets)
        AssignableDestination(
          id: target.id,
          type: AssignableDestinationType.assignmentTarget,
          displayName: target.code == null
              ? target.name
              : '${target.name} (${target.code})',
          subtitle: assignmentTargetTypeLabel(target.targetType),
          targetType: target.targetType,
        ),
    ];
    destinations.sort((left, right) {
      final typeCompare = (left.subtitle ?? '').compareTo(right.subtitle ?? '');
      if (typeCompare != 0) {
        return typeCompare;
      }
      return left.displayName.toLowerCase().compareTo(
        right.displayName.toLowerCase(),
      );
    });
    return destinations;
  }

  String? resolvePersonName(String? personId) {
    if (personId == null) {
      return null;
    }

    for (final person in _people) {
      if (person.id == personId) {
        return person.displayName;
      }
    }

    return 'Unknown';
  }

  String? resolveUserName(String? userId) {
    if (userId == null) {
      return null;
    }

    for (final user in _users) {
      if (user.id == userId) {
        return resolvePersonName(user.personId) ?? user.email;
      }
    }

    return 'Unknown';
  }

  String? _resolveUserEmail(String? userId) {
    if (userId == null) {
      return null;
    }
    for (final user in _users) {
      if (user.id == userId) {
        return user.email;
      }
    }
    return null;
  }

  List<CheckoutRecord> get openCheckoutRecords {
    final records = _checkoutRecords
        .where((record) => record.isOpen && record.quantityOpen > 0)
        .toList();

    records.sort((left, right) {
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

    return records;
  }

  List<CheckoutRecord> get overdueCheckoutRecords {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return openCheckoutRecords.where((record) {
      final dueAt = record.dueAt;
      return dueAt != null && dueAt.isBefore(startOfToday);
    }).toList();
  }

  List<CheckoutRecord> openCheckoutRecordsForItem(String itemId) {
    return openCheckoutRecords
        .where((record) => record.itemId == itemId)
        .toList();
  }

  List<CheckoutRecord> getOpenCheckoutsForItem(String itemId) {
    return openCheckoutRecordsForItem(itemId);
  }

  List<CheckoutRecord> getOpenCheckoutRecords() => openCheckoutRecords;

  List<CheckoutRecord> getOverdueCheckoutRecords() => overdueCheckoutRecords;

  List<CheckoutRecord> getDueSoonCheckoutRecords({int days = 7}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cutoff = today.add(Duration(days: days));
    return openCheckoutRecords.where((record) {
      final dueAt = record.dueAt;
      return dueAt != null && !dueAt.isBefore(today) && dueAt.isBefore(cutoff);
    }).toList();
  }

  double getCheckedOutQuantityForItem(String itemId) {
    return openCheckoutRecordsForItem(
      itemId,
    ).fold<double>(0, (total, record) => total + record.quantityOpen);
  }

  String resolveCheckoutAssigneeName(CheckoutRecord record) {
    final parts = <String>[];
    final person = resolvePersonName(record.assignedToPersonId);
    if (person != null) {
      parts.add(person);
    }
    final location = resolveLocationName(record.assignedToLocationId);
    if (location != null) {
      parts.add(location);
    }
    final target = resolveAssignmentTargetName(record.assignedToTargetId);
    if (target != null) {
      parts.add(target);
    }
    final text = record.assignedToText?.trim();
    if (text != null && text.isNotEmpty) {
      parts.add(text);
    }
    return parts.isEmpty ? 'Unassigned' : parts.join(' / ');
  }

  bool checkOutItem({
    required String itemId,
    required double quantity,
    required String sourceLocationId,
    String? assignedToPersonId,
    String? assignedToLocationId,
    String? assignedToTargetId,
    String? assignedToText,
    DateTime? dueAt,
    String? notes,
  }) {
    if (!permissions.canIssueItems ||
        !_canMutateItemQuantity(itemId, quantity)) {
      return false;
    }

    final itemIndex = _items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) {
      return false;
    }

    final item = _items[itemIndex];
    if (!item.isActive || item.itemType == ItemType.consumable) {
      return false;
    }
    final now = DateTime.now();
    final sourceBalance =
        _balanceFor(itemId, sourceLocationId)?.quantityOnHand ?? 0;
    if (sourceBalance < quantity) {
      return false;
    }
    final normalizedAssignedText = assignedToText?.trim();
    final hasAssignee =
        assignedToPersonId != null ||
        assignedToLocationId != null ||
        assignedToTargetId != null ||
        (normalizedAssignedText != null && normalizedAssignedText.isNotEmpty);
    if (!hasAssignee) {
      return false;
    }
    final normalizedNotes = notes?.trim();
    _setBalanceQuantity(
      itemId,
      sourceLocationId,
      sourceBalance - quantity,
      now,
    );
    _syncItemCachedQuantity(itemId, now);

    final record = CheckoutRecord(
      id: 'checkout-${now.microsecondsSinceEpoch}',
      itemId: item.id,
      assignedToPersonId: assignedToPersonId,
      assignedToLocationId: assignedToLocationId,
      assignedToTargetId: assignedToTargetId,
      assignedToText:
          normalizedAssignedText == null || normalizedAssignedText.isEmpty
          ? null
          : normalizedAssignedText,
      quantity: quantity,
      quantityReturned: 0,
      sourceLocationId: sourceLocationId,
      unitOfMeasureId: item.unitOfMeasureId,
      status: CheckoutStatus.open,
      checkedOutAt: now,
      dueAt: dueAt,
      returnedAt: null,
      checkedOutByUserId: currentUser?.id,
      returnedByUserId: null,
      notes: normalizedNotes == null || normalizedNotes.isEmpty
          ? null
          : normalizedNotes,
      returnNotes: null,
      conditionOnReturn: null,
    );
    _checkoutRecords.add(record);
    unawaited(_database.upsertCheckoutRecord(record.toCompanion()));
    queueCheckoutForSync(record.id);

    final transaction = InventoryTransaction(
      id: 'txn-checkout-${now.microsecondsSinceEpoch}',
      itemId: item.id,
      transactionType: InventoryTransactionType.checkout,
      quantityDelta: -quantity,
      unitOfMeasureId: item.unitOfMeasureId,
      fromLocationId: sourceLocationId,
      toLocationId: null,
      assignedToPersonId: assignedToPersonId,
      assignedToTargetId: assignedToTargetId,
      assignedToText:
          normalizedAssignedText == null || normalizedAssignedText.isEmpty
          ? null
          : normalizedAssignedText,
      performedByUserId: currentUser?.id,
      notes: _checkoutNote(record),
      createdAt: now,
    );
    _transactions.add(transaction);
    unawaited(_database.upsertTransaction(transaction.toCompanion()));
    queueTransactionForSync(transaction.id);
    notifyListeners();
    return true;
  }

  bool returnCheckout({
    required String checkoutRecordId,
    required double returnedQuantity,
    required String returnToLocationId,
    String? notes,
    CheckoutReturnCondition condition = CheckoutReturnCondition.good,
    bool returnDamagedToStock = true,
  }) {
    if (!permissions.canIssueItems || returnedQuantity <= 0) {
      return false;
    }

    final recordIndex = _checkoutRecords.indexWhere(
      (record) => record.id == checkoutRecordId,
    );
    if (recordIndex == -1) {
      return false;
    }

    final record = _checkoutRecords[recordIndex];
    if (!record.isOpen || returnedQuantity > record.quantityOpen) {
      return false;
    }

    final itemIndex = _items.indexWhere((item) => item.id == record.itemId);
    if (itemIndex == -1) {
      return false;
    }

    final now = DateTime.now();
    final item = _items[itemIndex];
    final shouldReturnToStock =
        condition == CheckoutReturnCondition.good ||
        (condition == CheckoutReturnCondition.damaged && returnDamagedToStock);
    if (shouldReturnToStock) {
      final current =
          _balanceFor(item.id, returnToLocationId)?.quantityOnHand ?? 0;
      _setBalanceQuantity(
        item.id,
        returnToLocationId,
        current + returnedQuantity,
        now,
      );
      _syncItemCachedQuantity(item.id, now);
    }

    final normalizedNotes = notes?.trim();
    final totalReturned = record.quantityReturned + returnedQuantity;
    final fullyClosed = totalReturned >= record.quantity;
    final status = switch (condition) {
      CheckoutReturnCondition.good =>
        fullyClosed
            ? CheckoutStatus.returned
            : CheckoutStatus.partiallyReturned,
      CheckoutReturnCondition.damaged =>
        fullyClosed && !returnDamagedToStock
            ? CheckoutStatus.damaged
            : fullyClosed
            ? CheckoutStatus.returned
            : CheckoutStatus.partiallyReturned,
      CheckoutReturnCondition.lost =>
        fullyClosed ? CheckoutStatus.lost : CheckoutStatus.partiallyReturned,
    };
    final updatedRecord = record.copyWith(
      status: status,
      quantityReturned: totalReturned,
      returnedAt: fullyClosed ? now : record.returnedAt,
      returnedByUserId: currentUser?.id,
      notes: normalizedNotes == null || normalizedNotes.isEmpty
          ? record.notes
          : normalizedNotes,
      returnNotes: normalizedNotes,
      conditionOnReturn: condition,
    );
    _checkoutRecords[recordIndex] = updatedRecord;
    unawaited(_database.upsertCheckoutRecord(updatedRecord.toCompanion()));
    queueCheckoutForSync(updatedRecord.id);

    final transaction = InventoryTransaction(
      id: 'txn-return-${now.microsecondsSinceEpoch}',
      itemId: item.id,
      transactionType: switch (condition) {
        CheckoutReturnCondition.good => InventoryTransactionType.returnItem,
        CheckoutReturnCondition.damaged =>
          shouldReturnToStock
              ? InventoryTransactionType.returnItem
              : InventoryTransactionType.markDamaged,
        CheckoutReturnCondition.lost => InventoryTransactionType.markLost,
      },
      quantityDelta: shouldReturnToStock ? returnedQuantity : 0,
      unitOfMeasureId: item.unitOfMeasureId,
      fromLocationId: null,
      toLocationId: shouldReturnToStock ? returnToLocationId : null,
      assignedToPersonId: record.assignedToPersonId,
      assignedToTargetId: record.assignedToTargetId,
      assignedToText: record.assignedToText,
      performedByUserId: currentUser?.id,
      notes: _returnNote(
        condition: condition,
        quantity: returnedQuantity,
        returnedToStock: shouldReturnToStock,
        notes: normalizedNotes,
      ),
      createdAt: now,
    );
    _transactions.add(transaction);
    unawaited(_database.upsertTransaction(transaction.toCompanion()));
    queueTransactionForSync(transaction.id);
    notifyListeners();
    return true;
  }

  bool partiallyReturnCheckout({
    required String checkoutRecordId,
    required double returnedQuantity,
    required String returnToLocationId,
    String? notes,
  }) {
    return returnCheckout(
      checkoutRecordId: checkoutRecordId,
      returnedQuantity: returnedQuantity,
      returnToLocationId: returnToLocationId,
      notes: notes,
    );
  }

  bool markCheckoutLost(String checkoutRecordId, String? notes) {
    if (!permissions.canAdjustQuantity) {
      return false;
    }
    final record = _checkoutRecordById(checkoutRecordId);
    if (record == null) {
      return false;
    }
    return returnCheckout(
      checkoutRecordId: checkoutRecordId,
      returnedQuantity: record.quantityOpen,
      returnToLocationId: record.sourceLocationId ?? '',
      notes: notes,
      condition: CheckoutReturnCondition.lost,
    );
  }

  bool markCheckoutDamaged(String checkoutRecordId, String? notes) {
    if (!permissions.canAdjustQuantity) {
      return false;
    }
    final record = _checkoutRecordById(checkoutRecordId);
    if (record == null) {
      return false;
    }
    return returnCheckout(
      checkoutRecordId: checkoutRecordId,
      returnedQuantity: record.quantityOpen,
      returnToLocationId: record.sourceLocationId ?? '',
      notes: notes,
      condition: CheckoutReturnCondition.damaged,
      returnDamagedToStock: false,
    );
  }

  CheckoutRecord? _checkoutRecordById(String checkoutRecordId) {
    for (final record in _checkoutRecords) {
      if (record.id == checkoutRecordId) {
        return record;
      }
    }
    return null;
  }

  String _checkoutNote(CheckoutRecord record) {
    final parts = ['Checked out to ${resolveCheckoutAssigneeName(record)}.'];
    final dueAt = record.dueAt;
    if (dueAt != null) {
      parts.add(
        'Due ${dueAt.year}-${dueAt.month.toString().padLeft(2, '0')}-${dueAt.day.toString().padLeft(2, '0')}.',
      );
    }
    final notes = record.notes?.trim();
    if (notes != null && notes.isNotEmpty) {
      parts.add(notes);
    }
    return parts.join(' ');
  }

  String _returnNote({
    required CheckoutReturnCondition condition,
    required double quantity,
    required bool returnedToStock,
    String? notes,
  }) {
    final parts = [
      '${checkoutReturnConditionLabel(condition)} return: ${_formatQuantity(quantity)}.',
    ];
    if (!returnedToStock) {
      parts.add('Closed out without returning to stock.');
    }
    final trimmed = notes?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      parts.add(trimmed);
    }
    return parts.join(' ');
  }

  List<Item> getLowStockItems() {
    final lowStockItems = _items.where((item) {
      return item.isActive &&
          item.minimumQuantity > 0 &&
          item.quantityOnHand <= item.minimumQuantity;
    }).toList();

    lowStockItems.sort((left, right) {
      return left.name.toLowerCase().compareTo(right.name.toLowerCase());
    });

    return lowStockItems;
  }

  double getSuggestedReorderQuantity(Item item) {
    var quantity = item.minimumQuantity - item.quantityOnHand;
    if (quantity <= 0) {
      quantity = 0;
    }

    final unit = _unitById(item.unitOfMeasureId);
    if (unit == null || !unit.allowsDecimal || !item.allowFractionalQuantity) {
      return quantity.ceilToDouble();
    }

    return quantity;
  }

  double getReorderSuggestedQuantity(Item item) {
    final suggested = getSuggestedReorderQuantity(item);
    if (suggested > 0) {
      return suggested;
    }
    final unit = _unitById(item.unitOfMeasureId);
    return unit == null || !unit.allowsDecimal || !item.allowFractionalQuantity
        ? 1
        : 1.0;
  }

  ReorderRequest? getActiveReorderForItem(String itemId) {
    for (final request in _reorderRequests) {
      if (request.itemId == itemId && request.isOpen) {
        return request;
      }
    }

    return null;
  }

  List<ReorderRequest> getOpenReorderRequestsForItem(String itemId) {
    return _sortedReorders(
      _reorderRequests
          .where((request) => request.itemId == itemId && request.isOpen)
          .toList(),
    );
  }

  List<ReorderRequest> getPendingReorderRequests() {
    return _sortedReorders(
      _reorderRequests
          .where((request) => request.status == ReorderStatus.needed)
          .toList(),
    );
  }

  List<ReorderRequest> getOrderedReorderRequests() {
    return _sortedReorders(
      _reorderRequests
          .where((request) => request.status == ReorderStatus.ordered)
          .toList(),
    );
  }

  List<ReorderRequest> getPartiallyReceivedReorderRequests() {
    return _sortedReorders(
      _reorderRequests
          .where((request) => request.status == ReorderStatus.partiallyReceived)
          .toList(),
    );
  }

  List<ReorderRequest> _sortedReorders(List<ReorderRequest> requests) {
    requests.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    return requests;
  }

  ReorderRequest? reorderRequestById(String reorderId) {
    for (final request in _reorderRequests) {
      if (request.id == reorderId) {
        return request;
      }
    }

    return null;
  }

  bool get canManageReorders => permissions.canManageItems;
  bool get canReceiveReorders =>
      canManageReorders || permissions.canReceiveStock;

  bool createReorderRequest(
    String itemId,
    double quantity,
    String? notes, {
    String? supplierId,
    String? supplier,
    String? destinationLocationId,
    String? orderNumber,
    bool allowDuplicateOpen = false,
  }) {
    if (!canManageReorders || quantity <= 0) {
      return false;
    }

    final item = _itemById(itemId);
    if (item == null || !item.isActive) {
      return false;
    }
    if (!allowDuplicateOpen && getActiveReorderForItem(itemId) != null) {
      return false;
    }
    if (!_isWholeQuantityAllowed(item.id, quantity)) {
      return false;
    }

    final now = DateTime.now();
    final normalizedNotes = notes?.trim();
    final normalizedSupplier = supplier?.trim();
    final selectedSupplier = supplierById(supplierId);
    final normalizedOrderNumber = orderNumber?.trim();
    final request = ReorderRequest(
      id: 'reorder-${now.microsecondsSinceEpoch}',
      itemId: item.id,
      requestedQuantity: quantity,
      receivedQuantity: 0,
      unitOfMeasureId: item.unitOfMeasureId,
      supplierId: selectedSupplier?.id ?? item.supplierId,
      supplier: normalizedSupplier == null || normalizedSupplier.isEmpty
          ? selectedSupplier?.name ?? item.supplier
          : normalizedSupplier,
      status: ReorderStatus.needed,
      notes: normalizedNotes == null || normalizedNotes.isEmpty
          ? null
          : normalizedNotes,
      createdAt: now,
      orderedAt: null,
      receivedAt: null,
      cancelledAt: null,
      createdByUserId: currentUser?.id,
      orderedByUserId: null,
      receivedByUserId: null,
      destinationLocationId: destinationLocationId ?? item.locationId,
      purchaseUnitOfMeasureId: item.purchaseUnitOfMeasureId,
      purchaseQuantity: hasPurchaseConversion(item)
          ? quantity / item.purchaseToStockConversionFactor!
          : null,
      purchaseToStockConversionFactor: item.purchaseToStockConversionFactor,
      expectedCost: item.unitCost == null ? null : item.unitCost! * quantity,
      orderNumber:
          normalizedOrderNumber == null || normalizedOrderNumber.isEmpty
          ? null
          : normalizedOrderNumber,
    );

    _reorderRequests.add(request);
    unawaited(_database.upsertReorderRequest(request.toCompanion()));
    queuePurchaseOrderForSync(request.id);
    notifyListeners();
    return true;
  }

  bool updateReorderRequest(
    String reorderId, {
    double? requestedQuantity,
    String? supplierId,
    String? supplier,
    String? destinationLocationId,
    String? notes,
    String? orderNumber,
  }) {
    if (!canManageReorders) {
      return false;
    }

    final requestIndex = _reorderRequests.indexWhere(
      (request) => request.id == reorderId,
    );
    if (requestIndex == -1) {
      return false;
    }

    final request = _reorderRequests[requestIndex];
    if (!request.isOpen) {
      return false;
    }
    final item = _itemById(request.itemId);
    if (item == null) {
      return false;
    }

    final updatedQuantity = requestedQuantity ?? request.requestedQuantity;
    if (updatedQuantity <= 0 ||
        !_isWholeQuantityAllowed(item.id, updatedQuantity)) {
      return false;
    }
    final trimmedSupplier = supplier?.trim();
    final selectedSupplier = supplierById(supplierId);
    final trimmedNotes = notes?.trim();
    final trimmedOrderNumber = orderNumber?.trim();
    final updatedRequest = request.copyWith(
      requestedQuantity: updatedQuantity,
      supplierId: selectedSupplier?.id ?? supplierId,
      clearSupplierId: supplierId != null && supplierId.isEmpty,
      supplier: trimmedSupplier,
      clearSupplier: trimmedSupplier != null && trimmedSupplier.isEmpty,
      destinationLocationId:
          destinationLocationId ?? request.destinationLocationId,
      notes: trimmedNotes,
      clearNotes: trimmedNotes != null && trimmedNotes.isEmpty,
      orderNumber: trimmedOrderNumber,
      clearOrderNumber:
          trimmedOrderNumber != null && trimmedOrderNumber.isEmpty,
      purchaseQuantity: hasPurchaseConversion(item)
          ? updatedQuantity / item.purchaseToStockConversionFactor!
          : request.purchaseQuantity,
      expectedCost: item.unitCost == null
          ? null
          : item.unitCost! * updatedQuantity,
    );
    _reorderRequests[requestIndex] = updatedRequest;
    unawaited(_database.upsertReorderRequest(updatedRequest.toCompanion()));
    queuePurchaseOrderForSync(updatedRequest.id);
    notifyListeners();
    return true;
  }

  bool markReorderOrdered(
    String reorderId, {
    String? orderNumber,
    String? notes,
  }) {
    if (!canManageReorders) {
      return false;
    }

    final requestIndex = _reorderRequests.indexWhere(
      (request) => request.id == reorderId,
    );
    if (requestIndex == -1) {
      return false;
    }

    final request = _reorderRequests[requestIndex];
    if (request.status != ReorderStatus.needed) {
      return false;
    }

    final normalizedNotes = notes?.trim();
    final normalizedOrderNumber = orderNumber?.trim();
    final now = DateTime.now();
    final updatedRequest = request.copyWith(
      status: ReorderStatus.ordered,
      orderedAt: now,
      orderedByUserId: currentUser?.id,
      orderNumber:
          normalizedOrderNumber == null || normalizedOrderNumber.isEmpty
          ? request.orderNumber
          : normalizedOrderNumber,
      notes: _combineNotes(request.notes, normalizedNotes),
    );
    _reorderRequests[requestIndex] = updatedRequest;
    unawaited(_database.upsertReorderRequest(updatedRequest.toCompanion()));
    queuePurchaseOrderForSync(updatedRequest.id);
    notifyListeners();
    return true;
  }

  bool receiveReorder(
    String reorderId,
    double receivedQuantity,
    String? notes, {
    String? destinationLocationId,
    bool allowOverReceipt = false,
  }) {
    if (!canReceiveReorders || receivedQuantity <= 0) {
      return false;
    }

    final requestIndex = _reorderRequests.indexWhere(
      (request) => request.id == reorderId,
    );
    if (requestIndex == -1) {
      return false;
    }

    final request = _reorderRequests[requestIndex];
    if (request.status != ReorderStatus.needed &&
        request.status != ReorderStatus.ordered &&
        request.status != ReorderStatus.partiallyReceived) {
      return false;
    }

    final item = _itemById(request.itemId);
    if (item == null) {
      return false;
    }
    if (!_isWholeQuantityAllowed(item.id, receivedQuantity)) {
      return false;
    }
    if (!allowOverReceipt && receivedQuantity > request.remainingQuantity) {
      return false;
    }

    final now = DateTime.now();
    final locationId =
        destinationLocationId ??
        request.destinationLocationId ??
        primaryLocationForItem(item.id)?.id ??
        item.locationId;
    final current = _balanceFor(item.id, locationId)?.quantityOnHand ?? 0;
    _setBalanceQuantity(item.id, locationId, current + receivedQuantity, now);
    _syncItemCachedQuantity(item.id, now);

    final normalizedNotes = notes?.trim();
    final newReceivedQuantity = request.receivedQuantity + receivedQuantity;
    final overReceipt = newReceivedQuantity > request.requestedQuantity;
    final nextStatus = newReceivedQuantity >= request.requestedQuantity
        ? ReorderStatus.received
        : ReorderStatus.partiallyReceived;
    final receiveLabel = nextStatus == ReorderStatus.partiallyReceived
        ? 'Partially received from reorder request.'
        : 'Received from reorder request.';
    final transaction = InventoryTransaction(
      id: 'txn-reorder-${now.microsecondsSinceEpoch}',
      itemId: item.id,
      transactionType: InventoryTransactionType.receive,
      quantityDelta: receivedQuantity,
      unitOfMeasureId: item.unitOfMeasureId,
      fromLocationId: null,
      toLocationId: locationId,
      assignedToPersonId: null,
      assignedToTargetId: null,
      assignedToText: null,
      performedByUserId: currentUser?.id,
      notes: [
        receiveLabel,
        if (overReceipt) 'Over-receipt.',
        if (normalizedNotes != null && normalizedNotes.isNotEmpty)
          normalizedNotes,
      ].join(' '),
      createdAt: now,
    );
    _transactions.add(transaction);
    unawaited(_database.upsertTransaction(transaction.toCompanion()));
    queueTransactionForSync(transaction.id);

    final updatedRequest = request.copyWith(
      status: nextStatus,
      receivedQuantity: newReceivedQuantity,
      receivedAt: nextStatus == ReorderStatus.received ? now : null,
      clearReceivedAt: nextStatus != ReorderStatus.received,
      receivedByUserId: currentUser?.id,
      destinationLocationId: locationId,
      notes: _combineNotes(
        request.notes,
        overReceipt
            ? 'Over-received by ${_formatQuantity(newReceivedQuantity - request.requestedQuantity)}.'
            : null,
      ),
    );
    _reorderRequests[requestIndex] = updatedRequest;
    unawaited(_database.upsertReorderRequest(updatedRequest.toCompanion()));
    queuePurchaseOrderForSync(updatedRequest.id);
    notifyListeners();
    return true;
  }

  bool cancelReorder(String reorderId, {String? notes}) {
    if (!canManageReorders) {
      return false;
    }

    final requestIndex = _reorderRequests.indexWhere(
      (request) => request.id == reorderId,
    );
    if (requestIndex == -1) {
      return false;
    }

    final request = _reorderRequests[requestIndex];
    if (request.status != ReorderStatus.needed &&
        request.status != ReorderStatus.ordered &&
        request.status != ReorderStatus.partiallyReceived) {
      return false;
    }

    final normalizedNotes = notes?.trim();
    final updatedRequest = request.copyWith(
      status: ReorderStatus.cancelled,
      cancelledAt: DateTime.now(),
      notes: _combineNotes(request.notes, normalizedNotes),
    );
    _reorderRequests[requestIndex] = updatedRequest;
    unawaited(_database.upsertReorderRequest(updatedRequest.toCompanion()));
    queuePurchaseOrderForSync(updatedRequest.id);
    notifyListeners();
    return true;
  }

  bool reopenReorderRequest(String reorderId) {
    if (!canManageReorders) {
      return false;
    }
    final requestIndex = _reorderRequests.indexWhere(
      (request) => request.id == reorderId,
    );
    if (requestIndex == -1) {
      return false;
    }
    final request = _reorderRequests[requestIndex];
    if (!request.isCancelled) {
      return false;
    }
    final updatedRequest = request.copyWith(
      status: request.receivedQuantity > 0
          ? ReorderStatus.partiallyReceived
          : ReorderStatus.needed,
      clearCancelledAt: true,
    );
    _reorderRequests[requestIndex] = updatedRequest;
    unawaited(_database.upsertReorderRequest(updatedRequest.toCompanion()));
    queuePurchaseOrderForSync(updatedRequest.id);
    notifyListeners();
    return true;
  }

  String? _combineNotes(String? existing, String? added) {
    final first = existing?.trim();
    final second = added?.trim();
    if ((first == null || first.isEmpty) &&
        (second == null || second.isEmpty)) {
      return null;
    }
    if (first == null || first.isEmpty) {
      return second;
    }
    if (second == null || second.isEmpty) {
      return first;
    }
    return '$first $second';
  }

  Item? _itemById(String itemId) {
    for (final item in _items) {
      if (item.id == itemId) {
        return item;
      }
    }

    return null;
  }

  InventoryTransaction? _transactionById(String transactionId) {
    for (final transaction in _transactions) {
      if (transaction.id == transactionId) {
        return transaction;
      }
    }
    return null;
  }

  UnitOfMeasure? _unitById(String unitOfMeasureId) {
    for (final unit in _unitsOfMeasure) {
      if (unit.id == unitOfMeasureId) {
        return unit;
      }
    }

    return null;
  }

  Location? _locationById(String locationId) {
    for (final location in _locations) {
      if (location.id == locationId) {
        return location;
      }
    }

    return null;
  }

  AssignmentTarget? _assignmentTargetById(String targetId) {
    for (final target in _assignmentTargets) {
      if (target.id == targetId) {
        return target;
      }
    }

    return null;
  }

  ItemLocationBalance? _balanceFor(String itemId, String locationId) {
    for (final balance in _itemLocationBalances) {
      if (balance.itemId == itemId && balance.locationId == locationId) {
        return balance;
      }
    }
    return null;
  }

  String _balanceId(String itemId, String locationId) {
    return 'balance-$itemId-$locationId';
  }

  void _upsertBalanceInMemory(ItemLocationBalance balance) {
    final index = _itemLocationBalances.indexWhere(
      (storedBalance) => storedBalance.id == balance.id,
    );
    if (index == -1) {
      _itemLocationBalances.add(balance);
    } else {
      _itemLocationBalances[index] = balance;
    }
  }

  void _setBalanceQuantity(
    String itemId,
    String locationId,
    double quantity,
    DateTime updatedAt,
  ) {
    final balance =
        _balanceFor(
          itemId,
          locationId,
        )?.copyWith(quantityOnHand: quantity, updatedAt: updatedAt) ??
        ItemLocationBalance(
          id: _balanceId(itemId, locationId),
          itemId: itemId,
          locationId: locationId,
          quantityOnHand: quantity,
          minimumQuantity: 0,
          updatedAt: updatedAt,
        );
    _upsertBalanceInMemory(balance);
    unawaited(_database.upsertItemLocationBalance(balance.toCompanion()));
    queueBalanceForSync(balance.id);
  }

  void _syncItemCachedQuantity(String itemId, DateTime updatedAt) {
    final itemIndex = _items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) {
      return;
    }
    final item = _items[itemIndex];
    _items[itemIndex] = item.copyWith(
      quantityOnHand: totalQuantityForItem(itemId),
      updatedAt: updatedAt,
    );
    unawaited(_database.upsertItem(_items[itemIndex].toCompanion()));
  }

  bool _isWholeQuantityAllowed(String itemId, double quantity) {
    final item = _itemById(itemId);
    if (item == null || item.allowFractionalQuantity) {
      return true;
    }
    final unit = _unitById(item.unitOfMeasureId);
    if (unit?.allowsDecimal == true) {
      return true;
    }
    return quantity == quantity.roundToDouble();
  }

  bool _canMutateItemQuantity(String itemId, double quantity) {
    final item = _itemById(itemId);
    return item != null &&
        item.isActive &&
        quantity > 0 &&
        _isWholeQuantityAllowed(itemId, quantity);
  }

  Map<String, double> _reversalLocationImpacts(
    InventoryTransaction transaction,
  ) {
    final impacts = <String, double>{};

    void addImpact(String? locationId, double delta) {
      if (locationId == null || delta == 0) {
        return;
      }
      impacts[locationId] = (impacts[locationId] ?? 0) + delta;
    }

    final quantity = transaction.quantityDelta.abs();
    switch (transaction.transactionType) {
      case InventoryTransactionType.receive:
        addImpact(transaction.toLocationId, -quantity);
        break;
      case InventoryTransactionType.issue ||
          InventoryTransactionType.markLost ||
          InventoryTransactionType.markDamaged:
        addImpact(transaction.fromLocationId, quantity);
        break;
      case InventoryTransactionType.transfer:
        addImpact(transaction.toLocationId, -quantity);
        addImpact(transaction.fromLocationId, quantity);
        break;
      case InventoryTransactionType.adjustment ||
          InventoryTransactionType.cycleCountAdjustment:
        if (transaction.quantityDelta > 0) {
          addImpact(transaction.toLocationId, -quantity);
        } else {
          addImpact(transaction.fromLocationId, quantity);
        }
        break;
      case InventoryTransactionType.checkout ||
          InventoryTransactionType.returnItem ||
          InventoryTransactionType.correction:
        break;
    }
    return impacts;
  }

  void _appendInventoryTransaction({
    required String itemId,
    required InventoryTransactionType type,
    required double quantityDelta,
    String? fromLocationId,
    String? toLocationId,
    String? assignedToPersonId,
    String? assignedToLocationId,
    String? assignedToTargetId,
    String? assignedToText,
    String? notes,
  }) {
    final item = _itemById(itemId);
    if (item == null) {
      return;
    }
    final transaction = InventoryTransaction(
      id: 'txn-${type.name}-${DateTime.now().microsecondsSinceEpoch}',
      itemId: itemId,
      transactionType: type,
      quantityDelta: quantityDelta,
      unitOfMeasureId: item.unitOfMeasureId,
      fromLocationId: fromLocationId,
      toLocationId: toLocationId,
      assignedToPersonId: assignedToPersonId,
      assignedToLocationId: assignedToLocationId,
      assignedToTargetId: assignedToTargetId,
      assignedToText: assignedToText,
      performedByUserId: currentUser?.id,
      notes: notes,
      createdAt: DateTime.now(),
    );
    _transactions.add(transaction);
    unawaited(_database.upsertTransaction(transaction.toCompanion()));
    queueTransactionForSync(transaction.id);
  }

  Future<void> _backfillItemLocationBalances() async {
    var changed = false;
    Location? firstActiveLocation;
    for (final location in _locations) {
      if (location.isActive) {
        firstActiveLocation = location;
        break;
      }
    }
    for (final item in _items.where((item) => item.isActive)) {
      if (_itemLocationBalances.any((balance) => balance.itemId == item.id)) {
        continue;
      }
      final locationId =
          _locations.any((location) => location.id == item.locationId)
          ? item.locationId
          : firstActiveLocation?.id;
      if (locationId == null) {
        continue;
      }
      final balance = ItemLocationBalance(
        id: _balanceId(item.id, locationId),
        itemId: item.id,
        locationId: locationId,
        quantityOnHand: item.quantityOnHand,
        minimumQuantity: 0,
        updatedAt: item.updatedAt,
      );
      _itemLocationBalances.add(balance);
      await _database.upsertItemLocationBalance(balance.toCompanion());
      changed = true;
    }
    for (final item in _items) {
      final total = totalQuantityForItem(item.id);
      if (item.quantityOnHand != total &&
          _itemLocationBalances.any((balance) => balance.itemId == item.id)) {
        final itemIndex = _items.indexWhere(
          (storedItem) => storedItem.id == item.id,
        );
        _items[itemIndex] = item.copyWith(quantityOnHand: total);
        await _database.upsertItem(_items[itemIndex].toCompanion());
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  CycleCountSession? _cycleCountSessionById(String sessionId) {
    for (final session in _cycleCountSessions) {
      if (session.id == sessionId) {
        return session;
      }
    }

    return null;
  }

  bool _cycleCountItemMatchesScope(
    Item item,
    CycleCountScope scope, {
    String? locationId,
    String? category,
    ItemType? itemType,
  }) {
    return switch (scope) {
      CycleCountScope.allItems => true,
      CycleCountScope.location =>
        locationId != null &&
            (_cycleCountLocationsForItem(
              item,
              scope,
              locationId: locationId,
            ).isNotEmpty),
      CycleCountScope.category => item.category == category,
      CycleCountScope.lowStock => isItemLowStock(item),
      CycleCountScope.itemType => item.itemType == itemType,
    };
  }

  List<String> _cycleCountLocationsForItem(
    Item item,
    CycleCountScope scope, {
    String? locationId,
  }) {
    final balances = itemBalancesForItem(item.id);
    if (scope == CycleCountScope.location) {
      if (locationId == null) {
        return const [];
      }
      if (balances.any((balance) => balance.locationId == locationId)) {
        return [locationId];
      }
      if (item.locationId == locationId) {
        return [locationId];
      }
      return const [];
    }

    if (balances.isNotEmpty) {
      return balances.map((balance) => balance.locationId).toSet().toList();
    }
    return [item.locationId];
  }

  String _cycleCountLineLocationId(CycleCountLine line) {
    if (line.locationId.trim().isNotEmpty) {
      return line.locationId;
    }
    final item = _itemById(line.itemId);
    return primaryLocationForItem(line.itemId)?.id ?? item?.locationId ?? '';
  }

  Iterable<InventoryTransaction> _usageTransactions(DateTime? start) {
    return _transactions.where((transaction) {
      if (transaction.isReversed) {
        return false;
      }
      if (start != null && transaction.createdAt.isBefore(start)) {
        return false;
      }

      return switch (transaction.transactionType) {
        InventoryTransactionType.issue ||
        InventoryTransactionType.checkout ||
        InventoryTransactionType.markLost ||
        InventoryTransactionType.markDamaged => true,
        InventoryTransactionType.cycleCountAdjustment =>
          transaction.quantityDelta < 0,
        InventoryTransactionType.correction => transaction.quantityDelta < 0,
        _ => false,
      };
    });
  }

  PlanLimitWarning? _limitWarning({
    required PlanLimitKind kind,
    required int used,
    required int limit,
    required String unitLabel,
  }) {
    if (limit <= 0) {
      return null;
    }

    final ratio = used / limit;
    final severity = switch (ratio) {
      >= 1 => PlanLimitSeverity.reached,
      >= 0.95 => PlanLimitSeverity.nearlyFull,
      >= 0.8 => PlanLimitSeverity.approaching,
      _ => null,
    };

    if (severity == null) {
      return null;
    }

    final message = switch (severity) {
      PlanLimitSeverity.reached =>
        'You are using $used of $limit ${currentPlan.name} plan $unitLabel.',
      PlanLimitSeverity.nearlyFull =>
        'You are using $used of $limit ${currentPlan.name} plan $unitLabel.',
      PlanLimitSeverity.approaching =>
        'You are using $used of $limit ${currentPlan.name} plan $unitLabel.',
    };

    return PlanLimitWarning(
      kind: kind,
      message: message,
      severity: severity,
      recommendedPlanCode: _recommendedPlanCode(kind, used),
    );
  }

  String? _recommendedPlanCode(PlanLimitKind kind, int used) {
    for (final plan in samplePlans) {
      final limit = switch (kind) {
        PlanLimitKind.items => plan.itemLimit,
        PlanLimitKind.users => plan.userLimit,
        PlanLimitKind.locations => plan.locationLimit,
        PlanLimitKind.photos => plan.photoLimit,
        PlanLimitKind.labels => plan.labelExportLimit,
      };

      if (limit > used && plan.code != currentPlan.code) {
        return plan.code;
      }
    }

    return null;
  }

  int _severityRank(PlanLimitSeverity severity) {
    return switch (severity) {
      PlanLimitSeverity.reached => 3,
      PlanLimitSeverity.nearlyFull => 2,
      PlanLimitSeverity.approaching => 1,
    };
  }

  AppActionResult addUnitOfMeasure(UnitOfMeasure unit) {
    if (!permissions.canManageSettings) {
      return AppActionResult.denied();
    }
    _unitsOfMeasure.add(unit);
    unawaited(_database.upsertUnitOfMeasure(unit.toCompanion()));
    notifyListeners();
    return const AppActionResult.success(message: 'Unit added.');
  }

  AppActionResult addLocation(Location location) {
    if (!permissions.canManageSettings) {
      return AppActionResult.denied();
    }
    final name = location.name.trim();
    final code = location.code?.trim();
    final parentId = location.parentLocationId;
    if (name.isEmpty) {
      return AppActionResult.failure('Location name is required.');
    }
    if (isLocationNameInUseUnderParent(name, parentLocationId: parentId)) {
      return AppActionResult.failure(
        'An active location with this name already exists under the same parent.',
      );
    }
    if (code != null && code.isNotEmpty && isLocationCodeInUse(code)) {
      return AppActionResult.failure(
        'Another location already uses this code.',
      );
    }
    if (parentId != null && _locationById(parentId) == null) {
      return AppActionResult.failure('Parent location not found.');
    }
    if (location.isActive && !canAddLocation) {
      return AppActionResult.failure(
        'Your ${currentPlan.name} plan includes up to ${currentPlan.locationLimit} active locations.',
      );
    }
    final now = DateTime.now();
    final saved = location.copyWith(
      name: name,
      code: code,
      clearCode: code == null || code.isEmpty,
      createdAt: location.createdAt == DateTime.fromMillisecondsSinceEpoch(0)
          ? now
          : location.createdAt,
      updatedAt: now,
    );
    _locations.add(saved);
    unawaited(_database.upsertLocation(saved.toCompanion()));
    notifyListeners();
    return const AppActionResult.success(message: 'Location added.');
  }

  AppActionResult updateLocation(Location location) {
    if (!permissions.canManageSettings) {
      return AppActionResult.denied();
    }
    final index = _locations.indexWhere((stored) => stored.id == location.id);
    if (index == -1) {
      return AppActionResult.failure('Location not found.');
    }
    final name = location.name.trim();
    final code = location.code?.trim();
    final parentId = location.parentLocationId;
    if (name.isEmpty) {
      return AppActionResult.failure('Location name is required.');
    }
    if (wouldCreateLocationCycle(location.id, parentId)) {
      return AppActionResult.failure('Parent location cannot create a cycle.');
    }
    if (isLocationNameInUseUnderParent(
      name,
      parentLocationId: parentId,
      excludingLocationId: location.id,
    )) {
      return AppActionResult.failure(
        'An active location with this name already exists under the same parent.',
      );
    }
    if (code != null &&
        code.isNotEmpty &&
        isLocationCodeInUse(code, excludingLocationId: location.id)) {
      return AppActionResult.failure(
        'Another location already uses this code.',
      );
    }
    final saved = location.copyWith(
      name: name,
      code: code,
      clearCode: code == null || code.isEmpty,
      updatedAt: DateTime.now(),
    );
    _locations[index] = saved;
    unawaited(_database.upsertLocation(saved.toCompanion()));
    notifyListeners();
    return const AppActionResult.success(message: 'Location updated.');
  }

  AppActionResult archiveLocation(String locationId) {
    if (!permissions.canManageSettings) {
      return AppActionResult.denied();
    }
    final index = _locations.indexWhere(
      (location) => location.id == locationId,
    );
    if (index == -1) {
      return AppActionResult.failure('Location not found.');
    }
    if (!canArchiveLocation(locationId)) {
      return AppActionResult.failure('This location still has stock.');
    }
    final archived = _locations[index].copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );
    _locations[index] = archived;
    unawaited(_database.upsertLocation(archived.toCompanion()));
    notifyListeners();
    return const AppActionResult.success(message: 'Location archived.');
  }

  AppActionResult unarchiveLocation(String locationId) {
    if (!permissions.canManageSettings) {
      return AppActionResult.denied();
    }
    if (!canAddLocation) {
      return AppActionResult.failure(
        'Your ${currentPlan.name} plan includes up to ${currentPlan.locationLimit} active locations.',
      );
    }
    final index = _locations.indexWhere(
      (location) => location.id == locationId,
    );
    if (index == -1) {
      return AppActionResult.failure('Location not found.');
    }
    final restored = _locations[index].copyWith(
      isActive: true,
      updatedAt: DateTime.now(),
    );
    _locations[index] = restored;
    unawaited(_database.upsertLocation(restored.toCompanion()));
    notifyListeners();
    return const AppActionResult.success(message: 'Location restored.');
  }

  AppActionResult transferAllStockFromLocation(
    String fromLocationId,
    String toLocationId,
  ) {
    if (!permissions.canTransferStock) {
      return AppActionResult.denied();
    }
    if (fromLocationId == toLocationId) {
      return AppActionResult.failure('Choose a different destination.');
    }
    final fromLocation = _locationById(fromLocationId);
    final toLocation = _locationById(toLocationId);
    if (fromLocation == null || toLocation == null || !toLocation.isActive) {
      return AppActionResult.failure('Location not found.');
    }
    final balances = getBalancesAtLocation(
      fromLocationId,
    ).where((balance) => balance.quantityOnHand > 0).toList();
    if (balances.isEmpty) {
      return const AppActionResult.success(message: 'No stock to transfer.');
    }
    final now = DateTime.now();
    for (final balance in balances) {
      final item = _itemById(balance.itemId);
      if (item == null || !item.isActive) {
        continue;
      }
      final toCurrent =
          _balanceFor(balance.itemId, toLocationId)?.quantityOnHand ?? 0;
      _setBalanceQuantity(balance.itemId, fromLocationId, 0, now);
      _setBalanceQuantity(
        balance.itemId,
        toLocationId,
        toCurrent + balance.quantityOnHand,
        now,
      );
      _syncItemCachedQuantity(balance.itemId, now);
      _appendInventoryTransaction(
        itemId: balance.itemId,
        type: InventoryTransactionType.transfer,
        quantityDelta: balance.quantityOnHand,
        fromLocationId: fromLocationId,
        toLocationId: toLocationId,
        notes:
            'Transferred all stock from ${fromLocation.name} to ${toLocation.name}.',
      );
    }
    notifyListeners();
    return AppActionResult.success(
      message: 'Transferred stock from ${fromLocation.name}.',
    );
  }

  AppActionResult addCustomFieldDefinition(CustomFieldDefinition field) {
    if (!permissions.canManageSettings) {
      return AppActionResult.denied();
    }
    _customFieldDefinitions.add(field);
    unawaited(_database.upsertCustomFieldDefinition(field.toCompanion()));
    notifyListeners();
    return const AppActionResult.success(message: 'Custom field added.');
  }

  AppActionResult updateCustomFieldDefinition(CustomFieldDefinition field) {
    if (!permissions.canManageSettings) {
      return AppActionResult.denied();
    }
    final fieldIndex = _customFieldDefinitions.indexWhere(
      (storedField) => storedField.id == field.id,
    );
    if (fieldIndex == -1) {
      return AppActionResult.failure('Custom field not found.');
    }

    _customFieldDefinitions[fieldIndex] = field;
    unawaited(_database.upsertCustomFieldDefinition(field.toCompanion()));
    notifyListeners();
    return const AppActionResult.success(message: 'Custom field updated.');
  }

  AppActionResult archiveCustomFieldDefinition(String fieldId) {
    if (!permissions.canManageSettings) {
      return AppActionResult.denied();
    }
    final fieldIndex = _customFieldDefinitions.indexWhere(
      (field) => field.id == fieldId,
    );
    if (fieldIndex == -1) {
      return AppActionResult.failure('Custom field not found.');
    }

    final archivedField = _customFieldDefinitions[fieldIndex].copyWith(
      isActive: false,
    );
    _customFieldDefinitions[fieldIndex] = archivedField;
    unawaited(
      _database.upsertCustomFieldDefinition(archivedField.toCompanion()),
    );
    notifyListeners();
    return const AppActionResult.success(message: 'Custom field archived.');
  }

  void addCycleCountSession(CycleCountSession session) {
    _cycleCountSessions.add(session);
    unawaited(_database.upsertCycleCountSession(session.toCompanion()));
    queueCycleCountForSync(session.id);
    notifyListeners();
  }

  void updateCycleCountSession(CycleCountSession session) {
    final sessionIndex = _cycleCountSessions.indexWhere(
      (storedSession) => storedSession.id == session.id,
    );
    if (sessionIndex == -1) {
      return;
    }

    _cycleCountSessions[sessionIndex] = session;
    unawaited(_database.upsertCycleCountSession(session.toCompanion()));
    queueCycleCountForSync(session.id);
    notifyListeners();
  }

  void addCycleCountLines(List<CycleCountLine> lines) {
    _cycleCountLines.addAll(lines);
    for (final line in lines) {
      unawaited(_database.upsertCycleCountLine(line.toCompanion()));
      queueCycleCountLineForSync(line.id);
    }
    notifyListeners();
  }

  void updateCycleCountLine(CycleCountLine line) {
    final lineIndex = _cycleCountLines.indexWhere(
      (storedLine) => storedLine.id == line.id,
    );
    if (lineIndex == -1) {
      return;
    }

    _cycleCountLines[lineIndex] = line;
    unawaited(_database.upsertCycleCountLine(line.toCompanion()));
    queueCycleCountLineForSync(line.id);
    notifyListeners();
  }

  AppActionResult submitCycleCount(
    String sessionId,
    List<CycleCountLine> updatedLines,
  ) {
    if (!permissions.canPerformInventoryActions) {
      return AppActionResult.denied();
    }
    final sessionIndex = _cycleCountSessions.indexWhere(
      (session) => session.id == sessionId,
    );
    if (sessionIndex == -1) {
      return AppActionResult.failure('Cycle count not found.');
    }
    final session = _cycleCountSessions[sessionIndex];
    if (session.status == CycleCountStatus.submitted ||
        session.status == CycleCountStatus.approved) {
      return AppActionResult.failure('Cycle count cannot be submitted.');
    }

    for (final line in updatedLines) {
      final lineIndex = _cycleCountLines.indexWhere(
        (storedLine) => storedLine.id == line.id,
      );
      if (lineIndex == -1) {
        return AppActionResult.failure('Cycle count line not found.');
      }
      _cycleCountLines[lineIndex] = line;
      unawaited(_database.upsertCycleCountLine(line.toCompanion()));
      queueCycleCountLineForSync(line.id);
    }

    final submittedSession = session.copyWith(
      status: CycleCountStatus.submitted,
      submittedAt: DateTime.now(),
    );
    _cycleCountSessions[sessionIndex] = submittedSession;
    unawaited(
      _database.upsertCycleCountSession(submittedSession.toCompanion()),
    );
    queueCycleCountForSync(submittedSession.id);
    notifyListeners();
    return AppActionResult.success(
      message: 'Cycle count submitted.',
      data: submittedSession,
    );
  }

  double getExpectedQuantityForItemAtLocation(
    String itemId,
    String locationId,
  ) {
    final balance = _balanceFor(itemId, locationId);
    if (balance != null) {
      return balance.quantityOnHand;
    }

    final item = _itemById(itemId);
    if (item == null) {
      return 0;
    }
    if (item.locationId == locationId && itemBalancesForItem(itemId).isEmpty) {
      return item.quantityOnHand;
    }
    return 0;
  }

  List<CycleCountLine> getCycleCountCandidateLines({
    required String sessionId,
    required CycleCountScope scope,
    String? locationId,
    String? category,
    ItemType? itemType,
  }) {
    final lines = <CycleCountLine>[];
    for (final item in _items.where((item) => item.isActive)) {
      if (!_cycleCountItemMatchesScope(
        item,
        scope,
        locationId: locationId,
        category: category,
        itemType: itemType,
      )) {
        continue;
      }

      final locations = _cycleCountLocationsForItem(
        item,
        scope,
        locationId: locationId,
      );
      for (final countedLocationId in locations) {
        lines.add(
          CycleCountLine(
            id: 'line-$sessionId-${item.id}-$countedLocationId',
            sessionId: sessionId,
            itemId: item.id,
            locationId: countedLocationId,
            expectedQuantity: getExpectedQuantityForItemAtLocation(
              item.id,
              countedLocationId,
            ),
            countedQuantity: null,
            varianceQuantity: null,
            unitOfMeasureId: item.unitOfMeasureId,
            notes: null,
          ),
        );
      }
    }

    lines.sort((left, right) {
      final locationCompare = (resolveLocationName(left.locationId) ?? '')
          .compareTo(resolveLocationName(right.locationId) ?? '');
      if (locationCompare != 0) {
        return locationCompare;
      }
      return resolveItemName(
        left.itemId,
      ).compareTo(resolveItemName(right.itemId));
    });
    return lines;
  }

  CycleCountSession? createCycleCountSessionFromScope({
    required String name,
    required CycleCountScope scope,
    required bool blindCount,
    DateTime? dueAt,
    String? locationId,
    String? category,
    ItemType? itemType,
  }) {
    if (!permissions.canManageCycleCounts) {
      return null;
    }

    final now = DateTime.now();
    final session = CycleCountSession(
      id: 'count-${now.microsecondsSinceEpoch}',
      name: name,
      status: CycleCountStatus.assigned,
      assignedToUserId: currentUser?.id,
      blindCount: blindCount,
      dueAt: dueAt,
      createdAt: now,
      submittedAt: null,
      approvedAt: null,
    );
    final lines = getCycleCountCandidateLines(
      sessionId: session.id,
      scope: scope,
      locationId: locationId,
      category: category,
      itemType: itemType,
    );
    if (lines.isEmpty) {
      return null;
    }

    _cycleCountSessions.add(session);
    unawaited(_database.upsertCycleCountSession(session.toCompanion()));
    _cycleCountLines.addAll(lines);
    queueCycleCountForSync(session.id);
    for (final line in lines) {
      unawaited(_database.upsertCycleCountLine(line.toCompanion()));
      queueCycleCountLineForSync(line.id);
    }
    notifyListeners();
    return session;
  }

  void approveCycleCount(String sessionId) {
    final sessionIndex = _cycleCountSessions.indexWhere(
      (session) =>
          session.id == sessionId &&
          session.status == CycleCountStatus.submitted,
    );
    if (sessionIndex == -1) {
      return;
    }

    final session = _cycleCountSessions[sessionIndex];
    final now = DateTime.now();
    final lines = _cycleCountLines.where((line) {
      return line.sessionId == sessionId && line.countedQuantity != null;
    });

    for (final line in lines) {
      final countedQuantity = line.countedQuantity!;
      final variance =
          line.varianceQuantity ?? countedQuantity - line.expectedQuantity;
      final itemIndex = _items.indexWhere((item) => item.id == line.itemId);
      if (itemIndex == -1) {
        continue;
      }

      final item = _items[itemIndex];
      final locationId = _cycleCountLineLocationId(line);
      _setBalanceQuantity(item.id, locationId, countedQuantity, now);
      _syncItemCachedQuantity(item.id, now);

      if (variance != 0) {
        final locationName =
            resolveLocationName(locationId) ?? 'Unknown location';
        final noteParts = [
          'Cycle count adjustment from ${session.name} at $locationName.',
          if ((line.notes ?? '').trim().isNotEmpty)
            'Count note: ${line.notes!.trim()}',
        ];
        final transaction = InventoryTransaction(
          id: 'txn-cycle-${now.microsecondsSinceEpoch}-${line.id}',
          itemId: item.id,
          transactionType: InventoryTransactionType.cycleCountAdjustment,
          quantityDelta: variance,
          unitOfMeasureId: line.unitOfMeasureId,
          fromLocationId: variance < 0 ? locationId : null,
          toLocationId: variance > 0 ? locationId : null,
          assignedToPersonId: null,
          assignedToTargetId: null,
          assignedToText: null,
          performedByUserId: currentUser?.id,
          notes: noteParts.join(' '),
          createdAt: now,
        );
        _transactions.add(transaction);
        unawaited(_database.upsertTransaction(transaction.toCompanion()));
        queueTransactionForSync(transaction.id);
      }
    }

    final approvedSession = session.copyWith(
      status: CycleCountStatus.approved,
      approvedAt: now,
    );
    _cycleCountSessions[sessionIndex] = approvedSession;
    unawaited(_database.upsertCycleCountSession(approvedSession.toCompanion()));
    queueCycleCountForSync(approvedSession.id);
    notifyListeners();
  }

  SyncUserStatusSummary _buildSyncUserStatus() {
    if (!isCloudConfigured) {
      return const SyncUserStatusSummary(
        status: SyncUserStatus.disabled,
        label: 'Sync off',
        detail: 'Cloud sync is not configured.',
        pendingCount: 0,
        failedCount: 0,
        conflictCount: 0,
        canOpenDiagnostics: false,
      );
    }
    if (!isCloudSignedIn) {
      return SyncUserStatusSummary(
        status: SyncUserStatus.signedOut,
        label: 'Sign in to sync',
        pendingCount: _cloudSyncSummary.pendingUploadCount,
        failedCount: _failedSyncUploadCount,
        conflictCount: syncConflictCount,
        lastSyncedAt: _cloudSyncSummary.lastSuccessfulSyncAt,
        canOpenDiagnostics: canOpenSyncDiagnostics,
      );
    }
    if (_activeWorkspace == null) {
      return SyncUserStatusSummary(
        status: SyncUserStatus.noWorkspace,
        label: 'Choose a workspace',
        pendingCount: _cloudSyncSummary.pendingUploadCount,
        failedCount: _failedSyncUploadCount,
        conflictCount: syncConflictCount,
        lastSyncedAt: _cloudSyncSummary.lastSuccessfulSyncAt,
        canOpenDiagnostics: canOpenSyncDiagnostics,
      );
    }
    if (shouldShowCloudAdoptionWizard) {
      return SyncUserStatusSummary(
        status: SyncUserStatus.setupRequired,
        label: 'Workspace setup needed',
        detail: 'Choose how this device should use the workspace.',
        pendingCount: _cloudSyncSummary.pendingUploadCount,
        failedCount: _failedSyncUploadCount,
        conflictCount: syncConflictCount,
        lastSyncedAt: _cloudSyncSummary.lastSuccessfulSyncAt,
        canOpenDiagnostics: canOpenSyncDiagnostics,
      );
    }
    if (syncCoordinator.isSyncing ||
        _cloudSyncSummary.status == CloudSyncStatus.syncing) {
      return SyncUserStatusSummary(
        status: SyncUserStatus.syncing,
        label: 'Syncing...',
        pendingCount: _cloudSyncSummary.pendingUploadCount,
        failedCount: _failedSyncUploadCount,
        conflictCount: syncConflictCount,
        lastSyncedAt: _cloudSyncSummary.lastSuccessfulSyncAt,
        canOpenDiagnostics: canOpenSyncDiagnostics,
      );
    }
    if (syncConflictCount > 0) {
      return SyncUserStatusSummary(
        status: SyncUserStatus.conflictsNeedReview,
        label: 'Sync problem - tap to review',
        detail: '$syncConflictCount records need review.',
        pendingCount: _cloudSyncSummary.pendingUploadCount,
        failedCount: _failedSyncUploadCount,
        conflictCount: syncConflictCount,
        lastSyncedAt: _cloudSyncSummary.lastSuccessfulSyncAt,
        canOpenDiagnostics: canOpenSyncDiagnostics,
      );
    }
    if (_failedSyncUploadCount > 0 ||
        _cloudSyncSummary.status == CloudSyncStatus.error ||
        _cloudSyncSummary.status == CloudSyncStatus.offline) {
      return SyncUserStatusSummary(
        status: SyncUserStatus.offlineOrFailed,
        label: 'Offline - changes will sync later',
        detail: _cloudSyncSummary.lastError ?? syncCoordinator.lastSyncError,
        pendingCount: _cloudSyncSummary.pendingUploadCount,
        failedCount: _failedSyncUploadCount,
        conflictCount: syncConflictCount,
        lastSyncedAt: _cloudSyncSummary.lastSuccessfulSyncAt,
        canOpenDiagnostics: canOpenSyncDiagnostics,
      );
    }
    if (_cloudSyncSummary.pendingUploadCount > 0) {
      final count = _cloudSyncSummary.pendingUploadCount;
      return SyncUserStatusSummary(
        status: SyncUserStatus.pendingChanges,
        label: '$count ${count == 1 ? 'change' : 'changes'} waiting to sync',
        pendingCount: count,
        failedCount: _failedSyncUploadCount,
        conflictCount: syncConflictCount,
        lastSyncedAt: _cloudSyncSummary.lastSuccessfulSyncAt,
        canOpenDiagnostics: canOpenSyncDiagnostics,
      );
    }
    return SyncUserStatusSummary(
      status: SyncUserStatus.synced,
      label: _cloudSyncSummary.lastSuccessfulSyncAt == null
          ? 'Sync ready'
          : 'Synced ${_relativeSyncTime(_cloudSyncSummary.lastSuccessfulSyncAt!)}',
      pendingCount: 0,
      failedCount: 0,
      conflictCount: 0,
      lastSyncedAt: _cloudSyncSummary.lastSuccessfulSyncAt,
      canOpenDiagnostics: canOpenSyncDiagnostics,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    syncCoordinator.dispose();
    unawaited(_cloudAuthSubscription?.cancel());
    unawaited(_database.close());
    super.dispose();
  }
}

String? _emptyToNull(String? value) {
  final trimmedValue = value?.trim();
  if (trimmedValue == null || trimmedValue.isEmpty) {
    return null;
  }

  return trimmedValue;
}

String _formatQuantity(double quantity) {
  if (quantity == quantity.roundToDouble()) {
    return quantity.toStringAsFixed(0);
  }
  return quantity.toStringAsFixed(2);
}

String cloudSyncStatusLabelForSummary(CloudSyncSummary summary) {
  return switch (summary.status) {
    CloudSyncStatus.disabled => 'Disabled',
    CloudSyncStatus.ready => 'Ready',
    CloudSyncStatus.syncing => 'Syncing',
    CloudSyncStatus.offline => 'Offline',
    CloudSyncStatus.error => 'Error',
    CloudSyncStatus.needsSetup => 'Needs setup',
  };
}

String _relativeSyncTime(DateTime value) {
  final difference = DateTime.now().difference(value);
  if (difference.inMinutes < 1) {
    return 'just now';
  }
  if (difference.inHours < 1) {
    return '${difference.inMinutes}m ago';
  }
  if (difference.inDays < 1) {
    return '${difference.inHours}h ago';
  }
  return '${difference.inDays}d ago';
}

String? _syncTriggerLabel(SyncTrigger? trigger) {
  return switch (trigger) {
    SyncTrigger.login => 'login',
    SyncTrigger.workspaceSelected => 'workspace selected',
    SyncTrigger.appResume => 'app resume',
    SyncTrigger.localChange => 'local change',
    SyncTrigger.manual => 'manual',
    SyncTrigger.retry => 'retry',
    SyncTrigger.startup => 'startup',
    SyncTrigger.connectivityRestored => 'connectivity restored',
    null => null,
  };
}

class InventorySummaryReport {
  const InventorySummaryReport({
    required this.activeItemCount,
    required this.archivedItemCount,
    required this.consumableCount,
    required this.returnableCount,
    required this.assetCount,
    required this.locationCount,
    required this.lowStockCount,
    required this.activeReorderCount,
    required this.openCheckoutCount,
  });

  final int activeItemCount;
  final int archivedItemCount;
  final int consumableCount;
  final int returnableCount;
  final int assetCount;
  final int locationCount;
  final int lowStockCount;
  final int activeReorderCount;
  final int openCheckoutCount;
}

class InventoryValueReport {
  const InventoryValueReport({
    required this.totalValue,
    required this.valueByType,
    required this.valueByLocation,
    required this.missingCostCount,
    required this.missingCostQuantity,
  });

  final double totalValue;
  final Map<ItemType, double> valueByType;
  final Map<String, double> valueByLocation;
  final int missingCostCount;
  final double missingCostQuantity;
}

class UsageByItemRow {
  const UsageByItemRow({
    required this.itemId,
    required this.quantity,
    required this.unitOfMeasureId,
    required this.transactionCount,
  });

  final String itemId;
  final double quantity;
  final String unitOfMeasureId;
  final int transactionCount;
}

class UsageByPersonRow {
  const UsageByPersonRow({
    required this.personId,
    required this.quantity,
    required this.transactionCount,
    required this.topItemIds,
  });

  final String personId;
  final double quantity;
  final int transactionCount;
  final List<String> topItemIds;
}

class UsageByAssignmentTargetRow {
  const UsageByAssignmentTargetRow({
    required this.targetId,
    required this.quantity,
    required this.transactionCount,
    required this.topItemIds,
  });

  final String targetId;
  final double quantity;
  final int transactionCount;
  final List<String> topItemIds;
}

class AppActionResult {
  const AppActionResult({required this.success, this.message, this.data});

  const AppActionResult.success({this.message, this.data}) : success = true;

  const AppActionResult.failure(this.message, {this.data}) : success = false;

  factory AppActionResult.denied() {
    return const AppActionResult.failure(
      'You do not have permission to do that in this workspace.',
    );
  }

  final bool success;
  final String? message;
  final Object? data;
}

class LostDamagedReportRow {
  const LostDamagedReportRow({
    required this.itemId,
    required this.status,
    required this.quantity,
    required this.unitOfMeasureId,
    required this.createdAt,
    required this.notes,
    required this.assignedToPersonId,
    required this.locationId,
  });

  final String itemId;
  final String status;
  final double quantity;
  final String unitOfMeasureId;
  final DateTime createdAt;
  final String? notes;
  final String? assignedToPersonId;
  final String? locationId;
}

class CycleCountVarianceRow {
  const CycleCountVarianceRow({
    required this.itemId,
    required this.sessionName,
    required this.sessionDate,
    required this.expectedQuantity,
    required this.countedQuantity,
    required this.varianceQuantity,
    required this.unitOfMeasureId,
    required this.locationId,
  });

  final String itemId;
  final String sessionName;
  final DateTime sessionDate;
  final double expectedQuantity;
  final double countedQuantity;
  final double varianceQuantity;
  final String unitOfMeasureId;
  final String locationId;
}

class ReorderStatusSummary {
  const ReorderStatusSummary({
    required this.needed,
    required this.ordered,
    required this.partiallyReceived,
    required this.received,
    required this.canceled,
  });

  final int needed;
  final int ordered;
  final int partiallyReceived;
  final int received;
  final int canceled;
}

class LocationStockSummary {
  const LocationStockSummary({
    required this.itemCount,
    required this.positiveBalanceCount,
    required this.totalQuantity,
  });

  final int itemCount;
  final int positiveBalanceCount;
  final double totalQuantity;
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalActiveItems,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.negativeStockCount,
    required this.missingLocationBalanceCount,
    required this.missingSetupDataCount,
    required this.checkedOutCount,
    required this.overdueCheckoutCount,
    required this.dueSoonCheckoutCount,
    required this.pendingReorderCount,
    required this.orderedReorderCount,
    required this.lowStockWithoutReorderCount,
    required this.draftCycleCountCount,
    required this.submittedCycleCountCount,
    required this.cycleCountVarianceCount,
    required this.dataHealthErrorCount,
    required this.dataHealthWarningCount,
    required this.recentTransactions,
  });

  final int totalActiveItems;
  final int lowStockCount;
  final int outOfStockCount;
  final int negativeStockCount;
  final int missingLocationBalanceCount;
  final int missingSetupDataCount;
  final int checkedOutCount;
  final int overdueCheckoutCount;
  final int dueSoonCheckoutCount;
  final int pendingReorderCount;
  final int orderedReorderCount;
  final int lowStockWithoutReorderCount;
  final int draftCycleCountCount;
  final int submittedCycleCountCount;
  final int cycleCountVarianceCount;
  final int? dataHealthErrorCount;
  final int? dataHealthWarningCount;
  final List<InventoryTransaction> recentTransactions;

  bool get hasAttentionItems {
    return lowStockCount > 0 ||
        outOfStockCount > 0 ||
        negativeStockCount > 0 ||
        missingLocationBalanceCount > 0 ||
        missingSetupDataCount > 0 ||
        overdueCheckoutCount > 0 ||
        pendingReorderCount > 0 ||
        orderedReorderCount > 0 ||
        submittedCycleCountCount > 0 ||
        cycleCountVarianceCount > 0 ||
        (dataHealthErrorCount ?? 0) > 0 ||
        (dataHealthWarningCount ?? 0) > 0;
  }
}

class AppStoreScope extends InheritedNotifier<AppStore> {
  const AppStoreScope({
    super.key,
    required AppStore store,
    required super.child,
  }) : super(notifier: store);

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStoreScope>();
    assert(scope != null, 'No AppStoreScope found in context.');
    return scope!.notifier!;
  }
}
