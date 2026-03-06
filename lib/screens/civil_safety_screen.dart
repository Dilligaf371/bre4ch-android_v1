// =============================================================================
// BRE4CH - Civil Safety Screen
// Shelter listings, map, and real-time airport status
// Sources: NCEMA, Civil Defence, FAA DINS NOTAMs, FlightRadar24
// =============================================================================

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../data/shelters.dart';
import '../models/shelter.dart';
import '../services/cached_tile_provider.dart';
import '../widgets/common/filter_chip_row.dart';
import '../widgets/common/header_bar.dart';
import '../widgets/common/palantir_card.dart';
import '../widgets/common/pulsing_dot.dart';

class CivilSafetyScreen extends ConsumerStatefulWidget {
  const CivilSafetyScreen({super.key});

  @override
  ConsumerState<CivilSafetyScreen> createState() => _CivilSafetyScreenState();
}

class _CivilSafetyScreenState extends ConsumerState<CivilSafetyScreen> {
  int _viewIndex = 0; // 0 = LIST, 1 = MAP
  final Set<String> _countryFilter = {'ALL'};
  final Set<String> _regionFilter = {'ALL'};
  final MapController _mapController = MapController();

  /// Shelters filtered by country only (used to derive available regions)
  List<Shelter> get _countryFilteredShelters {
    if (_countryFilter.contains('ALL') || _countryFilter.isEmpty) {
      return shelters;
    }
    final selected = _countryFilter
        .map(shelterCountryFromLabel)
        .whereType<ShelterCountry>()
        .toSet();
    return shelters
        .where((s) => selected.contains(s.country))
        .toList();
  }

  /// Available region labels based on current country selection
  List<String> get _availableRegions {
    final regions = _countryFilteredShelters
        .map((s) => s.region)
        .toSet()
        .toList()
      ..sort();
    return ['ALL', ...regions];
  }

  /// Final filtered shelters (country + region)
  List<Shelter> get _filteredShelters {
    var list = _countryFilteredShelters;
    if (!_regionFilter.contains('ALL') && _regionFilter.isNotEmpty) {
      list = list.where((s) => _regionFilter.contains(s.region)).toList();
    }
    return list;
  }

  int get _totalCapacity =>
      _filteredShelters.fold(0, (sum, s) => sum + s.capacity);

  int get _openCount =>
      _filteredShelters.where((s) => s.status == ShelterStatus.open).length;

