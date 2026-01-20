import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'restore_backup_controller.dart';
import '../../../vault/vault_controller.dart';
import '../../../albums/albums_state.dart';

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

    // ✅ Get global providers safely
    final vaultController =
    Provider.of<VaultController>(context, listen: false);
    final albumsState =
    Provider.of<AlbumsState>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _mainUI(
            context,
            controller,
            vaultController,
            albumsState,
          ),
          if (state.isLoading) _loadingOverlay(),
        ],
      ),
    );
  }

  // ================= MAIN UI =================

  Widget _mainUI(
      BuildContext context,
      RestoreBackupController controller,
      VaultController vaultController,
      AlbumsState albumsState,
      ) {
    return Container(
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
            _icon(),
            const SizedBox(height: 20),
            _title(),
            const SizedBox(height: 30),
            Expanded(
              child: _form(
                context,
                controller,
                vaultController,
                albumsState,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FORM =================

  Widget _form(
      BuildContext context,
      RestoreBackupController controller,
      VaultController vaultController,
      AlbumsState albumsState,
      ) {
    final state = controller.state;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        _label('Backup file'),
        _fileTile(
          fileName: state.selectedBackupName,
          onTap: controller.pickBackupFile,
        ),
        const SizedBox(height: 24),
        _label('Enter password'),
        _passwordField(controller),
        const SizedBox(height: 40),

        /// 🔥 FINAL RESTORE ACTION (CORRECT)
        ElevatedButton(
          onPressed: state.isLoading
              ? null
              : () async {
            await controller.restoreBackup(context);

            // 🔥 FORCE UI RELOAD
            await context.read<VaultController>().forceReload();
            await context.read<AlbumsState>().reloadFromStorage();

            Navigator.of(context).pop();
          },

          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0FB9B1),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            'Restore Backup',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  // ================= UI PARTS =================

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
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
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _icon() => Container(
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
  );

  Widget _title() => const Text(
    'Restore from encrypted backup',
    style: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
      ),
    ),
  );

  Widget _fileTile({
    required String fileName,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
      ),
    );
  }

  Widget _passwordField(RestoreBackupController controller) {
    return TextField(
      controller: controller.passwordController,
      obscureText: controller.state.obscurePassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        prefixIcon: const Icon(Icons.lock, color: Colors.white60),
        suffixIcon: IconButton(
          icon: Icon(
            controller.state.obscurePassword
                ? Icons.visibility_off
                : Icons.visibility,
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

  Widget _loadingOverlay() => Container(
    color: Colors.black.withOpacity(0.55),
    child: const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF0FB9B1),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'Restoring backup…',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
