import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/security/secure_storage.dart';
import '../../core/utils/app_preferences.dart';

import '../../features/settings/hide_app/fake_dialer_screen.dart';
import '../auth/enter_pin_screen.dart';
import '../auth/create_password_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashController {
  static const _kLaunchViaSecret = 'launch_via_secret_code';
  static const _kHideApp = 'hide_app_enabled';
  static const _kSecretBypass = 'secret_bypass_active';

  Future<void> startTimer(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));
    if (!context.mounted) return;

    final prefs = await SharedPreferences.getInstance();

    final launchViaSecret =
        prefs.getBool(_kLaunchViaSecret) ?? false;
    final isHidden =
        prefs.getBool(_kHideApp) ?? false;
    final secretBypass =
        prefs.getBool(_kSecretBypass) ?? false;

    // ================= 1️⃣ SECRET CODE (HIGHEST PRIORITY) =================
    if (launchViaSecret) {
      // Clear secret launch flag
      await prefs.setBool(_kLaunchViaSecret, false);

      // Enable one-time bypass of fake dialer
      await prefs.setBool(_kSecretBypass, true);

      await _continueAuthFlow(context);
      return;
    }

    // ================= 2️⃣ BYPASS ACTIVE (POST-RESTART SAFETY) =================
    if (secretBypass) {
      // Consume bypass so it runs only once
      await prefs.setBool(_kSecretBypass, false);

      await _continueAuthFlow(context);
      return;
    }

    // ================= 3️⃣ NORMAL HIDDEN LAUNCH =================
    if (isHidden) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const FakeDialerScreen(),
        ),
      );
      return;
    }

    // ================= 4️⃣ NORMAL FLOW =================
    await _continueAuthFlow(context);
  }

  // ================= AUTH / ONBOARDING FLOW =================
  Future<void> _continueAuthFlow(BuildContext context) async {
    final onboardingDone = await AppPreferences.isOnboardingComplete();
    if (!context.mounted) return;

    if (!onboardingDone) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );
      return;
    }

    final isPinSet = await SecureStorage.isPinSet();
    if (!context.mounted) return;

    if (!isPinSet) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CreatePinScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const EnterPinScreen(),
        ),
      );
    }
  }
}