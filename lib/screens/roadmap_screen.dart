// =============================================================================
// BRE4CH - Settings Screen
// Application info, feed integration status, deployment milestones
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../widgets/common/header_bar.dart';
import '../widgets/common/palantir_card.dart';
import '../widgets/common/pulsing_dot.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palantir.bg,
      body: SafeArea(
        child: Column(
          children: [
            const HeaderBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNotificationCard(context),
                    const SizedBox(height: 8),
                    _buildOfflineMapsCard(context),
                    const SizedBox(height: 12),
                    _buildSection('APPLICATION', [
                      _row('Version', '1.6'),
                      _row('Build', 'Flutter 3.41.3'),
                      _row('Platform', 'iOS + Android'),
                      _row('Codename', operationName),
                    ]),
                    const SizedBox(height: 12),
                    _buildSection('JOURNAUX GCC', [
                      // UAE
                      _statusRow('Khaleej Times', true),
                      _statusRow('Gulf News', true),
                      _statusRow('The National', true),
                      _statusRow('Gulf Today', true),
                      _statusRow('Emirates 24|7', true),
                      // Saudi Arabia
                      _statusRow('Arab News', true),
                      _statusRow('Saudi Gazette', true),
                      // Qatar
                      _statusRow('Gulf Times', true),
                      _statusRow('The Peninsula Qatar', true),
                      _statusRow('Qatar Tribune', true),
                      // Bahrain
                      _statusRow('Gulf Daily News', true),
                      _statusRow('Daily Tribune Bahrain', true),
                      // Oman
                      _statusRow('Times of Oman', true),
                      _statusRow('Oman Observer', true),
                    ]),
                    const SizedBox(height: 12),
                    _buildSection('WIRE SERVICES & AGENCIES', [
                      _statusRow('Reuters', true),
                      _statusRow('Associated Press', true),
                      _statusRow('Al Jazeera', true),
                      _statusRow('BBC Middle East', true),
                      _statusRow('Bloomberg', true),
                      _statusRow('CENTCOM', true),
                      _statusRow('DoD.gov', true),
                      // GCC official agencies
                      _statusRow('WAM (UAE)', true),
                      _statusRow('SPA (Saudi)', true),
                      _statusRow('QNA (Qatar)', true),
                      _statusRow('BNA (Bahrain)', true),
                      _statusRow('KUNA (Kuwait)', true),
                      _statusRow('ONA (Oman)', true),
                      // Israel
                      _statusRow('Times of Israel', true),
                      _statusRow('Jerusalem Post', true),
                    ]),
                    const SizedBox(height: 12),
                    _buildSection('CONFLICT TRACKING', [
                      _statusRow('Liveuamap API', true),
                      _statusRow('WorldMonitor', false),
                    ]),
                    const SizedBox(height: 12),
                    _buildSection('AVIATION / MARITIME / SAT', [
                      _statusRow('Flightradar24', false),
                      _statusRow('ADS-B Exchange', false),
                      _statusRow('MarineTraffic AIS', false),
                      _statusRow('NASA FIRMS', true),
                      _statusRow('Sentinel Hub', false),
                    ]),
                    const SizedBox(height: 12),
                    _buildSection('OSINT ACCOUNTS (X/TWITTER)', [
                      _statusRow('Faytuks Network', true),
                      _statusRow('OSINTdefender', true),
                      _statusRow('ELINT News', true),
                      _statusRow('Aurora Intel', true),
                      _statusRow('GeoConfirmed', true),
                      _statusRow('Critical Threats', true),
                    ]),
                    const SizedBox(height: 12),
                    _buildSection('TELEGRAM CHANNELS', [
                      _statusRow('OSINTdefender', true),
                      _statusRow('Abu Ali Express', true),
                      _statusRow('Rybar (English)', true),
                    ]),
                    const SizedBox(height: 12),
                    _buildSection('DATA PIPELINES', [
                      _statusRow('SOCMINT Aggregator', true),
                      _statusRow('OSINT Classifier', true),
                      _statusRow('Event Correlator', true),
                      _statusRow('Threat Scorer', false),
                      _statusRow('Geolocation Engine', false),
                    ]),
                    const SizedBox(height: 12),
                    _buildDeploymentSection(),
                    const SizedBox(height: 12),
                    _buildTechStackSection(),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'BRE4CH // $operationName',
                        style: AppTextStyles.mono(
                          size: 10,
                          color: Palantir.textMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/settings/notifications'),
      child: PalantirCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Palantir.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notifications_active, color: Palantir.accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Push Notifications',
                      style: AppTextStyles.mono(size: 14, weight: FontWeight.w600, color: Palantir.text)),
                  const SizedBox(height: 2),
                  Text('Configure country, city & alert preferences',
                      style: AppTextStyles.sans(size: 11, color: Palantir.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Palantir.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineMapsCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/settings/offline-maps'),
      child: PalantirCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Palantir.cyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.map_outlined, color: Palantir.cyan, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Offline Maps',
                      style: AppTextStyles.mono(size: 14, weight: FontWeight.w600, color: Palantir.text)),
                  const SizedBox(height: 2),
                  Text('Download maps by country for offline use',
                      style: AppTextStyles.sans(size: 11, color: Palantir.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Palantir.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return PalantirCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(
            value,
            style: AppTextStyles.mono(size: 13, color: Palantir.text),
          ),
        ],
      ),
    );
  }

  Widget _statusRow(String label, bool connected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          connected
              ? const PulsingDot(color: Palantir.success, size: 5)
              : Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Palantir.textMuted,
                  ),
                ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: connected
                  ? Palantir.success.withValues(alpha: 0.15)
                  : Palantir.border,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              connected ? 'ONLINE' : 'PENDING',
              style: AppTextStyles.mono(
                size: 9,
                weight: FontWeight.w700,
                color: connected ? Palantir.success : Palantir.textMuted,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeploymentSection() {
    return PalantirCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DEPLOYMENT ROADMAP', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 10),
          _milestoneRow('Alpha', 'Internal testing', MilestoneStatus.complete),
          _milestoneRow('Beta', 'TestFlight / Internal Track', MilestoneStatus.complete),
          _milestoneRow('v1.0', 'App Store + Google Play', MilestoneStatus.complete),
          _milestoneRow('v1.1', 'Push notifications + alerts', MilestoneStatus.complete),
          _milestoneRow('v1.2', 'EVAC unified screen', MilestoneStatus.complete),
          _milestoneRow('v1.3', 'Offline mode + caching', MilestoneStatus.complete),
          _milestoneRow('v1.4', 'Detection API + OSINT feeds', MilestoneStatus.complete),
          _milestoneRow('v1.5', 'SOCMINT + emergency alerts', MilestoneStatus.complete),
          _milestoneRow('v1.6', 'WebSocket real-time architecture', MilestoneStatus.active),
          _milestoneRow('v1.7', 'Real-time map overlays', MilestoneStatus.pending),
          _milestoneRow('v1.8', 'AI Agent Integration', MilestoneStatus.pending),
        ],
      ),
    );
  }

  Widget _milestoneRow(String version, String desc, MilestoneStatus status) {
    final Color color;
    final IconData icon;
    switch (status) {
      case MilestoneStatus.complete:
        color = Palantir.success;
        icon = Icons.check_circle;
      case MilestoneStatus.active:
        color = Palantir.accent;
        icon = Icons.play_circle;
      case MilestoneStatus.pending:
        color = Palantir.textMuted;
        icon = Icons.radio_button_unchecked;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
            ),
            child: Text(
              version,
              textAlign: TextAlign.center,
              style: AppTextStyles.mono(
                size: 10,
                weight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              desc,
              style: AppTextStyles.sans(
                size: 13,
                color: status == MilestoneStatus.pending
                    ? Palantir.textMuted
                    : Palantir.text,
              ),
            ),
          ),
          Icon(icon, size: 14, color: color),
        ],
      ),
    );
  }

  Widget _buildTechStackSection() {
    return PalantirCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TECH STACK', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 10),
          _techRow('Frontend', 'Flutter 3.41 / Dart 3.11'),
          _techRow('State Mgmt', 'Riverpod 2.6'),
          _techRow('Routing', 'go_router 14.8'),
          _techRow('Backend', 'Express.js / Node 20'),
          _techRow('Charts', 'fl_chart 0.70'),
          _techRow('Maps', 'Google Maps Flutter'),
          _techRow('Fonts', 'JetBrains Mono / Inter'),
          _techRow('CI/CD', 'GitHub Actions'),
        ],
      ),
    );
  }

  Widget _techRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.mono(
                size: 11,
                color: Palantir.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.mono(
                size: 12,
                color: Palantir.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum MilestoneStatus { complete, active, pending }
