// ── SOCMINT Feed Provider ────────────────────────────────────────
// WebSocket-first with HTTP polling fallback.
// WS: subscribes to 'socmint' + 'headlines' channels.
// HTTP: polls HeadlinesService when WS is disconnected.

import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/socmint_item.dart';
import '../services/headlines_service.dart';
import '../services/breach_socket_service.dart';

// ── Source mapping for platforms ─────────────────────────────────

const Map<String, String> _sourceToXAccount = {
  'CENTCOM':    '@CENTCOM',
  'Reuters':    '@Reuters',
  'Al Jazeera': '@AJEnglish',
  'AP':         '@AP',
  'IDF':        '@IDF',
  'DoD':        '@DeptofDefense',
  'BBC':        '@BBCBreaking',
};

const List<String> _osintXAccounts = [
  '@Conflicts', '@IntelCrab', '@sentdefender',
  '@OSINTdefender', '@ELINTNews', '@GeoConfirmed',
  '@AuroraIntel', '@FaytuksNetwork', '@criticalthreats',
  '@RALee85',
];

// ── Severity detection ──────────────────────────────────────────

SocmintSeverity _detectSeverity(String title) {
  final lower = title.toLowerCase();
  if (lower.contains('kill') || lower.contains('strike') || lower.contains('attack') ||
      lower.contains('war') || lower.contains('dead') || lower.contains('breaking')) {
    return SocmintSeverity.critical;
  } else if (lower.contains('iran') || lower.contains('military') ||
      lower.contains('missile') || lower.contains('bomb') || lower.contains('drone')) {
    return SocmintSeverity.high;
  } else if (lower.contains('middle east') || lower.contains('israel') ||
      lower.contains('gaza') || lower.contains('hezbollah') || lower.contains('gulf')) {
    return SocmintSeverity.medium;
  }
  return SocmintSeverity.low;
}

// ── Helpers ──────────────────────────────────────────────────────

final _rng = Random();

String _randomId(String prefix) {
  final ts = DateTime.now().millisecondsSinceEpoch;
  final r = _rng.nextInt(0xFFFF).toRadixString(36);
  return '$prefix-$ts-$r';
}

SocmintItem _headlineToSocmint(Map<String, dynamic> h, double roll) {
  final title = h['title'] as String? ?? '';
  final src = h['source'] as String? ?? '';
  final pubDate = h['pubDate'] as String? ?? '';

  final severity = _detectSeverity(title);

  int ts = DateTime.now().millisecondsSinceEpoch;
  if (pubDate.isNotEmpty) {
    final parsed = DateTime.tryParse(pubDate);
    if (parsed != null) ts = parsed.millisecondsSinceEpoch;
  }

  if (roll < 0.6) {
    final account = _sourceToXAccount[src] ??
        _osintXAccounts[_rng.nextInt(_osintXAccounts.length)];
    return SocmintItem(
      id: _randomId('socm-x'),
      platform: SocmintPlatform.x,
      source: account,
      content: '$title ($src)',
      timestamp: ts,
      severity: severity,
      language: 'EN',
      flagged: severity == SocmintSeverity.critical,
    );
  } else if (roll < 0.9) {
    String channel;
    if (src == 'CENTCOM') channel = 't.me/CentcomOfficial';
    else if (src == 'Al Jazeera') channel = 't.me/AJArabic';
    else if (src == 'Reuters') channel = 't.me/reuters';
    else if (src == 'IDF') channel = 't.me/IDFofficial';
    else channel = 't.me/IranDefenseWatch';

    return SocmintItem(
      id: _randomId('socm-tg'),
      platform: SocmintPlatform.telegram,
      source: channel,
      content: title,
      timestamp: ts,
      severity: severity,
      language: 'EN',
      flagged: severity == SocmintSeverity.critical,
    );
  } else {
    String location = 'Middle East';
    final lower = title.toLowerCase();
    if (lower.contains('dubai') || lower.contains('uae')) location = 'Dubai, UAE';
    else if (lower.contains('tehran')) location = 'Tehran, Iran';
    else if (lower.contains('israel') || lower.contains('tel aviv')) location = 'Tel Aviv, Israel';
    else if (lower.contains('kuwait')) location = 'Kuwait City';
    else if (lower.contains('bahrain')) location = 'Manama, Bahrain';
    else if (lower.contains('doha') || lower.contains('qatar')) location = 'Doha, Qatar';
    else if (lower.contains('beirut') || lower.contains('lebanon')) location = 'Beirut, Lebanon';

    return SocmintItem(
      id: _randomId('socm-snap'),
      platform: SocmintPlatform.snapchat,
      source: 'Snap Map $location',
      content: 'Geolocated $location: $title ($src)',
      timestamp: ts,
      severity: severity,
      language: 'EN',
      location: location,
      flagged: severity == SocmintSeverity.critical,
    );
  }
}

SocmintPlatform _parsePlatform(String name) {
  switch (name) {
    case 'telegram': return SocmintPlatform.telegram;
    case 'snapchat': return SocmintPlatform.snapchat;
    case 'x':        return SocmintPlatform.x;
    default:         return SocmintPlatform.x;
  }
}

