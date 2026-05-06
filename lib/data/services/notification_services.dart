import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../presentation/screens/main_screen.dart';
import 'auth_service.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    final settings = await _messaging.requestPermission();

    print("PERMISSION: ${settings.authorizationStatus}");

    // ✅ Get initial token + send to API
    String? token = await _messaging.getToken();

    if (token == null) {
      print("FCM TOKEN IS NULL ❌");
    }
    print("========== FCM TOKEN ==========");
    print(token);
    print("================================");

    if (token != null) {
      await AuthService().saveFcmToken(token);
    }

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important notifications',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // ✅ Listen for token refresh (VERY IMPORTANT)
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint("FCM REFRESH TOKEN: $newToken");
      await AuthService().saveFcmToken(newToken);
    });

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
      const InitializationSettings(android: android),
    );

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint("🔥 onMessage TRIGGERED");
      debugPrint("Title: ${message.notification?.title}");
      debugPrint("Body: ${message.notification?.body}");
      debugPrint("Data: ${message.data}");
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNavigation(message);
    });

    RemoteMessage? initialMessage = await _messaging.getInitialMessage();

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

    int _notificationId = 0;

    await _localNotifications.show(
      _notificationId++,
      message.notification?.title ?? message.data['title'],
      message.notification?.body ?? message.data['body'],
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
