import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  static const _supportEmail = 'support@hidra.app';
  static const _websiteUrl = 'https://www.hidra.app';

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
                    children: [
                      _hero(),
                      const SizedBox(height: 30),

                      _actionTile(
                        icon: Icons.chat_bubble_outline,
                        title: 'Send a Message',
                        subtitle: 'Contact our support team',
                        onTap: () {
                          _showComingSoon(context);
                        },
                      ),

                      _actionTile(
                        icon: Icons.email_outlined,
                        title: _supportEmail,
                        subtitle: 'Email support',
                        onTap: () => _openEmail(),
                      ),

                      _actionTile(
                        icon: Icons.language,
                        title: 'www.hidra.app',
                        subtitle: 'Visit our website',
                        onTap: () => _openWebsite(),
                      ),

                      const SizedBox(height: 50),

                      _footer(),
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
            'Contact Support',
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
    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Icon(
            Icons.mail_outline,
            color: Color(0xFF0FB9B1),
            size: 64,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Contact Support',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'We’re here to help you',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // ================= ACTION TILE =================

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
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
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white54,
        ),
      ),
    );
  }

  // ================= FOOTER =================

  Widget _footer() {
    return Column(
      children: const [
        SizedBox(height: 10),
        Icon(
          Icons.apartment,
          color: Colors.white54,
          size: 32,
        ),
        SizedBox(height: 8),
        Text(
          'MAKT Studio',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'A MAKT Studio Product',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ================= ACTIONS =================

  Future<void> _openEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: 'subject=Hidra Support',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openWebsite() async {
    final uri = Uri.parse(_websiteUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B1C2D),
        title: const Text(
          'Coming Soon',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'In-app messaging will be available soon.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF0FB9B1)),
            ),
          ),
        ],
      ),
    );
  }
}
