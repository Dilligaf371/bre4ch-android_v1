// ── Event Feed Provider ──────────────────────────────────────────
// WebSocket-first with HTTP polling fallback.
// WS: subscribes to 'event' + 'headlines' channels.
// HTTP: polls HeadlinesService + LiveUAMap when WS is disconnected.

import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attack_event.dart';
import '../services/headlines_service.dart';
import '../services/liveuamap_service.dart';
import '../services/breach_socket_service.dart';
import '../config/api.dart';

// ── Source URL mapping ───────────────────────────────────────────

const Map<String, Map<String, String>> _sourceUrls = {
  'CENTCOM':    {'name': 'CENTCOM',    'url': 'https://www.centcom.mil'},
  'Reuters':    {'name': 'Reuters',    'url': 'https://www.reuters.com/world/middle-east/'},
  'Al Jazeera': {'name': 'Al Jazeera', 'url': 'https://www.aljazeera.com/tag/iran/'},
  'AP':         {'name': 'AP News',    'url': 'https://apnews.com/hub/iran'},
  'IDF':        {'name': 'IDF',        'url': 'https://www.idf.il'},
  'DoD':        {'name': 'DoD',        'url': 'https://www.defense.gov'},
  'BBC':        {'name': 'BBC',        'url': 'https://www.bbc.com/news/world/middle_east'},
};

// ── Conflict keyword filter ──────────────────────────────────────

const List<String> _conflictKeywords = [
  'iran', 'israel', 'military', 'strike', 'missile', 'kill', 'attack', 'war',
  'drone', 'bomb', 'nuclear', 'hezbollah', 'gaza', 'gulf', 'navy', 'air force',
  'centcom', 'intercept', 'defense', 'defence', 'houthi', 'yemen', 'lebanon',
];

final _rng = Random();

String _randomId(String prefix) {
  final ts = DateTime.now().millisecondsSinceEpoch;
  final r = _rng.nextInt(0xFFFF).toRadixString(36);
  return '$prefix-$ts-$r';
}

// ── Convert live headline to AttackEvent ─────────────────────────

AttackEvent _liveHeadlineToEvent(Map<String, dynamic> h) {
  final title = h['title'] as String? ?? '';
  final src = h['source'] as String? ?? '';
  final pubDate = h['pubDate'] as String? ?? '';
  final link = h['link'] as String? ?? '';

  final lower = title.toLowerCase();

  AttackType type = AttackType.cruise;
  if (lower.contains('drone') || lower.contains('uav')) {
    type = AttackType.drone;
  } else if (lower.contains('missile') || lower.contains('ballistic') || lower.contains('rocket')) {
    type = AttackType.ballistic;
  } else if (lower.contains('cyber') || lower.contains('hack')) {
    type = AttackType.cyber;
  } else if (lower.contains('artillery') || lower.contains('shell')) {
    type = AttackType.artillery;
  } else if (lower.contains('sabotage') || lower.contains('explosion')) {
    type = AttackType.sabotage;
  }

  EventStatus status = EventStatus.ongoing;
  if (lower.contains('intercept') || lower.contains('shot down') || lower.contains('defended')) {
    status = EventStatus.intercepted;
  } else if (lower.contains('hit') || lower.contains('struck') || lower.contains('killed') || lower.contains('destroyed')) {
    status = EventStatus.impact;
  } else if (lower.contains('neutraliz')) {
    status = EventStatus.neutralized;
  }

  final srcInfo = _sourceUrls[src] ?? {'name': src, 'url': ''};

  int ts = DateTime.now().millisecondsSinceEpoch;
  if (pubDate.isNotEmpty) {
    final parsed = DateTime.tryParse(pubDate);
    if (parsed != null) ts = parsed.millisecondsSinceEpoch;
  }

  return AttackEvent(
    id: _randomId('live-evt'),
    timestamp: ts,
    type: type,
    origin: src,
    target: 'Iran Theater',
    status: status,
    details: title,
    source: srcInfo['name'],
    sourceUrl: link.isNotEmpty ? link : srcInfo['url'],
  );
}

// ── Convert LiveUAMap event to AttackEvent ───────────────────────

AttackEvent _liveuamapToEvent(Map<String, dynamic> e) {
  final name = e['name'] as String? ?? '';
  final source = e['source'] as String? ?? 'LiveUAMap';
  final url = e['url'] as String? ?? '';
  final time = e['time'] as int? ?? 0;

  final lower = name.toLowerCase();
  AttackType type = AttackType.cruise;
  if (lower.contains('drone') || lower.contains('uav')) type = AttackType.drone;
  else if (lower.contains('missile') || lower.contains('ballistic')) type = AttackType.ballistic;
  else if (lower.contains('cyber')) type = AttackType.cyber;
  else if (lower.contains('artillery') || lower.contains('rocket')) type = AttackType.artillery;

  EventStatus status = EventStatus.ongoing;
  if (lower.contains('intercept')) status = EventStatus.intercepted;
  else if (lower.contains('hit') || lower.contains('struck') || lower.contains('kill')) status = EventStatus.impact;

  return AttackEvent(
    id: _randomId('uamap'),
    timestamp: time > 0 ? time * 1000 : DateTime.now().millisecondsSinceEpoch,
    type: type,
    origin: source,
    target: e['region'] as String? ?? 'Middle East',
    status: status,
    details: name,
    source: 'LiveUAMap',
    sourceUrl: url,
  );
}

// ── StateNotifier ────────────────────────────────────────────────

class EventFeedNotifier extends StateNotifier<List<AttackEvent>> {
  EventFeedNotifier(this._ref, {this.maxEvents = 50}) : super([]) {
    _init();
  }

