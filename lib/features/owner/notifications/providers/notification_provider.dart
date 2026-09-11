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
  // LOAD NOTIFICATIONS
  // ============================================================

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final notifications =
      await _service.getNotifications();

      _notifications = notifications;

      // Keep unread count synchronized with
      // the actual notifications returned by backend.
      _unreadCount = _notifications
          .where((notification) => !notification.isRead)
          .length;
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // LOAD UNREAD COUNT
  // ============================================================

  Future<void> loadUnreadCount() async {
    try {
      final count =
      await _service.getUnreadCount();

      _unreadCount = count;

      notifyListeners();
    } catch (e) {
      _errorMessage = _cleanError(e);

      notifyListeners();
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    try {
      _errorMessage = null;

      final results = await Future.wait([
        _service.getNotifications(),
        _service.getUnreadCount(),
      ]);

      _notifications =
      results[0] as List<NotificationModel>;

      _unreadCount =
      results[1] as int;

      notifyListeners();
    } catch (e) {
      _errorMessage = _cleanError(e);

      notifyListeners();
    }
  }

  // ============================================================
  // MARK ONE AS READ
  // ============================================================

  Future<bool> markAsRead(int notificationId) async {
    try {
      _isUpdating = true;
      _errorMessage = null;

      notifyListeners();

      final updatedNotification =
      await _service.markAsRead(
        notificationId,
      );

      if (updatedNotification != null) {
        final index = _notifications.indexWhere(
              (notification) =>
          notification.id == notificationId,
        );

        if (index != -1) {
          _notifications[index] =
              updatedNotification;
        }
      } else {
        // Backend confirmed success but did not
        // return the notification object.
        final index = _notifications.indexWhere(
              (notification) =>
          notification.id == notificationId,
        );

        if (index != -1) {
          // Reload to keep local state authoritative.
          final notifications =
          await _service.getNotifications();

          _notifications = notifications;
        }
      }

      // Synchronize with backend.
      _unreadCount =
      await _service.getUnreadCount();

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return false;
    } finally {
      _isUpdating = false;

      notifyListeners();
    }
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  Future<bool> markAllAsRead() async {
    try {
      _isUpdating = true;
      _errorMessage = null;

      notifyListeners();

      await _service.markAllAsRead();

      // Reload from backend instead of assuming
      // local state is correct.
      _notifications =
      await _service.getNotifications();

      _unreadCount =
      await _service.getUnreadCount();

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return false;
    } finally {
      _isUpdating = false;

      notifyListeners();
    }
  }

  // ============================================================
  // DELETE NOTIFICATION
  // ============================================================

  Future<bool> deleteNotification(
      int notificationId,
      ) async {
    try {
      _isUpdating = true;
      _errorMessage = null;

      notifyListeners();

      await _service.deleteNotification(
        notificationId,
      );

      // Remove only after backend confirms deletion.
      _notifications.removeWhere(
            (notification) =>
        notification.id == notificationId,
      );

      // Synchronize unread count with backend.
      _unreadCount =
      await _service.getUnreadCount();

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return false;
    } finally {
      _isUpdating = false;

      notifyListeners();
    }
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    if (_errorMessage == null) {
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
}