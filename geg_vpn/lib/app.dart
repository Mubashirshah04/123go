import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'ui/pages/home_page.dart';
import 'ui/pages/plans_page.dart';
import 'ui/pages/settings_page.dart';
import 'ui/pages/help_page.dart';

class GEGVpnApp extends ConsumerStatefulWidget {
  const GEGVpnApp({super.key});

  @override
  ConsumerState<GEGVpnApp> createState() => _GEGVpnAppState();
}

class _GEGVpnAppState extends ConsumerState<GEGVpnApp> {
  int _tabIndex = 0;
  final _pages = const [HomePage(), PlansPage(), SettingsPage(), HelpPage()];

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'GEG VPN',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeMode,
      home: Scaffold(
        body: _pages[_tabIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tabIndex,
          onDestinationSelected: (i) => setState(() => _tabIndex = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.vpn_key), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.workspace_premium), label: 'Plans'),
            NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
            NavigationDestination(icon: Icon(Icons.help_outline), label: 'Help'),
          ],
        ),
      ),
    );
  }
}