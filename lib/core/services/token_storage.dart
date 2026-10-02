import 'package:shared_preferences/shared_preferences.dart';
import 'package:e7m/core/constants/pref_keys.dart';

class TokenStorage {
  TokenStorage._();

  // ============================================================
  // SAVE TOKEN
  // ============================================================

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      PrefKeys.authToken,
      token,
    );

    await prefs.setBool(
      PrefKeys.isLoggedIn,
      true,
    );
  }

  // ============================================================
  // GET TOKEN
  // ============================================================

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(
      PrefKeys.authToken,
    );
  }

  // ============================================================
  // CHECK LOGIN
  // ============================================================

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(
      PrefKeys.authToken,
    );

    return token != null && token.isNotEmpty;
  }

  // ============================================================
  // CLEAR AUTH
  // ============================================================

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(PrefKeys.authToken);
    await prefs.setBool(PrefKeys.isLoggedIn, false);

    await prefs.reload();

    print(
      '🔴 TOKEN AFTER LOGOUT: '
          '${prefs.getString(PrefKeys.authToken)}',
    );

    print(
      '🔴 IS LOGGED IN: '
          '${prefs.getBool(PrefKeys.isLoggedIn)}',
    );
  }

  // ============================================================
  // CLEAR EVERYTHING RELATED TO AUTH
  // ============================================================

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(
      PrefKeys.authToken,
    );

    await prefs.setBool(
      PrefKeys.isLoggedIn,
      false,
    );
  }
}