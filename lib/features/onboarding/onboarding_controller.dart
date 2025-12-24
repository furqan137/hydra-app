import 'package:flutter/material.dart';
import 'onboarding_state.dart';
import '../auth/create_password_intro_screen.dart';
import '../../core/utils/app_preferences.dart';

class OnboardingController extends ChangeNotifier {
  OnboardingState _state = const OnboardingState();

  OnboardingState get state => _state;

  void onPageChanged(int index) {
    _state = _state.copyWith(currentIndex: index);
    notifyListeners();
  }

  void nextPage(
      PageController pageController,
      int totalPages,
      BuildContext context,
      ) {
    if (_state.currentIndex < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToCreatePasswordIntro(context);
    }
  }

  void skip(BuildContext context) {
    _goToCreatePasswordIntro(context);
  }

  void _goToCreatePasswordIntro(BuildContext context) async {
    await AppPreferences.setOnboardingComplete();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const CreatePasswordIntroScreen(),
      ),
    );
  }
}
