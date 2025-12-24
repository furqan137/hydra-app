import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_permissions_controller.dart';

class AppPermissionsScreen extends StatelessWidget {
  const AppPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppPermissionsController(),
      child: const _PermissionsView(),
    );
  }
}

class _PermissionsView extends StatelessWidget {
  const _PermissionsView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppPermissionsController>();
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
                    _permissionTile(
                      icon: Icons.photo_library,
                      title: 'Photos & Media',
                      subtitle: 'Required to import photos & videos',
                      enabled: state.storageGranted,
                      onTap: controller.requestStorage,
                    ),
                    _permissionTile(
                      icon: Icons.camera_alt,
                      title: 'Camera',
                      subtitle: 'Capture photos securely',
                      enabled: state.cameraGranted,
                      onTap: controller.requestCamera,
                    ),
                    _permissionTile(
                      icon: Icons.mic,
                      title: 'Microphone',
                      subtitle: 'Record secure videos',
                      enabled: state.microphoneGranted,
                      onTap: controller.requestMicrophone,
                    ),
                    _permissionTile(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      subtitle: 'Security alerts & reminders',
                      enabled: state.notificationsGranted,
                      onTap: controller.requestNotifications,
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: controller.openSystemSettings,
                      child: const Text(
                        'Open system app settings',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'App Permissions',
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

  // ================= TILE =================
  Widget _permissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.tealAccent),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white60),
        ),
        trailing: Icon(
          enabled ? Icons.check_circle : Icons.radio_button_unchecked,
          color: enabled ? Colors.tealAccent : Colors.white38,
        ),
      ),
    );
  }
}
