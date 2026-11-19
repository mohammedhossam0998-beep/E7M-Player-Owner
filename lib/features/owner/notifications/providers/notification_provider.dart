
import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;

  NotificationProvider({
    NotificationService? service,
  }) : _service = service ?? NotificationService();

  // ============================================================
  // STATE
  // ============================================================

  List<NotificationModel> _notifications = [];

  bool _isLoading = false;
  bool _isUpdating = false;

  int _unreadCount = 0;
  String? _errorMessage;

  // Prevent old requests from restoring data after logout.
  int _sessionVersion = 0;
  int _listRequestVersion = 0;

  bool _disposed = false;

  bool _isCurrent(int version) {
    return !_disposed && version == _sessionVersion;
  }

  // ============================================================
  // GETTERS
  // ============================================================

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  bool get isLoading => _isLoading;

  bool get isUpdating => _isUpdating;

  int get unreadCount => _unreadCount;

  String? get errorMessage => _errorMessage;

  bool get hasNotifications => _notifications.isNotEmpty;

  bool get hasError => _errorMessage != null;

  // ============================================================
  // CLEAR NOTIFICATIONS ON LOGOUT
  // ============================================================

  void clearNotifications() {
    if (_disposed) return;

    _sessionVersion++;
    _listRequestVersion++;

    _notifications = [];
    _unreadCount = 0;
    _errorMessage = null;
    _isLoading = false;
    _isUpdating = false;

    notifyListeners();
  }

  // ============================================================
  // LOAD NOTIFICATIONS
  // ============================================================

  Future<void> loadNotifications() async {
    if (_disposed) return;

    final session = _sessionVersion;
    final request = ++_listRequestVersion;

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final notifications =
      await _service.getNotifications();

      if (!_isCurrent(session) ||
          request != _listRequestVersion) {
        return;
      }

      _notifications = notifications;

      _unreadCount = notifications
          .where((notification) => !notification.isRead)
          .length;
    } catch (error) {
      if (_isCurrent(session) &&
          request == _listRequestVersion) {
        _errorMessage = _cleanError(error);
      }
    } finally {
      if (_isCurrent(session) &&
          request == _listRequestVersion) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // ============================================================
  // LOAD UNREAD COUNT
  // ============================================================

  Future<void> loadUnreadCount() async {
    if (_disposed) return;

    final session = _sessionVersion;

    try {
      final count = await _service.getUnreadCount();

      if (!_isCurrent(session)) return;

      _unreadCount = count;
      notifyListeners();
    } catch (error) {
      if (!_isCurrent(session)) return;

      _errorMessage = _cleanError(error);
      notifyListeners();
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    if (_disposed) return;

    final session = _sessionVersion;
    final request = ++_listRequestVersion;

    _errorMessage = null;

    try {
      final results = await Future.wait<dynamic>([
        _service.getNotifications(),
        _service.getUnreadCount(),
      ]);

      if (!_isCurrent(session) ||
          request != _listRequestVersion) {
        return;
      }

      _notifications =
      results[0] as List<NotificationModel>;

      _unreadCount = results[1] as int;

      notifyListeners();
    } catch (error) {
      if (!_isCurrent(session) ||
          request != _listRequestVersion) {
        return;
      }

      _errorMessage = _cleanError(error);
      notifyListeners();
    }
  }

  // ============================================================
  // MARK ONE NOTIFICATION AS READ
  // ============================================================

  Future<bool> markAsRead(int notificationId) async {
    if (_disposed || _isUpdating) return false;

    final session = _sessionVersion;

    _isUpdating = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final updated = await _service.markAsRead(
        notificationId,
      );

      if (!_isCurrent(session)) return false;

      List<NotificationModel>? refreshed;

      if (updated == null) {
        refreshed = await _service.getNotifications();

        if (!_isCurrent(session)) return false;
      }

      final count = await _service.getUnreadCount();

      if (!_isCurrent(session)) return false;

      if (updated != null) {
        final index = _notifications.indexWhere(
              (notification) =>
          notification.id == notificationId,
        );

        if (index != -1) {
          _notifications[index] = updated;
        }
      } else if (refreshed != null) {
        _notifications = refreshed;
      }

      _unreadCount = count;

      return true;
    } catch (error) {
      if (_isCurrent(session)) {
        _errorMessage = _cleanError(error);
      }

      return false;
    } finally {
      if (_isCurrent(session)) {
        _isUpdating = false;
        notifyListeners();
      }
    }
  }

  // ============================================================
  // MARK ALL NOTIFICATIONS AS READ
  // ============================================================

  Future<bool> markAllAsRead() async {
    if (_disposed || _isUpdating) return false;

    final session = _sessionVersion;

    _isUpdating = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _service.markAllAsRead();

      if (!_isCurrent(session)) return false;

      final notifications =
      await _service.getNotifications();

      if (!_isCurrent(session)) return false;

      final count = await _service.getUnreadCount();

      if (!_isCurrent(session)) return false;

      _notifications = notifications;
      _unreadCount = count;

      return true;
    } catch (error) {
      if (_isCurrent(session)) {
        _errorMessage = _cleanError(error);
      }

      return false;
    } finally {
      if (_isCurrent(session)) {
        _isUpdating = false;
        notifyListeners();
      }
    }
  }

  // ============================================================
  // DELETE NOTIFICATION
  // ============================================================

  Future<bool> deleteNotification(
      int notificationId,
      ) async {
    if (_disposed || _isUpdating) return false;

    final session = _sessionVersion;

    _isUpdating = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _service.deleteNotification(
        notificationId,
      );

      if (!_isCurrent(session)) return false;

      final count = await _service.getUnreadCount();

      if (!_isCurrent(session)) return false;

      _notifications.removeWhere(
            (notification) =>
        notification.id == notificationId,
      );

      _unreadCount = count;

      return true;
    } catch (error) {
      if (_isCurrent(session)) {
        _errorMessage = _cleanError(error);
      }

      return false;
    } finally {
      if (_isCurrent(session)) {
        _isUpdating = false;
        notifyListeners();
      }
    }
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    if (_disposed || _errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================
  // ERROR HANDLING
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

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _sessionVersion++;
    _listRequestVersion++;
    _disposed = true;

    super.dispose();
  }
}
