import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'package:e7m/app/routes/route_names.dart';
import 'package:e7m/core/network/api_client.dart';
import 'package:e7m/features/auth/presentation/controllers/auth_controller.dart';

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

  // ============================================================
  // LOCAL NOTIFICATIONS
  // ============================================================

  static final FlutterLocalNotificationsPlugin
  _localNotifications =
  FlutterLocalNotificationsPlugin();

  // ============================================================
  // API
  // ============================================================

  static final ApiClient _apiClient = ApiClient();

  // ============================================================
  // STATE
  // ============================================================

  static String? _currentToken;

  static bool _initialized = false;

  static Map<String, dynamic>? _pendingNotificationData;

  // ============================================================
  // INITIALIZE
  // ============================================================

  static Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    if (_initialized) {
      debugPrint(
        '🟡 [FCM] Already initialized',
      );

      return;
    }

    debugPrint(
      '🟡 [FCM] initialize() called',
    );

    try {
      // ========================================================
      // REQUEST PERMISSION
      // ========================================================

      final settings =
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint(
        '🔔 [FCM] Permission = '
            '${settings.authorizationStatus}',
      );

      // ========================================================
      // LOCAL NOTIFICATIONS
      // ========================================================

      await _initializeLocalNotifications();

      // ========================================================
      // GET FCM TOKEN
      // ========================================================

      final token =
      await _messaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint(
          '❌ [FCM] No FCM token received',
        );
      } else {
        _currentToken = token;

        debugPrint(
          '🔥 [FCM] FCM token received',
        );

        debugPrint(
          '📱 [FCM] Token length: ${token.length}',
        );

        // IMPORTANT:
        // We DO NOT register the device here.
        //
        // Authentication may not be ready yet.
        //
        // Device registration happens after:
        // 1. Login
        // 2. Session restore
      }

      // ========================================================
      // TOKEN REFRESH
      // ========================================================

      _messaging.onTokenRefresh.listen(
            (newToken) async {
          debugPrint(
            '🔄 [FCM] TOKEN REFRESHED',
          );

          _currentToken = newToken;

          await registerCurrentDevice();
        },
      );

      // ========================================================
      // FOREGROUND MESSAGE
      // ========================================================

      FirebaseMessaging.onMessage.listen(
            (RemoteMessage message) async {
          debugPrint(
            '🔔 [FCM] FOREGROUND MESSAGE',
          );

          debugPrint(
            'Title: '
                '${message.notification?.title}',
          );

          debugPrint(
            'Body: '
                '${message.notification?.body}',
          );

          debugPrint(
            'Data: ${message.data}',
          );

          await _showLocalNotification(
            message,
          );
        },
      );

      // ========================================================
      // BACKGROUND MESSAGE TAP
      // ========================================================

      FirebaseMessaging.onMessageOpenedApp.listen(
            (RemoteMessage message) {
          debugPrint(
            '👆 [FCM] BACKGROUND NOTIFICATION TAPPED',
          );

          debugPrint(
            '📦 [FCM] Data: ${message.data}',
          );

          _handleNotificationTap(
            Map<String, dynamic>.from(
              message.data,
            ),
          );
        },
      );

      // ========================================================
      // TERMINATED MESSAGE TAP
      // ========================================================

      final initialMessage =
      await _messaging.getInitialMessage();

      if (initialMessage != null) {
        debugPrint(
          '🚀 [FCM] TERMINATED NOTIFICATION TAPPED',
        );

        debugPrint(
          '📦 [FCM] Data: ${initialMessage.data}',
        );

        _handleNotificationTap(
          Map<String, dynamic>.from(
            initialMessage.data,
          ),
        );
      }

      _initialized = true;

      debugPrint(
        '✅ [FCM] initialized successfully',
      );

      // ========================================================
      // HANDLE PENDING NOTIFICATION
      // ========================================================

      _tryHandlePendingNotification();
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
  // REGISTER CURRENT DEVICE
  // ============================================================

  static Future<void> registerCurrentDevice() async {
    if (kIsWeb) {
      return;
    }

    try {
      final token =
          _currentToken ??
              await _messaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint(
          '⚠️ [FCM] Cannot register device: token missing',
        );

        return;
      }

      _currentToken = token;

      debugPrint(
        '📱 [FCM] Registering current device...',
      );

      final response =
      await _apiClient.post(
        '/notifications/device',
        {
          'fcmToken': token,
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
        '⚠️ [FCM] Device registration failed: $e',
      );

      debugPrint(
        '⚠️ [FCM] Registration stackTrace: $stackTrace',
      );
    }
  }

  // ============================================================
  // LOCAL NOTIFICATION INITIALIZATION
  // ============================================================

  static Future<void>
  _initializeLocalNotifications() async {
    const AndroidInitializationSettings
    androidInitializationSettings =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings
    initializationSettings =
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
      description:
      'Notifications from E7M',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      channel,
    );

    debugPrint(
      '✅ [FCM] Local notification channel initialized',
    );
  }

  // ============================================================
  // SHOW LOCAL NOTIFICATION
  // ============================================================

  static Future<void> _showLocalNotification(
      RemoteMessage message,
      ) async {
    final notification =
        message.notification;

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

    const NotificationDetails
    notificationDetails =
    NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      id: notification.hashCode,
      title:
      notification.title ?? 'E7M',
      body:
      notification.body ?? '',
      notificationDetails:
      notificationDetails,
      payload:
      jsonEncode(message.data),
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

    _handlePayloadTap(
      response.payload,
    );
  }

  // ============================================================
  // HANDLE NOTIFICATION TAP
  // ============================================================

  static void _handleNotificationTap(
      Map<String, dynamic> data,
      ) {
    debugPrint(
      '🎯 [FCM] Handling notification',
    );

    debugPrint(
      '📦 [FCM] Data: $data',
    );

    final navigator =
        navigatorKey.currentState;

    // ==========================================================
    // NAVIGATOR NOT READY
    // ==========================================================

    if (navigator == null) {
      debugPrint(
        '⏳ [FCM] Navigator not ready. '
            'Saving notification for later.',
      );

      _pendingNotificationData =
      Map<String, dynamic>.from(
        data,
      );

      _tryHandlePendingNotification();

      return;
    }

    _navigateByUserRole(data);
  }

  // ============================================================
  // HANDLE LOCAL PAYLOAD
  // ============================================================

  static void _handlePayloadTap(
      String? payload,
      ) {
    if (payload == null ||
        payload.isEmpty) {
      _handleNotificationTap(
        <String, dynamic>{},
      );

      return;
    }

    debugPrint(
      '📦 [FCM] Local payload: $payload',
    );

    try {
      final decoded =
      jsonDecode(payload);

      final Map<String, dynamic> data =
      Map<String, dynamic>.from(
        decoded as Map,
      );

      _handleNotificationTap(data);
    } catch (e) {
      debugPrint(
        '❌ [FCM] Failed to parse local notification payload: $e',
      );

      _handleNotificationTap(
        <String, dynamic>{},
      );
    }
  }

  // ============================================================
  // NAVIGATE BY USER ROLE
  // ============================================================

  static void _navigateByUserRole(
      Map<String, dynamic> data,
      ) {
    final navigator =
        navigatorKey.currentState;

    if (navigator == null) {
      _pendingNotificationData =
      Map<String, dynamic>.from(
        data,
      );

      return;
    }

    final context =
        navigatorKey.currentContext;

    if (context == null) {
      _pendingNotificationData =
      Map<String, dynamic>.from(
        data,
      );

      _retryPendingNotification();

      return;
    }

    final authController =
    context.read<AuthController>();

    final role =
    authController.role
        ?.toString()
        .trim()
        .toLowerCase();

    debugPrint(
      '👤 [FCM] Current user role: $role',
    );

    // ==========================================================
    // OWNER
    // ==========================================================

    if (role == 'owner') {
      _navigateOwnerNotification(
        navigator,
        data,
      );

      return;
    }

    // ==========================================================
    // PLAYER
    // ==========================================================

    if (role == 'player') {
      _navigatePlayerNotification(
        navigator,
        data,
      );

      return;
    }

    // ==========================================================
    // UNKNOWN ROLE
    // ==========================================================

    debugPrint(
      '⚠️ [FCM] Unknown user role: $role',
    );

    _pendingNotificationData =
    Map<String, dynamic>.from(
      data,
    );

    _retryPendingNotification();
  }

  // ============================================================
  // OWNER NOTIFICATION
  // ============================================================

  static void _navigateOwnerNotification(
      NavigatorState navigator,
      Map<String, dynamic> data,
      ) {
    final type = (
        data['type'] ??
            data['notificationType'] ??
            'general'
    ).toString().toLowerCase();

    debugPrint(
      '🔔 OWNER NOTIFICATION TYPE: $type',
    );

    switch (type) {
    // ==========================================================
    // 🏟️ NEW BOOKING
    // ==========================================================

      case 'new_booking':
        navigator.pushNamed(
          RouteNames.ownerBookings,
          arguments: data,
        );
        return;

    // ==========================================================
    // ❌ BOOKING CANCELLED
    // ==========================================================

      case 'booking_cancelled':
      case 'booking_canceled':
        navigator.pushNamed(
          RouteNames.ownerBookings,
          arguments: data,
        );
        return;

    // ==========================================================
    // 💰 PAYMENT
    // ==========================================================

      case 'payments':
        navigator.pushNamed(
          RouteNames.ownerPayments,
          arguments: data,
        );
        return;

    // ==========================================================
    // ⭐ NEW REVIEW
    // ==========================================================

      case 'new_review':
        navigator.pushNamed(
          RouteNames.ownerReviews,
          arguments: data,
        );
        return;

    // ==========================================================
    // 🔔 DEFAULT
    // ==========================================================

      default:
        navigator.pushNamed(
          RouteNames.ownerNotifications,
          arguments: data,
        );
        return;
    }
  }

  // ============================================================
  // PLAYER NOTIFICATION
  // ============================================================

  static void _navigatePlayerNotification(
      NavigatorState navigator,
      Map<String, dynamic> data,
      ) {
    final type =
    data['type']?.toString();

    final bookingId =
    data['bookingId']?.toString();

    final teamId =
    data['teamId']?.toString();

    debugPrint(
      '👤 [FCM] PLAYER notification type: $type',
    );

    debugPrint(
      '🎯 [FCM] Booking ID: $bookingId',
    );

    debugPrint(
      '🎯 [FCM] Team ID: $teamId',
    );

    // ==========================================================
    // TEAM CHAT
    // ==========================================================

    if (type == 'team_chat' &&
        teamId != null &&
        teamId.isNotEmpty) {
      navigator.pushNamed(
        '/team-chat',
        arguments:
        int.tryParse(teamId),
      );

      return;
    }

    // ==========================================================
    // PLAYER BOOKING NOTIFICATION
    // ==========================================================

    if (bookingId != null &&
        bookingId.isNotEmpty) {
      navigator.pushNamed(
        RouteNames.bookingDetails,
        arguments: bookingId,
      );

      return;
    }

    // ==========================================================
    // BOOKING STATUS
    // ==========================================================

    if (type == 'booking_confirmed' ||
        type == 'booking_rejected') {
      navigator.pushNamed(
        RouteNames.myBookings,
      );

      return;
    }

    // ==========================================================
    // DEFAULT PLAYER NOTIFICATION
    // ==========================================================

    navigator.pushNamed(
      RouteNames.notifications,
    );
  }

  // ============================================================
  // PENDING NOTIFICATION
  // ============================================================

  static void _tryHandlePendingNotification() {
    if (_pendingNotificationData ==
        null) {
      return;
    }

    final navigator =
        navigatorKey.currentState;

    final context =
        navigatorKey.currentContext;

    if (navigator == null ||
        context == null) {
      _retryPendingNotification();

      return;
    }

    final authController =
    context.read<AuthController>();

    final role =
    authController.role
        ?.toString()
        .trim()
        .toLowerCase();

    if (role == null ||
        role.isEmpty) {
      _retryPendingNotification();

      return;
    }

    final data =
    _pendingNotificationData!;

    _pendingNotificationData = null;

    _navigateByUserRole(data);
  }

  // ============================================================
  // RETRY PENDING NOTIFICATION
  // ============================================================

  static void _retryPendingNotification() {
    Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
          () {
        if (_pendingNotificationData !=
            null) {
          _tryHandlePendingNotification();
        }
      },
    );
  }
}
