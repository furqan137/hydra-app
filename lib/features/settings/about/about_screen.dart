import 'package:flutter/material.dart';

// ABOUT SUB-SCREENS
import 'privacy_policy_screen.dart';
import 'contact_support_screen.dart';
import 'credits_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              _header(context),
              const SizedBox(height: 30),

              /// LOGO + APP INFO
              _appInfo(),

              const SizedBox(height: 40),

              /// OPTIONS
              _optionTile(
                icon: Icons.lock_outline,
                title: 'Privacy Policy',
                onTap: () {
                  _push(context, const PrivacyPolicyScreen());
                },
              ),
              _optionTile(
                icon: Icons.mail_outline,
                title: 'Contact Support',
                onTap: () {
                  _push(context, const ContactSupportScreen());
                },
              ),
              _optionTile(
                icon: Icons.info_outline,
                title: 'Credits',
                onTap: () {
                  _push(context, const CreditsScreen());
                },
              ),

              const Spacer(),

              /// FOOTER
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  '© 2024 Hidra App · All rights reserved',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
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
            'About Hidra',
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

  // ================= APP INFO =================

  Widget _appInfo() {
    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(
            Icons.shield,
            color: Color(0xFF0FB9B1),
            size: 64,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Hidra',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Version 1.2.0',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ================= OPTION TILE =================

  Widget _optionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.tealAccent),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white54,
        ),
      ),
    );
  }

  // ================= NAV HELPER =================

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
