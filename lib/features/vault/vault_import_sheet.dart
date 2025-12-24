import 'package:flutter/material.dart';
import 'vault_controller.dart';

class VaultImportSheet extends StatefulWidget {
  final VaultController controller;

  const VaultImportSheet({
    super.key,
    required this.controller,
  });

  @override
  State<VaultImportSheet> createState() => _VaultImportSheetState();
}

class _VaultImportSheetState extends State<VaultImportSheet> {
  bool deleteOriginals = false;
  bool isLoading = false;
  double progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      maxChildSize: 0.55,
      minChildSize: 0.35,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0B1C2D),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: isLoading
              ? _loadingView()
              : ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              _grabber(),

              _tile(
                icon: Icons.photo_library,
                title: 'Import photos & videos',
                onTap: _importFiles,
              ),

              const Divider(color: Colors.white24),

              CheckboxListTile(
                value: deleteOriginals,
                onChanged: (v) =>
                    setState(() => deleteOriginals = v ?? false),
                title: const Text(
                  'Delete originals after import',
                  style: TextStyle(color: Colors.white70),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: const Color(0xFF0FB9B1),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===============================
  // IMPORT LOGIC
  // ===============================

  Future<void> _importFiles() async {
    setState(() {
      isLoading = true;
      progress = 0.15;
    });

    await widget.controller.importFromGallery(
      deleteOriginals: deleteOriginals,
    );

    if (!mounted) return;

    setState(() => progress = 1.0);

    await Future.delayed(const Duration(milliseconds: 400));
    Navigator.pop(context);
  }

  // ===============================
  // LOADING UI (MATCHES DESIGN)
  // ===============================

  Widget _loadingView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          /// VAULT ICON
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.lock,
              color: Color(0xFF0FB9B1),
              size: 64,
            ),
          ),

          const SizedBox(height: 28),

          /// FILE COUNT
          Text(
            '${widget.controller.totalFiles + 1} files',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          /// PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(
                Color(0xFF0FB9B1),
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// STATUS TEXT
          const Text(
            'Encrypting files securely...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  // ===============================
  // UI HELPERS
  // ===============================

  Widget _grabber() {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing:
      const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: onTap,
    );
  }
}
