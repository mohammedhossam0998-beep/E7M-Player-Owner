import 'package:e7m/core/network/api_client.dart';

import '../models/availability_settings_model.dart';

class AvailabilityService {
  final ApiClient _apiClient;

  AvailabilityService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // GET AVAILABILITY SETTINGS
  // ============================================================

  Future<AvailabilitySettingsModel> getAvailabilitySettings(
      int pitchId,
      ) async {
    final response = await _apiClient.get(
      '/owner/pitches/$pitchId/availability',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid availability response',
      );
    }

    final settings = response['settings'];

    if (settings is! Map<String, dynamic>) {
      throw Exception(
        'Availability settings not found',
      );
    }

    return AvailabilitySettingsModel.fromJson(
      settings,
    );
  }

  // ============================================================
  // SAVE / UPDATE AVAILABILITY SETTINGS
  // ============================================================

  Future<AvailabilitySettingsModel>
  saveAvailabilitySettings(
      int pitchId,
      AvailabilitySettingsModel settings,
      ) async {
    final response = await _apiClient.put(
      '/owner/pitches/$pitchId/availability',
      settings.toJson(),
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid save availability response',
      );
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to save availability settings',
      );
    }

    final settingsData = response['settings'];

    if (settingsData is! Map<String, dynamic>) {
      throw Exception(
        'Saved availability settings not found',
      );
    }

    return AvailabilitySettingsModel.fromJson(
      settingsData,
    );
  }
}