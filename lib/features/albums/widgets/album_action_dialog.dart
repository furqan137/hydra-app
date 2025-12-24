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
    return AlertDialog(
      backgroundColor: const Color(0xFF101B2B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Add files to album',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _actionButton(
            icon: Icons.lock,
            label: 'Add from Vault',
            onTap: () {
              Navigator.of(context).pop(); // ONLY close dialog
              onAddFromVault();            // navigation handled outside
            },
          ),
          const SizedBox(height: 12),
          _actionButton(
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
            child: const Text(
              'Skip for now',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0FB9B1),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
