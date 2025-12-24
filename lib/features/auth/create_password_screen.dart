import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'biometric_setup_screen.dart';
import '../../core/security/secure_storage.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final TextEditingController pinController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool obscure1 = true;
  bool obscure2 = true;

  void _createPin() async {
    final pin = pinController.text.trim();
    final confirm = confirmController.text.trim();

    if (pin.isEmpty || confirm.isEmpty) {
      _showError('Please fill in both fields');
      return;
    }

    if (pin.length != 6) {
      _showError('PIN must be exactly 6 digits');
      return;
    }

    if (confirm.length != 6) {
      _showError('PIN must be exactly 6 digits');
      return;
    }

    if (pin != confirm) {
      _showError('PINs do not match');
      return;
    }

    await SecureStorage.savePin(pin);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const BiometricSetupScreen(),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'assets/icons/input.png',
                  width: 350,
                  height: 360,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Create your Hidra PIN',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your PIN encrypts your data. It cannot be recovered.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // PIN FIELD
                TextField(
                  controller: pinController,
                  obscureText: obscure1,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: 'Enter PIN',
                    counterText: '',
                    suffixIcon: IconButton(
                      icon: Icon(obscure1 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => obscure1 = !obscure1),
                    ),
                  ),
                  inputFormatters: [
                    // Only allow digits
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 16),
                // CONFIRM PIN FIELD
                TextField(
                  controller: confirmController,
                  obscureText: obscure2,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: 'Confirm PIN',
                    counterText: '',
                    suffixIcon: IconButton(
                      icon: Icon(obscure2 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => obscure2 = !obscure2),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _createPin,
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
                    'Create PIN',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
