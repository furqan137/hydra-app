import 'package:flutter/material.dart';
import '../vault_controller.dart';

class VaultTopBar extends StatelessWidget {
  final VaultController controller;

  const VaultTopBar({
    super.key,
    required this.controller,
  });

  static const double _barHeight = 64;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      height: _barHeight,
      // ✅ FIX: give bar a background
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colors.surface.withOpacity(0.08)
            : colors.surfaceVariant.withOpacity(0.85),
      ),
      child: controller.isSelectionMode
          ? const SizedBox()
          : _normalBar(context),
    );
  }

  // ================= NORMAL TOP BAR =================

  Widget _normalBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      child: Row(
        children: [
          /// 🟢 TITLE
          Text(
            'Hidra',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: colors.onSurface, // ✅ always visible
            ),
          ),

          const Spacer(),

          /// 🔽 SORT ICON
          _SortButton(controller: controller),
        ],
      ),
    );
  }
}

// ================= SORT BUTTON =================

class _SortButton extends StatelessWidget {
  final VaultController controller;

  const _SortButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final key = GlobalKey();

    return IconButton(
      key: key,
      splashRadius: 22,
      icon: Icon(
        Icons.sort,
        size: 24,
        color: colors.onSurface.withOpacity(0.75), // ✅ visible in light
      ),
      onPressed: () => _openSortPopup(context, key),
    );
  }

  void _openSortPopup(BuildContext context, GlobalKey key) {
    final renderBox =
    key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),
            Positioned(
              top: position.dy + size.height + 8,
              right: 12,
              child: _SortPopup(controller: controller),
            ),
          ],
        );
      },
    );
  }
}

// ================= SORT POPUP =================

class _SortPopup extends StatelessWidget {
  final VaultController controller;

  const _SortPopup({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 260,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          // ✅ FIX: better background for light mode
          color: theme.brightness == Brightness.dark
              ? colors.surface
              : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                theme.brightness == Brightness.dark ? 0.45 : 0.18,
              ),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _item(context,
                icon: Icons.sort_by_alpha,
                title: 'Name (A–Z)',
                onTap: () => _apply(context, VaultSortType.nameAsc)),
            _item(context,
                icon: Icons.sort_by_alpha,
                title: 'Name (Z–A)',
                onTap: () => _apply(context, VaultSortType.nameDesc)),
            _item(context,
                icon: Icons.storage,
                title: 'Size (Small → Large)',
                onTap: () => _apply(context, VaultSortType.sizeAsc)),
            _item(context,
                icon: Icons.storage,
                title: 'Size (Large → Small)',
                onTap: () => _apply(context, VaultSortType.sizeDesc)),
            _item(context,
                icon: Icons.schedule,
                title: 'Newest First',
                onTap: () => _apply(context, VaultSortType.dateNewest)),
            _item(context,
                icon: Icons.history,
                title: 'Oldest First',
                onTap: () => _apply(context, VaultSortType.dateOldest)),
            Divider(color: colors.onSurface.withOpacity(0.15)),
            _item(
              context,
              icon: Icons.restart_alt,
              title: 'Restore Default',
              highlight: true,
              onTap: () => _apply(context, VaultSortType.reset),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
        bool highlight = false,
      }) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      dense: true,
      onTap: onTap,
      leading: Icon(
        icon,
        size: 20,
        color: highlight
            ? colors.primary
            : colors.onSurface.withOpacity(0.75),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: highlight
              ? colors.onSurface
              : colors.onSurface.withOpacity(0.75),
          fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  void _apply(BuildContext context, VaultSortType type) {
    Navigator.pop(context);
    controller.sortFiles(type);
  }
}
