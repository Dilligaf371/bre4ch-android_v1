// ── API Configuration ─────────────────────────────────────────────
// Connects to the existing Express backend (port 3002).
// In dev, use your machine's local IP. In production, use the server URL.

class Api {
  Api._();

  static const String base = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://api.bre4ch.com',
  );

  /// WebSocket URL — derived from base, or override via WS_URL env.
  static String get ws {
    const override = String.fromEnvironment('WS_URL', defaultValue: '');
    if (override.isNotEmpty) return override;
    final uri = Uri.parse(base);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final port = uri.hasPort ? uri.port : (uri.scheme == 'https' ? 443 : 3001);
    return '$scheme://${uri.host}:$port/ws';
  }

  // Endpoints
  static String get health => '$base/api/health';
  static String get headlines => '$base/api/sources/headlines';
  static String get sourcesStatus => '$base/api/sources/status';
  static String get sourcesRefresh => '$base/api/sources/refresh';
  static String get liveuamap => '$base/api/liveuamap';
  static String get ultron => '$base/api/ultron';
  static String get c2 => '$base/api/c2';
  static String get centcomBriefings => '$base/api/centcom/briefings';
  static String get airportsStatus => '$base/api/airports/status';
  static String get forcesAxis => '$base/api/forces/axis';
  static String get forcesCoalition => '$base/api/forces/coalition';
  static String get cyber => '$base/api/cyber';
  static String get statsBaseline => '$base/api/stats/baseline';
  static String get notificationsRegister => '$base/api/notifications/register';
  static String get notificationsTest => '$base/api/notifications/test';
  static String get notificationsStatus => '$base/api/notifications/status';
}

// ── Poll Intervals (ms) ──────────────────────────────────────────
class PollIntervals {
  PollIntervals._();

  static const Duration osint = Duration(seconds: 60);
  static const Duration events = Duration(seconds: 60);
  static const Duration socmint = Duration(seconds: 60);
  static const Duration sources = Duration(seconds: 30);
  static const Duration liveuamap = Duration(seconds: 90);
  static const Duration clock = Duration(seconds: 1);
  static const Duration alerts = Duration(seconds: 45);
  static const Duration stats = Duration(seconds: 3);
  static const Duration centcom = Duration(seconds: 60);
  static const Duration airports = Duration(seconds: 90);
}

// ── Cache TTL per endpoint ───────────────────────────────────────
class CacheTtl {
  CacheTtl._();

  static const Duration headlines = Duration(minutes: 5);
  static const Duration alerts = Duration(minutes: 2);
  static const Duration airportsStatus = Duration(minutes: 5);
  static const Duration forces = Duration(minutes: 15);
  static const Duration centcom = Duration(minutes: 10);
  static const Duration liveuamap = Duration(minutes: 5);
  static const Duration sourcesStatus = Duration(minutes: 1);
  static const Duration cyber = Duration(minutes: 10);
  static const Duration stats = Duration(minutes: 5);
  static const Duration defaultTtl = Duration(minutes: 5);
}
