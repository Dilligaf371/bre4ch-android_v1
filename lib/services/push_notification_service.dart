// =============================================================================
// BRE4CH - Push Notification Service
// FCM initialization, token management, topic subscriptions
// =============================================================================

import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../config/api.dart';

// Top-level background handler (must be top-level, not a class method)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] Background message: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));
  bool _initialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    // Set background handler (only once)
    if (!_initialized) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }

    // Request iOS notification permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {

      // Get APNs token first (iOS only) — retry if null
      if (Platform.isIOS) {
        for (int i = 0; i < 3; i++) {
          try {
            final apnsToken = await _messaging.getAPNSToken()
                .timeout(const Duration(seconds: 8), onTimeout: () => null);
            debugPrint('[FCM] APNs token attempt ${i + 1}: ${apnsToken != null ? "obtained" : "null"}');
            if (apnsToken != null) break;
            if (i < 2) await Future.delayed(const Duration(seconds: 2));
          } catch (e) {
            debugPrint('[FCM] APNs token error: $e');
          }
        }
      }

      // Get FCM token — retry if null
      if (_fcmToken == null) {
        for (int i = 0; i < 3; i++) {
          try {
            _fcmToken = await _messaging.getToken()
                .timeout(const Duration(seconds: 10), onTimeout: () => null);
            debugPrint('[FCM] Token attempt ${i + 1}: ${_fcmToken != null ? "obtained (${_fcmToken!.substring(0, 20)}...)" : "null"}');
            if (_fcmToken != null) break;
            if (i < 2) await Future.delayed(const Duration(seconds: 2));
          } catch (e) {
            debugPrint('[FCM] Token error: $e');
          }
        }
      }

      // Register with backend
      if (_fcmToken != null) {
        _registerTokenWithBackend(_fcmToken!);
      } else {
        debugPrint('[FCM] WARNING: No FCM token after 3 attempts');
      }

      // Token refresh listener (only once)
      if (!_initialized) {
        _messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          debugPrint('[FCM] Token refreshed');
          _registerTokenWithBackend(newToken);
        });
      }

      // Restore saved topic subscriptions
      await _restoreSubscriptions();
    }

    _initialized = true;
  }

  // ── Topic Management ──────────────────────────────────────────────

  // Topic naming: breach_{dimension}_{value}
  //   breach_country_uae, breach_city_dubai,
  //   breach_type_danger, breach_severity_extreme

  Future<void> subscribeToTopic(String topic) async {
    final fullTopic = 'breach_$topic';
    await _messaging.subscribeToTopic(fullTopic);
    await _saveSubscription(fullTopic, true);
    debugPrint('[FCM] Subscribed: $fullTopic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    final fullTopic = 'breach_$topic';
    await _messaging.unsubscribeFromTopic(fullTopic);
    await _saveSubscription(fullTopic, false);
    debugPrint('[FCM] Unsubscribed: $fullTopic');
  }

  Future<void> subscribeToCountry(String code) =>
      subscribeToTopic('country_${code.toLowerCase()}');

  Future<void> unsubscribeFromCountry(String code) =>
      unsubscribeFromTopic('country_${code.toLowerCase()}');

  Future<void> subscribeToCity(String slug) =>
      subscribeToTopic('city_${slug.toLowerCase().replaceAll(' ', '_')}');

  Future<void> unsubscribeFromCity(String slug) =>
      unsubscribeFromTopic('city_${slug.toLowerCase().replaceAll(' ', '_')}');

  Future<void> subscribeToType(String type) =>
      subscribeToTopic('type_${type.toLowerCase()}');

  Future<void> unsubscribeFromType(String type) =>
      unsubscribeFromTopic('type_${type.toLowerCase()}');

  Future<void> subscribeToSeverity(String level) =>
      subscribeToTopic('severity_${level.toLowerCase()}');

  Future<void> unsubscribeFromSeverity(String level) =>
      unsubscribeFromTopic('severity_${level.toLowerCase()}');

  // ── Persistence ───────────────────────────────────────────────────

  Future<void> _saveSubscription(String topic, bool subscribed) async {
    final prefs = await SharedPreferences.getInstance();
    final subs = prefs.getStringList('fcm_subscriptions') ?? [];
    if (subscribed) {
      if (!subs.contains(topic)) subs.add(topic);
    } else {
      subs.remove(topic);
    }
    await prefs.setStringList('fcm_subscriptions', subs);
  }

  Future<Set<String>> getActiveSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('fcm_subscriptions') ?? []).toSet();
  }

  Future<void> _restoreSubscriptions() async {
    final subs = await getActiveSubscriptions();
    for (final topic in subs) {
      await _messaging.subscribeToTopic(topic);
    }
    debugPrint('[FCM] Restored ${subs.length} subscriptions');
  }

  // ── Backend Registration ──────────────────────────────────────────

  Future<void> _registerTokenWithBackend(String token) async {
    try {
      await _dio.post(
        '${Api.base}/api/notifications/register',
        data: {
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
        },
      );
    } catch (e) {
      debugPrint('[FCM] Token registration failed: $e');
    }
  }

  // ── Message Streams ───────────────────────────────────────────────

  Stream<RemoteMessage> get onForegroundMessage =>
      FirebaseMessaging.onMessage;

  Stream<RemoteMessage> get onNotificationTap =>
      FirebaseMessaging.onMessageOpenedApp;

  Future<RemoteMessage?> getInitialMessage() =>
      _messaging.getInitialMessage();
}
