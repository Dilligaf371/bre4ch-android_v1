// =============================================================================
// BRE4CH - HeaderBar Widget
// Compact top bar: burger menu (alerts), logo, phase badge, threat, LIVE, MET
// =============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/emergency_alerts_provider.dart';
import '../../utils/formatters.dart';
import 'pulsing_dot.dart';
import 'alert_drawer.dart';

class HeaderBar extends ConsumerStatefulWidget {
  const HeaderBar({super.key});

  @override
  ConsumerState<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends ConsumerState<HeaderBar> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateElapsed();
    });
  }

  void _updateElapsed() {
    final now = DateTime.now().toUtc();
    setState(() {
      _elapsed = now.difference(missionStart);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final threatColor = Color(currentThreatLevel.colorValue);
    final alertCount = ref.watch(emergencyAlertsProvider).activeCount;
    final isOnline = ref.watch(connectivityProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: Palantir.surface,
        border: Border(bottom: BorderSide(color: Palantir.border, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: burger, logo, phase, threat, live
          Row(
            children: [
              // ── Burger menu button (opens alert drawer) ────────
              GestureDetector(
                onTap: () => openAlertDrawer(context),
                child: SizedBox(
                  width: 32,
                  height: 28,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Burger icon
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: alertCount > 0
                              ? Palantir.danger.withValues(alpha: 0.12)
                              : Palantir.bg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: alertCount > 0
                                ? Palantir.danger.withValues(alpha: 0.4)
                                : Palantir.border,
                          ),
                        ),
                        child: Icon(
                          Icons.menu,
                          size: 16,
                          color: alertCount > 0
                              ? Palantir.danger
                              : Palantir.textMuted,
                        ),
                      ),
                      // Badge count
                      if (alertCount > 0)
                        Positioned(
                          top: -4,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Palantir.danger,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Palantir.danger.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Text(
                              '$alertCount',
                              style: AppTextStyles.mono(
                                size: 9,
                                weight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Logo
              Text(
                'BRE4CH',
                style: AppTextStyles.mono(
                  size: 14,
                  weight: FontWeight.w800,
                  color: Palantir.accent,
                  letterSpacing: 2.0,
                ),
              ),
              const Spacer(),
              // Threat level
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: threatColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: threatColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  currentThreatLevel.label,
                  style: AppTextStyles.mono(
                    size: 10,
                    weight: FontWeight.w700,
                    color: threatColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Live / Offline indicator
              if (isOnline) ...[
                const PulsingDot(color: Palantir.success, size: 5),
                const SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: AppTextStyles.mono(
                    size: 10,
                    weight: FontWeight.w700,
                    color: Palantir.success,
                    letterSpacing: 1.0,
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Palantir.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Palantir.warning.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off, size: 10, color: Palantir.warning),
                      const SizedBox(width: 3),
                      Text(
                        'OFFLINE',
                        style: AppTextStyles.mono(
                          size: 9,
                          weight: FontWeight.w700,
                          color: Palantir.warning,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          // Bottom row: mission elapsed time
          Row(
            children: [
              // Spacer matching burger button width
              const SizedBox(width: 40),
              Text(
                'MET ',
                style: AppTextStyles.mono(
                  size: 10,
                  weight: FontWeight.w500,
                  color: Palantir.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                formatDuration(_elapsed),
                style: AppTextStyles.mono(
                  size: 11,
                  weight: FontWeight.w700,
                  color: Palantir.accent,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                operationSubtitle,
                style: AppTextStyles.mono(
                  size: 8,
                  weight: FontWeight.w500,
                  color: Palantir.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
