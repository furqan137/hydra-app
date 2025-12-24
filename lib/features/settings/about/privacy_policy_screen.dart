import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _hero(),
                      const SizedBox(height: 24),
                      _introText(),
                      const SizedBox(height: 24),

                      _policySection(
                        title: 'Information We Collect',
                        content: '''
Hidra is designed with privacy at its core. We do NOT collect or transmit your personal files.

• Files stored in Hidra (photos, videos, albums) remain strictly on your device.
• Encryption keys and passwords never leave your phone.
• We do not collect names, emails, phone numbers, or contacts.
• No analytics or tracking of personal content is performed.
                        ''',
                      ),

                      _policySection(
                        title: 'How We Use Your Information',
                        content: '''
Any data used by Hidra is strictly for app functionality:

• Local encryption and decryption of files.
• Authentication (PIN / biometrics) stored securely on-device.
• App preferences such as theme or start page.

We never sell, share, or upload your data to third parties.
                        ''',
                      ),

                      _policySection(
                        title: 'Security & Encryption',
                        content: '''
Hidra uses industry-standard security practices:

• AES-256 encryption for files.
• Secure storage for PINs and keys.
• Optional biometric authentication.
• Secure delete ensures overwritten file removal.

Your data remains protected even if your device is compromised.
                        ''',
                      ),

                      _policySection(
                        title: 'Backups',
                        content: '''
Backups are optional and fully encrypted.

• Backups can be stored locally or on cloud storage (e.g. Google Drive).
• Backup passwords are never stored or transmitted.
• Without the password, backups cannot be restored.

You are always in full control.
                        ''',
                      ),

                      _policySection(
                        title: 'Permissions',
                        content: '''
Hidra only requests permissions required for core features:

• Media access (to import files).
• Storage access (for encrypted vault & backups).
• Biometrics (optional).

Permissions are never misused.
                        ''',
                      ),

                      _policySection(
                        title: 'Your Rights',
                        content: '''
You have full ownership and control over your data.

• You can delete your vault anytime.
• You can remove all app data instantly.
• You can uninstall Hidra with no residual data left behind.

Privacy is your right — not a feature.
                        ''',
                      ),

                      const SizedBox(height: 40),

                      Center(
                        child: Text(
                          'Effective Date: April 24, 2024',
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
            'Privacy Policy',
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

  // ================= HERO =================

  Widget _hero() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.shield,
              color: Color(0xFF0FB9B1),
              size: 60,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Privacy Policy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= INTRO =================

  Widget _introText() {
    return const Text(
      'Welcome to Hidra! Your privacy and security are our highest priority. '
          'This Privacy Policy explains how we protect your data and ensure complete confidentiality.',
      style: TextStyle(
        color: Colors.white70,
        fontSize: 15,
        height: 1.6,
      ),
      textAlign: TextAlign.center,
    );
  }

  // ================= SECTION =================

  Widget _policySection({
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ExpansionTile(
        iconColor: Colors.tealAccent,
        collapsedIconColor: Colors.white54,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            content.trim(),
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
