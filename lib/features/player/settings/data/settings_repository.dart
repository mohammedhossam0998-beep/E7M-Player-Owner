import 'settings_api.dart';

class SettingsRepository {
  final SettingsApi _api;

  SettingsRepository({
    SettingsApi? api,
  }) : _api = api ?? SettingsApi();

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _api.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}