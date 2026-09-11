import 'package:e7m/core/network/api_client.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // GET MY NOTIFICATIONS
  // GET /api/notifications
  // ============================================================

  Future<dynamic> getMyNotifications() async {
    return _apiClient.get(
      '/notifications',
    );
  }

  // ============================================================
  // GET UNREAD NOTIFICATIONS COUNT
  // GET /api/notifications/unread-count
  // ============================================================

  Future<dynamic> getUnreadNotificationsCount() async {
    return _apiClient.get(
      '/notifications/unread-count',
    );
  }

  // ============================================================
  // MARK ONE NOTIFICATION AS READ
  // PATCH /api/notifications/:id/read
  // ============================================================

  Future<dynamic> markNotificationAsRead({
    required int notificationId,
  }) async {
    return _apiClient.patch(
      '/notifications/$notificationId/read',
      {},
    );
  }

  // ============================================================
  // MARK ALL NOTIFICATIONS AS READ
  // PATCH /api/notifications/read-all
  // ============================================================

  Future<dynamic> markAllNotificationsAsRead() async {
    return _apiClient.patch(
      '/notifications/read-all',
      {},
    );
  }

  // ============================================================
  // DELETE NOTIFICATION
  // DELETE /api/notifications/:id
  // ============================================================

  Future<dynamic> deleteNotification({
    required int notificationId,
  }) async {
    return _apiClient.delete(
      '/notifications/$notificationId',
    );
  }
}