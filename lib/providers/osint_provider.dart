// ── OSINT Feed Provider ──────────────────────────────────────────
// WebSocket-first with HTTP polling fallback.
// WS: subscribes to 'osint' + 'headlines' channels.
// HTTP: polls HeadlinesService + CentcomService when WS is disconnected.

import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/osint_item.dart';
import '../services/headlines_service.dart';
import '../services/centcom_service.dart';
import '../services/breach_socket_service.dart';
import '../utils/sanitizer.dart';
import '../config/api.dart';

// ── Source config ────────────────────────────────────────────────

const Map<OsintSource, OsintSourceConfig> sourceConfig = {
  OsintSource.reuters:      OsintSourceConfig(label: 'REUTERS',        colorValue: 0xFFFB923C),
  OsintSource.aljazeera:    OsintSourceConfig(label: 'AL JAZEERA',     colorValue: 0xFFFBBF24),
  OsintSource.dod:          OsintSourceConfig(label: 'DOD.GOV',        colorValue: 0xFF60A5FA),
  OsintSource.idf:          OsintSourceConfig(label: 'IDF.IL',         colorValue: 0xFF22D3EE),
  OsintSource.ap:           OsintSourceConfig(label: 'AP NEWS',        colorValue: 0xFF4ADE80),
  OsintSource.centcom:      OsintSourceConfig(label: 'CENTCOM',        colorValue: 0xFFC084FC),
  OsintSource.flightradar:  OsintSourceConfig(label: 'FR24/SIGINT',    colorValue: 0xFFFB7185),
  OsintSource.bloomberg:    OsintSourceConfig(label: 'BLOOMBERG',      colorValue: 0xFF818CF8),
  OsintSource.khaleejtimes: OsintSourceConfig(label: 'KHALEEJ TIMES',  colorValue: 0xFFE879F9),
  OsintSource.thenational:  OsintSourceConfig(label: 'THE NATIONAL',   colorValue: 0xFF34D399),
  OsintSource.gulfnews:     OsintSourceConfig(label: 'GULF NEWS',      colorValue: 0xFF2DD4BF),
  OsintSource.gulftoday:    OsintSourceConfig(label: 'GULF TODAY',     colorValue: 0xFF67E8F9),
  OsintSource.emirates247:  OsintSourceConfig(label: 'EMIRATES 24|7',  colorValue: 0xFFD946EF),
  OsintSource.arabnews:     OsintSourceConfig(label: 'ARAB NEWS',      colorValue: 0xFFA78BFA),
  OsintSource.saudigazette: OsintSourceConfig(label: 'SAUDI GAZETTE',  colorValue: 0xFF38BDF8),
  OsintSource.gulftimes:      OsintSourceConfig(label: 'GULF TIMES',     colorValue: 0xFF5EEAD4),
  OsintSource.peninsulaQatar: OsintSourceConfig(label: 'THE PENINSULA',  colorValue: 0xFFFDA4AF),
  OsintSource.qatarTribune:   OsintSourceConfig(label: 'QATAR TRIBUNE',  colorValue: 0xFFBAE6FD),
  OsintSource.gulfDailyNews:  OsintSourceConfig(label: 'GULF DAILY NEWS', colorValue: 0xFFFDE68A),
  OsintSource.dailyTribuneBh: OsintSourceConfig(label: 'DAILY TRIBUNE',   colorValue: 0xFFBFDBFE),
  OsintSource.timesOfOman:  OsintSourceConfig(label: 'TIMES OF OMAN',  colorValue: 0xFFFECA57),
  OsintSource.omanObserver: OsintSourceConfig(label: 'OMAN OBSERVER',  colorValue: 0xFFA3E635),
  OsintSource.wam:          OsintSourceConfig(label: 'WAM',            colorValue: 0xFFF87171),
  OsintSource.spa:          OsintSourceConfig(label: 'SPA',            colorValue: 0xFF6EE7B7),
  OsintSource.qna:          OsintSourceConfig(label: 'QNA',            colorValue: 0xFFA5B4FC),
  OsintSource.bna:          OsintSourceConfig(label: 'BNA',            colorValue: 0xFFFCD34D),
  OsintSource.kuna:         OsintSourceConfig(label: 'KUNA',           colorValue: 0xFF86EFAC),
  OsintSource.omanNews:     OsintSourceConfig(label: 'ONA',            colorValue: 0xFFFCA5A5),
  OsintSource.timesOfIsrael: OsintSourceConfig(label: 'TIMES OF ISR',  colorValue: 0xFF93C5FD),
  OsintSource.jpost:         OsintSourceConfig(label: 'JPOST',         colorValue: 0xFF7DD3FC),
};

