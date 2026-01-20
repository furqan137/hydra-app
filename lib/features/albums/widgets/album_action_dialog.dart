import 'package:flutter/material.dart';

class AlbumActionDialog extends StatelessWidget {
  final VoidCallback onAddFromVault;
  final VoidCallback onImport;
  final VoidCallback onSkip;

  const AlbumActionDialog({
    super.key,
    required this.onAddFromVault,
    required this.onImport,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      backgroundColor: colors.surface, // ✅ THEME AWARE
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        'Add files to album',
        style: theme.textTheme.titleMedium,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _actionButton(
            context: context,
            icon: Icons.lock,
            label: 'Add from Vault',
            onTap: () {
              Navigator.of(context).pop();
              onAddFromVault();
            },
          ),
          const SizedBox(height: 12),
          _actionButton(
            context: context,
            icon: Icons.add_photo_alternate,
            label: 'Import Files',
            onTap: () {
              Navigator.of(context).pop();
              onImport();
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onSkip();
            },
            child: Text(
              'Skip for now',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary, // ✅ FROM THEME
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
