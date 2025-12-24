import 'dart:io';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// 1️⃣ Device supports biometrics hardware?
  static Future<bool> isSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// 2️⃣ Any biometric enrolled on device?
  static Future<bool> isEnrolled() async {
    try {
      final biometrics = await _auth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// 3️⃣ Can app actually use biometrics?
  static Future<bool> canUseBiometrics() async {
    final supported = await isSupported();
    if (!supported) return false;

    final enrolled = await isEnrolled();
    return enrolled;
  }

  /// 4️⃣ Authenticate user (fingerprint / face)
  static Future<bool> authenticate({
    String reason = 'Authenticate to unlock Hidra',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// 5️⃣ Open phone security settings (Android only)
  static Future<void> openDeviceSettings() async {
    try {
      if (Platform.isAndroid) {
        await _auth.stopAuthentication();
        await _auth.authenticate(
          localizedReason: '',
          options: const AuthenticationOptions(
            biometricOnly: false,
          ),
        );
      }
    } catch (_) {}
  }
}
