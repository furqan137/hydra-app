import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../vault_controller.dart';

class VaultBottomStatus extends StatelessWidget {
  const VaultBottomStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VaultController>();

    if (!controller.isSelectionMode) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Encrypting files securely...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Import photos or videos.',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
