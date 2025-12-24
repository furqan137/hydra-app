import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/security/secure_storage.dart';

class EnterPinScreen extends StatefulWidget {
  const EnterPinScreen({super.key});

  @override
  State<EnterPinScreen> createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {
  final TextEditingController pinController = TextEditingController();
  bool obscure = true;
  String? errorText;

  Future<void> _validatePin() async {
    final enteredPin = pinController.text.trim();
    final savedPin = await SecureStorage.readPin();
    if (enteredPin == savedPin) {
      // Navigate to Home (replace with your home screen route)
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
              child: Column(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
