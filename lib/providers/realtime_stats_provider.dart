// ── Realtime Stats Provider ──────────────────────────────────────
// WebSocket-first: subscribes to 'stats' channel for server-authoritative data.
// Falls back to local derivation from event feed when WS is disconnected.

import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attack_stats.dart';
import '../models/attack_event.dart';
import '../services/stats_service.dart';
import '../services/breach_socket_service.dart';
import 'event_feed_provider.dart';

// =============================================================================
// Hardcoded fallback baseline (used when backend is unreachable)
// =============================================================================

const AttackStats _fallbackBaseline = AttackStats(
  total: 1500,
  ballistic: 400,
  drone: 900,
  cyber: 0,
  artillery: 200,
  cruise: 2,
  sabotage: 0,
  intercepted: 1200,
  last24h: 400,
  sorties: 800,
  targetsDamaged: 8,
  targetsNeutralized: 1,
);

// ── State class ──────────────────────────────────────────────────

class RealtimeStatsState {
  final AttackStats stats;
  final List<StatsHistory> history;
  final double interceptRate;
  final int liveEventCount;
  final bool backendConnected;

  const RealtimeStatsState({
    required this.stats,
    required this.history,
    required this.interceptRate,
    this.liveEventCount = 0,
    this.backendConnected = false,
  });
}

// ── StateNotifier ────────────────────────────────────────────────

class RealtimeStatsNotifier extends StateNotifier<RealtimeStatsState> {
  RealtimeStatsNotifier(this._ref)
      : super(const RealtimeStatsState(
          stats: _fallbackBaseline,
          history: [],
          interceptRate: 0,
        )) {
    _init();
  }

  final Ref _ref;
  Timer? _timer;
  AttackStats _baseline = _fallbackBaseline;

  StreamSubscription? _wsInitSub;
  StreamSubscription? _wsStatsSub;
  StreamSubscription? _wsConnSub;
  bool _wsActive = false;

  void _init() {
    final ws = BreachSocketService.instance;

    // ── WS init (seed stats + history) ──────────────────────────
    _wsInitSub = ws.channel(WsMessageType.init).listen((data) {
      if (!mounted) return;
      final json = data as Map<String, dynamic>;
      _applyWsStats(json);
    });

    // ── WS live stats updates ───────────────────────────────────
    _wsStatsSub = ws.channel(WsMessageType.stats).listen((data) {
      if (!mounted) return;
      _applyWsStats(data as Map<String, dynamic>);
    });

    // ── Connection state ────────────────────────────────────────
    _wsConnSub = ws.connectionStream.listen((connected) {
      _wsActive = connected;
      if (connected) {
        // WS connected — stop local derivation timer
        _timer?.cancel();
        _timer = null;
      } else {
        // WS disconnected — fall back to local derivation
        _startLocalDerivation();
      }
    });

    // ── Initial setup ───────────────────────────────────────────
    _fetchBaseline().then((_) => _seedHistory());

    if (!ws.connected) {
      _startLocalDerivation();
    }
  }

  void _applyWsStats(Map<String, dynamic> json) {
    try {
      final statsJson = json['stats'] as Map<String, dynamic>?;
      if (statsJson == null) return;

      final stats = AttackStats.fromJson(statsJson);
      final historyJson = json['history'] as List<dynamic>?;
      final interceptRate = (json['interceptRate'] as num?)?.toDouble() ?? state.interceptRate;

      List<StatsHistory> history = state.history;
      if (historyJson != null && historyJson.isNotEmpty) {
        history = historyJson.map((h) => StatsHistory.fromJson(h as Map<String, dynamic>)).toList();
      } else {
        // Append new sparkline point
        final newEntry = StatsHistory(
          timestamp: DateTime.now().millisecondsSinceEpoch,
          total: stats.total,
          intercepted: stats.intercepted,
        );
        history = [...state.history, newEntry];
        if (history.length > 30) history = history.sublist(history.length - 30);
      }

      state = RealtimeStatsState(
        stats: stats,
        history: history,
        interceptRate: interceptRate,
        liveEventCount: state.liveEventCount,
        backendConnected: true,
      );
    } catch (_) {}
  }

