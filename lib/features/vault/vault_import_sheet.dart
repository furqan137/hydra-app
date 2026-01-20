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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      maxChildSize: 0.55,
      minChildSize: 0.35,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            // ✅ THEME-AWARE BACKGROUND
            color: theme.brightness == Brightness.dark
                ? colors.surface
                : colors.surfaceVariant,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: isLoading
              ? _loadingView(context)
              : ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              _grabber(context),

              /// 📷 IMPORT FROM GALLERY
              _assetTile(
                context,
                asset: 'assets/icons/gallery.png',
                title: 'Import from Gallery',
                onTap: _importFromGallery,
              ),

              /// 🔄 RESTORE BACKUP
              _assetTile(
                context,
                asset: 'assets/icons/restore.png',
                title: 'Restore Backup',
                onTap: _restoreBackup,
              ),

              Divider(color: colors.onSurface.withOpacity(0.15)),

              /// 🗑 DELETE ORIGINALS
              CheckboxListTile(
                value: deleteOriginals,
                onChanged: (v) =>
                    setState(() => deleteOriginals = v ?? false),
                title: Text(
                  'Delete originals after import',
                  style: TextStyle(
                    color: colors.onSurface.withOpacity(0.75),
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: colors.primary,
                checkColor: colors.onPrimary,
              ),

              const SizedBox(height: 8),

              /// ❌ CANCEL
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===============================
  // ACTIONS
  // ===============================

  Future<void> _importFromGallery() async {
    setState(() {
      isLoading = true;
      progress = 0.15;
    });

    await widget.controller.importFromGallery(
      deleteOriginals: deleteOriginals,
    );

    if (!mounted) return;

    setState(() => progress = 1.0);
    await Future.delayed(const Duration(milliseconds: 300));
    Navigator.pop(context);
  }

  Future<void> _restoreBackup() async {
    setState(() {
      isLoading = true;
      progress = 0.1;
    });

    try {
      await widget.controller.restoreBackup();

      if (!mounted) return;

      setState(() => progress = 1.0);
      await Future.delayed(const Duration(milliseconds: 300));
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  // ===============================
  // LOADING UI
  // ===============================

  Widget _loadingView(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              Icons.lock,
              color: colors.primary,
              size: 64,
            ),
          ),

          const SizedBox(height: 28),

          Text(
            '${widget.controller.totalFiles} files',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colors.onSurface.withOpacity(0.12),
              valueColor:
              AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Processing securely...',
            style: TextStyle(
              color: colors.onSurface.withOpacity(0.7),
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

  Widget _grabber(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colors.onSurface.withOpacity(0.25),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _assetTile(
      BuildContext context, {
        required String asset,
        required String title,
        required VoidCallback onTap,
      }) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      leading: Image.asset(
        asset,
        width: 28,
        height: 28,
        color: colors.onSurface,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: colors.onSurface,
          fontSize: 16,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colors.onSurface.withOpacity(0.5),
      ),
      onTap: onTap,
    );
  }
}
