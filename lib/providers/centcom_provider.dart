// ── CENTCOM Briefing Provider ────────────────────────────────────
// Real-time CENTCOM press releases, news, and statements.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/centcom_briefing.dart';
import '../services/centcom_service.dart';
import '../config/api.dart';

// ── State ────────────────────────────────────────────────────────

class CentcomState {
  final List<CentcomBriefing> briefings;
  final bool isLoading;
  final String? error;
  final DateTime? lastRefresh;

  const CentcomState({
    this.briefings = const [],
    this.isLoading = false,
    this.error,
    this.lastRefresh,
  });

  CentcomState copyWith({
    List<CentcomBriefing>? briefings,
    bool? isLoading,
    String? error,
    DateTime? lastRefresh,
  }) {
    return CentcomState(
      briefings: briefings ?? this.briefings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastRefresh: lastRefresh ?? this.lastRefresh,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────

class CentcomNotifier extends StateNotifier<CentcomState> {
  CentcomNotifier() : super(const CentcomState()) {
    _init();
  }

  Timer? _pollTimer;
  final _service = CentcomService.instance;

  void _init() {
    refresh();
    _pollTimer = Timer.periodic(PollIntervals.centcom, (_) => refresh());
  }

  Future<void> refresh() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final briefings = await _service.fetchBriefings();
      if (!mounted) return;
      state = CentcomState(
        briefings: briefings,
        isLoading: false,
        lastRefresh: DateTime.now(),
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

// ── Provider ─────────────────────────────────────────────────────

final centcomProvider =
    StateNotifierProvider<CentcomNotifier, CentcomState>((ref) {
  return CentcomNotifier();
});
