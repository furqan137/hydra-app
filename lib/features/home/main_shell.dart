import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../vault/vault_screen.dart';
import '../vault/vault_controller.dart';
import '../albums/albums_screen.dart';
import '../settings/settings_screen.dart'; // ✅ ADD THIS

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;

  final pages = const [
    VaultScreen(),
    AlbumsScreen(),
    SettingsScreen(), // ✅ REPLACED PLACEHOLDER
  ];

  @override
  Widget build(BuildContext context) {
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
