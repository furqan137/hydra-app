import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/splash/splash_screen.dart';
import 'features/settings/hide_app/fake_dialer_screen.dart';
import 'features/home/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HidraApp());
}

class HidraApp extends StatelessWidget {
  const HidraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _StartupGate(), // ✅ SINGLE ENTRY POINT
      onGenerateRoute: _routes,
    );
  }

  static Route<dynamic>? _routes(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => const MainShell());
      default:
        return null;
    }
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
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final isHidden = snapshot.data!;

        // 🔒 HIDDEN → FAKE DIALER
        if (isHidden) {
          return const FakeDialerScreen();
        }

        // 🔑 NORMAL FLOW → SPLASH (AUTH → PIN → HOME)
        return const SplashScreen();
      },
    );
  }
}
