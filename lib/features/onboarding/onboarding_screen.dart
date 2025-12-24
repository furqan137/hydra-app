import 'package:flutter/material.dart';
import 'onboarding_controller.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final OnboardingController _controller = OnboardingController();

  final List<Map<String, String>> pages = [
    {
      'image': 'assets/onboarding/Onboarding1.png',
      'title': 'Your privacy matters',
      'subtitle':
      'Your photos and videos are encrypted directly on your device.',
    },
    {
      'image': 'assets/onboarding/Onboarding2.png',
      'title': 'Strong protection',
      'subtitle':
      'AES-256 encryption with password and biometric lock.',
    },
    {
      'image': 'assets/onboarding/Onboarding3.png',
      'title': 'You’re in control',
      'subtitle': 'Import, organize, export files anytime.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Column(
                children: [
                  /// SKIP BUTTON
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () => _controller.skip(context),
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),

                  /// PAGES
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: pages.length,
                      onPageChanged: _controller.onPageChanged,
                      itemBuilder: (_, index) {
                        final page = pages[index];
                        return OnboardingPage(
                          image: page['image']!,
                          title: page['title']!,
                          subtitle: page['subtitle']!,
                        );
                      },
                    ),
                  ),

                  /// INDICATORS + BUTTON
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            pages.length,
                                (index) => AnimatedContainer(
                              duration:
                              const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              height: 8,
                              width: _controller.state.currentIndex ==
                                  index
                                  ? 22
                                  : 8,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        /// NEXT / GET STARTED BUTTON
                        ElevatedButton(
                          onPressed: () => _controller.nextPage(
                            _pageController,
                            pages.length,
                            context,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFF0FB9B1),
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 80,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            _controller.state.currentIndex ==
                                pages.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style:
                            const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
