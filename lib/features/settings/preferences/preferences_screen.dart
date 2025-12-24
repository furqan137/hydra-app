import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'preferences_controller.dart';
import 'preferences_state.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PreferencesController(),
      child: const _PreferencesView(),
    );
  }
}

class _PreferencesView extends StatelessWidget {
  const _PreferencesView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PreferencesController>();
    final state = controller.state;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
          child: Column(
            children: [
              _header(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _sectionTitle('Start page'),
                    _startPageSelector(controller, state),
                    const SizedBox(height: 28),

                    _sectionTitle('Theme'),
                    _themeSelector(controller, state),
                    const SizedBox(height: 28),

                    _sectionTitle('Storage'),
                    _storageBar(state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const Icon(Icons.more_vert, color: Colors.white),
        ],
      ),
    );
  }

  // ================= START PAGE =================
  Widget _startPageSelector(
      PreferencesController controller,
      PreferencesState state,
      ) {
    return Row(
      children: [
        _selectTile(
          icon: Icons.shield,
          label: 'Vault',
          selected: state.startPage == StartPage.vault,
          onTap: () => controller.setStartPage(StartPage.vault),
        ),
        const SizedBox(width: 12),
        _selectTile(
          icon: Icons.folder,
          label: 'Albums',
          selected: state.startPage == StartPage.albums,
          onTap: () => controller.setStartPage(StartPage.albums),
        ),
      ],
    );
  }

  // ================= THEME =================
  Widget _themeSelector(
      PreferencesController controller,
      PreferencesState state,
      ) {
    return Row(
      children: [
        _selectTile(
          icon: Icons.settings,
          label: 'System',
          selected: state.theme == AppTheme.system,
          onTap: () => controller.setTheme(AppTheme.system),
        ),
        const SizedBox(width: 12),
        _selectTile(
          icon: Icons.light_mode,
          label: 'Light',
          selected: state.theme == AppTheme.light,
          onTap: () => controller.setTheme(AppTheme.light),
        ),
        const SizedBox(width: 12),
        _selectTile(
          icon: Icons.dark_mode,
          label: 'Dark',
          selected: state.theme == AppTheme.dark,
          onTap: () => controller.setTheme(AppTheme.dark),
        ),
      ],
    );
  }

  // ================= STORAGE =================
  Widget _storageBar(PreferencesState state) {
    final percent = state.storageUsed / state.storageTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(
              Color(0xFF7B7CFF),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${state.storageUsed} GB of ${state.storageTotal} GB used',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ================= REUSABLE =================
  Widget _selectTile({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
              colors: [
                Color(0xFF0FB9B1),
                Color(0xFF1FA2FF),
              ],
            )
                : null,
            color: selected ? null : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (selected)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
