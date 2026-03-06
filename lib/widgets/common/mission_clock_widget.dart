// =============================================================================
// BRE4CH - MissionClockWidget
// Displays mission elapsed time with city clocks
// =============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../utils/formatters.dart';

class MissionClockWidget extends StatefulWidget {
  const MissionClockWidget({super.key});

  @override
  State<MissionClockWidget> createState() => _MissionClockWidgetState();
}

class _MissionClockWidgetState extends State<MissionClockWidget> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;
  DateTime _nowUtc = DateTime.now().toUtc();

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now().toUtc();
    setState(() {
      _nowUtc = now;
      _elapsed = now.difference(missionStart);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatCityTime(int utcOffsetHours) {
    final local = _nowUtc.add(Duration(hours: utcOffsetHours));
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    final s = local.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Palantir.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Palantir.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elapsed time
          Row(
            children: [
              Text(
                'MISSION ELAPSED',
                style: AppTextStyles.mono(
                  size: 8,
                  weight: FontWeight.w600,
                  color: Palantir.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Palantir.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            formatDuration(_elapsed),
            style: AppTextStyles.mono(
              size: 20,
              weight: FontWeight.w700,
              color: Palantir.accent,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          // City clocks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _cityTime('WASHINGTON', -5),
              _cityTime('TEHRAN', 3), // UTC+3:30, simplified
              _cityTime('ABU DHABI', 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cityTime(String city, int offset) {
    return Column(
      children: [
        Text(
          city,
          style: AppTextStyles.mono(
            size: 7,
            weight: FontWeight.w500,
            color: Palantir.textMuted,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formatCityTime(offset),
          style: AppTextStyles.mono(
            size: 11,
            weight: FontWeight.w600,
            color: Palantir.text,
          ),
        ),
      ],
    );
  }
}
