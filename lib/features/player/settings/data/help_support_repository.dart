import 'help_support_api.dart';
import '../models/help_support_model.dart';

class HelpSupportRepository {
  final HelpSupportApi _api;

  HelpSupportRepository({HelpSupportApi? api})
      : _api = api ?? HelpSupportApi();

  /// Get Help & Support data
  Future<HelpSupportModel> getHelpSupport() {
    return _api.getHelpSupport();
  }

  /// Submit a problem report
  Future<void> submitReport({
    required String subject,
    required String description,
  }) {
    return _api.submitReport(
      subject: subject,
      description: description,
    );
  }
}