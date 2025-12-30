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
    return SizedBox(
      height: _barHeight,
      child: controller.isSelectionMode
          ? const SizedBox()
          : _normalBar(context),
    );
  }

  // ================= NORMAL TOP BAR =================

  Widget _normalBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      child: Row(
        children: [
          /// 🟢 TITLE (LEFT)
          const Text(
            'Hidra',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Colors.white,
            ),
          ),

          const Spacer(),

          /// 🔽 FILTER / SORT ICON (RIGHT)
          _SortButton(controller: controller),
        ],
      ),
    );
  }
}

// ================= SORT BUTTON (ANCHOR) =================

class _SortButton extends StatelessWidget {
  final VaultController controller;

  const _SortButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey();

    return IconButton(
      key: key,
      splashRadius: 22,
      icon: const Icon(
        Icons.sort,
        color: Colors.white70,
        size: 24,
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
            // Tap outside to close
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.transparent),
            ),

            // Popup anchored BELOW the icon
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

// ================= SORT POPUP PANEL =================

class _SortPopup extends StatelessWidget {
  final VaultController controller;

  const _SortPopup({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 260,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF101B2B),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _item(
              icon: Icons.sort_by_alpha,
              title: 'Name (A–Z)',
              onTap: () => _apply(context, VaultSortType.nameAsc),
            ),
            _item(
              icon: Icons.sort_by_alpha,
              title: 'Name (Z–A)',
              onTap: () => _apply(context, VaultSortType.nameDesc),
            ),
            _item(
              icon: Icons.storage,
              title: 'Size (Small → Large)',
              onTap: () => _apply(context, VaultSortType.sizeAsc),
            ),
            _item(
              icon: Icons.storage,
              title: 'Size (Large → Small)',
              onTap: () => _apply(context, VaultSortType.sizeDesc),
            ),
            _item(
              icon: Icons.schedule,
              title: 'Newest First',
              onTap: () => _apply(context, VaultSortType.dateNewest),
            ),
            _item(
              icon: Icons.history,
              title: 'Oldest First',
              onTap: () => _apply(context, VaultSortType.dateOldest),
            ),
            const Divider(color: Colors.white24),
            _item(
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

  Widget _item({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    return ListTile(
      dense: true,
      onTap: onTap,
      leading: Icon(
        icon,
        size: 20,
        color: highlight ? const Color(0xFF0FB9B1) : Colors.white70,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: highlight ? Colors.white : Colors.white70,
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
