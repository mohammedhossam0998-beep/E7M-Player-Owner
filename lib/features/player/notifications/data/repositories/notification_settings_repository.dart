import 'package:e7m/core/network/api_client.dart';

class NotificationSettingsRepository {
  final ApiClient _apiClient = ApiClient();

  /// جلب إعدادات الإشعارات من Backend
  Future<Map<String, dynamic>> getSettings() async {
    final response = await _apiClient.get(
      '/notifications/settings',
    );

    if (response is Map<String, dynamic>) {
      if (response['success'] == true) {
        final settings = response['settings'];

        if (settings is Map<String, dynamic>) {
          return settings;
        }
      }
    }

    throw Exception('Failed to load notification settings');
  }

  /// تحديث إعداد واحد أو أكثر
  Future<Map<String, dynamic>> updateSettings(
      Map<String, dynamic> settings,
      ) async {
    final response = await _apiClient.patch(
      '/notifications/settings',
      settings,
    );

    if (response is Map<String, dynamic>) {
      if (response['success'] == true) {
        final updatedSettings = response['settings'];

        if (updatedSettings is Map<String, dynamic>) {
          return updatedSettings;
        }
      }
    }

    throw Exception('Failed to update notification settings');
  }
}