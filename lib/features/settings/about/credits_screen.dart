import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  static const _donationUrl = 'https://www.buymeacoffee.com/';

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

                      _creditRow(
                        name: 'Furqan Zafar',
                        role: 'Design & Development',
                      ),
                      _creditRow(
                        name: 'Furqan Zafar',
                        role: 'Marketing & Content',
                      ),
                      _creditRow(
                        name: 'Mehboob',
                        role: 'Quality Assurance & Testing',
                      ),
                      _creditRow(
                        name: 'FlatIcons.com',
                        role: 'Icons',
                      ),

                      const SizedBox(height: 40),

                      _donationCard(),

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
            'Credits',
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
            Icons.shield_outlined,
            color: Color(0xFF0FB9B1),
            size: 64,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Credits',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'People & technologies behind Hidra',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // ================= CREDIT ROW =================

  Widget _creditRow({
    required String name,
    required String role,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            role,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ================= DONATION =================

  Widget _donationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.favorite,
            color: Color(0xFF0FB9B1),
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'Support Development',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your support helps us keep Hidra secure, private, and improving.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _openDonation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0FB9B1),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Donate / Support',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FOOTER =================

  Widget _footer() {
    return Column(
      children: const [
        Icon(
          Icons.apartment,
          color: Colors.white54,
          size: 34,
        ),
        SizedBox(height: 8),
        Text(
          'Hydra Apps',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'A Hydra Studio Product',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ================= ACTION =================

  static Future<void> _openDonation() async {
    final uri = Uri.parse(_donationUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
