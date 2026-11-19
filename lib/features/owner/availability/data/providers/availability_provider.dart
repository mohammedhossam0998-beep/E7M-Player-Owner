
import 'package:flutter/foundation.dart';

import '../models/availability_settings_model.dart';
import '../services/availability_service.dart';

class AvailabilityProvider extends ChangeNotifier {
  final AvailabilityService _service;

  AvailabilityProvider({
    AvailabilityService? service,
  }) : _service = service ?? AvailabilityService();

  AvailabilitySettingsModel? _settings;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _disposed = false;

  String? _errorMessage;
  int? _pitchId;

  int _requestVersion = 0;

  // ============================================================
  // GETTERS
  // ============================================================

  AvailabilitySettingsModel? get settings => _settings;

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  bool get hasError => _errorMessage != null;

  String? get errorMessage => _errorMessage;

  int? get pitchId => _pitchId;

  bool get hasSettings => _settings != null;

  // ============================================================
  // SAFE NOTIFICATION
  // ============================================================

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // ============================================================
  // SWITCH STADIUM SAFELY
  // ============================================================

  void _activatePitch(int pitchId) {
    if (_pitchId == pitchId) return;

    ++_requestVersion;

    _pitchId = pitchId;
    _settings = null;
    _errorMessage = null;

    _isLoading = false;
    _isSaving = false;
  }

  // ============================================================
  // FETCH AVAILABILITY
  // ============================================================

  Future<void> fetchAvailability(int pitchId) async {
    if (_disposed) return;

    _activatePitch(pitchId);

    if (_isSaving) return;

    final request = ++_requestVersion;

    _isLoading = true;
    _errorMessage = null;

    _notify();

    try {
      final result =
      await _service.getAvailabilitySettings(pitchId);

      if (_disposed || request != _requestVersion) {
        return;
      }

      _settings = result;
    } catch (error) {
      if (_disposed || request != _requestVersion) {
        return;
      }

      _errorMessage = _cleanError(error);
    } finally {
      if (!_disposed && request == _requestVersion) {
        _isLoading = false;
        _notify();
      }
    }
  }

  // ============================================================
  // SAVE AVAILABILITY
  // ============================================================

  Future<AvailabilitySettingsModel?> saveAvailability(
      int pitchId,
      AvailabilitySettingsModel settings,
      ) async {
    if (_disposed) return null;

    _activatePitch(pitchId);

    if (_isSaving) return null;

    final request = ++_requestVersion;

    _isLoading = false;
    _isSaving = true;
    _errorMessage = null;

    _notify();

    try {
      final saved =
      await _service.saveAvailabilitySettings(
        pitchId,
        settings,
      );

      if (_disposed || request != _requestVersion) {
        return null;
      }

      _settings = saved;

      return saved;
    } catch (error) {
      if (!_disposed && request == _requestVersion) {
        _errorMessage = _cleanError(error);
      }

      return null;
    } finally {
      if (!_disposed && request == _requestVersion) {
        _isSaving = false;
        _notify();
      }
    }
  }

  // ============================================================
  // CLEAR ALL STATE
  // ============================================================

  void clear() {
    if (_disposed) return;

    ++_requestVersion;

    _settings = null;
    _pitchId = null;
    _errorMessage = null;

    _isLoading = false;
    _isSaving = false;

    _notify();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    if (_disposed) return;

    _errorMessage = null;
    _notify();
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _disposed = true;
    ++_requestVersion;

    super.dispose();
  }
}
