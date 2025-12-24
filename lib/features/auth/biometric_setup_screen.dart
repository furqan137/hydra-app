import 'package:flutter/material.dart';
import '../../services/biometric_service.dart';
import '../home/main_shell.dart';

class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  State<BiometricSetupScreen> createState() =>
      _BiometricSetupScreenState();
}

class _BiometricSetupScreenState
    extends State<BiometricSetupScreen> {
  String? _error;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  // ✅ CORRECT biometric availability check
  Future<void> _checkAvailability() async {
    final canUse = await BiometricService.canUseBiometrics();

    if (!mounted) return;

    setState(() {
      _checking = false;
      if (!canUse) {
        _error =
        'No fingerprint or face unlock found.\n'
            'Please add one in phone settings first.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
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
          child: Center(
            child: _checking
                ? const CircularProgressIndicator(color: Colors.white)
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/biometrics.png',
                  width: 160,
                ),

                const SizedBox(height: 40),

                const Text(
                  'Enable biometric unlock',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Use biometrics for faster access.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 20),

                /// ⚠️ ERROR MESSAGE
                if (_error != null)
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

                /// ✅ ENABLE BUTTON (FIXED)
                ElevatedButton(
                  onPressed: _error != null
                      ? null
                      : () async {
                    final authenticated =
                    await BiometricService.authenticate(
                      reason:
                      'Authenticate to enable biometric unlock',
                    );

                    if (!mounted) return;

                    if (!authenticated) {
                      setState(() {
                        _error =
                        'Authentication failed.\nPlease try again.';
                      });
                      return;
                    }

                    // ✅ SUCCESS → go home
                    _goToHome(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0FB9B1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 90,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Enable',
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                const SizedBox(height: 20),

                /// SKIP
                TextButton(
                  onPressed: () => _goToHome(context),
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MainShell(),
      ),
          (route) => false,
    );
  }
}
