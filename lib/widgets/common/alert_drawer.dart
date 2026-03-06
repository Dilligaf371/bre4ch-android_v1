// =============================================================================
// BRE4CH - Alert Drawer
// Fullscreen overlay triggered by burger menu — shows all emergency alerts.
// Slides from top with dark background, dismissible.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/emergency_alert.dart';
import '../../providers/emergency_alerts_provider.dart';
import 'pulsing_dot.dart';
import 'palantir_card.dart';
import 'filter_chip_row.dart';

// ── Helpers ──────────────────────────────────────────────────────────

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

String _formatAlertTime(int timestamp) {
  final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ── Open the drawer ─────────────────────────────────────────────────

void openAlertDrawer(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) => const _AlertDrawerPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    ),
  );
}

// ── Drawer page ─────────────────────────────────────────────────────

class _AlertDrawerPage extends ConsumerStatefulWidget {
  const _AlertDrawerPage();

  @override
  ConsumerState<_AlertDrawerPage> createState() => _AlertDrawerPageState();
}

class _AlertDrawerPageState extends ConsumerState<_AlertDrawerPage> {
  final Set<String> _levelFilter = {};
  bool _showDismissed = false;

  @override
  Widget build(BuildContext context) {
    final alertsState = ref.watch(emergencyAlertsProvider);
    final allAlerts = alertsState.alerts;
    final activeAlerts = alertsState.activeAlerts;
    final dismissedAlerts = allAlerts.where((a) => a.dismissed).toList();

    // Apply level filter
    List<EmergencyAlert> filteredActive = activeAlerts;
    List<EmergencyAlert> filteredDismissed = dismissedAlerts;
    if (_levelFilter.isNotEmpty) {
      filteredActive = activeAlerts
          .where((a) => _levelFilter.contains(_levelLabel(a.level)))
          .toList();
      filteredDismissed = dismissedAlerts
          .where((a) => _levelFilter.contains(_levelLabel(a.level)))
          .toList();
    }

    final displayAlerts =
        _showDismissed ? filteredDismissed : filteredActive;

    return Scaffold(
      backgroundColor: Palantir.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Drawer header ────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Palantir.surface,
                border: Border(
                  bottom: BorderSide(color: Palantir.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Close button (burger → X)
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Palantir.danger.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Palantir.danger.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(Icons.close, size: 18, color: Palantir.danger),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.warning_amber_rounded,
                      size: 16, color: Palantir.danger),
                  const SizedBox(width: 6),
                  Text(
                    'EMERGENCY ALERTS',
                    style: AppTextStyles.mono(
                      size: 12,
                      weight: FontWeight.w700,
                      color: Palantir.danger,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  if (activeAlerts.isNotEmpty) ...[
                    const PulsingDot(color: Palantir.danger, size: 5),
                    const SizedBox(width: 4),
                    Text(
                      '${activeAlerts.length}',
                      style: AppTextStyles.mono(
                        size: 12,
                        weight: FontWeight.w800,
                        color: Palantir.danger,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Stats pills ──────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  _statPill(
                    'EXTREME',
                    activeAlerts.where((a) => a.level == AlertLevel.extreme).length,
                    Palantir.danger,
                  ),
                  const SizedBox(width: 6),
                  _statPill(
                    'SEVERE',
                    activeAlerts.where((a) => a.level == AlertLevel.severe).length,
                    Palantir.orange,
                  ),
                  const SizedBox(width: 6),
                  _statPill(
                    'MODERATE',
                    activeAlerts.where((a) => a.level == AlertLevel.moderate).length,
                    Palantir.warning,
                  ),
                  const Spacer(),
                  if (activeAlerts.isNotEmpty && !_showDismissed)
                    GestureDetector(
                      onTap: () {
                        ref.read(emergencyAlertsProvider.notifier).dismissAll();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Palantir.danger.withValues(alpha: 0.4)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'DISMISS ALL',
                          style: AppTextStyles.mono(
                            size: 9,
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

            // ── Level filter chips ───────────────────────────────
            FilterChipRow(
              labels: const ['EXTREME', 'SEVERE', 'MODERATE'],
              selected: _levelFilter,
              onToggle: (label) {
                setState(() {
                  if (_levelFilter.contains(label)) {
                    _levelFilter.remove(label);
                  } else {
                    _levelFilter.add(label);
                  }
                });
              },
              activeColor: Palantir.danger,
            ),
            const SizedBox(height: 6),

            // ── Active / History toggle ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildToggle('ACTIVE', !_showDismissed, filteredActive.length),
                  const SizedBox(width: 8),
                  _buildToggle('HISTORY', _showDismissed, filteredDismissed.length),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // ── Alert list ───────────────────────────────────────
            Expanded(
              child: displayAlerts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: displayAlerts.length,
                      itemBuilder: (context, index) {
                        return _AlertFullCard(alert: displayAlerts[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statPill(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: count > 0 ? color.withValues(alpha: 0.15) : Palantir.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: count > 0 ? color.withValues(alpha: 0.4) : Palantir.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: AppTextStyles.mono(
              size: 10,
              weight: FontWeight.w700,
              color: count > 0 ? color : Palantir.textMuted,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTextStyles.mono(
              size: 9,
              weight: FontWeight.w600,
              color: count > 0 ? color : Palantir.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool active, int count) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _showDismissed = label == 'HISTORY'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? Palantir.danger.withValues(alpha: 0.12)
                : Palantir.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: active ? Palantir.danger : Palantir.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.mono(
                  size: 9,
                  weight: FontWeight.w600,
                  color: active ? Palantir.danger : Palantir.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: active
                      ? Palantir.danger.withValues(alpha: 0.2)
                      : Palantir.border,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.mono(
                    size: 10,
                    weight: FontWeight.w700,
                    color: active ? Palantir.danger : Palantir.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showDismissed ? Icons.history : Icons.check_circle_outline,
            size: 48,
            color: Palantir.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            _showDismissed ? 'NO DISMISSED ALERTS' : 'NO ACTIVE ALERTS',
            style: AppTextStyles.mono(
              size: 11,
              weight: FontWeight.w600,
              color: Palantir.textMuted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _showDismissed
                ? 'Dismissed alerts appear here'
                : 'All clear — monitoring live feeds',
            style: AppTextStyles.sans(size: 12, color: Palantir.textMuted),
          ),
        ],
      ),
    );
  }
}

// ── Open source URL ─────────────────────────────────────────────────

Future<void> _openAlertSource(String? url) async {
  if (url == null || url.isEmpty) return;
  final uri = Uri.tryParse(url);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ── Full Alert Card ─────────────────────────────────────────────────

class _AlertFullCard extends ConsumerWidget {
  final EmergencyAlert alert;

  const _AlertFullCard({required this.alert});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _levelColor(alert.level);
    final isRead = alert.readAt != null;
    final isDismissed = alert.dismissed;
    final hasSource = alert.sourceUrl != null && alert.sourceUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          if (!isRead && !isDismissed) {
            ref.read(emergencyAlertsProvider.notifier).markAsRead(alert.id);
          }
          _openAlertSource(alert.sourceUrl);
        },
        child: PalantirCard(
          borderColor:
              isDismissed ? Palantir.border : color.withValues(alpha: 0.5),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Row 1: level badge, authority, region, dismiss
            Row(
              children: [
                Icon(_levelIcon(alert.level),
                    size: 16,
                    color: isDismissed ? Palantir.textMuted : color),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isDismissed ? Palantir.textMuted : color)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    _levelLabel(alert.level),
                    style: AppTextStyles.mono(
                      size: 10,
                      weight: FontWeight.w800,
                      color: isDismissed ? Palantir.textMuted : color,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    border: Border.all(color: Palantir.border),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    _authorityLabel(alert.authority),
                    style: AppTextStyles.mono(
                      size: 9,
                      weight: FontWeight.w600,
                      color: Palantir.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  alert.region,
                  style: AppTextStyles.mono(
                    size: 10,
                    weight: FontWeight.w600,
                    color: isDismissed
                        ? Palantir.textMuted
                        : color.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                if (!isDismissed) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(emergencyAlertsProvider.notifier)
                          .dismissAlert(alert.id);
                    },
                    child:
                        const Icon(Icons.close, size: 16, color: Palantir.textMuted),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // Headline
            Text(
              alert.headline,
              style: AppTextStyles.mono(
                size: 11,
                weight: FontWeight.w700,
                color: isDismissed ? Palantir.textMuted : color,
                letterSpacing: 0.3,
              ),
            ),
            // Arabic headline
            if (alert.headlineAr != null) ...[
              const SizedBox(height: 4),
              Text(
                alert.headlineAr!,
                style: AppTextStyles.sans(
                  size: 11,
                  color: isDismissed
                      ? Palantir.textMuted.withValues(alpha: 0.5)
                      : color.withValues(alpha: 0.6),
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
            const SizedBox(height: 8),
            // Body
            Text(
              alert.body,
              style: AppTextStyles.sans(
                size: 12,
                color: isDismissed ? Palantir.textMuted : Palantir.text,
              ),
            ),
            // Arabic body
            if (alert.bodyAr != null) ...[
              const SizedBox(height: 4),
              Text(
                alert.bodyAr!,
                style: AppTextStyles.sans(
                  size: 11,
                  color: Palantir.textMuted,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
            const SizedBox(height: 8),
            // Bottom row
            Row(
              children: [
                Expanded(
                  child: Text(
                    alert.source,
                    style: AppTextStyles.mono(
                      size: 10,
                      color: Palantir.textMuted,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatAlertTime(alert.timestamp),
                  style: AppTextStyles.mono(
                    size: 10,
                    color: Palantir.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
                // VIEW SOURCE button
                if (hasSource)
                  GestureDetector(
                    onTap: () => _openAlertSource(alert.sourceUrl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Palantir.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                            color: Palantir.accent.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.open_in_new,
                              size: 10, color: Palantir.accent),
                          const SizedBox(width: 3),
                          Text(
                            'SOURCE',
                            style: AppTextStyles.mono(
                              size: 9,
                              weight: FontWeight.w700,
                              color: Palantir.accent,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (hasSource) const SizedBox(width: 6),
                if (!isDismissed && !isRead)
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(emergencyAlertsProvider.notifier)
                          .markAsRead(alert.id);
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: color.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        'MARK READ',
                        style: AppTextStyles.mono(
                          size: 9,
                          weight: FontWeight.w700,
                          color: color,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  )
                else if (isDismissed)
                  Text(
                    'DISMISSED',
                    style: AppTextStyles.mono(
                      size: 9,
                      weight: FontWeight.w600,
                      color: Palantir.textMuted,
                      letterSpacing: 0.8,
                    ),
                  )
                else
                  Text(
                    'READ \u2713',
                    style: AppTextStyles.mono(
                      size: 9,
                      weight: FontWeight.w600,
                      color: Palantir.success,
                      letterSpacing: 0.8,
                    ),
                  ),
              ],
            ),
          ],
         ),
        ),
      ),
    );
  }
}
