import 'package:e7m/core/network/api_client.dart';

class SettingsApi {
  final ApiClient _apiClient;

  SettingsApi({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // CHANGE PASSWORD
  // PATCH /api/auth/change-password
  // ============================================================

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _apiClient.patch(
      '/auth/change-password',
      {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid change password response');
    }

    return response;
  }
}