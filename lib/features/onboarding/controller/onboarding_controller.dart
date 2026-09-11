import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:e7m/core/constants/pref_keys.dart';

class OnboardingController extends ChangeNotifier {
  final PageController pageController = PageController();

  // ============================================================
  // CONFIG
  // ============================================================

  static const int totalPages = 3;

  static const Duration animationDuration =
  Duration(milliseconds: 350);

  // ============================================================
  // STATE
  // ============================================================

  int _currentPage = 0;

  int get currentPage => _currentPage;

  bool get isLastPage => _currentPage == totalPages - 1;

  // ============================================================
  // PAGE CHANGED
  // ============================================================

  void onPageChanged(int index) {
    _currentPage = index;
    notifyListeners();
  }

  // ============================================================
  // NEXT PAGE
  // ============================================================

  Future<bool> nextPage() async {
    debugPrint(
      'Onboarding: current page = $_currentPage',
    );

    // ----------------------------------------------------------
    // Still have pages
    // ----------------------------------------------------------

    if (!isLastPage) {
      if (!pageController.hasClients) {
        debugPrint(
          'Onboarding: PageController has no clients.',
        );

        return false;
      }

      await pageController.nextPage(
        duration: animationDuration,
        curve: Curves.easeInOut,
      );

      return false;
    }

    // ----------------------------------------------------------
    // Last page
    // ----------------------------------------------------------

    await markOnboardingAsCompleted();

    debugPrint(
      'Onboarding: completed.',
    );

    return true;
  }

  // ============================================================
  // SKIP
  // ============================================================

  Future<void> skip() async {
    debugPrint(
      'Onboarding: skipped.',
    );

    await markOnboardingAsCompleted();
  }

  // ============================================================
  // SAVE COMPLETION
  // ============================================================

  Future<void> markOnboardingAsCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      PrefKeys.onboardingFinished,
      true,
    );

    debugPrint(
      'Onboarding: onboarding_finished = true',
    );
  }

  // ============================================================
  // CHECK FIRST TIME
  // ============================================================

  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();

    return !(prefs.getBool(
      PrefKeys.onboardingFinished,
    ) ??
        false);
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}