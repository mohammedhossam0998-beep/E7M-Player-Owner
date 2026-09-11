import 'package:flutter/foundation.dart';

import '../../data/help_support_repository.dart';
import '../../models/help_support_model.dart';

class HelpSupportProvider extends ChangeNotifier {
  final HelpSupportRepository _repository;

  HelpSupportProvider({
    HelpSupportRepository? repository,
  }) : _repository = repository ?? HelpSupportRepository();

  HelpSupportModel? _data;

  bool _isLoading = false;

  bool _isSubmittingReport = false;

  String? _error;

  String? _reportError;

  HelpSupportModel? get data => _data;

  bool get isLoading => _isLoading;

  bool get isSubmittingReport => _isSubmittingReport;

  String? get error => _error;

  String? get reportError => _reportError;

  Future<void> loadHelpSupport() async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      _data = await _repository.getHelpSupport();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReport({
    required String subject,
    required String description,
  }) async {
    _isSubmittingReport = true;
    _reportError = null;

    notifyListeners();

    try {
      await _repository.submitReport(
        subject: subject,
        description: description,
      );

      return true;
    } catch (e) {
      _reportError = e.toString();

      return false;
    } finally {
      _isSubmittingReport = false;

      notifyListeners();
    }
  }
}