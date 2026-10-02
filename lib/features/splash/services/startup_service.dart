import 'package:shared_preferences/shared_preferences.dart';

import 'package:e7m/app/routes/route_names.dart';
import 'package:e7m/core/constants/pref_keys.dart';

class StartupService {
  Future<String> getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();

    final onboardingDone =
        prefs.getBool(
          PrefKeys.onboardingFinished,
        ) ??
            false;

    final language =
    prefs.getString(
      PrefKeys.selectedLanguage,
    );

    final authToken =
    prefs.getString(
      PrefKeys.authToken,
    );

    final loggedIn =
        authToken != null &&
            authToken.isNotEmpty;

    // ==========================================================
    // FIRST LAUNCH
    // ==========================================================

    if (!onboardingDone) {
      return RouteNames.onboarding;
    }

    // ==========================================================
    // LANGUAGE NOT SELECTED
    // ==========================================================

    if (language == null || language.isEmpty) {
      return RouteNames.language;
    }

    // ==========================================================
    // NO AUTH SESSION
    // ==========================================================

    if (!loggedIn) {
      return RouteNames.welcome;
    }

    // ==========================================================
    // AUTH SESSION EXISTS
    //
    // The exact role will be handled by SplashScreen
    // after validating the current user with /auth/me.
    // ==========================================================

    return RouteNames.welcome;
  }
}