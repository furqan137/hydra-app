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

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Container(
              height: 72, // ✅ refined height
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? colors.surface.withOpacity(0.85)
                    : colors.surfaceVariant.withOpacity(0.95),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      isDark ? 0.35 : 0.18,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// ❌ CLEAR
                  _iconButton(
                    context,
                    icon: Icons.close,
                    onTap: onClear,
                    tooltip: 'Clear selection',
                  ),

                  const SizedBox(width: 12),

                  /// 📌 SELECTED COUNT
                  Text(
                    'Selected • $selectedCount',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),

                  const Spacer(),

                  /// ⬆️ EXPORT
                  _iconButton(
                    context,
                    icon: Icons.upload,
                    onTap: onExport,
                    tooltip: 'Export',
                  ),

                  const SizedBox(width: 6),

                  /// 🗑 DELETE
                  _iconButton(
                    context,
                    icon: Icons.delete,
                    color: colors.error,
                    onTap: onDelete,
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

  // ================= ICON BUTTON =================

  Widget _iconButton(
      BuildContext context, {
        required IconData icon,
        required VoidCallback onTap,
        required String tooltip,
        Color? color,
      }) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Tooltip(
            message: tooltip,
            child: Center(
              child: Icon(
                icon,
                size: 26,
                color: color ?? colors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
