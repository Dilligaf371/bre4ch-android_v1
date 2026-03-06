// =============================================================================
// BRE4CH - Airports Screen
// Real-time airport status with NOTAM + headline data
// Sources: FAA DINS NOTAMs, FlightRadar24, Headlines
// =============================================================================

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../data/airports.dart';
import '../providers/airport_provider.dart';
import '../services/cached_tile_provider.dart';
import '../widgets/common/filter_chip_row.dart';
import '../widgets/common/header_bar.dart';
import '../widgets/common/palantir_card.dart';
import '../widgets/common/pulsing_dot.dart';

// ── Airport country filter labels ────────────────────────────────────

const _airportCountryLabels = [
  'ALL', 'UAE', 'KSA', 'OMAN', 'QATAR', 'BAHRAIN', 'ISRAEL', 'LEBANON',
];

String? _countryCodeFromLabel(String label) {
  switch (label) {
    case 'UAE': return 'AE';
    case 'KSA': return 'SA';
    case 'OMAN': return 'OM';
    case 'QATAR': return 'QA';
    case 'BAHRAIN': return 'BH';
    case 'ISRAEL': return 'IL';
    case 'LEBANON': return 'LB';
    default: return null;
  }
}

// ── Screen ──────────────────────────────────────────────────────────

class AirportsScreen extends ConsumerStatefulWidget {
  const AirportsScreen({super.key});

  @override
  ConsumerState<AirportsScreen> createState() => _AirportsScreenState();
}

class _AirportsScreenState extends ConsumerState<AirportsScreen> {
  int _viewIndex = 0; // 0 = LIST, 1 = MAP
  final Set<String> _countryFilter = {'ALL'};
  final MapController _mapController = MapController();

  List<AirportData> get _filteredAirportData {
    if (_countryFilter.contains('ALL') || _countryFilter.isEmpty) {
      return regionalAirports;
    }
    final codes = _countryFilter
        .map(_countryCodeFromLabel)
        .whereType<String>()
        .toSet();
    return regionalAirports.where((a) => codes.contains(a.countryCode)).toList();
  }

