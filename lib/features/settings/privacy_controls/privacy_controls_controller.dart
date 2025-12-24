import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'privacy_controls_state.dart';

class PrivacyControlsController extends ChangeNotifier {
  PrivacyControlsState _state = const PrivacyControlsState();
  PrivacyControlsState get state => _state;

  static const MethodChannel _channel =
  MethodChannel('hidra/screenshot');

  PrivacyControlsController() {
    _applyScreenshotBlock(_state.blockScreenshots);
  }

  // ================= SCREENSHOT BLOCK =================

  Future<void> toggleScreenshots(bool value) async {
    _state = _state.copyWith(blockScreenshots: value);
    notifyListeners();
    await _applyScreenshotBlock(value);
  }

  Future<void> _applyScreenshotBlock(bool enabled) async {
    // Android only – iOS ignored safely
    if (!Platform.isAndroid) return;

    try {
      if (enabled) {
        await _channel.invokeMethod('enableSecure');
      } else {
        await _channel.invokeMethod('disableSecure');
      }
    } catch (e) {
      debugPrint('Screenshot block error: $e');
    }
  }

  // ================= CACHE =================

  void toggleClearCache(bool value) {
    _state = _state.copyWith(clearCacheOnExit: value);
    notifyListeners();
  }

  // ================= SECURE DELETE =================

  void toggleSecureDelete(bool value) {
    _state = _state.copyWith(secureDelete: value);
    notifyListeners();
  }
}
