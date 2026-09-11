import 'package:flutter/foundation.dart';
import 'package:e7m/features/player/notifications/data/models/notification_model.dart';
import 'package:e7m/features/player/notifications/data/repositories/notification_repository.dart';
class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationProvider({
    NotificationRepository? repository,
  }) : _repository =
      repository ?? NotificationRepository();

  // ============================================================
  // STATE
  // ============================================================

  List<NotificationModel> _notifications = [];

  int _unreadCount = 0;

  bool _isLoading = false;
  bool _isLoadingUnreadCount = false;
  bool _isMarkingAsRead = false;
  bool _isMarkingAllAsRead = false;
  bool _isDeleting = false;

  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount => _unreadCount;

  bool get isLoading => _isLoading;

  bool get isLoadingUnreadCount =>
      _isLoadingUnreadCount;

  bool get isMarkingAsRead =>
      _isMarkingAsRead;

  bool get isMarkingAllAsRead =>
      _isMarkingAllAsRead;

  bool get isDeleting => _isDeleting;

  String? get errorMessage => _errorMessage;

  bool get hasNotifications =>
      _notifications.isNotEmpty;

  bool get hasUnreadNotifications =>
      _unreadCount > 0;

  // ============================================================
  // LOAD NOTIFICATIONS
  // ============================================================

  Future<void> loadNotifications() async {
    print('🔔 NotificationProvider: loadNotifications() CALLED');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔔 NotificationProvider: Calling repository...');

      _notifications =
      await _repository.getMyNotifications();

      print(
        '🔔 NotificationProvider: Loaded ${_notifications.length} notifications',
      );

      for (final notification in _notifications) {
        print(
          '🔔 Notification: '
              'id=${notification.id}, '
              'title=${notification.title}, '
              'isRead=${notification.isRead}',
        );
      }

      _unreadCount = _notifications
          .where((notification) => !notification.isRead)
          .length;

      print(
        '🔔 NotificationProvider: Unread count = $_unreadCount',
      );
    } catch (error) {
      print(
        '❌ NotificationProvider Error: $error',
      );

      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();

      print(
        '🔔 NotificationProvider: loadNotifications() FINISHED',
      );
    }
  }

  // ============================================================
  // LOAD UNREAD COUNT
  // ============================================================

  Future<void> loadUnreadCount() async {
    _isLoadingUnreadCount = true;

    try {
      _unreadCount =
      await _repository
          .getUnreadNotificationsCount();
    } catch (error) {
      _errorMessage =
          error.toString();
    } finally {
      _isLoadingUnreadCount = false;
      notifyListeners();
    }
  }

  // ============================================================
  // MARK ONE NOTIFICATION AS READ
  // ============================================================

  Future<bool> markNotificationAsRead(
      int notificationId,
      ) async {
    _isMarkingAsRead = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedNotification =
      await _repository.markNotificationAsRead(
        notificationId: notificationId,
      );

      final index = _notifications.indexWhere(
            (notification) =>
        notification.id == notificationId,
      );

      if (index != -1) {
        _notifications[index] =
            updatedNotification;
      }

      if (_unreadCount > 0) {
        _unreadCount--;
      }

      return true;
    } catch (error) {
      _errorMessage =
          error.toString();

      return false;
    } finally {
      _isMarkingAsRead = false;
      notifyListeners();
    }
  }

  // ============================================================
  // MARK ALL NOTIFICATIONS AS READ
  // ============================================================

  Future<bool> markAllNotificationsAsRead() async {
    _isMarkingAllAsRead = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository
          .markAllNotificationsAsRead();

      _notifications = _notifications
          .map(
            (notification) =>
            notification.copyWith(
              isRead: true,
            ),
      )
          .toList();

      _unreadCount = 0;

      return true;
    } catch (error) {
      _errorMessage =
          error.toString();

      return false;
    } finally {
      _isMarkingAllAsRead = false;
      notifyListeners();
    }
  }

  // ============================================================
  // DELETE NOTIFICATION
  // ============================================================

  Future<bool> deleteNotification(
      int notificationId,
      ) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final notificationIndex =
      _notifications.indexWhere(
            (notification) =>
        notification.id == notificationId,
      );

      if (notificationIndex == -1) {
        throw Exception(
          'Notification not found',
        );
      }

      final notification =
      _notifications[notificationIndex];

      await _repository.deleteNotification(
        notificationId: notificationId,
      );

      _notifications.removeAt(
        notificationIndex,
      );

      if (!notification.isRead &&
          _unreadCount > 0) {
        _unreadCount--;
      }

      return true;
    } catch (error) {
      _errorMessage =
          error.toString();

      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refresh() async {
    await loadNotifications();
  }
}