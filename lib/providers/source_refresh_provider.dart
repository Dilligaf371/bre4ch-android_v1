// ── Source Refresh Provider ──────────────────────────────────────
// Ports useSourceRefresh hook — poll status, force refresh, countdown.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/source_status.dart';
import '../services/sources_service.dart';
import '../config/api.dart';

// ── State class ──────────────────────────────────────────────────

class SourceRefreshState {
  final SourceStatus? status;
  final int countdown;
  final String? error;
  final int onlineCount;
  final int totalCount;

  const SourceRefreshState({
    this.status,
    this.countdown = 300,
    this.error,
    this.onlineCount = 0,
    this.totalCount = 0,
  });

  SourceRefreshState copyWith({
    SourceStatus? status,
    int? countdown,
    String? error,
    int? onlineCount,
    int? totalCount,
  }) {
    return SourceRefreshState(
      status: status ?? this.status,
      countdown: countdown ?? this.countdown,
      error: error,
      onlineCount: onlineCount ?? this.onlineCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

// ── StateNotifier ────────────────────────────────────────────────

class SourceRefreshNotifier extends StateNotifier<SourceRefreshState> {
  SourceRefreshNotifier(this._ref)
      : super(const SourceRefreshState()) {
    _init();
  }

  final Ref _ref; // ignore: unused_field — reserved for API integration
  Timer? _pollTimer;
  Timer? _countdownTimer;
  final _service = SourcesService.instance;

  void _init() {
    // Initial fetch
    fetchStatus();

    // Poll every 30s
    _pollTimer = Timer.periodic(
      PollIntervals.sources,
      (_) => fetchStatus(),
    );

    // Countdown ticker (1s)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (state.countdown > 0) {
        state = state.copyWith(countdown: state.countdown - 1);
      }
    });
  }

  Future<void> fetchStatus() async {
    try {
      final data = await _service.fetchStatus();
      if (data.isEmpty || !mounted) return;

      final status = SourceStatus.fromJson(data);
      int countdown = state.countdown;
      if (status.nextRefresh != null) {
        final remaining = ((status.nextRefresh! - DateTime.now().millisecondsSinceEpoch) / 1000)
            .floor()
            .clamp(0, 999999);
        countdown = remaining;
      }

      final onlineCount = status.sources.values.where((s) => s.status == 'ok').length;
      final totalCount = status.sources.length;

      state = SourceRefreshState(
        status: status,
        countdown: countdown,
        error: null,
        onlineCount: onlineCount,
        totalCount: totalCount,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> forceRefresh() async {
    try {
      state = state.copyWith(error: null);
      final data = await _service.forceRefresh();
      if (data.isEmpty || !mounted) return;

      final status = SourceStatus.fromJson(data);
      int countdown = state.countdown;
      if (status.nextRefresh != null) {
        countdown = ((status.nextRefresh! - DateTime.now().millisecondsSinceEpoch) / 1000)
            .floor()
            .clamp(0, 999999);
      }

      final onlineCount = status.sources.values.where((s) => s.status == 'ok').length;
      final totalCount = status.sources.length;

      state = SourceRefreshState(
        status: status,
        countdown: countdown,
        error: null,
        onlineCount: onlineCount,
        totalCount: totalCount,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: 'Refresh failed');
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}

// ── Provider ─────────────────────────────────────────────────────

final sourceRefreshProvider =
    StateNotifierProvider<SourceRefreshNotifier, SourceRefreshState>((ref) {
  return SourceRefreshNotifier(ref);
});
