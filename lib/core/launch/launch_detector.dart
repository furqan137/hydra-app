import 'package:flutter/services.dart';

class LaunchDetector {
  static const MethodChannel _channel =
  MethodChannel('hidra/launch');

  static Future<bool> fromSecretDial() async {
    try {
      final source = await _channel.invokeMethod<String>('getLaunchSource');
      return source == 'secret';
    } catch (_) {
      return false;
    }
  }
}
