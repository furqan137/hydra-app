import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'create_backup_controller.dart';

class CreateBackupScreen extends StatelessWidget {
  const CreateBackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateBackupController(),
      child: const _CreateBackupView(),
    );
  }
}

class _CreateBackupView extends StatelessWidget {
  const _CreateBackupView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CreateBackupController>();
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
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.shield,
                  color: Color(0xFF0FB9B1),
                  size: 64,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Create encrypted backup',
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
                    _label('Save to'),

                    _locationTile(state.backupLocation),

                    const SizedBox(height: 24),

                    _label('Backup password'),

                    _passwordField(
                      controller: controller,
                      obscure: state.obscurePassword,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'A password is required to restore this backup.',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => controller.createBackup(context),
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
                        'Create Backup',
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
            'Create Backup',
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

  Widget _locationTile(String location) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud, color: Colors.tealAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              location,
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
    required CreateBackupController controller,
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
