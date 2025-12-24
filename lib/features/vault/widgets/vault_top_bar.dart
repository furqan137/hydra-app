import 'package:flutter/material.dart';
import '../vault_controller.dart';

class VaultTopBar extends StatelessWidget {
  final VaultController controller;

  const VaultTopBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return controller.isSelectionMode
        ? _selectionBar(context)
        : _normalBar(context);
  }

  // ================= NORMAL TOP BAR =================

  Widget _normalBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// 🟢 APP TITLE (LEFT ALIGNED)
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

          /// SORT BUTTON
          IconButton(
            splashRadius: 22,
            icon: const Icon(
              Icons.sort,
              color: Colors.white70,
              size: 24,
            ),
            onPressed: () => _openSortSheet(context),
          ),
        ],
      ),
    );
  }


  // ================= SELECTION MODE BAR =================

  Widget _selectionBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(
              'Selected • ${controller.selectedCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: controller.deleteSelected,
            ),
          ],
        ),
      ),
    );
  }

  // ================= SORT SHEET =================

  void _openSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(controller: controller),
    );
  }
}

// ================= SORT BOTTOM SHEET =================

class _SortSheet extends StatelessWidget {
  final VaultController controller;

  const _SortSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF101B2B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
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
