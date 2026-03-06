// ── Mission Clock Provider ───────────────────────────────────────
// Ports useMissionClock hook — 1s tick, elapsed time, city clocks.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/source_status.dart';

// Operation Epic Fury start: 28 FEB 2026 02:00:00 UTC
final int _missionStartMs = DateTime.utc(2026, 2, 28, 2, 0, 0).millisecondsSinceEpoch;

// ── City time formatting ─────────────────────────────────────────
// Using fixed UTC offsets since intl timezone support requires extra setup.
// Washington = UTC-5 (EST), Tehran = UTC+3:30, Abu Dhabi = UTC+4

String _formatCityTime(DateTime utcNow, Duration offset) {
  final local = utcNow.add(offset);
  final h = local.hour.toString().padLeft(2, '0');
  final m = local.minute.toString().padLeft(2, '0');
  final s = local.second.toString().padLeft(2, '0');
  return '$h:$m:$s';
}

MissionTime _calcTime() {
  final now = DateTime.now().toUtc();
  final nowMs = now.millisecondsSinceEpoch;
  final elapsed = nowMs - _missionStartMs;
  final totalSeconds = elapsed ~/ 1000;
  final days = totalSeconds ~/ 86400;
  final hours = (totalSeconds % 86400) ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  String pad(int n) => n.toString().padLeft(2, '0');
  final formatted = '${days}d ${pad(hours)}:${pad(minutes)}:${pad(seconds)}';

  return MissionTime(
    days: days,
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    formatted: formatted,
    washingtonTime: _formatCityTime(now, const Duration(hours: -5)),
    tehranTime: _formatCityTime(now, const Duration(hours: 3, minutes: 30)),
    abuDhabiTime: _formatCityTime(now, const Duration(hours: 4)),
  );
}

// ── StateNotifier ────────────────────────────────────────────────

class MissionClockNotifier extends StateNotifier<MissionTime> {
  MissionClockNotifier() : super(_calcTime()) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      state = _calcTime();
    });
  }

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ── Provider ─────────────────────────────────────────────────────

final missionClockProvider =
    StateNotifierProvider<MissionClockNotifier, MissionTime>((ref) {
  return MissionClockNotifier();
});
