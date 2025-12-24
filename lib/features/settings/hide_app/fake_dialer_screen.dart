import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../splash/splash_screen.dart';

class FakeDialerScreen extends StatefulWidget {
  const FakeDialerScreen({super.key});

  @override
  State<FakeDialerScreen> createState() => _FakeDialerScreenState();
}

class _FakeDialerScreenState extends State<FakeDialerScreen> {
  static const String _dialCodeKey = 'hide_app_dial_code';

  String _input = '';
  String _secretCode = '*#*#13710#*#*';

  @override
  void initState() {
    super.initState();
    _loadSecretCode();
  }

  Future<void> _loadSecretCode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _secretCode = prefs.getString(_dialCodeKey) ?? '*#*#13710#*#*';
    });
  }

  // ================= DIAL INPUT =================

  void _onKeyTap(String value) {
    if (_input.length >= 20) return;

    setState(() {
      _input += value;
    });

    _checkUnlock();
  }

  void _onBackspace() {
    if (_input.isEmpty) return;
    setState(() {
      _input = _input.substring(0, _input.length - 1);
    });
  }

  void _checkUnlock() {
    if (_input == _secretCode) {
      _unlockApp();
    }
  }

  // ================= UNLOCK FLOW =================

  Future<void> _unlockApp() async {
    final prefs = await SharedPreferences.getInstance();

    // 🔑 THIS IS THE ONLY FLAG SPLASH CARES ABOUT
    await prefs.setBool('launch_via_secret_code', true);

    if (!mounted) return;

    // ✅ Restart app flow from Splash
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  }


  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Phone',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          const SizedBox(height: 24),

          // ================= NUMBER DISPLAY =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 60,
              alignment: Alignment.centerRight,
              child: Text(
                _input,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  letterSpacing: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          const Spacer(),

          // ================= DIAL PAD =================
          _dialPad(),

          const SizedBox(height: 24),

          // ================= CALL BUTTON =================
          const CircleAvatar(
            radius: 34,
            backgroundColor: Colors.green,
            child: Icon(
              Icons.phone,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }

  // ================= DIAL PAD =================

  Widget _dialPad() {
    return Column(
      children: [
        _dialRow(['1', '2', '3']),
        _dialRow(['4', '5', '6']),
        _dialRow(['7', '8', '9']),
        _dialRow(['*', '0', '#']),
        const SizedBox(height: 10),

        IconButton(
          icon: const Icon(Icons.backspace, color: Colors.white70),
          onPressed: _onBackspace,
        ),
      ],
    );
  }

  Widget _dialRow(List<String> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values.map(_dialButton).toList(),
    );
  }

  Widget _dialButton(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: () => _onKeyTap(value),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade900,
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}