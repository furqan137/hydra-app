import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsController(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF050B18),
              Color(0xFF0FB9B1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _header(),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // ================= APP PERMISSIONS =================
                    _SettingsTile(
                      icon: Icons.folder_open,
                      title: 'App permissions',
                      subtitle: 'Manage app permissions',
                      onTap: () =>
                          controller.openAppSettings(context),
                    ),

                    // ================= PRIVACY CONTROLS =================
                    _SettingsTile(
                      icon: Icons.privacy_tip,
                      title: 'Privacy Controls',
                      subtitle:
                      'Screenshots, cache, secure delete',
                      onTap: () =>
                          controller.openPrivacyControls(context),
                    ),

                    // ================= SECURITY =================
                    _SettingsTile(
                      icon: Icons.shield,
                      title: 'Security',
                      subtitle:
                      'Password, biometrics, encryption',
                      onTap: () =>
                          controller.openSecurity(context),
                    ),

                    // ================= BACKUP =================
                    _SettingsTile(
                      icon: Icons.cloud_upload,
                      title: 'Backup',
                      subtitle: 'Backup & restore data',
                      onTap: () =>
                          controller.openBackup(context),
                    ),

                    // ================= PREFERENCES =================
                    _SettingsTile(
                      icon: Icons.tune,
                      title: 'Preferences',
                      subtitle: 'Theme, notifications',
                      onTap: () =>
                          controller.openPreferences(context),
                    ),

                    // ================= ABOUT =================
                    _SettingsTile(
                      icon: Icons.info,
                      title: 'About',
                      subtitle: 'Version, about us',
                      onTap: () =>
                          controller.openAbout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: const [
          Icon(Icons.shield, color: Colors.white),
          Spacer(),
          Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Icon(Icons.more_vert, color: Colors.white),
        ],
      ),
    );
  }
}

// ================= SETTINGS TILE =================
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.tealAccent),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white54,
        ),
      ),
    );
  }
}
