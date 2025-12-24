import 'package:flutter/material.dart';

class AlbumViewerActions extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onMove;
  final VoidCallback onDelete;

  const AlbumViewerActions({
    Key? key,
    required this.onExport,
    required this.onMove,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _btn(Icons.upload, 'Export', Colors.white, onExport),
            _btn(Icons.folder, 'Move', Colors.white, onMove),
            _btn(Icons.delete, 'Delete', Colors.redAccent, onDelete),
          ],
        ),
      ),
    );
  }

  Widget _btn(
      IconData icon,
      String label,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}