  final Ref _ref;
  final int maxEvents;
  Timer? _headlineTimer;
  Timer? _liveuamapTimer;
  final Set<String> _injected = {};
  final Set<String> _seenIds = {};

  StreamSubscription? _wsSub;
  StreamSubscription? _wsHeadlinesSub;
  StreamSubscription? _wsInitSub;
  StreamSubscription? _wsConnSub;
  bool _wsActive = false;

  void _init() {
    final ws = BreachSocketService.instance;

    // ── Subscribe to WS init (seed) ─────────────────────────────
    _wsInitSub = ws.channel(WsMessageType.init).listen((data) {
      if (!mounted) return;
      final json = data as Map<String, dynamic>;
      final events = json['events'] as List<dynamic>?;
      if (events == null || events.isEmpty) return;

      final parsed = events
          .map((e) => AttackEvent.fromJson(e as Map<String, dynamic>))
          .where((e) => _seenIds.add(e.id))
          .toList();
      if (parsed.isEmpty) return;

      state = parsed.take(maxEvents).toList();
    });

    // ── Subscribe to WS live events ─────────────────────────────
    _wsSub = ws.channel(WsMessageType.event).listen((data) {
      if (!mounted) return;
      try {
        final evt = AttackEvent.fromJson(data as Map<String, dynamic>);
        if (!_seenIds.add(evt.id)) return; // dedupe
        final merged = [evt, ...state];
        state = merged.take(maxEvents).toList();
      } catch (_) {}
    });

    // ── Subscribe to WS headlines (real RSS pushed by server) ───
    _wsHeadlinesSub = ws.channel(WsMessageType.headlines).listen((data) {
      if (!mounted) return;
      _processHeadlines(data as List<dynamic>);
    });

    // ── Connection state: toggle HTTP polling fallback ──────────
    _wsConnSub = ws.connectionStream.listen((connected) {
      _wsActive = connected;
      if (connected) {
        // WS connected — stop HTTP polling
        _headlineTimer?.cancel();
        _headlineTimer = null;
        _liveuamapTimer?.cancel();
        _liveuamapTimer = null;
      } else {
        // WS disconnected — start HTTP polling fallback
        _startHttpPolling();
      }
    });

    // If WS not connected yet, start HTTP polling immediately
    if (!ws.connected) {
      _startHttpPolling();
    }
  }

  // ── HTTP Polling (fallback) ───────────────────────────────────

  void _startHttpPolling() {
    _fetchLiveEvents();
    _fetchLiveuamapEvents();

    _headlineTimer ??= Timer.periodic(
      const Duration(seconds: 30),
      (_) => _fetchLiveEvents(),
    );

    _liveuamapTimer ??= Timer.periodic(
      PollIntervals.liveuamap,
      (_) => _fetchLiveuamapEvents(),
    );
  }

  void _processHeadlines(List<dynamic> headlines) {
    final relevant = headlines.where((h) {
      final map = h as Map<String, dynamic>;
      final l = (map['title'] as String? ?? '').toLowerCase();
      return _conflictKeywords.any((kw) => l.contains(kw));
    }).toList();

    final newOnes = relevant.where((h) {
      final title = (h as Map<String, dynamic>)['title'] as String? ?? '';
      return title.isNotEmpty && !_injected.contains(title);
    }).toList();
    if (newOnes.isEmpty) return;

    final events = newOnes.map((h) => _liveHeadlineToEvent(h as Map<String, dynamic>)).toList();
    for (final e in events) {
      _injected.add(e.details);
    }

    final merged = [...events, ...state];
    merged.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = merged.take(maxEvents).toList();
  }

  Future<void> _fetchLiveEvents() async {
    try {
      final headlines = await HeadlinesService.instance.fetchHeadlines();
      if (headlines.isEmpty || !mounted) return;

      final relevant = headlines.where((h) {
        final l = (h['title'] as String? ?? '').toLowerCase();
        return _conflictKeywords.any((kw) => l.contains(kw));
      }).toList();

      final newOnes = relevant.where((h) {
        final title = h['title'] as String? ?? '';
        return title.isNotEmpty && !_injected.contains(title);
      }).toList();
      if (newOnes.isEmpty) return;

      final events = newOnes.map(_liveHeadlineToEvent).toList();
      for (final e in events) {
        _injected.add(e.details);
      }

      final merged = [...events, ...state];
      merged.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      state = merged.take(maxEvents).toList();
    } catch (_) {}
  }

  Future<void> _fetchLiveuamapEvents() async {
    try {
      final events = await LiveuamapService.instance.fetchEvents();
      if (events.isEmpty || !mounted) return;

      final newOnes = events.where((e) {
        final name = e['name'] as String? ?? '';
        return name.isNotEmpty && !_injected.contains(name);
      }).toList();
      if (newOnes.isEmpty) return;

      final attackEvents = newOnes.map(_liveuamapToEvent).toList();
      for (final e in attackEvents) {
        _injected.add(e.details);
      }

      final merged = [...attackEvents, ...state];
      merged.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      state = merged.take(maxEvents).toList();
    } catch (_) {}
  }

  @override
  void dispose() {
    _headlineTimer?.cancel();
    _liveuamapTimer?.cancel();
    _wsSub?.cancel();
    _wsHeadlinesSub?.cancel();
    _wsInitSub?.cancel();
    _wsConnSub?.cancel();
    super.dispose();
  }
}

// ── Provider ─────────────────────────────────────────────────────

final eventFeedProvider =
    StateNotifierProvider<EventFeedNotifier, List<AttackEvent>>((ref) {
  return EventFeedNotifier(ref);
});
