// =============================================================================
// BRE4CH - Delta-S Screen
// OSINT + SOCMINT + BRIEFING intelligence feeds
// BRE4CH
// =============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../models/centcom_briefing.dart';
import '../models/socmint_item.dart';
import '../models/osint_item.dart';
import '../providers/centcom_provider.dart';
import '../providers/osint_provider.dart';
import '../providers/socmint_provider.dart';
import '../utils/formatters.dart';
import '../widgets/common/header_bar.dart';
import '../widgets/common/palantir_card.dart';
import '../widgets/common/severity_badge.dart';
import '../widgets/common/priority_badge.dart';
import '../widgets/common/filter_chip_row.dart';
import '../widgets/common/pulsing_dot.dart';

class DeltaSScreen extends ConsumerStatefulWidget {
  const DeltaSScreen({super.key});

  @override
  ConsumerState<DeltaSScreen> createState() => _DeltaSScreenState();
}

class _DeltaSScreenState extends ConsumerState<DeltaSScreen> {
  final Set<String> _severityFilter = {};
  Timer? _clockTimer;
  DateTime _now = DateTime.now().toUtc();

  // Operation Epic Fury start: ~4 days ago
  static final DateTime _opStart = DateTime.now().toUtc().subtract(const Duration(days: 4, hours: 3, minutes: 31));

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now().toUtc());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palantir.bg,
      body: SafeArea(
        child: Column(
          children: [
            const HeaderBar(),
            // Content
            Expanded(
              child: _buildBriefingTab(),
            ),
          ],
        ),
      ),
    );
  }

  // ── SOCMINT TAB ──────────────────────────────────────────────────

  Widget _buildSocmintTab() {
    final allSocmint = ref.watch(socmintProvider);
    final filtered = _filteredSocmint(allSocmint);

    return Column(
      children: [
        // Platform stats
        _buildPlatformStats(allSocmint),
        const SizedBox(height: 8),
        // Severity filter
        FilterChipRow(
          labels: const ['CRIT', 'HIGH', 'MED', 'LOW'],
          selected: _severityFilter,
          onToggle: (label) {
            setState(() {
              if (_severityFilter.contains(label)) {
                _severityFilter.remove(label);
              } else {
                _severityFilter.add(label);
              }
            });
          },
          activeColor: Palantir.danger,
        ),
        const SizedBox(height: 8),
        // Feed list
        Expanded(
          child: RefreshIndicator(
            color: Palantir.accent,
            backgroundColor: Palantir.surface,
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
            },
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'Waiting for live SOCMINT data...',
                      style: AppTextStyles.sans(size: 11, color: Palantir.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _buildSocmintCard(filtered[index]);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  List<SocmintItem> _filteredSocmint(List<SocmintItem> items) {
    if (_severityFilter.isEmpty) return items;
    return items.where((item) {
      final label = _severityLabel(item.severity);
      return _severityFilter.contains(label);
    }).toList();
  }

  String _severityLabel(SocmintSeverity s) {
    switch (s) {
      case SocmintSeverity.critical:
        return 'CRIT';
      case SocmintSeverity.high:
        return 'HIGH';
      case SocmintSeverity.medium:
        return 'MED';
      case SocmintSeverity.low:
        return 'LOW';
    }
  }

  Widget _buildPlatformStats(List<SocmintItem> items) {
    final tgCount =
        items.where((i) => i.platform == SocmintPlatform.telegram).length;
    final xCount =
        items.where((i) => i.platform == SocmintPlatform.x).length;
    final snapCount =
        items.where((i) => i.platform == SocmintPlatform.snapchat).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _platformStat('TG', tgCount, Palantir.info),
          const SizedBox(width: 12),
          _platformStat('X', xCount, Palantir.text),
          const SizedBox(width: 12),
          _platformStat('SNAP', snapCount, Palantir.warning),
          const Spacer(),
          Text(
            '${items.length} ITEMS',
            style: AppTextStyles.mono(
              size: 11,
              color: Palantir.textMuted,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _platformStat(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.mono(
            size: 10,
            weight: FontWeight.w600,
            color: Palantir.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: AppTextStyles.mono(
            size: 10,
            weight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSocmintCard(SocmintItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PalantirCard(
        borderColor: item.flagged
            ? Palantir.danger.withValues(alpha: 0.5)
            : null,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: platform icon, source, timestamp, severity
            Row(
              children: [
                _platformIcon(item.platform),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.source,
                    style: AppTextStyles.mono(
                      size: 10,
                      weight: FontWeight.w600,
                      color: Palantir.accent,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item.flagged) ...[
                  Icon(Icons.flag, size: 12, color: Palantir.danger),
                  const SizedBox(width: 6),
                ],
                SeverityBadge(severity: item.severity),
              ],
            ),
            const SizedBox(height: 6),
            // Content
            Text(
              item.content,
              style: AppTextStyles.sans(size: 12, color: Palantir.text),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Bottom row: language, location, timestamp
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Palantir.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    item.language,
                    style: AppTextStyles.mono(
                      size: 11,
                      weight: FontWeight.w600,
                      color: Palantir.textMuted,
                    ),
                  ),
                ),
                if (item.location != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.location_on, size: 10, color: Palantir.textMuted),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      item.location!,
                      style: AppTextStyles.mono(
                        size: 10,
                        color: Palantir.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  formatTimestamp(item.timestamp),
                  style: AppTextStyles.mono(
                    size: 10,
                    color: Palantir.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _platformIcon(SocmintPlatform platform) {
    final IconData icon;
    final Color color;
    switch (platform) {
      case SocmintPlatform.telegram:
        icon = Icons.send;
        color = Palantir.info;
      case SocmintPlatform.x:
        icon = Icons.tag;
        color = Palantir.text;
      case SocmintPlatform.snapchat:
        icon = Icons.camera_alt;
        color = Palantir.warning;
    }
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 12, color: color),
    );
  }

  // ── OSINT TAB ────────────────────────────────────────────────────

  Widget _buildOsintTab() {
    final osintItems = ref.watch(osintProvider);

    return Column(
      children: [
        // Source legend
        _buildSourceLegend(),
        const SizedBox(height: 8),
        // Feed list
        Expanded(
          child: RefreshIndicator(
            color: Palantir.accent,
            backgroundColor: Palantir.surface,
            onRefresh: () async {
              await ref.read(osintProvider.notifier).refresh();
            },
            child: osintItems.isEmpty
                ? Center(
                    child: Text(
                      'Waiting for live OSINT data...',
                      style: AppTextStyles.sans(size: 11, color: Palantir.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: osintItems.length,
                    itemBuilder: (context, index) {
                      return _buildOsintCard(osintItems[index]);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSourceLegend() {
    return SizedBox(
      height: 24,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _sourceLegendItem('REUTERS', Palantir.orange),
          const SizedBox(width: 10),
          _sourceLegendItem('CENTCOM', Palantir.info),
          const SizedBox(width: 10),
          _sourceLegendItem('AJ', Palantir.success),
          const SizedBox(width: 10),
          _sourceLegendItem('IDF', Palantir.cyan),
          const SizedBox(width: 10),
          _sourceLegendItem('DoD', Palantir.purple),
          const SizedBox(width: 10),
          _sourceLegendItem('AP', Palantir.warning),
          const SizedBox(width: 10),
          _sourceLegendItem('FR24', Palantir.textMuted),
        ],
      ),
    );
  }

  Widget _sourceLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.mono(
            size: 11,
            weight: FontWeight.w600,
            color: Palantir.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildOsintCard(OsintItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PalantirCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: source badge, timestamp, priority
            Row(
              children: [
                _osintSourceBadge(item.source),
                const Spacer(),
                Text(
                  formatTimestamp(item.timestamp),
                  style: AppTextStyles.mono(
                    size: 10,
                    color: Palantir.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
                PriorityBadge(priority: item.priority),
              ],
            ),
            const SizedBox(height: 6),
            // Title
            Text(
              item.title,
              style: AppTextStyles.sans(
                size: 13,
                weight: FontWeight.w600,
                color: Palantir.text,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Summary
            Text(
              item.summary,
              style: AppTextStyles.sans(size: 11, color: Palantir.textMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Bottom: region
            Row(
              children: [
                Icon(Icons.public, size: 10, color: Palantir.textMuted),
                const SizedBox(width: 4),
                Text(
                  item.region,
                  style: AppTextStyles.mono(
                    size: 10,
                    color: Palantir.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                if (item.priority == OsintPriority.flash)
                  const PulsingDot(color: Palantir.danger, size: 5),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _osintSourceBadge(OsintSource source) {
    final String label;
    final Color color;
    switch (source) {
      case OsintSource.reuters:
        label = 'REUTERS';
        color = Palantir.orange;
      case OsintSource.aljazeera:
        label = 'AL JAZEERA';
        color = Palantir.success;
      case OsintSource.dod:
        label = 'DoD';
        color = Palantir.purple;
      case OsintSource.idf:
        label = 'IDF';
        color = Palantir.cyan;
      case OsintSource.ap:
        label = 'AP';
        color = Palantir.warning;
      case OsintSource.centcom:
        label = 'CENTCOM';
        color = Palantir.info;
      case OsintSource.flightradar:
        label = 'FR24';
        color = Palantir.textMuted;
      default:
        final cfg = sourceConfig[source];
        label = cfg?.label ?? source.name.toUpperCase();
        color = Color(cfg?.colorValue ?? 0xFF9CA3AF);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Text(
        label,
        style: AppTextStyles.mono(
          size: 11,
          weight: FontWeight.w700,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ── BRIEFING TAB (LIVE DATA) ────────────────────────────────────

  void _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Classify CENTCOM briefing title into attack type for color coding
  String _classifyActivityType(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('drone') || lower.contains('uav') || lower.contains('shahed')) return 'DRONE';
    if (lower.contains('ballistic') || lower.contains('missile') || lower.contains('thaad') || lower.contains('patriot')) return 'BALLISTIC';
    if (lower.contains('strike') || lower.contains('cruise') || lower.contains('tomahawk')) return 'CRUISE';
    if (lower.contains('cyber') || lower.contains('network')) return 'CYBER';
    if (lower.contains('naval') || lower.contains('ship') || lower.contains('destroyer')) return 'NAVAL';
    if (lower.contains('air') || lower.contains('f-15') || lower.contains('f-22') || lower.contains('f-35') || lower.contains('sortie') || lower.contains('flight')) return 'AIR';
    return 'INTEL';
  }

  /// Get source display name from OsintSource
  String _osintSourceName(OsintSource source) {
    switch (source) {
      case OsintSource.reuters: return 'Reuters';
      case OsintSource.aljazeera: return 'Al Jazeera';
      case OsintSource.dod: return 'DoD';
      case OsintSource.idf: return 'IDF';
      case OsintSource.ap: return 'AP';
      case OsintSource.centcom: return 'CENTCOM';
      case OsintSource.flightradar: return 'FR24';
      default: return sourceConfig[source]?.label ?? source.name.toUpperCase();
    }
  }

  /// Get source color
  Color _osintSourceColor(OsintSource source) {
    switch (source) {
      case OsintSource.reuters: return Palantir.orange;
      case OsintSource.aljazeera: return Palantir.success;
      case OsintSource.dod: return Palantir.purple;
      case OsintSource.idf: return Palantir.cyan;
      case OsintSource.ap: return Palantir.warning;
      case OsintSource.centcom: return Palantir.info;
      case OsintSource.flightradar: return Palantir.textMuted;
      default: return Color(sourceConfig[source]?.colorValue ?? 0xFF9CA3AF);
    }
  }

  Widget _buildBriefingTab() {
    final centcomState = ref.watch(centcomProvider);
    final osintItems = ref.watch(osintProvider);
    final briefings = centcomState.briefings;

    final elapsed = _now.difference(_opStart);
    final zuluFmt = DateFormat('EEE, dd MMM yyyy HH:mm:ss');
    final dateFmt = DateFormat('EEE, dd MMM yyyy');

    // World clocks
    final wdc = _now.subtract(const Duration(hours: 5)); // EST
    final dxb = _now.add(const Duration(hours: 4)); // GST
    final thr = _now.add(const Duration(hours: 3, minutes: 30)); // IRST

    // Stats from live data
    final pressCount = briefings.where((b) => b.category == CentcomCategory.pressRelease).length;
    final newsCount = briefings.where((b) => b.category == CentcomCategory.news).length;
    final stmtCount = briefings.where((b) => b.category == CentcomCategory.statement).length;
    final flashCount = briefings.where((b) => b.priority == CentcomPriority.flash).length;

    return RefreshIndicator(
      color: Palantir.accent,
      backgroundColor: Palantir.surface,
      onRefresh: () async {
        await ref.read(centcomProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: CENTCOM BRIEFING + date + LIVE ──
            PalantirCard(
              borderColor: Palantir.cyan.withValues(alpha: 0.4),
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Palantir.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.description, size: 14, color: Palantir.cyan),
                        const SizedBox(width: 8),
                        Text(
                          'CENTCOM BRIEFING',
                          style: AppTextStyles.mono(
                            size: 14,
                            weight: FontWeight.w800,
                            color: Palantir.text,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            dateFmt.format(_now),
                            style: AppTextStyles.mono(size: 11, color: Palantir.textMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        if (centcomState.isLoading)
                          SizedBox(
                            width: 10, height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5, color: Palantir.accent,
                            ),
                          )
                        else
                          const PulsingDot(color: Palantir.success, size: 6),
                        const SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: AppTextStyles.mono(
                            size: 10, weight: FontWeight.w700,
                            color: Palantir.success, letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Operation Banner ──
                        Text(
                          'OPERATION EPIC FURY // IRAN THEATRE',
                          style: AppTextStyles.mono(
                            size: 11, weight: FontWeight.w700,
                            color: Palantir.accent, letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // ── Zulu time ──
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 12, color: Palantir.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              '${zuluFmt.format(_now)} Z',
                              style: AppTextStyles.mono(size: 12, color: Palantir.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // ── Mission elapsed + world clocks ──
                        Text(
                          'Mission elapsed: ${_fmtElapsed(elapsed)} | WDC: ${_fmtClock(wdc)} | DXB: ${_fmtClock(dxb)} | THR: ${_fmtClock(thr)}',
                          style: AppTextStyles.mono(size: 10, color: Palantir.textMuted),
                        ),
                        const SizedBox(height: 12),

                        // ── Stats Grid (2x2) — Live counts ──
                        Row(
                          children: [
                            Expanded(child: _briefingStat('CENTCOM items', '${briefings.length}', Palantir.accent, url: 'https://www.centcom.mil/')),
                            const SizedBox(width: 8),
                            Expanded(child: _briefingStat('Press releases', '$pressCount', Palantir.info, url: 'https://www.centcom.mil/MEDIA/PRESS-RELEASES/')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _briefingStat('News articles', '$newsCount', Palantir.cyan, url: 'https://www.centcom.mil/MEDIA/NEWS-ARTICLES/')),
                            const SizedBox(width: 8),
                            Expanded(child: _briefingStat('Flash priority', '$flashCount', Palantir.danger, url: 'https://www.centcom.mil/MEDIA/STATEMENTS/')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── RECENT ACTIVITY (live CENTCOM briefings) ──
            Row(
              children: [
                Icon(Icons.insights, size: 14, color: Palantir.text),
                const SizedBox(width: 6),
                Text(
                  'RECENT ACTIVITY',
                  style: AppTextStyles.mono(
                    size: 12, weight: FontWeight.w700,
                    color: Palantir.text, letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Text(
                  '${briefings.length} ITEMS',
                  style: AppTextStyles.mono(size: 10, color: Palantir.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (briefings.isEmpty && centcomState.isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: CircularProgressIndicator(strokeWidth: 2, color: Palantir.accent),
                ),
              )
            else if (briefings.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No CENTCOM briefings available',
                  style: AppTextStyles.sans(size: 11, color: Palantir.textMuted),
                ),
              )
            else
              ...briefings.take(10).map((b) => _buildLiveActivityItem(b)),

            const SizedBox(height: 16),

            // ── LATEST FROM SOURCES (live OSINT headlines) ──
            Row(
              children: [
                Icon(Icons.rss_feed, size: 14, color: Palantir.text),
                const SizedBox(width: 6),
                Text(
                  'LATEST FROM SOURCES',
                  style: AppTextStyles.mono(
                    size: 12, weight: FontWeight.w700,
                    color: Palantir.text, letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Text(
                  '${osintItems.length} ITEMS',
                  style: AppTextStyles.mono(size: 10, color: Palantir.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (osintItems.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No source headlines available',
                  style: AppTextStyles.sans(size: 11, color: Palantir.textMuted),
                ),
              )
            else
              ...osintItems.take(8).map((item) => _buildLiveSourceItem(item)),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _briefingStat(String label, String value, Color valueColor, {String? url}) {
    final card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Palantir.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: url != null ? valueColor.withValues(alpha: 0.4) : Palantir.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.sans(size: 10, color: Palantir.textMuted)),
          ),
          Text(
            value,
            style: AppTextStyles.mono(size: 14, weight: FontWeight.w800, color: valueColor),
          ),
          if (url != null) ...[
            const SizedBox(width: 6),
            Icon(Icons.open_in_new, size: 10, color: valueColor.withValues(alpha: 0.6)),
          ],
        ],
      ),
    );
    if (url != null) {
      return GestureDetector(
        onTap: () => _openUrl(url),
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }
    return card;
  }

  Color _activityTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'BALLISTIC': return AttackColors.ballistic;
      case 'CRUISE': return AttackColors.cruise;
      case 'DRONE': return AttackColors.drone;
      case 'CYBER': return Palantir.purple;
      case 'NAVAL': return Palantir.info;
      case 'AIR': return Palantir.cyan;
      default: return Palantir.textMuted;
    }
  }

  /// Live CENTCOM briefing item with clickable link, source, timestamp
  Widget _buildLiveActivityItem(CentcomBriefing b) {
    final type = _classifyActivityType(b.title);
    final color = _activityTypeColor(type);
    final catLabel = b.category == CentcomCategory.pressRelease
        ? 'PRESS' : b.category == CentcomCategory.statement
        ? 'STMT' : 'NEWS';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => _openUrl(b.link),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type + title
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$type ',
                          style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: color),
                        ),
                        TextSpan(
                          text: '\u2014 ',
                          style: AppTextStyles.sans(size: 11, color: Palantir.textMuted),
                        ),
                        TextSpan(
                          text: b.title,
                          style: AppTextStyles.sans(size: 11, color: Palantir.text),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Source + timestamp + link icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Palantir.info.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          catLabel,
                          style: AppTextStyles.mono(size: 11, weight: FontWeight.w600, color: Palantir.info),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.military_tech, size: 11, color: Palantir.textMuted),
                      const SizedBox(width: 2),
                      Text(
                        'CENTCOM',
                        style: AppTextStyles.mono(size: 11, weight: FontWeight.w600, color: Palantir.textMuted),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formatTimestamp(b.timestamp),
                        style: AppTextStyles.mono(size: 11, color: Palantir.textMuted),
                      ),
                      const Spacer(),
                      if (b.link.isNotEmpty)
                        Icon(Icons.open_in_new, size: 11, color: Palantir.info),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Live OSINT headline item with clickable link, source name, timestamp
  Widget _buildLiveSourceItem(OsintItem item) {
    final sourceName = _osintSourceName(item.source);
    final sourceColor = _osintSourceColor(item.source);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () => _openUrl(item.url ?? ''),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '[$sourceName] ',
                    style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: sourceColor),
                  ),
                  TextSpan(
                    text: item.title,
                    style: AppTextStyles.sans(size: 11, color: Palantir.text),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  formatTimestamp(item.timestamp),
                  style: AppTextStyles.mono(size: 11, color: Palantir.textMuted),
                ),
                if (item.url != null && item.url!.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.open_in_new, size: 11, color: sourceColor),
                  const SizedBox(width: 2),
                  Text(
                    'SOURCE',
                    style: AppTextStyles.mono(size: 11, weight: FontWeight.w600, color: sourceColor, letterSpacing: 0.5),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmtElapsed(Duration d) {
    final days = d.inDays;
    final hours = d.inHours.remainder(24).toString().padLeft(2, '0');
    final mins = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${days}d $hours:$mins:$secs';
  }

  String _fmtClock(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
