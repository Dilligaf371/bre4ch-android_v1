// ── BRE4CH WebSocket Provider ────────────────────────────────────
// Riverpod provider that initializes and exposes the WebSocket service.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/breach_socket_service.dart';

/// Whether the WebSocket is currently connected.
final wsConnectedProvider = StreamProvider<bool>((ref) {
  final svc = BreachSocketService.instance;
  // Start connection if not already connected
  if (!svc.connected) svc.connect();
  return svc.connectionStream;
});

/// Get a typed stream for a specific WS channel.
/// Usage: ref.listen(wsChannelProvider(WsMessageType.event), ...)
final wsChannelProvider =
    StreamProvider.family<dynamic, WsMessageType>((ref, type) {
  return BreachSocketService.instance.channel(type);
});
