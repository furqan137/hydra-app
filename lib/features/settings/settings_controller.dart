import 'package:flutter/material.dart';

import 'settings_state.dart';

// SETTINGS FEATURES
import 'preferences/preferences_screen.dart';
import 'app_permissions/app_permissions_screen.dart';
import 'privacy_controls/privacy_controls_screen.dart';
import 'security/security_settings_screen.dart';

// BACKUP FEATURE
import 'backup/backup_restore_screen.dart';

// ABOUT FEATURE
import 'about/about_screen.dart';

class SettingsController extends ChangeNotifier {
  SettingsState _state = const SettingsState();

  SettingsState get state => _state;

  void setLoading(bool value) {
    _state = _state.copyWith(isLoading: value);
    notifyListeners();
  }

  // ================= NAVIGATION =================

  /// App → Manage system permissions
  void openAppSettings(BuildContext context) {
    _push(context, const AppPermissionsScreen());
  }

  /// Privacy → Screenshots, cache, secure delete, hide app
  void openPrivacyControls(BuildContext context) {
    _push(context, const PrivacyControlsScreen());
  }

  /// Security → PIN, biometrics, auto-lock
  void openSecurity(BuildContext context) {
    _push(context, const SecuritySettingsScreen());
  }

  /// Backup → Backup & Restore
  void openBackup(BuildContext context) {
    _push(context, const BackupRestoreScreen());
  }

  /// Preferences → Theme, start page
  void openPreferences(BuildContext context) {
    _push(context, const PreferencesScreen());
  }

  /// About → Version, policy, support, credits
  void openAbout(BuildContext context) {
    _push(context, const AboutScreen());
  }

  // ================= HELPER =================

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
