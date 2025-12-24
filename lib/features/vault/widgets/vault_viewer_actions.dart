import 'dart:ui';
import 'package:flutter/material.dart';

class VaultViewerActions extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onMove;
  final VoidCallback onDelete;

  const VaultViewerActions({
    super.key,
    required this.onExport,
    required this.onMove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _action(
                    icon: Icons.upload,
                    label: 'Export',
                    color: Colors.white,
                    onTap: onExport,
                  ),
                  _action(
                    icon: Icons.folder,
                    label: 'Move',
                    color: Colors.white,
                    onTap: onMove,
                  ),
                  _action(
                    icon: Icons.delete,
                    label: 'Delete',
                    color: Colors.redAccent,
                    onTap: onDelete,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
