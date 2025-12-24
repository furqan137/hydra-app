import 'package:flutter/material.dart';

class EmptyVaultView extends StatelessWidget {
  final VoidCallback onImport;
  final VoidCallback onSkip;

  const EmptyVaultView({
    super.key,
    required this.onImport,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ICON
          Image.asset(
            'assets/icons/vault_empty.png',
            width: size.width * 0.48,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 28),

          /// TITLE
          const Text(
            'Your vault is empty',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          /// SUBTITLE
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 36),
            child: Text(
              'Import photos or videos to secure them.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 36),

          /// IMPORT BUTTON
          ElevatedButton.icon(
            onPressed: onImport,
            icon: const Icon(Icons.add),
            label: const Text('+ Import'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0FB9B1),
              padding: const EdgeInsets.symmetric(
                horizontal: 56,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),

          const SizedBox(height: 18),

          /// SKIP BUTTON
          TextButton(
            onPressed: onSkip,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}