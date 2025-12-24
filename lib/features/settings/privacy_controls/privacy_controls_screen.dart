import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'privacy_controls_controller.dart';
import '../hide_app/hide_app_screen.dart';

class PrivacyControlsScreen extends StatelessWidget {
  const PrivacyControlsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PrivacyControlsController(),
      child: const _PrivacyControlsView(),
    );
  }
}

class _PrivacyControlsView extends StatelessWidget {
  const _PrivacyControlsView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrivacyControlsController>();
    final state = controller.state;

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
              _header(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _sectionTitle('Privacy Controls'),

                    /// 🔒 Disable screenshots
                    _toggleTile(
                      icon: Icons.visibility_off,
                      title: 'Disable screenshots',
                      subtitle:
                      'Block screenshots while viewing files.',
                      value: state.blockScreenshots,
                      onChanged: controller.toggleScreenshots,
                    ),

                    /// 🧹 Clear cache
                    _toggleTile(
                      icon: Icons.cleaning_services,
                      title: 'Clear cache on exit',
                      subtitle:
                      'Automatically clear cached files on exit.',
                      value: state.clearCacheOnExit,
                      onChanged: controller.toggleClearCache,
                    ),

                    /// 🛡 Secure delete
                    _toggleTile(
                      icon: Icons.security,
                      title: 'Secure delete',
                      subtitle:
                      'Permanently overwrite shredded files.',
                      value: state.secureDelete,
                      onChanged: controller.toggleSecureDelete,
                    ),

                    const SizedBox(height: 28),

                    _sectionTitle('Advanced Privacy'),

                    /// 🕵️ Hide App (NEW)
                    _navigationTile(
                      icon: Icons.phonelink_lock,
                      title: 'Hide app',
                      subtitle:
                      'Hide Hidra and access it using a dial code.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HideAppScreen(),
                          ),
                        );
                      },
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
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'Privacy Controls',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ================= TOGGLE TILE =================
  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.tealAccent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF0FB9B1),
          ),
        ],
      ),
    );
  }

  // ================= NAVIGATION TILE =================
  Widget _navigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.tealAccent),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white54,
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
