import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/security/secure_storage.dart';
import '../../features/auth/biometric_controller.dart';
import '../../services/biometric_service.dart';

class EnterPinScreen extends StatefulWidget {
  const EnterPinScreen({super.key});

  @override
  State<EnterPinScreen> createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {
  final TextEditingController pinController = TextEditingController();
  bool obscure = true;
  String? errorText;
  bool _showPin = false;
  bool _biometricTried = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricEnabled();
  }

  Future<void> _checkBiometricEnabled() async {
    final biometricController = BiometricController();
    await biometricController.loadEnabled(); // Ensure latest value from storage
    setState(() {
      _biometricEnabled = biometricController.isEnabled;
    });
    if (_biometricEnabled) {
      Future.delayed(const Duration(milliseconds: 300), _tryBiometricUnlock);
    } else {
      setState(() {
        _showPin = true;
      });
    }
  }

  Future<void> _tryBiometricUnlock() async {
    if (_biometricTried) return;
    _biometricTried = true;
    try {
      await BiometricService.authenticate(reason: 'Authenticate to unlock Hidra');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _showPin = true;
      });
    }
  }

  Future<void> _triggerBiometric() async {
    _biometricTried = false;
    await _tryBiometricUnlock();
  }

  Future<void> _validatePin() async {
    final enteredPin = pinController.text.trim();
    final savedPin = await SecureStorage.readPin();
    if (enteredPin == savedPin) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        errorText = 'Incorrect PIN. Please try again.';
      });
    }
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _showPin
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/lock.png',
                    width: 120,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Enter your PIN',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_biometricEnabled) ...[
                    GestureDetector(
                      onTap: _triggerBiometric,
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/icons/biometrics.png',
                            width: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Use fingerprint',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: pinController,
                    obscureText: obscure,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: 'PIN',
                      counterText: '',
                      errorText: errorText,
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => obscure = !obscure),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onSubmitted: (_) => _validatePin(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _validatePin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0FB9B1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Unlock',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                ],
              )
                  : const CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
