// ── Liveuamap Provider ───────────────────────────────────────────
// Ports useLiveuamap hook — 90s polling for liveuamap events.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/liveuamap_service.dart';
import '../config/api.dart';

// ── Liveuamap event class ────────────────────────────────────────

class LiveuamapEvent {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String time;
  final String source;
  final String url;
  final String region;

  const LiveuamapEvent({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.time,
    required this.source,
    required this.url,
    required this.region,
  });

  factory LiveuamapEvent.fromJson(Map<String, dynamic> json) {
    return LiveuamapEvent(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      time: json['time']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
    );
  }
}

// ── State class ──────────────────────────────────────────────────

class LiveuamapState {
  final List<LiveuamapEvent> events;
  final bool loading;
  final String? error;
  final int? lastFetch;
  final bool cached;

  const LiveuamapState({
    this.events = const [],
    this.loading = true,
    this.error,
    this.lastFetch,
    this.cached = false,
  });

  LiveuamapState copyWith({
    List<LiveuamapEvent>? events,
    bool? loading,
    String? error,
    int? lastFetch,
    bool? cached,
  }) {
    return LiveuamapState(
      events: events ?? this.events,
      loading: loading ?? this.loading,
      error: error,
      lastFetch: lastFetch ?? this.lastFetch,
      cached: cached ?? this.cached,
    );
  }
}

// ── StateNotifier ────────────────────────────────────────────────

class LiveuamapNotifier extends StateNotifier<LiveuamapState> {
  LiveuamapNotifier(this._ref, {this.region = 'middleeast', this.count = 20})
      : super(const LiveuamapState()) {
    _init();
  }

  final Ref _ref; // ignore: unused_field — reserved for API integration
  final String region;
  final int count;
  Timer? _pollTimer;
  final _service = LiveuamapService.instance;

  void _init() {
    _fetchEvents();
    _pollTimer = Timer.periodic(
      PollIntervals.liveuamap,
      (_) => _fetchEvents(),
    );
  }

  Future<void> _fetchEvents() async {
    try {
      final rawEvents = await _service.fetchEvents(
        region: region,
        count: count,
      );

      if (!mounted) return;

      final events = rawEvents.map(LiveuamapEvent.fromJson).toList();

      state = LiveuamapState(
        events: events,
        loading: false,
        error: null,
        lastFetch: DateTime.now().millisecondsSinceEpoch,
        cached: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

// ── Provider ─────────────────────────────────────────────────────

final liveuamapProvider =
    StateNotifierProvider<LiveuamapNotifier, LiveuamapState>((ref) {
  return LiveuamapNotifier(ref);
});