// ── Source map (RSS name -> OsintSource) ─────────────────────────

const Map<String, OsintSource> sourceMap = {
  'CENTCOM': OsintSource.centcom, 'Reuters': OsintSource.reuters,
  'Al Jazeera': OsintSource.aljazeera, 'Al jazeera': OsintSource.aljazeera,
  'AP': OsintSource.ap, 'IDF': OsintSource.idf, 'DoD': OsintSource.dod,
  'BBC': OsintSource.reuters, 'Bbc': OsintSource.reuters,
  'Bloomberg': OsintSource.bloomberg, 'bloomberg': OsintSource.bloomberg,
  'Khaleej Times': OsintSource.khaleejtimes, 'KhaleejTimes': OsintSource.khaleejtimes, 'khaleejtimes': OsintSource.khaleejtimes,
  'The National': OsintSource.thenational, 'thenational': OsintSource.thenational,
  'Gulf News': OsintSource.gulfnews, 'GulfNews': OsintSource.gulfnews, 'gulfnews': OsintSource.gulfnews,
  'Gulf Today': OsintSource.gulftoday, 'GulfToday': OsintSource.gulftoday, 'gulftoday': OsintSource.gulftoday,
  'Emirates 24|7': OsintSource.emirates247, 'Emirates247': OsintSource.emirates247, 'emirates247': OsintSource.emirates247,
  'Arab News': OsintSource.arabnews, 'ArabNews': OsintSource.arabnews, 'arabnews': OsintSource.arabnews,
  'Saudi Gazette': OsintSource.saudigazette, 'SaudiGazette': OsintSource.saudigazette, 'saudigazette': OsintSource.saudigazette,
  'Gulf Times': OsintSource.gulftimes, 'GulfTimes': OsintSource.gulftimes, 'gulftimes': OsintSource.gulftimes,
  'The Peninsula': OsintSource.peninsulaQatar, 'Peninsula Qatar': OsintSource.peninsulaQatar, 'thepeninsulaqatar': OsintSource.peninsulaQatar,
  'Qatar Tribune': OsintSource.qatarTribune, 'QatarTribune': OsintSource.qatarTribune, 'qatartribune': OsintSource.qatarTribune,
  'Gulf Daily News': OsintSource.gulfDailyNews, 'GulfDailyNews': OsintSource.gulfDailyNews, 'gulfdailynews': OsintSource.gulfDailyNews,
  'Daily Tribune': OsintSource.dailyTribuneBh, 'DailyTribune': OsintSource.dailyTribuneBh, 'dailytribune': OsintSource.dailyTribuneBh,
  'Times of Oman': OsintSource.timesOfOman, 'TimesOfOman': OsintSource.timesOfOman, 'timesofoman': OsintSource.timesOfOman,
  'Oman Observer': OsintSource.omanObserver, 'OmanObserver': OsintSource.omanObserver, 'omanobserver': OsintSource.omanObserver,
  'WAM': OsintSource.wam, 'wam': OsintSource.wam,
  'SPA': OsintSource.spa, 'spa': OsintSource.spa,
  'QNA': OsintSource.qna, 'qna': OsintSource.qna,
  'BNA': OsintSource.bna, 'bna': OsintSource.bna,
  'KUNA': OsintSource.kuna, 'kuna': OsintSource.kuna,
  'Oman News': OsintSource.omanNews, 'ONA': OsintSource.omanNews,
  'Times of Israel': OsintSource.timesOfIsrael, 'timesofisrael': OsintSource.timesOfIsrael,
  'Jerusalem Post': OsintSource.jpost, 'JPost': OsintSource.jpost, 'jpost': OsintSource.jpost,
};

// ── Helpers ──────────────────────────────────────────────────────

final _rng = Random();

String _randomId(String prefix) {
  final ts = DateTime.now().millisecondsSinceEpoch;
  final r = _rng.nextInt(0xFFFF).toRadixString(36);
  return '$prefix-$ts-$r';
}

