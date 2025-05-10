import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/api_service.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState>? navigatorKey;
  final ApiService _apiService = ApiService();

  FirebaseMessagingService({this.navigatorKey});

  Future<void> initialize() async {
    try {
      // Request permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        String? token = await _messaging.getToken();
        if (token != null) {
          await _saveFcmToken(token);
        }

        // Handle messages when app is terminated
        FirebaseMessaging.instance.getInitialMessage().then(
          (message) {
            if (message != null) {
              _handleMessage(message);
            }
          },
        );

        // Handle messages in background
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Set up background message handler
        FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

        // Handle token refresh
        _messaging.onTokenRefresh.listen((String token) {
          _saveFcmToken(token);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Messaging initialization error: $e');
      }
    }
  }

  Future<void> _saveFcmToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      
      final userId = prefs.getInt('user_id');
      if (userId != null) {
        await _apiService.updateFcmToken(userId, token);
      }
      
      if (kDebugMode) {
        print('FCM Token sauvegardé: $token');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur sauvegarde FCM token: $e');
      }
    }
  }

  void _handleMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Handling message: ${message.messageId}');
      print('Data: ${message.data}');
    }

    if (navigatorKey?.currentState != null) {
      // Example: Navigate based on the notification data
      if (message.data['screen'] != null) {
        navigatorKey!.currentState!.pushNamed(
          '/${message.data['screen']}',
          arguments: message.data,
        );
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Received foreground message:');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    if (navigatorKey?.currentContext != null) {
      Flushbar(
        title: message.notification?.title,
        message: message.notification?.body,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: Colors.blue,
        onTap: (_) {
          if (message.data['screen'] != null) {
            navigatorKey!.currentState!.pushNamed(
              '/${message.data['screen']}',
              arguments: message.data,
            );
          }
        },
      ).show(navigatorKey!.currentContext!);
    }
  }
}

@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
  }
}
