import 'package:flutter/foundation.dart';

import '../models/availability_settings_model.dart';
import '../services/availability_service.dart';

class AvailabilityProvider extends ChangeNotifier {
  final AvailabilityService _service;

  AvailabilityProvider({
    AvailabilityService? service,
  }) : _service = service ?? AvailabilityService();

  // ============================================================
  // STATE
  // ============================================================

  AvailabilitySettingsModel? _settings;

  bool _isLoading = false;
  bool _isSaving = false;

  String? _errorMessage;

  int? _pitchId;

  // ============================================================
  // GETTERS
  // ============================================================

  AvailabilitySettingsModel? get settings =>
      _settings;

  bool get isLoading =>
      _isLoading;

  bool get isSaving =>
      _isSaving;

  bool get hasError =>
      _errorMessage != null;

  String? get errorMessage =>
      _errorMessage;

  int? get pitchId =>
      _pitchId;

  bool get hasSettings =>
      _settings != null;

  // ============================================================
  // GET AVAILABILITY
  // ============================================================

  Future<void> fetchAvailability(
      int pitchId,
      ) async {
    _pitchId = pitchId;

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _settings =
      await _service.getAvailabilitySettings(
        pitchId,
      );
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // SAVE AVAILABILITY
  // ============================================================

  Future<AvailabilitySettingsModel?> saveAvailability(
      int pitchId,
      AvailabilitySettingsModel settings,
      ) async {
    _pitchId = pitchId;

    _isSaving = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final savedSettings =
      await _service.saveAvailabilitySettings(
        pitchId,
        settings,
      );

      _settings = savedSettings;

      return savedSettings;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return null;
    } finally {
      _isSaving = false;

      notifyListeners();
    }
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clear() {
    _settings = null;
    _pitchId = null;
    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAN ERROR
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }
}