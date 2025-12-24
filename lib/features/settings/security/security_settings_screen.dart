import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'security_settings_controller.dart';
import 'security_settings_state.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SecuritySettingsController(),
      child: const _SecuritySettingsView(),
    );
  }
}

class _SecuritySettingsView extends StatelessWidget {
  const _SecuritySettingsView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SecuritySettingsController>();
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
                    _sectionTitle('Security Settings'),

                    /// CHANGE PASSWORD
                    _navTile(
                      icon: Icons.key,
                      title: 'Change Password',
                      onTap: () =>
                          controller.openChangePassword(context),
                    ),

                    /// BIOMETRIC (SYNCED WITH CONTROLLER)
                    _toggleTile(
                      icon: Icons.fingerprint,
                      title: 'Enable biometric unlock',
                      subtitle: 'Use biometrics for faster access.',
                      value: state.biometricEnabled,
                      onChanged: (value) async {
                        await controller.toggleBiometric(value, context);
                      },
                    ),

                    const SizedBox(height: 28),

                    _sectionTitle('Auto-lock timeout'),

                    _radioTile(
                      label: 'Immediately',
                      selected:
                      state.autoLockTimeout ==
                          AutoLockTimeout.immediate,
                      onTap: () => controller.setAutoLockTimeout(
                        AutoLockTimeout.immediate,
                      ),
                    ),

                    _radioTile(
                      label: '1 min',
                      selected:
                      state.autoLockTimeout ==
                          AutoLockTimeout.oneMinute,
                      onTap: () => controller.setAutoLockTimeout(
                        AutoLockTimeout.oneMinute,
                      ),
                    ),

                    _radioTile(
                      label: '5 min',
                      selected:
                      state.autoLockTimeout ==
                          AutoLockTimeout.fiveMinutes,
                      onTap: () => controller.setAutoLockTimeout(
                        AutoLockTimeout.fiveMinutes,
                      ),
                    ),

                    _radioTile(
                      label: '10 min',
                      selected:
                      state.autoLockTimeout ==
                          AutoLockTimeout.tenMinutes,
                      onTap: () => controller.setAutoLockTimeout(
                        AutoLockTimeout.tenMinutes,
                      ),
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
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'Settings',
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

  // ================= UI HELPERS =================

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

  Widget _navTile({
    required IconData icon,
    required String title,
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
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white54,
        ),
      ),
    );
  }

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

  Widget _radioTile({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          selected
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
          color:
          selected ? const Color(0xFF0FB9B1) : Colors.white38,
        ),
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
