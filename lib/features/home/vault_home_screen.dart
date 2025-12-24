import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../vault/vault_controller.dart';
import '../vault/vault_import_sheet.dart';

class VaultHomeScreen extends StatelessWidget {
  const VaultHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF050B18),
              Color(0xFF0FB9B1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              /// VAULT EMPTY ICON
              Image.asset(
                'assets/icons/vault_empty.png',
                width: size.width * 0.48,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 28),

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
                onPressed: () => _openImportSheet(context),
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
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 15,
                  ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  /// IMPORT BOTTOM SHEET (✅ FIXED)
  void _openImportSheet(BuildContext context) {
    final controller = context.read<VaultController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VaultImportSheet(
        controller: controller, // ✅ REQUIRED
      ),
    );
  }
}
