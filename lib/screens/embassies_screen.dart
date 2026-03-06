// =============================================================================
// BRE4CH - Embassies Screen
// Consular missions directory with nationality & country filters
// =============================================================================

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../data/embassies.dart';
import '../services/cached_tile_provider.dart';
import '../widgets/common/filter_chip_row.dart';
import '../widgets/common/header_bar.dart';
import '../widgets/common/palantir_card.dart';

// ── Screen ──────────────────────────────────────────────────────────

class EmbassiesScreen extends StatefulWidget {
  const EmbassiesScreen({super.key});

  @override
  State<EmbassiesScreen> createState() => _EmbassiesScreenState();
}

class _EmbassiesScreenState extends State<EmbassiesScreen> {
  int _viewIndex = 0; // 0 = LIST, 1 = MAP
  final Set<String> _nationalityFilter = {'ALL'};
  final Set<String> _countryFilter = {'ALL'};
  final MapController _mapController = MapController();

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openGoogleMaps(double lat, double lng, String name) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  List<Embassy> get _filtered {
    var list = embassies.toList();
    if (!_nationalityFilter.contains('ALL') && _nationalityFilter.isNotEmpty) {
      list = list.where((e) => _nationalityFilter.contains(e.nationality)).toList();
    }
    if (!_countryFilter.contains('ALL') && _countryFilter.isNotEmpty) {
      list = list.where((e) => _countryFilter.contains(e.country)).toList();
    }
    return list;
  }

  List<String> get _dynamicCountryLabels {
    final availableCountries = <String>{'ALL'};
    final natFiltered = _nationalityFilter.contains('ALL') || _nationalityFilter.isEmpty
        ? embassies
        : embassies.where((e) => _nationalityFilter.contains(e.nationality));
    for (final e in natFiltered) {
      availableCountries.add(e.country);
    }
    return embassyCountryLabels.where((l) => availableCountries.contains(l)).toList();
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

  // ── LIST VIEW ─────────────────────────────────────────────────────

  Widget _buildListView() {
    final filtered = _filtered;
    return Column(
      children: [
        // ── Nationality filter ──
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('NATIONALITY', style: AppTextStyles.mono(size: 9, color: Palantir.textMuted, letterSpacing: 1.0)),
          ),
        ),
        FilterChipRow(
          labels: nationalityLabels,
          selected: _nationalityFilter,
          onToggle: (label) {
            setState(() {
              if (label == 'ALL') {
                _nationalityFilter.clear();
                _nationalityFilter.add('ALL');
              } else {
                _nationalityFilter.remove('ALL');
                if (_nationalityFilter.contains(label)) {
                  _nationalityFilter.remove(label);
                  if (_nationalityFilter.isEmpty) _nationalityFilter.add('ALL');
                } else {
                  _nationalityFilter.add(label);
                }
              }
              _countryFilter.clear();
              _countryFilter.add('ALL');
            });
          },
        ),
        const SizedBox(height: 4),
        // ── Target country filter ──
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('TARGET COUNTRY', style: AppTextStyles.mono(size: 9, color: Palantir.textMuted, letterSpacing: 1.0)),
          ),
        ),
        FilterChipRow(
          labels: _dynamicCountryLabels,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.verified, size: 10, color: Palantir.success),
              const SizedBox(width: 4),
              Text(
                'OFFICIAL CONSULAR CONTACTS — ${filtered.length} missions',
                style: AppTextStyles.mono(size: 9, color: Palantir.textMuted, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filtered.length,
            itemBuilder: (context, index) => _buildEmbassyCard(filtered[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildEmbassyCard(Embassy e) {
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
                Text(e.flag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.name,
                    style: AppTextStyles.sans(size: 13, weight: FontWeight.w600, color: Palantir.text),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Palantir.info.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    e.country,
                    style: AppTextStyles.mono(size: 9, weight: FontWeight.w600, color: Palantir.info, letterSpacing: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.location_on, size: 10, color: Palantir.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    e.address,
                    style: AppTextStyles.mono(size: 9, color: Palantir.textMuted),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            if (e.phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 10, color: Palantir.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    e.phone,
                    style: AppTextStyles.mono(size: 9, color: Palantir.accent),
                  ),
                ],
              ),
            ],
            if (e.emergency.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.warning_amber, size: 10, color: Palantir.danger),
                  const SizedBox(width: 4),
                  Text(
                    'EMERGENCY: ${e.emergency}',
                    style: AppTextStyles.mono(size: 9, weight: FontWeight.w700, color: Palantir.danger),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (e.website.isNotEmpty)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openUrl(e.website),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Palantir.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Palantir.info.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.language, size: 10, color: Palantir.info),
                            const SizedBox(width: 4),
                            Text('WEBSITE', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.info, letterSpacing: 0.8)),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (e.website.isNotEmpty) const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openUrl('tel:${e.phone.replaceAll(' ', '').replaceAll('-', '')}'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Palantir.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Palantir.success.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call, size: 10, color: Palantir.success),
                          const SizedBox(width: 4),
                          Text('CALL', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.success, letterSpacing: 0.8)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (e.lat != null && e.lng != null) {
                        _openGoogleMaps(e.lat!, e.lng!, e.name);
                      } else {
                        _openUrl('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('${e.name}, ${e.address}')}');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Palantir.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Palantir.accent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.navigation, size: 10, color: Palantir.accent),
                          const SizedBox(width: 4),
                          Text('NAVIGATE', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.accent, letterSpacing: 0.8)),
                        ],
                      ),
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

