import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin
  _localNotifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await _initLocalNotification();
    await _requestPermission();
    await _generateFcmToken();
    _setupForegroundListener();
    await _setupNotificationClickHandling();
  }

  /// On-demand FCM token retrieval for auth flows.
  ///
  /// The init() pipeline above generates the token once at app start, but
  /// auth requests (OTP login, social login) need to attach it to the
  /// backend call at the moment of sign-in — so they call this method
  /// to grab the current token. Returns null if Firebase isn't ready or
  /// the device hasn't granted notification permission.
  static Future<String?> getFcmToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint("🔥 FCM token fetch failed: $e");
      return null;
    }
  }

  static Future<void> _requestPermission() async {
    NotificationSettings settings =
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint(
      "NOTIFICATION PERMISSION: ${settings.authorizationStatus}",
    );
  }

  static Future<void> _generateFcmToken() async {
    try {
      /// iOS only
      if (Platform.isIOS) {
        String? apnsToken =
        await _messaging.getAPNSToken();

        debugPrint(
          "APNS TOKEN: $apnsToken",
        );
      }

      /// FCM Token
      String? fcmToken =
      await _messaging.getToken();

      debugPrint(
          "====================================");
      debugPrint(
          "🔥 FCM TOKEN GENERATED SUCCESS");
      debugPrint(
          "FCM TOKEN: $fcmToken");
      debugPrint(
          "====================================");

      if (fcmToken == null ||
          fcmToken.isEmpty) {
        debugPrint(
          "FCM TOKEN IS NULL ❌",
        );
        return;
      }

      FirebaseMessaging.instance
          .onTokenRefresh
          .listen((newToken) {
        debugPrint(
            "🔄 NEW REFRESHED FCM TOKEN:");
        debugPrint(newToken);
      });
    } catch (e) {
      debugPrint(
        "FCM TOKEN ERROR: $e",
      );
    }
  }

  static Future<void>
  _initLocalNotification() async {
    const AndroidInitializationSettings
    androidSettings =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const DarwinInitializationSettings
    iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings
    settings =
    InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse:
          (details) {
        debugPrint(
          "LOCAL NOTIFICATION CLICKED",
        );
      },
    );

    const AndroidNotificationChannel
    channel =
    AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description:
      'Used for important notifications',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      channel,
    );
  }

  static void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) {
        debugPrint(
            "🔥 FOREGROUND NOTIFICATION RECEIVED");

        debugPrint(
            "TITLE: ${message.notification?.title}");
        debugPrint(
            "BODY: ${message.notification?.body}");
        debugPrint(
            "DATA: ${message.data}");

        _showNotification(message);
      },
    );
  }

  static Future<void> _showNotification(
      RemoteMessage message) async {
    const AndroidNotificationDetails
    androidDetails =
    AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails
    iosDetails =
    DarwinNotificationDetails();

    String title =
        message.notification?.title ??
            message.data['title'] ??
            "No Title";

    String body =
        message.notification?.body ??
            message.data['body'] ??
            "No Body";

    await _localNotifications.show(
      DateTime.now()
          .millisecondsSinceEpoch ~/
          1000,
      title,
      body,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
    );
  }


  static Future<void>
  _setupNotificationClickHandling() async {
    /// Background click
    FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage message) {
      debugPrint(
          "BACKGROUND NOTIFICATION CLICKED");
    });

    /// Terminated click
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance
        .getInitialMessage();

    if (initialMessage != null) {
      debugPrint(
          "TERMINATED STATE NOTIFICATION CLICKED");
    }
  }
}
