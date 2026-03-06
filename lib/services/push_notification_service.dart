// =============================================================================
// BRE4CH - Push Notification Service
// FCM initialization, token management, topic subscriptions
// =============================================================================

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../config/api.dart';
import 'secure_storage_service.dart';

// Top-level background handler (must be top-level, not a class method)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) debugPrint('[FCM] Background message: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  // Lazy init — avoid accessing FirebaseMessaging on web before Firebase.initializeApp()
  FirebaseMessaging? _messagingInstance;
  FirebaseMessaging get _messaging {
    _messagingInstance ??= FirebaseMessaging.instance;
    return _messagingInstance!;
  }
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));
  final _secureStorage = SecureStorageService.instance;
  bool _initialized = false;
  String? _fcmToken;

  // HIGH-04: Token rotation — rotate every 7 days
  static const Duration _tokenRotationInterval = Duration(days: 7);

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

    if (kDebugMode) debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {

      // Get APNs token first (iOS only) — retry if null
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        for (int i = 0; i < 3; i++) {
          try {
            final apnsToken = await _messaging.getAPNSToken()
                .timeout(const Duration(seconds: 8), onTimeout: () => null);
            if (kDebugMode) debugPrint('[FCM] APNs token attempt ${i + 1}: ${apnsToken != null ? "obtained" : "null"}');
            if (apnsToken != null) break;
            if (i < 2) await Future.delayed(const Duration(seconds: 2));
          } catch (e) {
            if (kDebugMode) debugPrint('[FCM] APNs token error: $e');
          }
        }
      }

      // HIGH-04: Check if token needs rotation
      await _ensureValidToken();

      // Register with backend
      if (_fcmToken != null) {
        _registerTokenWithBackend(_fcmToken!);
        // HIGH-01: Store token in encrypted storage
        await _secureStorage.saveFcmToken(_fcmToken!);
      } else {
        if (kDebugMode) debugPrint('[FCM] WARNING: No FCM token after 3 attempts');
      }

      // Token refresh listener (only once)
      if (!_initialized) {
        _messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          if (kDebugMode) debugPrint('[FCM] Token refreshed');
          _registerTokenWithBackend(newToken);
          _secureStorage.saveFcmToken(newToken);
        });
      }

      // Restore saved topic subscriptions
      await _restoreSubscriptions();
    }

    _initialized = true;
  }

  // HIGH-04: Token rotation logic
  Future<void> _ensureValidToken() async {
    final storedToken = await _secureStorage.getFcmToken();
    final tokenTs = await _secureStorage.getFcmTokenTimestamp();

    final needsRotation = storedToken == null ||
        tokenTs == null ||
        DateTime.now().difference(tokenTs) > _tokenRotationInterval;

    if (needsRotation) {
      if (kDebugMode) debugPrint('[FCM] Token rotation required');
      // Delete old token to force new one
      if (storedToken != null) {
        try {
          await _messaging.deleteToken();
          if (kDebugMode) debugPrint('[FCM] Old token deleted for rotation');
        } catch (e) {
          if (kDebugMode) debugPrint('[FCM] Token deletion failed: $e');
        }
      }
    }

    // Get FCM token — retry if null
    if (_fcmToken == null) {
      for (int i = 0; i < 3; i++) {
        try {
          _fcmToken = await _messaging.getToken()
              .timeout(const Duration(seconds: 10), onTimeout: () => null);
          if (kDebugMode) debugPrint('[FCM] Token attempt ${i + 1}: ${_fcmToken != null ? "obtained" : "null"}');
          if (_fcmToken != null) break;
          if (i < 2) await Future.delayed(const Duration(seconds: 2));
        } catch (e) {
          if (kDebugMode) debugPrint('[FCM] Token error: $e');
        }
      }
    }
  }

  // ── Topic Management ──────────────────────────────────────────────

  // Topic naming: breach_{dimension}_{value}
  //   breach_country_uae, breach_city_dubai,
  //   breach_type_danger, breach_severity_extreme

  Future<void> subscribeToTopic(String topic) async {
    final fullTopic = 'breach_$topic';
    await _messaging.subscribeToTopic(fullTopic);
    await _saveSubscription(fullTopic, true);
    if (kDebugMode) debugPrint('[FCM] Subscribed: $fullTopic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    final fullTopic = 'breach_$topic';
    await _messaging.unsubscribeFromTopic(fullTopic);
    await _saveSubscription(fullTopic, false);
    if (kDebugMode) debugPrint('[FCM] Unsubscribed: $fullTopic');
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
    if (kDebugMode) debugPrint('[FCM] Restored ${subs.length} subscriptions');
  }

  // ── Backend Registration ──────────────────────────────────────────

  Future<void> _registerTokenWithBackend(String token) async {
    try {
      await _dio.post(
        '${Api.base}/api/notifications/register',
        data: {
          'token': token,
          'platform': (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) ? 'ios' : 'android',
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] Token registration failed: $e');
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
