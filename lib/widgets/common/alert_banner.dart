// =============================================================================
// BRE4CH - Emergency Alert Banner
// NCEMA-style emergency alert overlay — slides from top, auto-dismisses.
// Based on real UAE Ministry of Interior alerts from Feb 28-Mar 1, 2026.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/emergency_alert.dart';
import '../../providers/emergency_alerts_provider.dart';
import 'pulsing_dot.dart';

// ── Alert level styling ──────────────────────────────────────────────

Color _levelColor(AlertLevel level) {
  switch (level) {
    case AlertLevel.extreme:
      return Palantir.danger;
    case AlertLevel.severe:
      return Palantir.orange;
    case AlertLevel.moderate:
      return Palantir.warning;
  }
}

String _levelLabel(AlertLevel level) {
  switch (level) {
    case AlertLevel.extreme:
      return 'EXTREME';
    case AlertLevel.severe:
      return 'SEVERE';
    case AlertLevel.moderate:
      return 'MODERATE';
  }
}

IconData _levelIcon(AlertLevel level) {
  switch (level) {
    case AlertLevel.extreme:
      return Icons.warning_amber_rounded;
    case AlertLevel.severe:
      return Icons.shield_outlined;
    case AlertLevel.moderate:
      return Icons.info_outline;
  }
}

String _authorityLabel(AlertAuthority auth) {
  switch (auth) {
    case AlertAuthority.ncema:
      return 'NCEMA';
    case AlertAuthority.moi:
      return 'MOI';
    case AlertAuthority.mod:
      return 'MOD';
    case AlertAuthority.centcom:
      return 'CENTCOM';
    case AlertAuthority.idf:
      return 'IDF';
    case AlertAuthority.coalition:
      return 'COALITION';
  }
}

// ── AlertBanner: shows active alerts as stacked cards ─────────────

class AlertBanner extends ConsumerWidget {
  const AlertBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsState = ref.watch(emergencyAlertsProvider);
    final active = alertsState.activeAlerts;

    if (active.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Summary bar: count + dismiss all
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Palantir.danger.withValues(alpha: 0.15),
            border: Border(
              bottom: BorderSide(
                color: Palantir.danger.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              const PulsingDot(color: Palantir.danger, size: 5),
              const SizedBox(width: 6),
              Text(
                '${active.length} ACTIVE ALERT${active.length > 1 ? 'S' : ''}',
                style: AppTextStyles.mono(
                  size: 9,
                  weight: FontWeight.w700,
                  color: Palantir.danger,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  ref.read(emergencyAlertsProvider.notifier).dismissAll();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Palantir.danger.withValues(alpha: 0.4),
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'DISMISS ALL',
                    style: AppTextStyles.mono(
                      size: 7,
                      weight: FontWeight.w600,
                      color: Palantir.danger,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Alert cards (max 3 visible)
        ...active.take(3).map((alert) => _AlertCard(alert: alert)),
      ],
    );
  }
}

// ── Single Alert Card ─────────────────────────────────────────────

class _AlertCard extends ConsumerWidget {
  final EmergencyAlert alert;

  const _AlertCard({required this.alert});

  Future<void> _openSource() async {
    final url = alert.sourceUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _levelColor(alert.level);
    final isRead = alert.readAt != null;

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          ref.read(emergencyAlertsProvider.notifier).markAsRead(alert.id);
        }
        _openSource();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isRead ? 0.05 : 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: isRead ? 0.2 : 0.5),
            width: isRead ? 0.5 : 1,
          ),
          boxShadow: isRead
              ? []
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: level badge, authority, region, dismiss
            Row(
              children: [
                // Level icon
                Icon(_levelIcon(alert.level), size: 14, color: color),
                const SizedBox(width: 4),
                // Level badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    _levelLabel(alert.level),
                    style: AppTextStyles.mono(
                      size: 7,
                      weight: FontWeight.w800,
                      color: color,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Authority
                Text(
                  _authorityLabel(alert.authority),
                  style: AppTextStyles.mono(
                    size: 7,
                    weight: FontWeight.w600,
                    color: Palantir.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                // Region
                Text(
                  alert.region,
                  style: AppTextStyles.mono(
                    size: 7,
                    weight: FontWeight.w600,
                    color: color.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 6),
                // Dismiss
                GestureDetector(
                  onTap: () {
                    ref
                        .read(emergencyAlertsProvider.notifier)
                        .dismissAlert(alert.id);
                  },
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: Palantir.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Headline
            Text(
              alert.headline,
              style: AppTextStyles.mono(
                size: 10,
                weight: FontWeight.w700,
                color: isRead ? color.withValues(alpha: 0.6) : color,
                letterSpacing: 0.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Arabic headline (if available)
            if (alert.headlineAr != null) ...[
              const SizedBox(height: 2),
              Text(
                alert.headlineAr!,
                style: AppTextStyles.sans(
                  size: 10,
                  color: color.withValues(alpha: 0.5),
                ),
                textDirection: TextDirection.rtl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            // Body
            Text(
              alert.body,
              style: AppTextStyles.sans(
                size: 10,
                color: isRead ? Palantir.textMuted : Palantir.text,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Bottom: source + timestamp
            Row(
              children: [
                Expanded(
                  child: Text(
                    alert.source,
                    style: AppTextStyles.mono(
                      size: 7,
                      color: Palantir.textMuted,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isRead) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.open_in_new, size: 7, color: color),
                        const SizedBox(width: 2),
                        Text(
                          'TAP TO VIEW',
                          style: AppTextStyles.mono(
                            size: 6,
                            weight: FontWeight.w700,
                            color: color,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.open_in_new, size: 7, color: Palantir.textMuted),
                      const SizedBox(width: 2),
                      Text(
                        'READ',
                        style: AppTextStyles.mono(
                          size: 6,
                          weight: FontWeight.w600,
                          color: Palantir.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Alert Count Badge (for HeaderBar) ────────────────────────────

class AlertCountBadge extends ConsumerWidget {
  const AlertCountBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsState = ref.watch(emergencyAlertsProvider);
    final count = alertsState.activeCount;

    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Palantir.danger,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Palantir.danger.withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 9, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            '$count',
            style: AppTextStyles.mono(
              size: 8,
              weight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
