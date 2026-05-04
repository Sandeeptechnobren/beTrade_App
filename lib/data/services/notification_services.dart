import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../presentation/screens/main_screen.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 🔐 Permission
    await _messaging.requestPermission();

    // 📲 Token
    String? token = await _messaging.getToken();
    debugPrint("FCM TOKEN: $token");

    // 🔔 Local notification init
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
      const InitializationSettings(android: android),
    );

    // 📩 Foreground
    FirebaseMessaging.onMessage.listen((message) {
      _showNotification(message);
    });

    // 👉 Click (background)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNavigation(message);
    });

    // 👉 Click (terminated app)
    RemoteMessage? initialMessage =
    await _messaging.getInitialMessage();

    if (initialMessage != null) {
      _handleNavigation(initialMessage);
    }
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _localNotifications.show(
      0,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(android: androidDetails),
    );
  }

  static void _handleNavigation(RemoteMessage message) {
    debugPrint("Notification clicked");

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainScreen(),
      ),
          (route) => false,
    );
  }
}