OsintItem liveHeadlineToOsint(Map<String, dynamic> h) {
  // MED-05: Sanitize RSS content
  final title = sanitizeContent(h['title'] as String? ?? '');
  final link = h['link'] as String? ?? '';
  final pubDate = h['pubDate'] as String? ?? '';
  final src = sanitizeContent(h['source'] as String? ?? '');

  final source = sourceMap[src] ?? OsintSource.reuters;

  final lower = title.toLowerCase();
  OsintPriority priority = OsintPriority.routine;
  if (lower.contains('breaking') || lower.contains('killed') || lower.contains('strike') || lower.contains('attack') || lower.contains('war')) {
    priority = OsintPriority.flash;
  } else if (lower.contains('iran') || lower.contains('military') || lower.contains('missile') || lower.contains('nuclear')) {
    priority = OsintPriority.immediate;
  } else if (lower.contains('middle east') || lower.contains('gulf') || lower.contains('israel') || lower.contains('hezbollah')) {
    priority = OsintPriority.priority;
  }

  String region = 'Middle East';
  if (lower.contains('iran') || lower.contains('tehran')) region = 'Iran';
  else if (lower.contains('israel') || lower.contains('tel aviv')) region = 'Israel';
  else if (lower.contains('uae') || lower.contains('dubai')) region = 'UAE';
  else if (lower.contains('kuwait')) region = 'Kuwait';
  else if (lower.contains('lebanon') || lower.contains('hezbollah')) region = 'Lebanon';
  else if (lower.contains('qatar') || lower.contains('doha')) region = 'Qatar';
  else if (lower.contains('bahrain')) region = 'Bahrain';

  int ts = DateTime.now().millisecondsSinceEpoch;
  if (pubDate.isNotEmpty) {
    final parsed = DateTime.tryParse(pubDate);
    if (parsed != null) ts = parsed.millisecondsSinceEpoch;
  }

  return OsintItem(
    id: _randomId('live'),
    source: source,
    title: title,
    summary: '$src — ${pubDate.isEmpty ? 'just now' : pubDate}',
    timestamp: ts,
    priority: priority,
    region: region,
    url: link,
  );
}

OsintSource _mapOsintSource(String name) {
  final mapped = sourceMap[name];
  if (mapped != null) return mapped;
  final lower = name.toLowerCase();
  if (lower.contains('reuters')) return OsintSource.reuters;
  if (lower.contains('jazeera')) return OsintSource.aljazeera;
  if (lower.contains('centcom') || lower.contains('dod')) return OsintSource.centcom;
  if (lower.contains('idf') || lower.contains('israel')) return OsintSource.idf;
  if (lower.contains('ap')) return OsintSource.ap;
  return OsintSource.reuters;
}

OsintPriority _mapPriority(String name) {
  switch (name) {
    case 'flash': return OsintPriority.flash;
    case 'immediate': return OsintPriority.immediate;
    case 'priority': return OsintPriority.priority;
    default: return OsintPriority.routine;
  }
}

// ── StateNotifier ────────────────────────────────────────────────

class OsintNotifier extends StateNotifier<List<OsintItem>> {
  OsintNotifier(this._ref, {this.maxItems = 50}) : super([]) {
    _init();
  }

  final Ref _ref;
  final int maxItems;
  Timer? _headlineTimer;
  Timer? _centcomTimer;
  final Set<String> _injected = {};
  final Set<String> _seenIds = {};

  StreamSubscription? _wsInitSub;
  StreamSubscription? _wsOsintSub;
  StreamSubscription? _wsHeadlinesSub;
  StreamSubscription? _wsConnSub;

