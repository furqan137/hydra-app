import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final _storage = FlutterSecureStorage();
  static const _pinKey = 'user_pin';
  static const _pinSetKey = 'is_pin_set';

  // Save PIN (should be hashed in production)
  static Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
    await _storage.write(key: _pinSetKey, value: 'true');
  }

  // Read PIN
  static Future<String?> readPin() async {
    return await _storage.read(key: _pinKey);
  }

  // Check if PIN is set
  static Future<bool> isPinSet() async {
    final value = await _storage.read(key: _pinSetKey);
    return value == 'true';
  }

  // Remove PIN (for reset)
  static Future<void> clearPin() async {
    await _storage.delete(key: _pinKey);
    await _storage.delete(key: _pinSetKey);
  }
}