  void _startLocalDerivation() {
    _timer ??= Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _wsActive) return;
      _updateFromLiveEvents();
    });
  }

  Future<void> _fetchBaseline() async {
    final remote = await StatsService.instance.fetchBaseline();
    if (remote != null && mounted) {
      _baseline = remote;
      state = RealtimeStatsState(
        stats: _baseline,
        history: state.history,
        interceptRate: state.interceptRate,
        liveEventCount: state.liveEventCount,
        backendConnected: true,
      );
    }
  }

  void _seedHistory() {
    final synth = <StatsHistory>[];
    final now = DateTime.now().millisecondsSinceEpoch;
    for (int i = 29; i >= 0; i--) {
      final jitter = (sin(i * 0.5) * 3).round();
      synth.add(StatsHistory(
        timestamp: now - i * 4000,
        total: _baseline.total + jitter,
        intercepted: _baseline.intercepted + (jitter * 0.8).round(),
      ));
    }

    final rate = _baseline.total > 0
        ? (_baseline.intercepted / _baseline.total * 100 * 10).round() / 10.0
        : 0.0;

    state = RealtimeStatsState(
      stats: _baseline,
      history: synth,
      interceptRate: rate,
      backendConnected: state.backendConnected,
    );
  }

  void _updateFromLiveEvents() {
    final events = _ref.read(eventFeedProvider);
    final now = DateTime.now().millisecondsSinceEpoch;

    int liveBallistic = 0, liveDrone = 0, liveCyber = 0, liveArtillery = 0;
    int liveCruise = 0, liveSabotage = 0;
    int liveIntercepted = 0;
    int liveLast24h = 0;
    final cutoff24h = now - 24 * 60 * 60 * 1000;

    for (final e in events) {
      switch (e.type) {
        case AttackType.ballistic: liveBallistic++; break;
        case AttackType.drone: liveDrone++; break;
        case AttackType.cyber: liveCyber++; break;
        case AttackType.artillery: liveArtillery++; break;
        case AttackType.cruise: liveCruise++; break;
        case AttackType.sabotage: liveSabotage++; break;
      }
      if (e.status == EventStatus.intercepted || e.status == EventStatus.neutralized) {
        liveIntercepted++;
      }
      if (e.timestamp > cutoff24h) liveLast24h++;
    }

    final updatedStats = AttackStats(
      total: _baseline.total + events.length,
      ballistic: _baseline.ballistic + liveBallistic,
      drone: _baseline.drone + liveDrone,
      cyber: _baseline.cyber + liveCyber,
      artillery: _baseline.artillery + liveArtillery,
      cruise: _baseline.cruise + liveCruise,
      sabotage: _baseline.sabotage + liveSabotage,
      intercepted: _baseline.intercepted + liveIntercepted,
      last24h: _baseline.last24h + liveLast24h,
      sorties: _baseline.sorties,
      targetsDamaged: _baseline.targetsDamaged,
      targetsNeutralized: _baseline.targetsNeutralized,
    );

    final newEntry = StatsHistory(
      timestamp: now,
      total: updatedStats.total,
      intercepted: updatedStats.intercepted,
    );

    final newHistory = [...state.history, newEntry];
    final trimmed = newHistory.length > 30
        ? newHistory.sublist(newHistory.length - 30)
        : newHistory;

    final rate = updatedStats.total > 0
        ? (updatedStats.intercepted / updatedStats.total * 100 * 10).round() / 10.0
        : 0.0;

    state = RealtimeStatsState(
      stats: updatedStats,
      history: trimmed,
      interceptRate: rate,
      liveEventCount: events.length,
      backendConnected: state.backendConnected,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _wsInitSub?.cancel();
    _wsStatsSub?.cancel();
    _wsConnSub?.cancel();
    super.dispose();
  }
}

final realtimeStatsProvider =
    StateNotifierProvider<RealtimeStatsNotifier, RealtimeStatsState>((ref) {
  return RealtimeStatsNotifier(ref);
});
