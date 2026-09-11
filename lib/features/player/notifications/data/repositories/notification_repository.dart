import 'package:e7m/features/player/notifications/data/models/notification_model.dart';
import 'package:e7m/features/player/notifications/services/notification_service.dart';

class NotificationRepository {
  final NotificationService _notificationService;

  NotificationRepository({
    NotificationService? notificationService,
  }) : _notificationService =
      notificationService ?? NotificationService();

  // ============================================================
  // GET MY NOTIFICATIONS
  // ============================================================

  Future<List<NotificationModel>> getMyNotifications() async {
    final response =
    await _notificationService.getMyNotifications();

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid notifications response',
      );
    }

    final notifications = response['notifications'];

    if (notifications is! List) {
      throw Exception(
        'Invalid notifications data',
      );
    }

    return notifications
        .whereType<Map>()
        .map(
          (notification) =>
          NotificationModel.fromJson(
            Map<String, dynamic>.from(notification),
          ),
    )
        .toList();
  }

  // ============================================================
  // GET UNREAD COUNT
  // ============================================================

  Future<int> getUnreadNotificationsCount() async {
    final response =
    await _notificationService
        .getUnreadNotificationsCount();

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid unread count response',
      );
    }

    final count = response['count'];

    if (count == null) {
      throw Exception(
        'Invalid unread count data',
      );
    }

    return int.parse(count.toString());
  }

  // ============================================================
  // MARK ONE AS READ
  // ============================================================

  Future<NotificationModel> markNotificationAsRead({
    required int notificationId,
  }) async {
    final response =
    await _notificationService
        .markNotificationAsRead(
      notificationId: notificationId,
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid mark as read response',
      );
    }

    final notification =
    response['notification'];

    if (notification is! Map) {
      throw Exception(
        'Invalid notification data',
      );
    }

    return NotificationModel.fromJson(
      Map<String, dynamic>.from(notification),
    );
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  Future<int> markAllNotificationsAsRead() async {
    final response =
    await _notificationService
        .markAllNotificationsAsRead();

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid mark all as read response',
      );
    }

    final updatedCount =
    response['updatedCount'];

    if (updatedCount == null) {
      throw Exception(
        'Invalid updated count data',
      );
    }

    return int.parse(
      updatedCount.toString(),
    );
  }

  // ============================================================
  // DELETE NOTIFICATION
  // ============================================================

  Future<void> deleteNotification({
    required int notificationId,
  }) async {
    final response =
    await _notificationService
        .deleteNotification(
      notificationId: notificationId,
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid delete notification response',
      );
    }

    final success = response['success'];

    if (success != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to delete notification',
      );
    }
  }
}