  // ── MAP VIEW ──────────────────────────────────────────────────────

  Widget _buildMapView() {
    final filtered = _filtered.where((e) => e.lat != null && e.lng != null).toList();

    return Column(
      children: [
        // Nationality filter (shared with list)
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('NATIONALITY', style: AppTextStyles.mono(size: 9, color: Palantir.textMuted, letterSpacing: 1.0)),
          ),
        ),
        FilterChipRow(
          labels: nationalityLabels,
          selected: _nationalityFilter,
          onToggle: (label) {
            setState(() {
              if (label == 'ALL') {
                _nationalityFilter.clear();
                _nationalityFilter.add('ALL');
              } else {
                _nationalityFilter.remove('ALL');
                if (_nationalityFilter.contains(label)) {
                  _nationalityFilter.remove(label);
                  if (_nationalityFilter.isEmpty) _nationalityFilter.add('ALL');
                } else {
                  _nationalityFilter.add(label);
                }
              }
              _countryFilter.clear();
              _countryFilter.add('ALL');
            });
          },
        ),
        const SizedBox(height: 2),
        // Target country filter
        FilterChipRow(
          labels: _dynamicCountryLabels,
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
                '${filtered.length} embassies displayed',
                style: AppTextStyles.mono(size: 10, color: Palantir.textMuted),
              ),
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
                    initialCenter: _embassyMapCenter(filtered),
                    initialZoom: _embassyMapZoom(filtered),
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
                      markers: filtered.map((e) => _buildEmbassyMarker(e)).toList(),
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

  LatLng _embassyMapCenter(List<Embassy> list) {
    if (list.isEmpty) return const LatLng(27.0, 48.0);
    final avgLat = list.map((e) => e.lat!).reduce((a, b) => a + b) / list.length;
    final avgLng = list.map((e) => e.lng!).reduce((a, b) => a + b) / list.length;
    return LatLng(avgLat, avgLng);
  }

  double _embassyMapZoom(List<Embassy> list) {
    if (list.isEmpty) return 5;
    final countries = list.map((e) => e.country).toSet();
    if (countries.length == 1) return 8;
    return 5;
  }

  Marker _buildEmbassyMarker(Embassy embassy) {
    return Marker(
      point: LatLng(embassy.lat!, embassy.lng!),
      width: 32,
      height: 40,
      child: GestureDetector(
        onTap: () => _showEmbassyPopup(embassy),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Palantir.info.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Palantir.info.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.account_balance, size: 12, color: Colors.white),
              ),
            ),
            CustomPaint(
              size: const Size(8, 6),
              painter: EmbassyTrianglePainter(Palantir.info),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmbassyPopup(Embassy embassy) {
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
            Row(
              children: [
                Text(embassy.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    embassy.name,
                    style: AppTextStyles.sans(size: 16, weight: FontWeight.w700, color: Palantir.text),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Palantir.info.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(embassy.country, style: AppTextStyles.mono(size: 9, weight: FontWeight.w600, color: Palantir.info)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Palantir.textMuted),
                const SizedBox(width: 4),
                Expanded(child: Text(embassy.address, style: AppTextStyles.mono(size: 10, color: Palantir.textMuted))),
              ],
            ),
            if (embassy.phone.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.phone, size: 12, color: Palantir.textMuted),
                  const SizedBox(width: 4),
                  Text(embassy.phone, style: AppTextStyles.mono(size: 10, color: Palantir.accent)),
                ],
              ),
            ],
            if (embassy.emergency.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.warning_amber, size: 12, color: Palantir.danger),
                  const SizedBox(width: 4),
                  Text('EMERGENCY: ${embassy.emergency}', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.danger)),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _openGoogleMaps(embassy.lat!, embassy.lng!, embassy.name);
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
                      Icon(Icons.navigation, size: 14, color: Palantir.accent),
                      const SizedBox(width: 6),
                      Text('NAVIGATE', style: AppTextStyles.mono(size: 12, weight: FontWeight.w700, color: Palantir.accent, letterSpacing: 1.0)),
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
}

// ── Triangle Painter ────────────────────────────────────────────────

class EmbassyTrianglePainter extends CustomPainter {
  final Color color;
  EmbassyTrianglePainter(this.color);

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

