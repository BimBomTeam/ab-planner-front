import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:ab_planner/services/notification_service.dart';
// import 'package:ab_planner/firebase_options.dart'; // Using google-services.json for Android

class FCMService {
  /// Initialize Firebase and FCM
  static Future<void> initialize() async {
    if (!kIsWeb &&
        defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      debugPrint(
        '⚠️ FCM not supported on this platform: $defaultTargetPlatform',
      );
      return;
    }

    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      final messaging = FirebaseMessaging.instance;

      // Request permissions
      await _requestPermission(messaging);

      // Get initial token
      final token = await messaging.getToken();
      if (token != null) {
        debugPrint('🔥 FCM Token: $token');
        // We will register this token after user login or if already logged in
      }

      // Listen for token refresh
      messaging.onTokenRefresh.listen((newToken) {
        debugPrint('🔥 FCM Token Refreshed: $newToken');
        _registerToken(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
          '🔔 Foreground Message received: ${message.notification?.title}',
        );
      });
    } catch (e) {
      debugPrint('❌ Error initializing FCM: $e');
    }
  }

  static Future<void> _requestPermission(FirebaseMessaging messaging) async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('🔔 User granted permission: ${settings.authorizationStatus}');
  }

  static Future<void> _registerToken(String token) async {
    try {
      await NotificationService.registerFcmToken(token);
    } catch (e) {
      debugPrint(
        '⚠️ Helper registration check failed (user might not be logged in): $e',
      );
    }
  }

  /// Trigger registration manually (e.g., after login)
  static Future<void> uploadToken() async {
    if (!kIsWeb &&
        defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _registerToken(token);
      }
    } catch (e) {
      debugPrint('❌ Error uploading token: $e');
    }
  }
}
