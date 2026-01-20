import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/splash/splash_screen.dart';
import 'features/settings/hide_app/fake_dialer_screen.dart';
import 'features/home/main_shell.dart';

import 'core/navigation/app_navigator.dart';

import 'features/settings/preferences/preferences_controller.dart';
import 'features/settings/preferences/preferences_state.dart';

import 'features/vault/vault_controller.dart';
import 'features/albums/albums_state.dart';

import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        /// ================= GLOBAL STATE =================
        ChangeNotifierProvider(create: (_) => PreferencesController()),

        /// ================= DATA STATE =================
        ChangeNotifierProvider(create: (_) => VaultController()),
        ChangeNotifierProvider(create: (_) => AlbumsState()),
      ],
      child: const HidraApp(),
    ),
  );
}

class HidraApp extends StatelessWidget {
  const HidraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferencesController>(
      builder: (context, prefs, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          /// 🔥 GLOBAL NAVIGATION (dialogs, restore, errors)
          navigatorKey: appNavigatorKey,

          // ================= THEME =================
          /// ✅ FIX: system theme truly follows OS
          themeMode: prefs.state.theme == AppTheme.system
              ? ThemeMode.system
              : _mapTheme(prefs.state.theme),

          theme: AppThemes.light,
          darkTheme: AppThemes.dark,

          // ================= ENTRY =================
          home: const _StartupGate(),
          onGenerateRoute: _routes,
        );
      },
    );
  }

  // ================= ROUTES =================
  static Route<dynamic>? _routes(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => const MainShell());
      default:
        return null;
    }
  }
}

// ================= THEME MAPPER =================
ThemeMode _mapTheme(AppTheme theme) {
  switch (theme) {
    case AppTheme.light:
      return ThemeMode.light;
    case AppTheme.dark:
      return ThemeMode.dark;
    case AppTheme.system:
    default:
      return ThemeMode.system;
  }
}

/// ================= STARTUP DECIDER =================
class _StartupGate extends StatelessWidget {
  const _StartupGate();

  Future<bool> _isHidden() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hide_app_enabled') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isHidden(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isHidden = snapshot.data!;

        // 🔒 HIDDEN MODE → FAKE DIALER
        if (isHidden) {
          return const FakeDialerScreen();
        }

        // 🔑 NORMAL FLOW → SPLASH → HOME
        return const SplashScreen();
      },
    );
  }
}
