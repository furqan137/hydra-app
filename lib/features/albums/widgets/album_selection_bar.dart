import 'package:flutter/material.dart';

class AlbumSelectionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onDelete;
  final VoidCallback onExport;
  final VoidCallback onClear;

  const AlbumSelectionBar({
    super.key,
    required this.selectedCount,
    required this.onDelete,
    required this.onExport,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  /// ❌ CLEAR SELECTION
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: onClear,
                  ),

                  const SizedBox(width: 6),

                  /// 📌 SELECTED COUNT
                  Text(
                    'Selected • $selectedCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  /// ⬆️ EXPORT
                  IconButton(
                    icon: const Icon(
                      Icons.upload,
                      color: Colors.white,
                    ),
                    onPressed: onExport,
                    tooltip: 'Export',
                  ),

                  /// 🗑 DELETE
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    ),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
