// =============================================================================
// BRE4CH - Connectivity Provider
// Monitors network connectivity and exposes online/offline state
// =============================================================================

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the device currently has network connectivity.
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>(
  (ref) => ConnectivityNotifier(),
);

class ConnectivityNotifier extends StateNotifier<bool> {
  late final StreamSubscription<List<ConnectivityResult>> _sub;

  ConnectivityNotifier() : super(true) {
    _init();
  }

  Future<void> _init() async {
    // Check current state
    final results = await Connectivity().checkConnectivity();
    state = _isConnected(results);

    // Listen for changes
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      state = _isConnected(results);
    });
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
