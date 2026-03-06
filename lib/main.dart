import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'services/api_service.dart';
import 'services/cached_tile_provider.dart';
import 'services/push_notification_service.dart';
import 'services/breach_socket_service.dart';

/// Native badge clearing channel
const _badgeChannel = MethodChannel('com.qyber.breach/badge');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize offline cache (non-blocking)
  ApiService.instance.initCache().catchError((e) {
    debugPrint('[CACHE] Init error: $e');
  });

  // Initialize persistent tile cache for maps
  await initTileCache();

  // Initialize push notifications (non-blocking to avoid launch hang)
  PushNotificationService.instance.initialize().catchError((e) {
    debugPrint('[FCM] Init error: $e');
  });

  // Connect WebSocket to backend (non-blocking, auto-reconnect)
  BreachSocketService.instance.connect();

  // Force dark status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF060A10),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Lock to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: BadgeClearer(child: BreachApp())));
}

/// Watches app lifecycle and clears badge on resume / startup
class BadgeClearer extends StatefulWidget {
  final Widget child;
  const BadgeClearer({super.key, required this.child});

  @override
  State<BadgeClearer> createState() => _BadgeClearerState();
}

class _BadgeClearerState extends State<BadgeClearer> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Clear on cold start
    _clearBadge();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _clearBadge();
    }
  }

  Future<void> _clearBadge() async {
    try {
      await _badgeChannel.invokeMethod('clearBadge');
    } catch (e) {
      debugPrint('[Badge] Clear error: $e');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
