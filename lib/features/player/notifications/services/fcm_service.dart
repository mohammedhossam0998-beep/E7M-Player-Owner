import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:e7m/core/network/api_client.dart';
import 'package:e7m/app/routes/route_names.dart';

class FCMService {
  FCMService._();

  // ============================================================
  // NAVIGATION
  // ============================================================

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  // ============================================================
  // FIREBASE
  // ============================================================

  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin
  _localNotifications =
  FlutterLocalNotificationsPlugin();

  static final ApiClient _apiClient = ApiClient();

  // ============================================================
  // INITIALIZE
  // ============================================================

  static Future<void> initialize() async {
    debugPrint('🟡 [FCM] Step 0: initialize() called');

    try {
      // --------------------------------------------------------
      // PERMISSION
      // --------------------------------------------------------

      debugPrint(
        '🟡 [FCM] Step 1: requesting permission...',
      );

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint(
        '🔔 [FCM] Permission = '
            '${settings.authorizationStatus}',
      );

      // --------------------------------------------------------
      // LOCAL NOTIFICATIONS
      // --------------------------------------------------------

      await _initializeLocalNotifications();

      // --------------------------------------------------------
      // FCM TOKEN
      // --------------------------------------------------------

      final token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint(
          '❌ [FCM] No FCM token received',
        );
      } else {
        debugPrint(
          '🔥 [FCM] FCM token received',
        );

        await _registerDevice(token);
      }

      // --------------------------------------------------------
      // TOKEN REFRESH
      // --------------------------------------------------------

      _messaging.onTokenRefresh.listen(
            (newToken) async {
          debugPrint(
            '🔄 [FCM] TOKEN REFRESHED',
          );

          await _registerDevice(newToken);
        },
      );

      // --------------------------------------------------------
      // FOREGROUND MESSAGE
      // --------------------------------------------------------

      FirebaseMessaging.onMessage.listen(
            (RemoteMessage message) async {
          debugPrint(
            '🔔 [FCM] FOREGROUND MESSAGE',
          );

          debugPrint(
            'Title: ${message.notification?.title}',
          );

          debugPrint(
            'Body: ${message.notification?.body}',
          );

          debugPrint(
            'Data: ${message.data}',
          );

          await _showLocalNotification(message);
        },
      );

      // --------------------------------------------------------
      // BACKGROUND → OPEN APP
      // --------------------------------------------------------

      FirebaseMessaging.onMessageOpenedApp.listen(
            (RemoteMessage message) {
          debugPrint(
            '👆 [FCM] BACKGROUND NOTIFICATION TAPPED',
          );

          debugPrint(
            '📦 [FCM] Data: ${message.data}',
          );

          _handleNotificationTap(message.data);
        },
      );

      // --------------------------------------------------------
      // TERMINATED → OPEN APP
      // --------------------------------------------------------

      final initialMessage =
      await _messaging.getInitialMessage();

      if (initialMessage != null) {
        debugPrint(
          '🚀 [FCM] TERMINATED NOTIFICATION TAPPED',
        );

        debugPrint(
          '📦 [FCM] Data: ${initialMessage.data}',
        );

        _handleNotificationTap(initialMessage.data);
      }

      debugPrint(
        '✅ [FCM] initialized successfully',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ [FCM] initialization error: $e',
      );

      debugPrint(
        '❌ [FCM] stackTrace: $stackTrace',
      );
    }
  }

  // ============================================================
  // LOCAL NOTIFICATIONS
  // ============================================================

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings
    androidInitializationSettings =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidInitializationSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:
      _onNotificationTapped,
    );

    const AndroidNotificationChannel channel =
    AndroidNotificationChannel(
      'e7m_notifications',
      'E7M Notifications',
      description: 'Notifications from E7M',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    debugPrint(
      '✅ [FCM] Local notification channel initialized',
    );
  }

  // ============================================================
  // SHOW FOREGROUND NOTIFICATION
  // ============================================================

  static Future<void> _showLocalNotification(
      RemoteMessage message,
      ) async {
    final notification = message.notification;

    if (notification == null) {
      debugPrint(
        '⚠️ [FCM] No notification payload',
      );
      return;
    }

    const AndroidNotificationDetails
    androidDetails =
    AndroidNotificationDetails(
      'e7m_notifications',
      'E7M Notifications',
      channelDescription:
      'Notifications from E7M',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title ?? 'E7M',
      body: notification.body ?? '',
      notificationDetails: notificationDetails,
      payload: jsonEncode(message.data),
    );

    debugPrint(
      '✅ [FCM] Foreground notification displayed',
    );
  }

  // ============================================================
  // LOCAL NOTIFICATION TAP
  // ============================================================

  static void _onNotificationTapped(
      NotificationResponse response,
      ) {
    debugPrint(
      '👆 [FCM] LOCAL NOTIFICATION TAPPED',
    );

    debugPrint(
      '📦 [FCM] Payload: ${response.payload}',
    );

    // Foreground notification payload handling
    _handlePayloadTap(response.payload);
  }

  // ============================================================
  // HANDLE FCM DATA
  // ============================================================

  static void _handleNotificationTap(
      Map<String, dynamic> data,
      ) {
    final type = data['type']?.toString();
    final bookingId = data['bookingId']?.toString();
    final teamId = data['teamId']?.toString();

    debugPrint('🎯 [FCM] Handling notification type: $type');
    debugPrint('🎯 [FCM] Booking ID: $bookingId');
    debugPrint('🎯 [FCM] Team ID: $teamId');

    if (type == 'team_chat' &&
        teamId != null &&
        teamId.isNotEmpty) {
      navigatorKey.currentState?.pushNamed(
        '/team-chat',
        arguments: int.tryParse(teamId),
      );
      return;
    }

    if (bookingId != null && bookingId.isNotEmpty) {
      navigatorKey.currentState?.pushNamed(
        RouteNames.bookingDetails,
        arguments: bookingId,
      );
      return;
    }

    if (type == 'booking_confirmed' ||
        type == 'booking_rejected') {
      navigatorKey.currentState?.pushNamed(
        RouteNames.myBookings,
      );
      return;
    }

    navigatorKey.currentState?.pushNamed(
      RouteNames.notifications,
    );
  }

  // ============================================================
  // HANDLE LOCAL PAYLOAD
  // ============================================================

  static void _handlePayloadTap(String? payload) {
    if (payload == null || payload.isEmpty) {
      navigatorKey.currentState?.pushNamed(
        RouteNames.notifications,
      );
      return;
    }

    debugPrint('📦 [FCM] Local payload: $payload');

    try {
      final Map<String, dynamic> data =
      Map<String, dynamic>.from(jsonDecode(payload));

      _handleNotificationTap(data);
    } catch (e) {
      debugPrint('❌ [FCM] Failed to parse local notification payload: $e');

      navigatorKey.currentState?.pushNamed(
        RouteNames.notifications,
      );
    }
  }

  // ============================================================
  // REGISTER DEVICE
  // ============================================================

  static Future<void> _registerDevice(
      String fcmToken,
      ) async {
    try {
      debugPrint(
        '📱 [FCM] Registering device with backend...',
      );

      final response = await _apiClient.post(
        '/notifications/device',
        {
          'fcmToken': fcmToken,
          'platform': 'android',
          'deviceName': 'Android Device',
        },
      );

      debugPrint(
        '✅ [FCM] Device registered successfully',
      );

      debugPrint(
        '📦 [FCM] Backend response: $response',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ [FCM] Device registration failed: $e',
      );

      debugPrint(
        '❌ [FCM] Registration stackTrace: $stackTrace',
      );
    }
  }
}