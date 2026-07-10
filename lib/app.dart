import 'package:flutter/material.dart';

import 'core/app_store.dart';
import 'screens/cloud_login_screen.dart';
import 'screens/counts_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/invite_acceptance_screen.dart';
import 'screens/items_screen.dart';
import 'screens/quick_issue_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/session_lock_screen.dart';
import 'screens/workspace_selection_screen.dart';
import 'widgets/issued_brand_loading.dart';

class IssuedApp extends StatefulWidget {
  const IssuedApp({super.key, this.store});

  final AppStore? store;

  @override
  State<IssuedApp> createState() => _IssuedAppState();
}

class _IssuedAppState extends State<IssuedApp> {
  late final AppStore _store;
  late final Future<void> _initializeStore;
  late final bool _ownsStore;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? AppStore();
    _ownsStore = widget.store == null;
    _initializeStore = _store.initialize();
  }

  @override
  void dispose() {
    if (_ownsStore) {
      _store.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF1E3A5F);

    return AppStoreScope(
      store: _store,
      child: MaterialApp(
        title: 'Issued',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light,
            surface: const Color(0xFFF4F6F8),
          ),
          scaffoldBackgroundColor: const Color(0xFFF4F6F8),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF17212F),
            foregroundColor: Colors.white,
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE1E6EC)),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: seedColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1E3A5F),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        home: FutureBuilder<void>(
          future: _initializeStore,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(body: IssuedBrandLoading());
            }

            if (snapshot.hasError) {
              return _StartupErrorScreen(error: snapshot.error);
            }

            return AnimatedBuilder(
              animation: _store,
              builder: (context, _) {
                if (_store.shouldShowInviteAcceptance) {
                  return const InviteAcceptanceScreen();
                }
                if (_store.isCloudConfigured && !_store.isCloudSignedIn) {
                  return const CloudLoginScreen();
                }
                if (_store.isCloudSignedIn) {
                  if (_store.activeWorkspace == null) {
                    return const WorkspaceSelectionScreen();
                  }
                  return const IssuedShell();
                }
                if (!_store.isSetupComplete) {
                  return const SetupScreen();
                }
                if (_store.isLocked) {
                  return const SessionLockScreen();
                }
                return const IssuedShell();
              },
            );
          },
        ),
      ),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Unable to load Issued data: $error'),
        ),
      ),
    );
  }
}

class IssuedShell extends StatefulWidget {
  const IssuedShell({super.key});

  @override
  State<IssuedShell> createState() => _IssuedShellState();
}

class _IssuedShellState extends State<IssuedShell> {
  int _selectedIndex = 0;

  static const _screens = <Widget>[
    DashboardScreen(),
    QuickIssueScreen(),
    ScanScreen(),
    ItemsScreen(),
    CountsScreen(),
    SettingsScreen(embeddedInShell: true),
  ];

  @override
  Widget build(BuildContext context) {
    final store = AppStoreScope.of(context);
    final userName = store.currentDisplayUserName;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issued'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                userName,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Lock',
            onPressed: () => store.lockSession(),
            icon: const Icon(Icons.lock_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _screens),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (store.checkSessionTimeout()) {
            return;
          }
          store.recordUserActivity();
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.flash_on_outlined),
            selectedIcon: Icon(Icons.flash_on),
            label: 'Quick Issue',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Items',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Counts',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
