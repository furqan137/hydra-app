import 'package:flutter/material.dart';

import 'create_backup/create_backup_screen.dart';
import 'restore_backup/restore_backup_screen.dart';

class BackupRestoreScreen extends StatelessWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 32),

              _card(
                icon: Icons.cloud_upload,
                title: 'Create Backup',
                subtitle: 'Securely backup your vault data.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateBackupScreen(),
                    ),
                  );
                },
              ),

              _card(
                icon: Icons.cloud_download,
                title: 'Restore Backup',
                subtitle: 'Restore data from encrypted backup.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RestoreBackupScreen(),
                    ),
                  );
                },
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
            'Backup & Restore',
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

  // ================= CARD =================
  Widget _card({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.tealAccent, size: 28),
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
        trailing:
        const Icon(Icons.chevron_right, color: Colors.white54),
      ),
    );
  }
}
