// FILE: lib/services/supabase/notification_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
  debugPrint('Handling a background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isFirebaseInitialized = false;

  Future<void> initialize() async {
    try {
      // Attempt Firebase initialization
      await Firebase.initializeApp();
      _isFirebaseInitialized = true;

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;

      // Request notification permissions
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('User granted notification permissions: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Retrieve and sync FCM token
        final token = await messaging.getToken();
        if (token != null) {
          debugPrint('FCM Token: $token');
          await _updateToken(token);
        }

        // Listen for token refresh events
        messaging.onTokenRefresh.listen((newToken) async {
          await _updateToken(newToken);
        });

        // Setup foreground message streams
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Foreground message received: ${message.messageId}');
          debugPrint('Data payload: ${message.data}');
          if (message.notification != null) {
            debugPrint('Notification Details: ${message.notification?.title} - ${message.notification?.body}');
          }
        });

        // Setup notifications click handler when app is opened
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('App opened from notification: ${message.messageId}');
        });
      }
    } catch (e) {
      debugPrint('Firebase/FCM is not initialized/configured: $e');
      debugPrint('FCM NotificationService falling back to simulated stub.');
    }
  }

  Future<void> _updateToken(String token) async {
    try {
      final auth = AuthService();
      if (auth.currentUser != null) {
        await auth.updateFcmToken(token);
      }
    } catch (e) {
      debugPrint('Failed to sync FCM token to profiles: $e');
    }
  }

  Future<String?> getDeviceToken() async {
    if (_isFirebaseInitialized) {
      try {
        return await FirebaseMessaging.instance.getToken();
      } catch (e) {
        debugPrint('Error fetching token: $e');
      }
    }
    return 'mock_device_token_fcm_12345';
  }
}
