import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../vault_controller.dart';

class VaultSelectionBar extends StatelessWidget {
  const VaultSelectionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VaultController>();

    if (!controller.isSelectionMode) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(16),
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

              /// MOVE
              IconButton(
                icon: const Icon(Icons.drive_file_move,
                    color: Colors.white),
                onPressed: () {
                  // TODO: implement move
                },
              ),

              /// EXPORT
              IconButton(
                icon:
                const Icon(Icons.upload, color: Colors.white),
                onPressed: () {
                  // TODO: implement export
                },
              ),

              /// DELETE
              IconButton(
                icon: const Icon(Icons.delete,
                    color: Colors.redAccent),
                onPressed: controller.deleteSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
