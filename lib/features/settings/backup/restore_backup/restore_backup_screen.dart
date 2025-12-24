import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'restore_backup_controller.dart';

class RestoreBackupScreen extends StatelessWidget {
  const RestoreBackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RestoreBackupController(),
      child: const _RestoreBackupView(),
    );
  }
}

class _RestoreBackupView extends StatelessWidget {
  const _RestoreBackupView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RestoreBackupController>();
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

              const SizedBox(height: 30),

              /// ICON
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.lock_open,
                  color: Color(0xFF0FB9B1),
                  size: 70,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Restore from encrypted backup',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _label('Backup file'),

                    _fileTile(state.selectedBackup),

                    const SizedBox(height: 24),

                    _label('Enter password'),

                    _passwordField(
                      controller: controller,
                      obscure: state.obscurePassword,
                    ),

                    const SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => controller.restoreBackup(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0FB9B1),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Restore Backup',
                        style: TextStyle(fontSize: 16),
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            icon:
            const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'Restore Backup',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _fileTile(String fileName) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder, color: Colors.tealAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }

  Widget _passwordField({
    required RestoreBackupController controller,
    required bool obscure,
  }) {
    return TextField(
      controller: controller.passwordController,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        prefixIcon:
        const Icon(Icons.lock, color: Colors.white60),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white60,
          ),
          onPressed: controller.togglePasswordVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
