import 'package:e7m/core/network/api_client.dart';

import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // GET MY NOTIFICATIONS
  // GET /api/notifications
  // ============================================================

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.get(
        '/notifications',
      );

      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid notifications response',
        );
      }

      if (response['success'] != true) {
        throw Exception(
          response['message']?.toString() ??
              'Failed to get notifications',
        );
      }

      final notificationsData =
      response['notifications'];

      if (notificationsData is! List) {
        return [];
      }

      return notificationsData
          .map(
            (notification) =>
            NotificationModel.fromJson(
              Map<String, dynamic>.from(
                notification,
              ),
            ),
      )
          .toList();
    } catch (e) {
      print(
        '❌ GET NOTIFICATIONS SERVICE ERROR: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // GET UNREAD COUNT
  // GET /api/notifications/unread-count
  // ============================================================

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get(
        '/notifications/unread-count',
      );

      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid unread count response',
        );
      }

      if (response['success'] != true) {
        throw Exception(
          response['message']?.toString() ??
              'Failed to get unread notifications count',
        );
      }

      return int.parse(
        response['count'].toString(),
      );
    } catch (e) {
      print(
        '❌ GET UNREAD COUNT SERVICE ERROR: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // MARK ONE AS READ
  // PATCH /api/notifications/:id/read
  // ============================================================

  Future<NotificationModel?> markAsRead(
      int notificationId,
      ) async {
    try {
      final response = await _apiClient.patch(
        '/notifications/$notificationId/read',
        {},
      );

      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid mark as read response',
        );
      }

      if (response['success'] != true) {
        throw Exception(
          response['message']?.toString() ??
              'Failed to mark notification as read',
        );
      }

      final notificationData =
      response['notification'];

      if (notificationData is Map) {
        return NotificationModel.fromJson(
          Map<String, dynamic>.from(
            notificationData,
          ),
        );
      }

      return null;
    } catch (e) {
      print(
        '❌ MARK NOTIFICATION AS READ ERROR: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // MARK ALL AS READ
  // PATCH /api/notifications/read-all
  // ============================================================

  Future<int> markAllAsRead() async {
    try {
      final response = await _apiClient.patch(
        '/notifications/read-all',
        {},
      );

      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid mark all as read response',
        );
      }

      if (response['success'] != true) {
        throw Exception(
          response['message']?.toString() ??
              'Failed to mark all notifications as read',
        );
      }

      return int.parse(
        response['updatedCount']?.toString() ?? '0',
      );
    } catch (e) {
      print(
        '❌ MARK ALL NOTIFICATIONS AS READ ERROR: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // DELETE NOTIFICATION
  // DELETE /api/notifications/:id
  // ============================================================

  Future<void> deleteNotification(
      int notificationId,
      ) async {
    try {
      final response =
      await _apiClient.delete(
        '/notifications/$notificationId',
      );

      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid delete notification response',
        );
      }

      if (response['success'] != true) {
        throw Exception(
          response['message']?.toString() ??
              'Failed to delete notification',
        );
      }
    } catch (e) {
      print(
        '❌ DELETE NOTIFICATION SERVICE ERROR: $e',
      );

      rethrow;
    }
  }
}