  Future<void> _openGoogleMaps(double lat, double lng, String name) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palantir.bg,
      body: SafeArea(
        child: Column(
          children: [
            const HeaderBar(),
            // View toggle — LIST / MAP
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildToggle('LIST', 0),
                  const SizedBox(width: 6),
                  _buildToggle('MAP', 1),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _viewIndex == 0
                  ? _buildListContent()
                  : _buildMapView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(String label, int index) {
    final active = _viewIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _viewIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? Palantir.accent.withValues(alpha: 0.15)
                : Palantir.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: active ? Palantir.accent : Palantir.border,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.mono(
              size: 10,
              weight: FontWeight.w600,
              color: active ? Palantir.accent : Palantir.textMuted,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ── LIST VIEW ──────────────────────────────────────────────────────

  Widget _buildListContent() {
    final airportState = ref.watch(airportProvider);

    return Column(
      children: [
        // Country filter chips
        FilterChipRow(
          labels: _airportCountryLabels,
          selected: _countryFilter,
          onToggle: (label) {
            setState(() {
              if (label == 'ALL') {
                _countryFilter.clear();
                _countryFilter.add('ALL');
              } else {
                _countryFilter.remove('ALL');
                if (_countryFilter.contains(label)) {
                  _countryFilter.remove(label);
                  if (_countryFilter.isEmpty) {
                    _countryFilter.add('ALL');
                  }
                } else {
                  _countryFilter.add(label);
                }
              }
            });
          },
        ),
        const SizedBox(height: 8),
        // Stats bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _statPill('AIRPORTS', '${_filteredAirportData.length}', Palantir.info),
              const SizedBox(width: 6),
              _statPill('OPEN', '${airportState.openCount}', Palantir.success),
              const SizedBox(width: 6),
              _statPill('RESTRICTED', '${airportState.restrictedCount}', Palantir.accent),
              const SizedBox(width: 6),
              _statPill('CLOSED', '${airportState.closedCount}', Palantir.danger),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Source + live indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const PulsingDot(size: 5),
              const SizedBox(width: 5),
              Text(
                'LIVE — FAA DINS NOTAMs + Headlines',
                style: AppTextStyles.mono(
                  size: 9,
                  color: Palantir.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (airportState.isLoading)
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Palantir.accent,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Airport cards
        Expanded(
          child: RefreshIndicator(
            color: Palantir.accent,
            backgroundColor: Palantir.surface,
            onRefresh: () => ref.read(airportProvider.notifier).refresh(),
            child: _buildAirportList(airportState),
          ),
        ),
      ],
    );
  }

  Widget _statPill(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.mono(
                size: 9,
                weight: FontWeight.w500,
                color: Palantir.textMuted,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.mono(
                size: 14,
                weight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirportList(AirportState airportState) {
    final filteredData = _filteredAirportData;
    final liveMap = <String, AirportStatus>{};
    for (final a in airportState.airports) {
      liveMap[a.icao] = a;
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final airport = filteredData[index];
        final live = liveMap[airport.icao];
        if (live != null) {
          return _buildAirportCard(airport, live);
        }
        return _buildOfflineAirportCard(airport);
      },
    );
  }

  Widget _buildAirportCard(AirportData airport, AirportStatus live) {
    final sColor = _airportStatusColor(live.status);
    final tColor = _airportTrafficColor(live.traffic);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PalantirCard(
        borderColor: sColor.withValues(alpha: 0.3),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: sColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    live.status,
                    style: AppTextStyles.mono(
                      size: 9, weight: FontWeight.w700, color: sColor, letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: tColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    live.traffic,
                    style: AppTextStyles.mono(
                      size: 9, weight: FontWeight.w600, color: tColor, letterSpacing: 0.8,
                    ),
                  ),
                ),
                if (live.headlineOverride) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Palantir.danger.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber, size: 10, color: Palantir.danger),
                        const SizedBox(width: 3),
                        Text(
                          'ALERT',
                          style: AppTextStyles.mono(
                            size: 6, weight: FontWeight.w700, color: Palantir.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                if (live.notamCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Palantir.info.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${live.notamCount} NOTAMs',
                      style: AppTextStyles.mono(
                        size: 9, weight: FontWeight.w600, color: Palantir.info,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(airport.flag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        airport.name,
                        style: AppTextStyles.sans(size: 13, weight: FontWeight.w600, color: Palantir.text),
                      ),
                      Text(
                        '${airport.icao} / ${airport.iata} — ${airport.city}, ${airport.country}',
                        style: AppTextStyles.mono(size: 9, color: Palantir.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (live.reason.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Palantir.bg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: sColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  live.reason,
                  style: AppTextStyles.mono(size: 10, color: Palantir.textMuted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                _linkButton('FR24', Icons.flight, Palantir.cyan, airport.fr24Url),
                const SizedBox(width: 8),
                _linkButton('NOTAMs', Icons.description, Palantir.info, airport.notamUrl),
                const Spacer(),
                GestureDetector(
                  onTap: () => _openGoogleMaps(airport.lat, airport.lng, airport.name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Palantir.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Palantir.accent.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.navigation, size: 10, color: Palantir.accent),
                        const SizedBox(width: 4),
                        Text(
                          'NAVIGATE',
                          style: AppTextStyles.mono(
                            size: 10, weight: FontWeight.w700, color: Palantir.accent, letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineAirportCard(AirportData airport) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PalantirCard(
        borderColor: Palantir.border,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Palantir.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'PENDING',
                    style: AppTextStyles.mono(
                      size: 9, weight: FontWeight.w700, color: Palantir.textMuted, letterSpacing: 1.0,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: Palantir.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(airport.flag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        airport.name,
                        style: AppTextStyles.sans(size: 13, weight: FontWeight.w600, color: Palantir.text),
                      ),
                      Text(
                        '${airport.icao} / ${airport.iata} — ${airport.city}',
                        style: AppTextStyles.mono(size: 9, color: Palantir.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _linkButton('FR24', Icons.flight, Palantir.cyan, airport.fr24Url),
                const SizedBox(width: 8),
                _linkButton('NOTAMs', Icons.description, Palantir.info, airport.notamUrl),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _linkButton(String label, IconData icon, Color color, String url) {
    return GestureDetector(
      onTap: () => _openUrl(url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.mono(
                size: 10, weight: FontWeight.w700, color: color, letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _airportStatusColor(String status) {
    switch (status) {
      case 'OPEN': return Palantir.success;
      case 'RESTRICTED': return Palantir.accent;
      case 'CLOSED': return Palantir.danger;
      default: return Palantir.textMuted;
    }
  }

  Color _airportTrafficColor(String traffic) {
    switch (traffic) {
      case 'NORMAL': return Palantir.success;
      case 'CAUTION': return Palantir.accent;
      case 'DISRUPTED': return Palantir.warning;
      case 'DELAYED': return Palantir.warning;
      case 'SUSPENDED': return Palantir.danger;
      default: return Palantir.textMuted;
    }
  }

  // ── MAP VIEW ──────────────────────────────────────────────────────

  Widget _buildMapView() {
    final airportState = ref.watch(airportProvider);
    final filteredData = _filteredAirportData;
    final liveMap = <String, AirportStatus>{};
    for (final a in airportState.airports) {
      liveMap[a.icao] = a;
    }

    return Column(
      children: [
        // Country filter chips
        FilterChipRow(
          labels: _airportCountryLabels,
          selected: _countryFilter,
          onToggle: (label) {
            setState(() {
              if (label == 'ALL') {
                _countryFilter.clear();
                _countryFilter.add('ALL');
              } else {
                _countryFilter.remove('ALL');
                if (_countryFilter.contains(label)) {
                  _countryFilter.remove(label);
                  if (_countryFilter.isEmpty) _countryFilter.add('ALL');
                } else {
                  _countryFilter.add(label);
                }
              }
            });
          },
        ),
        const SizedBox(height: 4),
        // Map stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.verified, size: 10, color: Palantir.success),
              const SizedBox(width: 4),
              Text(
                '${filteredData.length} airports displayed',
                style: AppTextStyles.mono(size: 10, color: Palantir.textMuted),
              ),
              const Spacer(),
              _legendDot(Palantir.success, 'OPEN'),
              const SizedBox(width: 8),
              _legendDot(Palantir.accent, 'RESTRICTED'),
              const SizedBox(width: 8),
              _legendDot(Palantir.danger, 'CLOSED'),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Map
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _airportMapCenter(filteredData),
                    initialZoom: _airportMapZoom(filteredData),
                    minZoom: 3,
                    maxZoom: 18,
                    backgroundColor: const Color(0xFF0A0E17),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.breach',
                      retinaMode: true,
                      tileProvider: createCachedTileProvider(),
                    ),
                    MarkerLayer(
                      markers: filteredData.map((a) {
                        final live = liveMap[a.icao];
                        return _buildAirportMarker(a, live);
                      }).toList(),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 4,
                  right: 8,
                  child: Text(
                    'CARTO / OpenStreetMap',
                    style: AppTextStyles.mono(
                      size: 9,
                      color: Palantir.textMuted.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 3),
        Text(label, style: AppTextStyles.mono(size: 8, color: Palantir.textMuted)),
      ],
    );
  }

  LatLng _airportMapCenter(List<AirportData> list) {
    if (list.isEmpty) return const LatLng(27.0, 48.0);
    final avgLat = list.map((a) => a.lat).reduce((a, b) => a + b) / list.length;
    final avgLng = list.map((a) => a.lng).reduce((a, b) => a + b) / list.length;
    return LatLng(avgLat, avgLng);
  }

  double _airportMapZoom(List<AirportData> list) {
    if (list.isEmpty) return 5;
    final countries = list.map((a) => a.countryCode).toSet();
    if (countries.length == 1) return 8;
    return 5;
  }

  Marker _buildAirportMarker(AirportData airport, AirportStatus? live) {
    final Color markerColor;
    if (live != null) {
      markerColor = _airportStatusColor(live.status);
    } else {
      markerColor = Palantir.textMuted;
    }

    return Marker(
      point: LatLng(airport.lat, airport.lng),
      width: 32,
      height: 40,
      child: GestureDetector(
        onTap: () => _showAirportPopup(airport, live),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: markerColor.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: markerColor.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  airport.isMilitary ? Icons.military_tech : Icons.flight,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
            CustomPaint(
              size: const Size(8, 6),
              painter: _AirportTrianglePainter(markerColor),
            ),
          ],
        ),
      ),
    );
  }

  void _showAirportPopup(AirportData airport, AirportStatus? live) {
    final sColor = live != null ? _airportStatusColor(live.status) : Palantir.textMuted;

    showModalBottomSheet(
      context: context,
      backgroundColor: Palantir.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Palantir.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 12),
            // Status badges
            if (live != null)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: sColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(live.status, style: AppTextStyles.mono(size: 9, weight: FontWeight.w700, color: sColor, letterSpacing: 1.0)),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _airportTrafficColor(live.traffic).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(live.traffic, style: AppTextStyles.mono(size: 9, weight: FontWeight.w600, color: _airportTrafficColor(live.traffic))),
                  ),
                  if (live.notamCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Palantir.info.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('${live.notamCount} NOTAMs', style: AppTextStyles.mono(size: 9, weight: FontWeight.w600, color: Palantir.info)),
                    ),
                  ],
                ],
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(airport.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(airport.name, style: AppTextStyles.sans(size: 16, weight: FontWeight.w700, color: Palantir.text)),
                      Text('${airport.icao} / ${airport.iata} — ${airport.city}, ${airport.country}', style: AppTextStyles.mono(size: 10, color: Palantir.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
            if (live != null && live.reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Palantir.bg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: sColor.withValues(alpha: 0.2)),
                ),
                child: Text(live.reason, style: AppTextStyles.mono(size: 10, color: Palantir.textMuted)),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _openUrl(airport.fr24Url);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Palantir.cyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Palantir.cyan.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flight, size: 12, color: Palantir.cyan),
                          const SizedBox(width: 4),
                          Text('FR24', style: AppTextStyles.mono(size: 11, weight: FontWeight.w700, color: Palantir.cyan)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _openGoogleMaps(airport.lat, airport.lng, airport.name);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Palantir.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Palantir.accent.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.navigation, size: 12, color: Palantir.accent),
                          const SizedBox(width: 4),
                          Text('NAVIGATE', style: AppTextStyles.mono(size: 11, weight: FontWeight.w700, color: Palantir.accent, letterSpacing: 1.0)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Triangle Painter ────────────────────────────────────────────────

class _AirportTrianglePainter extends CustomPainter {
  final Color color;
  _AirportTrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.9);
    final path = ui.Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
