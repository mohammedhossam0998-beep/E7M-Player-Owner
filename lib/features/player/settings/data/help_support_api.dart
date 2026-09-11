import 'package:e7m/core/network/api_client.dart';
import '../models/help_support_model.dart';

class HelpSupportApi {
  final ApiClient _apiClient;

  HelpSupportApi({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get Help & Support data
  Future<HelpSupportModel> getHelpSupport() async {
    final response = await _apiClient.get('/player/help-support');

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ?? 'Failed to load help support',
      );
    }

    return HelpSupportModel.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  /// Submit a problem report
  Future<void> submitReport({
    required String subject,
    required String description,
  }) async {
    final response = await _apiClient.post(
      '/player/help-support/report',
      {
        'subject': subject,
        'description': description,
      },
    );

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ?? 'Failed to submit report',
      );
    }
  }
}