SocmintSeverity _parseSeverity(String name) {
  switch (name) {
    case 'critical': return SocmintSeverity.critical;
    case 'high':     return SocmintSeverity.high;
    case 'medium':   return SocmintSeverity.medium;
    default:         return SocmintSeverity.low;
  }
}

SocmintItem _wsToSocmint(Map<String, dynamic> m) {
  return SocmintItem(
    id: m['id'] as String? ?? _randomId('socm'),
    platform: _parsePlatform(m['platform'] as String? ?? 'x'),
    source: m['source'] as String? ?? '',
    content: m['content'] as String? ?? '',
    timestamp: m['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    severity: _parseSeverity(m['severity'] as String? ?? 'low'),
    language: m['language'] as String? ?? 'EN',
    location: m['location'] as String?,
    flagged: m['flagged'] as bool? ?? false,
  );
}

// ── StateNotifier ────────────────────────────────────────────────

class SocmintNotifier extends StateNotifier<List<SocmintItem>> {
  SocmintNotifier(this._ref, {this.maxItems = 50}) : super([]) {
    _init();
  }

  final Ref _ref;
  final int maxItems;
  Timer? _headlineTimer;
  final Set<String> _injected = {};
  final Set<String> _seenIds = {};

  StreamSubscription? _wsInitSub;
  StreamSubscription? _wsSocmintSub;
  StreamSubscription? _wsHeadlinesSub;
  StreamSubscription? _wsConnSub;

  void _init() {
    final ws = BreachSocketService.instance;

    // ── WS init (seed) ──────────────────────────────────────────
    _wsInitSub = ws.channel(WsMessageType.init).listen((data) {
      if (!mounted) return;
      final json = data as Map<String, dynamic>;
      final socmint = json['socmint'] as List<dynamic>?;
      if (socmint == null || socmint.isEmpty) return;

      final parsed = <SocmintItem>[];
      for (final raw in socmint) {
        try {
          final m = raw as Map<String, dynamic>;
          final item = _wsToSocmint(m);
          if (_seenIds.add(item.id)) parsed.add(item);
        } catch (_) {}
      }
      if (parsed.isNotEmpty) state = parsed.take(maxItems).toList();
    });

    // ── WS live socmint ─────────────────────────────────────────
    _wsSocmintSub = ws.channel(WsMessageType.socmint).listen((data) {
      if (!mounted) return;
      try {
        final item = _wsToSocmint(data as Map<String, dynamic>);
        if (!_seenIds.add(item.id)) return;
        state = [item, ...state].take(maxItems).toList();
      } catch (_) {}
    });

    // ── WS headlines (transform to SOCMINT locally) ─────────────
    _wsHeadlinesSub = ws.channel(WsMessageType.headlines).listen((data) {
      if (!mounted) return;
      _processHeadlines(data as List<dynamic>);
    });

    // ── Connection fallback ─────────────────────────────────────
    _wsConnSub = ws.connectionStream.listen((connected) {
      if (connected) {
        _headlineTimer?.cancel();
        _headlineTimer = null;
      } else {
        _startHttpPolling();
      }
    });

    if (!ws.connected) _startHttpPolling();
  }

  void _processHeadlines(List<dynamic> headlines) {
    final newOnes = headlines.where((h) {
      final title = (h as Map<String, dynamic>)['title'] as String? ?? '';
      return title.isNotEmpty && !_injected.contains(title);
    }).toList();
    if (newOnes.isEmpty) return;

    final items = newOnes.map((h) {
      final title = (h as Map<String, dynamic>)['title'] as String? ?? '';
      _injected.add(title);
      return _headlineToSocmint(h, _rng.nextDouble());
    }).toList();

    final merged = [...items, ...state];
    merged.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = merged.take(maxItems).toList();
  }

  void _startHttpPolling() {
    _fetchLiveHeadlines();
    _headlineTimer ??= Timer.periodic(const Duration(seconds: 30), (_) => _fetchLiveHeadlines());
  }

  Future<void> _fetchLiveHeadlines() async {
    try {
      final headlines = await HeadlinesService.instance.fetchHeadlines();
      if (headlines.isEmpty || !mounted) return;
      final newOnes = headlines.where((h) {
        final title = h['title'] as String? ?? '';
        return title.isNotEmpty && !_injected.contains(title);
      }).toList();
      if (newOnes.isEmpty) return;
      final items = newOnes.map((h) {
        final title = h['title'] as String? ?? '';
        _injected.add(title);
        return _headlineToSocmint(h, _rng.nextDouble());
      }).toList();
      final merged = [...items, ...state];
      merged.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      state = merged.take(maxItems).toList();
    } catch (_) {}
  }

  @override
  void dispose() {
    _headlineTimer?.cancel();
    _wsInitSub?.cancel();
    _wsSocmintSub?.cancel();
    _wsHeadlinesSub?.cancel();
    _wsConnSub?.cancel();
    super.dispose();
  }
}

final socmintProvider =
    StateNotifierProvider<SocmintNotifier, List<SocmintItem>>((ref) {
  return SocmintNotifier(ref);
});
