import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../vault/vault_screen.dart';
import '../vault/vault_controller.dart';
import '../albums/albums_screen.dart';
import '../settings/settings_screen.dart';
import '../../features/settings/preferences/preferences_state.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;
  bool _loaded = false;

  final pages = const [
    VaultScreen(),   // index 0
    AlbumsScreen(),  // index 1
    SettingsScreen() // index 2
  ];

  @override
  void initState() {
    super.initState();
    _loadStartPage();
  }

  // ================= LOAD START PAGE =================
  Future<void> _loadStartPage() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('start_page');

    if (index != null && index < StartPage.values.length) {
      final startPage = StartPage.values[index];
      currentIndex = startPage == StartPage.albums ? 1 : 0;
    }

    setState(() {
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: Color(0xFF050B18),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => VaultController(),
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF050B18),
          selectedItemColor: const Color(0xFF0FB9B1),
          unselectedItemColor: Colors.white60,
          currentIndex: currentIndex,
          onTap: (i) => setState(() => currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shield),
              label: 'Vault',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              label: 'Albums',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
