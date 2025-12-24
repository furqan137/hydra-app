import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/settings/hide_app/fake_dialer_screen.dart';
import '../features/splash/splash_screen.dart';

class StartupRouter extends StatelessWidget {
  const StartupRouter({super.key});

  Future<_StartupDecision> _resolve() async {
    final prefs = await SharedPreferences.getInstance();

    final isHidden = prefs.getBool('hide_app_enabled') ?? false;
    final launchSource =
        prefs.getString('launch_source') ?? 'launcher';

    return _StartupDecision(
      isHidden: isHidden,
      launchSource: launchSource,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StartupDecision>(
      future: _resolve(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final decision = snapshot.data!;

        // 🔒 HIDDEN + LAUNCHER → FAKE DIALER
        if (decision.isHidden &&
            decision.launchSource == 'launcher') {
          return const FakeDialerScreen();
        }

        // 🔑 SECRET / NORMAL → REAL APP
        return const SplashScreen();
      },
    );
  }
}

class _StartupDecision {
  final bool isHidden;
  final String launchSource;

  _StartupDecision({
    required this.isHidden,
    required this.launchSource,
  });
}
