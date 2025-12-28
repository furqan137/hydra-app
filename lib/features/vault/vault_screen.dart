import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'vault_controller.dart';
import 'vault_import_sheet.dart';
import 'empty_vault_view.dart';

// UI
import 'widgets/vault_top_bar.dart';
import 'widgets/vault_grid.dart';
import 'widgets/vault_selection_bar.dart';

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

      /// FAB (hidden while selecting files)
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
        /// MAIN CONTENT
        Column(
          children: [
            /// TOP BAR
            VaultTopBar(controller: controller),

            /// GRID (extra bottom padding for selection bar)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: controller.isSelectionMode ? 110 : 0,
                ),
                child: controller.isEmpty
                    ? _emptyText()
                    : VaultGrid(controller: controller),
              ),
            ),
          ],
        ),

        /// ✅ SELECTION BAR (Move / Export / Delete)
        const Align(
          alignment: Alignment.bottomCenter,
          child: VaultSelectionBar(),
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
      builder: (_) => VaultImportSheet(
        controller: context.read<VaultController>(),
      ),
    );
  }

  // ================= EMPTY =================

  Widget _emptyText() {
    final size = MediaQuery.of(context).size;

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
