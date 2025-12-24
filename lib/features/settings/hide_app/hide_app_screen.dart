import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'hide_app_controller.dart';

class HideAppScreen extends StatelessWidget {
  const HideAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HideAppController(),
      child: const _HideAppView(),
    );
  }
}

class _HideAppView extends StatelessWidget {
  const _HideAppView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HideAppController>();
    final state = controller.state;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050B18), Color(0xFF0FB9B1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _header(context),
              const SizedBox(height: 28),

              /// ICON TRANSITION (REAL → FAKE)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _AppIcon(icon: Icons.shield),
                  SizedBox(width: 16),
                  Icon(Icons.arrow_forward, color: Colors.tealAccent),
                  SizedBox(width: 16),
                  _AppIcon(icon: Icons.phone),
                ],
              ),

              const SizedBox(height: 36),

              /// STATUS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'App Visibility',
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _statusChip(
                          label: 'Visible',
                          selected: !state.isHidden,
                          onTap: () async {
                            if (!state.isHidden) return;
                            await _toggle(context, controller, false);
                          },
                        ),
                        const SizedBox(width: 12),
                        _statusChip(
                          label: 'Hidden',
                          selected: state.isHidden,
                          onTap: () async {
                            if (state.isHidden) return;
                            await _toggle(context, controller, true);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// DIAL CODE INFO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Open Hidra using dial code',
                      style: TextStyle(color: Colors.white60),
                    ),
                    const SizedBox(height: 10),
                    _dialCodeBox(state.dialCode),
                    const SizedBox(height: 8),
                    const Text(
                      'After hiding, Hidra appears as a Phone app.\n'
                          'Dial this code in the fake dialer to unlock Hidra.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
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
            'Hide App',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ================= STATUS CHIP =================

  static Widget _statusChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF0FB9B1)
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                if (selected) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check, size: 18, color: Colors.white),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= DIAL CODE =================

  Widget _dialCodeBox(String code) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            code,
            style: const TextStyle(
              color: Colors.tealAccent,
              fontSize: 22,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  // ================= TOGGLE HANDLER =================

  Future<void> _toggle(
      BuildContext context,
      HideAppController controller,
      bool hide,
      ) async {
    final ok = await controller.toggleHidden(hide);

    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to change app visibility'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}

// ================= ICON =================

class _AppIcon extends StatelessWidget {
  final IconData icon;
  const _AppIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: Colors.tealAccent, size: 36),
    );
  }
}