  int get _standbyCount =>
      _filteredShelters.where((s) => s.status == ShelterStatus.standby).length;

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
            // View toggle — 4 tabs
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
                  ? _buildListView()
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (label == 'AIRPORTS' && active) ...[
                const PulsingDot(size: 5),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.mono(
                  size: 10,
                  weight: FontWeight.w600,
                  color: active ? Palantir.accent : Palantir.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── LIST VIEW ───────────────────────────────────────────────────

  Widget _buildListView() {
    return Column(
      children: [
        // Country filter chips
        FilterChipRow(
          labels: shelterCountryLabels,
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
              // Reset region filter when country changes
              _regionFilter.clear();
              _regionFilter.add('ALL');
            });
          },
        ),
        const SizedBox(height: 4),
        // Region / City filter chips (dynamic based on country)
        FilterChipRow(
          labels: _availableRegions,
          selected: _regionFilter,
          onToggle: (label) {
            setState(() {
              if (label == 'ALL') {
                _regionFilter.clear();
                _regionFilter.add('ALL');
              } else {
                _regionFilter.remove('ALL');
                if (_regionFilter.contains(label)) {
                  _regionFilter.remove(label);
                  if (_regionFilter.isEmpty) _regionFilter.add('ALL');
                } else {
                  _regionFilter.add(label);
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
              _statPill(
                'SITES',
                '${_filteredShelters.length}',
                Palantir.info,
              ),
              const SizedBox(width: 6),
              _statPill(
                'OPEN',
                '$_openCount',
                Palantir.success,
              ),
              const SizedBox(width: 6),
              _statPill(
                'STANDBY',
                '$_standbyCount',
                Palantir.accent,
              ),
              const SizedBox(width: 6),
              _statPill(
                'CAPACITY',
                _formatCapacity(_totalCapacity),
                Palantir.cyan,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Source label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.verified, size: 10, color: Palantir.success),
              const SizedBox(width: 4),
              Text(
                'COALITION CIVIL DEFENCE — ${shelters.length} sites verified',
                style: AppTextStyles.mono(
                  size: 9,
                  color: Palantir.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Shelter list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredShelters.length,
            itemBuilder: (context, index) {
              return _buildShelterCard(_filteredShelters[index]);
            },
          ),
        ),
      ],
    );
  }

  String _formatCapacity(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return '$n';
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

  // ── Status helpers ─────────────────────────────────────────────────

  Color _statusColor(ShelterStatus status) {
    switch (status) {
      case ShelterStatus.open:
        return Palantir.success;
      case ShelterStatus.standby:
        return Palantir.accent;
      case ShelterStatus.full:
        return Palantir.warning;
      case ShelterStatus.damaged:
        return Palantir.danger;
    }
  }

  Color _statusBorderColor(ShelterStatus status) {
    switch (status) {
      case ShelterStatus.open:
        return Palantir.success.withValues(alpha: 0.3);
      case ShelterStatus.standby:
        return Palantir.accent.withValues(alpha: 0.3);
      case ShelterStatus.full:
        return Palantir.warning.withValues(alpha: 0.3);
      case ShelterStatus.damaged:
        return Palantir.danger.withValues(alpha: 0.3);
    }
  }

  // ── Shelter Card ───────────────────────────────────────────────────

  Widget _buildShelterCard(Shelter shelter) {
    final sColor = _statusColor(shelter.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PalantirCard(
        borderColor: _statusBorderColor(shelter.status),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: status badge, type label, levels
            Row(
              children: [
                // Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: sColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    shelter.status.label,
                    style: AppTextStyles.mono(
                      size: 9,
                      weight: FontWeight.w700,
                      color: sColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Type
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Palantir.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    shelter.type.label,
                    style: AppTextStyles.mono(
                      size: 9,
                      weight: FontWeight.w600,
                      color: Palantir.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                if (shelter.levels > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Palantir.info.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'B${shelter.levels}',
                      style: AppTextStyles.mono(
                        size: 9,
                        weight: FontWeight.w600,
                        color: Palantir.info,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                // Capacity
                Text(
                  _formatCapacity(shelter.capacity),
                  style: AppTextStyles.mono(
                    size: 12,
                    weight: FontWeight.w700,
                    color: Palantir.accent,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.people, size: 12, color: Palantir.textMuted),
              ],
            ),
            const SizedBox(height: 8),
            // Name EN
            Text(
              shelter.name,
              style: AppTextStyles.sans(
                size: 13,
                weight: FontWeight.w600,
                color: Palantir.text,
              ),
            ),
            // Name AR
            Text(
              shelter.nameAr,
              style: AppTextStyles.sans(
                size: 11,
                color: Palantir.textMuted,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 6),
            // Bottom: district, emirate, navigate button
            Row(
              children: [
                Icon(Icons.location_on, size: 10, color: Palantir.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${shelter.district}, ${shelter.region} — ${shelter.country.displayName}',
                    style: AppTextStyles.mono(
                      size: 9,
                      color: Palantir.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      _openGoogleMaps(shelter.lat, shelter.lng, shelter.name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Palantir.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Palantir.accent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.navigation, size: 10, color: Palantir.accent),
                        const SizedBox(width: 4),
                        Text(
                          'NAVIGATE',
                          style: AppTextStyles.mono(
                            size: 10,
                            weight: FontWeight.w700,
                            color: Palantir.accent,
                            letterSpacing: 0.8,
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

  // ── MAP VIEW ─────────────────────────────────────────────────────

  Widget _buildMapView() {
    final filtered = _filteredShelters;

    return Column(
      children: [
        // Country filter chips (shared with list view)
        FilterChipRow(
          labels: shelterCountryLabels,
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
              _regionFilter.clear();
              _regionFilter.add('ALL');
            });
          },
        ),
        const SizedBox(height: 2),
        // Region / City filter
        FilterChipRow(
          labels: _availableRegions,
          selected: _regionFilter,
          onToggle: (label) {
            setState(() {
              if (label == 'ALL') {
                _regionFilter.clear();
                _regionFilter.add('ALL');
              } else {
                _regionFilter.remove('ALL');
                if (_regionFilter.contains(label)) {
                  _regionFilter.remove(label);
                  if (_regionFilter.isEmpty) _regionFilter.add('ALL');
                } else {
                  _regionFilter.add(label);
                }
              }
            });
          },
        ),
        const SizedBox(height: 4),
        // Map stats overlay
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.verified, size: 10, color: Palantir.success),
              const SizedBox(width: 4),
              Text(
                '${filtered.length} shelters displayed',
                style: AppTextStyles.mono(
                  size: 10,
                  color: Palantir.textMuted,
                ),
              ),
              const Spacer(),
              // Legend
              _legendDot(Palantir.success, 'OPEN'),
              const SizedBox(width: 8),
              _legendDot(Palantir.accent, 'STANDBY'),
              const SizedBox(width: 8),
              _legendDot(Palantir.danger, 'FULL/DMG'),
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
                    initialCenter: _mapCenter(filtered),
                    initialZoom: _mapZoom(filtered),
                    minZoom: 5,
                    maxZoom: 18,
                    backgroundColor: const Color(0xFF0A0E17),
                  ),
                  children: [
                    // Dark tile layer (cached for offline)
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'com.breach',
                      retinaMode: true,
                      tileProvider: createCachedTileProvider(),
                    ),
                    // Shelter markers
                    MarkerLayer(
                      markers: filtered.map((s) => _buildMarker(s)).toList(),
                    ),
                  ],
                ),
                // Attribution overlay (bottom right)
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

  LatLng _mapCenter(List<Shelter> list) {
    if (list.isEmpty) return const LatLng(27.0, 48.0); // Middle East center
    final avgLat = list.map((s) => s.lat).reduce((a, b) => a + b) / list.length;
    final avgLng = list.map((s) => s.lng).reduce((a, b) => a + b) / list.length;
    return LatLng(avgLat, avgLng);
  }

  double _mapZoom(List<Shelter> list) {
    if (list.isEmpty) return 5;
    final countries = list.map((s) => s.country).toSet();
    if (countries.length == 1) {
      // Single country — zoom by region count
      final regions = list.map((s) => s.region).toSet();
      if (regions.length == 1) return 12;
      return 8;
    }
    return 5; // Multiple countries — wide view
  }

  Marker _buildMarker(Shelter shelter) {
    final color = _statusColor(shelter.status);

    return Marker(
      point: LatLng(shelter.lat, shelter.lng),
      width: 32,
      height: 40,
      child: GestureDetector(
        onTap: () => _showShelterPopup(shelter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  shelter.type == ShelterType.bunker
                      ? Icons.shield
                      : Icons.night_shelter,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
            // Tiny triangle pointer
            CustomPaint(
              size: const Size(8, 6),
              painter: _TrianglePainter(color),
            ),
          ],
        ),
      ),
    );
  }

  void _showShelterPopup(Shelter shelter) {
    final sColor = _statusColor(shelter.status);
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
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Palantir.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Status + type row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: sColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    shelter.status.label,
                    style: AppTextStyles.mono(
                      size: 9,
                      weight: FontWeight.w700,
                      color: sColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Palantir.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    shelter.type.label,
                    style: AppTextStyles.mono(
                      size: 9,
                      weight: FontWeight.w600,
                      color: Palantir.textMuted,
                    ),
                  ),
                ),
                if (shelter.levels > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    'B${shelter.levels}',
                    style: AppTextStyles.mono(
                      size: 9,
                      weight: FontWeight.w600,
                      color: Palantir.info,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  '${_formatCapacity(shelter.capacity)} capacity',
                  style: AppTextStyles.mono(
                    size: 10,
                    weight: FontWeight.w700,
                    color: Palantir.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Name
            Text(
              shelter.name,
              style: AppTextStyles.sans(
                size: 16,
                weight: FontWeight.w700,
                color: Palantir.text,
              ),
            ),
            Text(
              shelter.nameAr,
              style: AppTextStyles.sans(
                size: 13,
                color: Palantir.textMuted,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            // District
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Palantir.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${shelter.district}, ${shelter.region} — ${shelter.country.displayName}',
                  style: AppTextStyles.mono(
                    size: 10,
                    color: Palantir.textMuted,
                  ),
                ),
              ],
            ),
            if (shelter.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                shelter.notes,
                style: AppTextStyles.mono(
                  size: 9,
                  color: Palantir.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Navigate button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _openGoogleMaps(shelter.lat, shelter.lng, shelter.name);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Palantir.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Palantir.accent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.navigation, size: 14, color: Palantir.accent),
                      const SizedBox(width: 8),
                      Text(
                        'NAVIGATE TO SHELTER',
                        style: AppTextStyles.mono(
                          size: 10,
                          weight: FontWeight.w700,
                          color: Palantir.accent,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.mono(
            size: 9,
            color: Palantir.textMuted,
          ),
        ),
      ],
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter old) => old.color != color;
}
