import 'package:e7m/core/network/api_client.dart';

class ChangePasswordService {
  final ApiClient _apiClient;

  ChangePasswordService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // CHANGE PASSWORD
  // PATCH /api/auth/change-password
  // ============================================================

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/auth/change-password',
        {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid change password response',
        );
      }

      final success = response['success'] == true;

      if (!success) {
        throw Exception(
          response['message']?.toString() ??
              'Failed to change password',
        );
      }
    } catch (e) {
      print(
        '❌ CHANGE PASSWORD SERVICE ERROR: $e',
      );

      rethrow;
    }
  }
}