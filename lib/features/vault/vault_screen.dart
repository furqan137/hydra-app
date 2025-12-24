import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'vault_controller.dart';
import 'vault_import_sheet.dart';
import 'empty_vault_view.dart';

// ✅ SEPARATED UI COMPONENTS
import 'widgets/vault_top_bar.dart';
import 'widgets/vault_grid.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  bool hasSkippedEmpty = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VaultController>();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,

      /// FAB (hidden during selection)
      floatingActionButton:
      (!controller.isSelectionMode &&
          (hasSkippedEmpty || controller.files.isNotEmpty))
          ? FloatingActionButton.extended(
        onPressed: () => _openImportSheet(context),
        backgroundColor: const Color(0xFF0FB9B1),
        icon: const Icon(Icons.add),
        label: const Text('Import'),
      )
          : null,

      body: Container(
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
          child: _buildBody(context, controller),
        ),
      ),
    );
  }

  // ================= BODY =================

  Widget _buildBody(BuildContext context, VaultController controller) {
    /// First-time empty state
    if (!hasSkippedEmpty && controller.isEmpty) {
      return EmptyVaultView(
        onImport: () => _openImportSheet(context),
        onSkip: () => setState(() => hasSkippedEmpty = true),
      );
    }

    return Stack(
      children: [
        Column(
          children: [

            /// ✅ TOP BAR (SEPARATED)
            VaultTopBar(controller: controller),

            /// ✅ GRID (SEPARATED)
            Expanded(
              child: controller.isEmpty
                  ? _emptyText()
                  : VaultGrid(controller: controller),
            ),
          ],
        ),

        /// Bottom status (selection mode)
        if (controller.isSelectionMode)
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 90),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
            ),
          ),
      ],
    );
  }

  // ================= IMPORT =================

  void _openImportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          VaultImportSheet(
            controller: context.read<VaultController>(),
          ),
    );
  }

  // ================= EMPTY =================
  Widget _emptyText() {
    final size = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    ).size;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/vault_empty.png',
            width: size.width * 0.48,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          const Text(
            'No files in vault',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Import photos or videos to keep them secure',
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