  void _init() {
    final ws = BreachSocketService.instance;

    _wsInitSub = ws.channel(WsMessageType.init).listen((data) {
      if (!mounted) return;
      final json = data as Map<String, dynamic>;
      final osint = json['osint'] as List<dynamic>?;
      if (osint == null || osint.isEmpty) return;

      final parsed = <OsintItem>[];
      for (final raw in osint) {
        try {
          final m = raw as Map<String, dynamic>;
          final id = m['id'] as String? ?? '';
          if (id.isEmpty || !_seenIds.add(id)) continue;
          parsed.add(OsintItem(
            id: id,
            source: _mapOsintSource(m['source'] as String? ?? ''),
            title: m['title'] as String? ?? '',
            summary: m['summary'] as String? ?? '',
            timestamp: m['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
            priority: _mapPriority(m['priority'] as String? ?? 'routine'),
            region: m['region'] as String? ?? 'Middle East',
            url: m['url'] as String?,
          ));
        } catch (_) {}
      }
      if (parsed.isNotEmpty) state = parsed.take(maxItems).toList();
    });

    _wsOsintSub = ws.channel(WsMessageType.osint).listen((data) {
      if (!mounted) return;
      try {
        final m = data as Map<String, dynamic>;
        final id = m['id'] as String? ?? '';
        if (id.isEmpty || !_seenIds.add(id)) return;

        final item = OsintItem(
          id: id,
          source: _mapOsintSource(m['source'] as String? ?? ''),
          title: m['title'] as String? ?? '',
          summary: m['summary'] as String? ?? '',
          timestamp: m['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
          priority: _mapPriority(m['priority'] as String? ?? 'routine'),
          region: m['region'] as String? ?? 'Middle East',
          url: m['url'] as String?,
        );
        state = [item, ...state].take(maxItems).toList();
      } catch (_) {}
    });

    _wsHeadlinesSub = ws.channel(WsMessageType.headlines).listen((data) {
      if (!mounted) return;
      _processHeadlines(data as List<dynamic>);
    });

    _wsConnSub = ws.connectionStream.listen((connected) {
      if (connected) {
        _headlineTimer?.cancel();
        _headlineTimer = null;
        _centcomTimer?.cancel();
        _centcomTimer = null;
      } else {
        _startHttpPolling();
      }
    });

    if (!ws.connected) _startHttpPolling();
  }

  void _processHeadlines(List<dynamic> headlines) {
    final newItems = headlines.where((h) {
      final title = (h as Map<String, dynamic>)['title'] as String? ?? '';
      return title.isNotEmpty && !_injected.contains(title);
    }).toList();
    if (newItems.isEmpty) return;

    final osintItems = newItems.map((h) => liveHeadlineToOsint(h as Map<String, dynamic>)).toList();
    for (final item in osintItems) { _injected.add(item.title); }

    final merged = [...osintItems, ...state];
    merged.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = merged.take(maxItems).toList();
  }

  void _startHttpPolling() {
    _fetchLiveHeadlines();
    _fetchCentcomBriefings();
    _headlineTimer ??= Timer.periodic(const Duration(seconds: 30), (_) => _fetchLiveHeadlines());
    _centcomTimer ??= Timer.periodic(PollIntervals.centcom, (_) => _fetchCentcomBriefings());
  }

  Future<void> _fetchLiveHeadlines() async {
    try {
      final headlines = await HeadlinesService.instance.fetchHeadlines();
      if (headlines.isEmpty || !mounted) return;
      final newItems = headlines.where((h) {
        final title = h['title'] as String? ?? '';
        return title.isNotEmpty && !_injected.contains(title);
      }).toList();
      if (newItems.isEmpty) return;
      final osintItems = newItems.map(liveHeadlineToOsint).toList();
      for (final item in osintItems) { _injected.add(item.title); }
      final merged = [...osintItems, ...state];
      merged.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      state = merged.take(maxItems).toList();
    } catch (_) {}
  }

  Future<void> _fetchCentcomBriefings() async {
    try {
      final briefings = await CentcomService.instance.fetchBriefings();
      if (briefings.isEmpty || !mounted) return;
      final newItems = briefings.where((b) => !_injected.contains(b.title)).toList();
      if (newItems.isEmpty) return;
      final osintItems = newItems.map((b) => OsintItem(
        id: _randomId('centcom'),
        source: OsintSource.centcom,
        title: b.title,
        summary: b.summary.isNotEmpty ? b.summary : 'CENTCOM — ${b.pubDate}',
        timestamp: b.timestamp * 1000,
        priority: b.priority.index <= 1 ? OsintPriority.flash : OsintPriority.priority,
        region: 'CENTCOM AOR',
        url: b.link,
      )).toList();
      for (final item in osintItems) { _injected.add(item.title); }
      final merged = [...osintItems, ...state];
      merged.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      state = merged.take(maxItems).toList();
    } catch (_) {}
  }

  Future<void> refresh() async {
    _injected.clear();
    _seenIds.clear();
    state = [];
    await Future.wait([_fetchLiveHeadlines(), _fetchCentcomBriefings()]);
  }

  @override
  void dispose() {
    _headlineTimer?.cancel();
    _centcomTimer?.cancel();
    _wsInitSub?.cancel();
    _wsOsintSub?.cancel();
    _wsHeadlinesSub?.cancel();
    _wsConnSub?.cancel();
    super.dispose();
  }
}

final osintProvider =
    StateNotifierProvider<OsintNotifier, List<OsintItem>>((ref) {
  return OsintNotifier(ref);
});
