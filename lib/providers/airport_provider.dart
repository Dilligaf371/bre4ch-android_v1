// ── Airport Status Provider ──────────────────────────────────────
// Real-time airport status from backend NOTAM analysis + headline overrides.
// Polls every 90s. Source: FAA DINS NOTAMs + live headlines.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api.dart';
import '../services/api_service.dart';

// ── Airport status model ────────────────────────────────────────

class AirportStatus {
  final String icao;
  final String iata;
  final String name;
  final String country;
  final String status;      // OPEN, RESTRICTED, CLOSED, UNKNOWN
  final String traffic;     // NORMAL, CAUTION, DISRUPTED, DELAYED, SUSPENDED, UNKNOWN
  final int notamCount;
  final String reason;
  final bool headlineOverride;

  const AirportStatus({
    required this.icao,
    required this.iata,
    required this.name,
    required this.country,
    required this.status,
    required this.traffic,
    required this.notamCount,
    required this.reason,
    this.headlineOverride = false,
  });

  factory AirportStatus.fromJson(Map<String, dynamic> json) {
    return AirportStatus(
      icao: json['icao'] as String? ?? '',
      iata: json['iata'] as String? ?? '',
      name: json['name'] as String? ?? '',
      country: json['country'] as String? ?? '',
      status: json['status'] as String? ?? 'UNKNOWN',
      traffic: json['traffic'] as String? ?? 'UNKNOWN',
      notamCount: json['notamCount'] as int? ?? 0,
      reason: json['reason'] as String? ?? '',
      headlineOverride: json['headlineOverride'] as bool? ?? false,
    );
  }
}

// ── State ────────────────────────────────────────────────────────

class AirportState {
  final List<AirportStatus> airports;
  final bool isLoading;
  final String? error;
  final String? lastRefresh;
  final int openCount;
  final int restrictedCount;
  final int closedCount;

  const AirportState({
    this.airports = const [],
    this.isLoading = false,
    this.error,
    this.lastRefresh,
    this.openCount = 0,
    this.restrictedCount = 0,
    this.closedCount = 0,
  });
}

// ── Notifier ────────────────────────────────────────────────────

class AirportNotifier extends StateNotifier<AirportState> {
  AirportNotifier() : super(const AirportState(isLoading: true)) {
    _init();
  }

  Timer? _pollTimer;

  void _init() {
    _fetchStatus();
    _pollTimer = Timer.periodic(PollIntervals.airports, (_) => _fetchStatus());
  }

  Future<void> _fetchStatus() async {
    try {
      final response = await ApiService.instance.get<dynamic>(Api.airportsStatus);
      if (!mounted) return;
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final items = data['airports'] as List<dynamic>? ?? [];
        final airports = items
            .map((e) => AirportStatus.fromJson(e as Map<String, dynamic>))
            .toList();

        state = AirportState(
          airports: airports,
          isLoading: false,
          lastRefresh: data['lastRefresh'] as String?,
          openCount: data['open'] as int? ?? 0,
          restrictedCount: data['restricted'] as int? ?? 0,
          closedCount: data['closed'] as int? ?? 0,
        );
      }
    } catch (e) {
      if (!mounted) return;
      state = AirportState(
        airports: state.airports,
        isLoading: false,
        error: e.toString(),
        lastRefresh: state.lastRefresh,
        openCount: state.openCount,
        restrictedCount: state.restrictedCount,
        closedCount: state.closedCount,
      );
    }
  }

  Future<void> refresh() async {
    state = AirportState(
      airports: state.airports,
      isLoading: true,
      lastRefresh: state.lastRefresh,
      openCount: state.openCount,
      restrictedCount: state.restrictedCount,
      closedCount: state.closedCount,
    );
    await _fetchStatus();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

// ── Provider ────────────────────────────────────────────────────

final airportProvider =
    StateNotifierProvider<AirportNotifier, AirportState>((ref) {
  return AirportNotifier();
});
