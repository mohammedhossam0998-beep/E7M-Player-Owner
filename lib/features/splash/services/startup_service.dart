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

    final loggedIn =
        prefs.getBool(
          PrefKeys.isLoggedIn,
        ) ??
            false;

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
    // USER LOGGED IN
    // ==========================================================

    if (loggedIn) {
      return RouteNames.home;
    }

    // ==========================================================
    // USER NOT LOGGED IN
    // ==========================================================

    return RouteNames.welcome;
  }
}