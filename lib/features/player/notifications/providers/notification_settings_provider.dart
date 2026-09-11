import 'package:flutter/foundation.dart';

import '../data/repositories/notification_settings_repository.dart';

class NotificationSettingsProvider extends ChangeNotifier {
  final NotificationSettingsRepository _repository =
  NotificationSettingsRepository();

  bool _bookingConfirmed = true;
  bool _bookingRejected = true;
  bool _payments = true;
  bool _offers = true;
  bool _matches = true;
  bool _general = true;

  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;

  bool get bookingConfirmed => _bookingConfirmed;
  bool get bookingRejected => _bookingRejected;
  bool get payments => _payments;
  bool get offers => _offers;
  bool get matches => _matches;
  bool get general => _general;

  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;

  /// Load settings from backend
  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final settings = await _repository.getSettings();

      _bookingConfirmed =
          settings['booking_confirmed'] as bool? ?? true;

      _bookingRejected =
          settings['booking_rejected'] as bool? ?? true;

      _payments =
          settings['payments'] as bool? ?? true;

      _offers =
          settings['offers'] as bool? ?? true;

      _matches =
          settings['matches'] as bool? ?? true;

      _general =
          settings['general'] as bool? ?? true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update booking confirmed notifications
  Future<bool> setBookingConfirmed(bool value) async {
    return _updateSetting(
      key: 'booking_confirmed',
      value: value,
      onSuccess: () {
        _bookingConfirmed = value;
      },
    );
  }

  /// Update booking rejected notifications
  Future<bool> setBookingRejected(bool value) async {
    return _updateSetting(
      key: 'booking_rejected',
      value: value,
      onSuccess: () {
        _bookingRejected = value;
      },
    );
  }

  /// Update payment notifications
  Future<bool> setPayments(bool value) async {
    return _updateSetting(
      key: 'payments',
      value: value,
      onSuccess: () {
        _payments = value;
      },
    );
  }

  /// Update offers notifications
  Future<bool> setOffers(bool value) async {
    return _updateSetting(
      key: 'offers',
      value: value,
      onSuccess: () {
        _offers = value;
      },
    );
  }

  /// Update match notifications
  Future<bool> setMatches(bool value) async {
    return _updateSetting(
      key: 'matches',
      value: value,
      onSuccess: () {
        _matches = value;
      },
    );
  }

  /// Update general notifications
  Future<bool> setGeneral(bool value) async {
    return _updateSetting(
      key: 'general',
      value: value,
      onSuccess: () {
        _general = value;
      },
    );
  }

  Future<bool> _updateSetting({
    required String key,
    required bool value,
    required VoidCallback onSuccess,
  }) async {
    if (_isUpdating) return false;

    _isUpdating = true;
    _error = null;

    // Optimistic UI update
    onSuccess();
    notifyListeners();

    try {
      await _repository.updateSettings({
        key: value,
      });

      return true;
    } catch (e) {
      _error = e.toString();

      // Reload real value from backend if update failed.
      await loadSettings();

      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
}