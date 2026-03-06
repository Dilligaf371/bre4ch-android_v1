// ── BRE4CH WebSocket Service ─────────────────────────────────────
// Single persistent WebSocket connection to the backend.
// Auto-reconnect with exponential backoff (1s → 30s max).
// Broadcasts typed messages via per-channel streams.

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/api.dart';

/// Message types the server can send.
enum WsMessageType {
  init,
  event,
  osint,
  socmint,
  stats,
  headlines,
  detection,
  ping,
}

/// A parsed WebSocket message.
class WsMessage {
  final WsMessageType type;
  final dynamic data;

  const WsMessage(this.type, this.data);
}

/// Singleton WebSocket manager.
class BreachSocketService {
  BreachSocketService._();
  static final instance = BreachSocketService._();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  int _retryCount = 0;
  static const int _maxRetryDelay = 30; // seconds

  bool _disposed = false;
  bool _connected = false;

  bool get connected => _connected;

  // ── Per-channel broadcast controllers ──────────────────────────
  final _controllers = <WsMessageType, StreamController<dynamic>>{};
  final _connectedController = StreamController<bool>.broadcast();

  /// Stream that emits true/false when connection state changes.
  Stream<bool> get connectionStream => _connectedController.stream;

  /// Get a broadcast stream for a specific message type.
  Stream<dynamic> channel(WsMessageType type) {
    _controllers.putIfAbsent(type, () => StreamController<dynamic>.broadcast());
    return _controllers[type]!.stream;
  }

  // ── Last init snapshot (for late subscribers) ─────────────────
  Map<String, dynamic>? _lastInit;
  Map<String, dynamic>? get lastInit => _lastInit;

  // ── Connect ───────────────────────────────────────────────────

  void connect() {
    if (_disposed) return;
    _doConnect();
  }

  void _doConnect() {
    _cleanup();

    final url = Api.ws;

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: (error) {
          _setConnected(false);
          _scheduleReconnect();
        },
        onDone: () {
          _setConnected(false);
          _scheduleReconnect();
        },
        cancelOnError: false,
      );
    } catch (_) {
      _setConnected(false);
      _scheduleReconnect();
    }
  }

  // ── Message handling ──────────────────────────────────────────

  void _onMessage(dynamic raw) {
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      final typeName = json['type'] as String? ?? '';

      final type = _parseType(typeName);
      if (type == null) return;

      // Connection confirmed on first message
      if (!_connected) {
        _setConnected(true);
        _retryCount = 0;
      }

      if (type == WsMessageType.ping) {
        // Respond with pong
        _send({'type': 'pong'});
        return;
      }

      if (type == WsMessageType.init) {
        _lastInit = json;
        _emit(WsMessageType.init, json);
        return;
      }

      // All other types: emit data payload
      _emit(type, json['data']);
    } catch (_) {
      // Malformed message — ignore
    }
  }

  WsMessageType? _parseType(String name) {
    switch (name) {
      case 'init':      return WsMessageType.init;
      case 'event':     return WsMessageType.event;
      case 'osint':     return WsMessageType.osint;
      case 'socmint':   return WsMessageType.socmint;
      case 'stats':     return WsMessageType.stats;
      case 'headlines': return WsMessageType.headlines;
      case 'detection': return WsMessageType.detection;
      case 'ping':      return WsMessageType.ping;
      default:          return null;
    }
  }

  void _emit(WsMessageType type, dynamic data) {
    final ctrl = _controllers[type];
    if (ctrl != null && !ctrl.isClosed) {
      ctrl.add(data);
    }
  }

  void _send(Map<String, dynamic> msg) {
    try {
      _channel?.sink.add(jsonEncode(msg));
    } catch (_) {}
  }

  // ── Connection state ──────────────────────────────────────────

  void _setConnected(bool value) {
    if (_connected == value) return;
    _connected = value;
    if (!_connectedController.isClosed) {
      _connectedController.add(value);
    }
  }

  // ── Reconnection ──────────────────────────────────────────────

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();

    final delay = min(pow(2, _retryCount).toInt(), _maxRetryDelay);
    _retryCount++;

    _reconnectTimer = Timer(Duration(seconds: delay), () {
      if (!_disposed) _doConnect();
    });
  }

  // ── Cleanup ───────────────────────────────────────────────────

  void _cleanup() {
    _subscription?.cancel();
    _subscription = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  /// Permanently close the connection and all streams.
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _cleanup();
    _setConnected(false);
    _connectedController.close();
    for (final ctrl in _controllers.values) {
      ctrl.close();
    }
    _controllers.clear();
  }
}
