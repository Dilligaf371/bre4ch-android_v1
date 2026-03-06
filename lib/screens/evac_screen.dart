// =============================================================================
// BRE4CH - EVAC Screen
// Unified evacuation view: Shelters + Embassies + Airports + Hospitals
// Sources: NCEMA, Civil Defence, FAA DINS NOTAMs, FlightRadar24, Consular DB
// =============================================================================

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../data/airports.dart';
import '../data/embassies.dart';
import '../data/hospitals.dart';
import '../data/shelters.dart';
import '../models/shelter.dart';
import '../providers/airport_provider.dart';
import '../widgets/common/filter_chip_row.dart';
import '../widgets/common/header_bar.dart';
import '../widgets/common/palantir_card.dart';
import '../services/cached_tile_provider.dart';
import '../widgets/common/compass_nav_sheet.dart';
import '../widgets/common/pulsing_dot.dart';
import 'live_nav_screen.dart';

// ── Evacuation category enum ────────────────────────────────────────

enum EvacCategory { airports, embassies, shelters, hospitals }

// ── Country filter labels (union of all sources) ────────────────────

const _evacCountryLabels = [
  'ALL', 'UAE', 'Israel', 'KSA', 'Bahrain', 'Qatar', 'Kuwait', 'Oman',
  'Jordan', 'LEBANON',
];

// ── Airport country code mapping ────────────────────────────────────

String? _countryCodeFromLabel(String label) {
  switch (label) {
    case 'UAE': return 'AE';
    case 'KSA': return 'SA';
    case 'Oman': return 'OM';
    case 'Qatar': return 'QA';
    case 'Bahrain': return 'BH';
    case 'Israel': return 'IL';
    case 'LEBANON': return 'LB';
    case 'Kuwait': return 'KW';
    case 'Jordan': return 'JO';
    default: return null;
  }
}

// ── Embassy country label mapping ───────────────────────────────────

String? _embassyCountryFromLabel(String label) {
  switch (label) {
    case 'UAE': return 'UAE';
    case 'Israel': return 'Israel';
    case 'KSA': return 'KSA';
    case 'Bahrain': return 'Bahrain';
    case 'Qatar': return 'Qatar';
    case 'Kuwait': return 'Kuwait';
    case 'Oman': return 'Oman';
    case 'Jordan': return 'Jordan';
    default: return null;
  }
}

// ── Screen ──────────────────────────────────────────────────────────

class EvacScreen extends ConsumerStatefulWidget {
  const EvacScreen({super.key});

  @override
  ConsumerState<EvacScreen> createState() => _EvacScreenState();
}

class _EvacScreenState extends ConsumerState<EvacScreen> {
  int _viewIndex = 0; // 0 = LIST, 1 = MAP
  final Set<String> _countryFilter = {'ALL'};
  final Set<String> _cityFilter = {'ALL'};
  final Set<String> _nationalityFilter = {'ALL'};
  final Set<EvacCategory> _activeCategories = {
    EvacCategory.airports,
    EvacCategory.embassies,
    EvacCategory.shelters,
    EvacCategory.hospitals,
  };
  final MapController _mapController = MapController();

  // ── User location tracking ──────────────────────────────────────
  StreamSubscription<Position>? _positionSub;
  double? _userLat;
  double? _userLng;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  void _startLocationTracking() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;

      // Initial position
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) setState(() { _userLat = pos.latitude; _userLng = pos.longitude; });

      // Stream
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((pos) {
        if (mounted) setState(() { _userLat = pos.latitude; _userLng = pos.longitude; });
      });
    } catch (_) {}
  }

  void _centerOnUser() {
    if (_userLat != null && _userLng != null) {
      _mapController.move(LatLng(_userLat!, _userLng!), 14);
    }
  }

  void _openLiveNav(double lat, double lng, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveNavScreen(
          targetLat: lat,
          targetLng: lng,
          targetName: name,
        ),
      ),
    );
  }

  // ── City extraction helpers ─────────────────────────────────────

  /// Extract city from embassy name (e.g., "U.S. Embassy — Abu Dhabi" → "Abu Dhabi")
  String _extractEmbassyCity(Embassy e) {
    final dashIndex = e.name.lastIndexOf('—');
    if (dashIndex >= 0 && dashIndex < e.name.length - 2) {
      return e.name.substring(dashIndex + 1).trim();
    }
    return e.country; // fallback
  }

  /// Get city for a shelter (uses region = city/emirate)
  String _shelterCity(Shelter s) => s.region;

  /// Available cities based on current country filter and active categories
  List<String> get _availableCities {
    final cities = <String>{};

    // Pre-filter by country only (before city filter)
    final isAllCountry = _countryFilter.contains('ALL') || _countryFilter.isEmpty;

    if (_activeCategories.contains(EvacCategory.airports)) {
      for (final a in regionalAirports) {
        if (isAllCountry) {
          cities.add(a.city);
        } else {
          final codes = _countryFilter.map(_countryCodeFromLabel).whereType<String>().toSet();
          if (codes.contains(a.countryCode)) cities.add(a.city);
        }
      }
    }

    if (_activeCategories.contains(EvacCategory.shelters)) {
      for (final s in shelters) {
        if (isAllCountry) {
          cities.add(_shelterCity(s));
        } else {
          final selected = _countryFilter.map(shelterCountryFromLabel).whereType<ShelterCountry>().toSet();
          if (selected.contains(s.country)) cities.add(_shelterCity(s));
        }
      }
    }

    if (_activeCategories.contains(EvacCategory.embassies)) {
      for (final e in embassies) {
        if (isAllCountry) {
          cities.add(_extractEmbassyCity(e));
        } else {
          final labels = _countryFilter.map(_embassyCountryFromLabel).whereType<String>().toSet();
          if (labels.contains(e.country)) cities.add(_extractEmbassyCity(e));
        }
      }
    }

    if (_activeCategories.contains(EvacCategory.hospitals)) {
      for (final h in hospitals) {
        if (isAllCountry) {
          cities.add(h.city);
        } else {
          final selected = _countryFilter.map(hospitalCountryFromLabel).whereType<HospitalCountry>().toSet();
          if (selected.contains(h.country)) cities.add(h.city);
        }
      }
    }

    final sorted = cities.toList()..sort();
    return ['ALL', ...sorted];
  }

  /// Available nationalities (only from embassies)
  List<String> get _availableNationalities {
    if (!_activeCategories.contains(EvacCategory.embassies)) return [];
    return nationalityLabels;
  }

  // ── Filtered data accessors ─────────────────────────────────────

  List<Shelter> get _filteredShelters {
    if (!_activeCategories.contains(EvacCategory.shelters)) return [];
    var result = shelters.toList();
    // Country filter
    if (!_countryFilter.contains('ALL') && _countryFilter.isNotEmpty) {
      final selected = _countryFilter
          .map(shelterCountryFromLabel)
          .whereType<ShelterCountry>()
          .toSet();
      result = result.where((s) => selected.contains(s.country)).toList();
    }
    // City filter
    if (!_cityFilter.contains('ALL') && _cityFilter.isNotEmpty) {
      result = result.where((s) => _cityFilter.contains(_shelterCity(s))).toList();
    }
    return result;
  }

  List<Embassy> get _filteredEmbassies {
    if (!_activeCategories.contains(EvacCategory.embassies)) return [];
    var result = embassies.toList();
    // Country filter
    if (!_countryFilter.contains('ALL') && _countryFilter.isNotEmpty) {
      final labels = _countryFilter
          .map(_embassyCountryFromLabel)
          .whereType<String>()
          .toSet();
      result = result.where((e) => labels.contains(e.country)).toList();
    }
    // City filter
    if (!_cityFilter.contains('ALL') && _cityFilter.isNotEmpty) {
      result = result.where((e) => _cityFilter.contains(_extractEmbassyCity(e))).toList();
    }
    // Nationality filter
    if (!_nationalityFilter.contains('ALL') && _nationalityFilter.isNotEmpty) {
      result = result.where((e) => _nationalityFilter.contains(e.nationality)).toList();
    }
    return result;
  }

  List<AirportData> get _filteredAirports {
    if (!_activeCategories.contains(EvacCategory.airports)) return [];
    var result = regionalAirports.toList();
    // Country filter
    if (!_countryFilter.contains('ALL') && _countryFilter.isNotEmpty) {
      final codes = _countryFilter
          .map(_countryCodeFromLabel)
          .whereType<String>()
          .toSet();
      result = result.where((a) => codes.contains(a.countryCode)).toList();
    }
    // City filter
    if (!_cityFilter.contains('ALL') && _cityFilter.isNotEmpty) {
      result = result.where((a) => _cityFilter.contains(a.city)).toList();
    }
    return result;
  }

  List<Hospital> get _filteredHospitals {
    if (!_activeCategories.contains(EvacCategory.hospitals)) return [];
    var result = hospitals.toList();
    // Country filter
    if (!_countryFilter.contains('ALL') && _countryFilter.isNotEmpty) {
      final selected = _countryFilter
          .map(hospitalCountryFromLabel)
          .whereType<HospitalCountry>()
          .toSet();
      result = result.where((h) => selected.contains(h.country)).toList();
    }
    // City filter
    if (!_cityFilter.contains('ALL') && _cityFilter.isNotEmpty) {
      result = result.where((h) => _cityFilter.contains(h.city)).toList();
    }
    return result;
  }

  int get _totalSites =>
      _filteredShelters.length +
      _filteredEmbassies.length +
      _filteredAirports.length +
      _filteredHospitals.length;

  int get _openShelterCount =>
      _filteredShelters.where((s) => s.status == ShelterStatus.open).length;

  // ── URL launchers ───────────────────────────────────────────────

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

  Future<void> _callPhone(String phone) async {
    final cleaned = phone.replaceAll(' ', '').replaceAll('-', '');
    final uri = Uri.parse('tel:$cleaned');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────

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

  // ── Country filter handler ────────────────────────────────────────

  void _onCountryToggle(String label) {
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
      // Reset city filter when country changes (cities depend on country)
      _cityFilter.clear();
      _cityFilter.add('ALL');
    });
  }

  void _onCityToggle(String label) {
    setState(() {
      if (label == 'ALL') {
        _cityFilter.clear();
        _cityFilter.add('ALL');
      } else {
        _cityFilter.remove('ALL');
        if (_cityFilter.contains(label)) {
          _cityFilter.remove(label);
          if (_cityFilter.isEmpty) _cityFilter.add('ALL');
        } else {
          _cityFilter.add(label);
        }
      }
    });
  }

  void _onNationalityToggle(String label) {
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
    });
  }

  // ── Category toggles ──────────────────────────────────────────────

  Widget _buildCategoryToggles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildCategoryChip(
            EvacCategory.airports,
            'AIRPORTS',
            Icons.flight,
            Palantir.cyan,
          ),
          const SizedBox(width: 6),
          _buildCategoryChip(
            EvacCategory.embassies,
            'EMBASSIES',
            Icons.account_balance,
            Palantir.info,
          ),
          const SizedBox(width: 6),
          _buildCategoryChip(
            EvacCategory.shelters,
            'SHELTERS',
            Icons.night_shelter,
            Palantir.success,
          ),
          const SizedBox(width: 6),
          _buildCategoryChip(
            EvacCategory.hospitals,
            'MEDICAL',
            Icons.local_hospital,
            Palantir.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    EvacCategory category,
    String label,
    IconData icon,
    Color color,
  ) {
    final active = _activeCategories.contains(category);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (active && _activeCategories.length > 1) {
              _activeCategories.remove(category);
            } else if (!active) {
              _activeCategories.add(category);
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? color.withValues(alpha: 0.15)
                : Palantir.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: active
                  ? color.withValues(alpha: 0.5)
                  : Palantir.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 11, color: active ? color : Palantir.textMuted),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.mono(
                  size: 9,
                  weight: FontWeight.w600,
                  color: active ? color : Palantir.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sub-filter row (city / nationality) ──────────────────────────

  Widget _buildSubFilterRow({
    required IconData icon,
    required String label,
    required List<String> labels,
    required Set<String> selected,
    required void Function(String) onToggle,
  }) {
    return SizedBox(
      height: 28,
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: [
            Icon(icon, size: 10, color: Palantir.textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.mono(
                size: 8,
                weight: FontWeight.w600,
                color: Palantir.textMuted,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, __) => const SizedBox(width: 4),
                itemCount: labels.length,
                itemBuilder: (context, index) {
                  final l = labels[index];
                  final active = selected.contains(l);
                  return GestureDetector(
                    onTap: () => onToggle(l),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: active
                            ? Palantir.accent.withValues(alpha: 0.15)
                            : Palantir.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: active
                              ? Palantir.accent.withValues(alpha: 0.5)
                              : Palantir.border,
                        ),
                      ),
                      child: Text(
                        l,
                        style: AppTextStyles.mono(
                          size: 8,
                          weight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? Palantir.accent : Palantir.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── LIST VIEW ─────────────────────────────────────────────────────

  Widget _buildListContent() {
    final airportState = ref.watch(airportProvider);

    return Column(
      children: [
        // Country filter chips
        FilterChipRow(
          labels: _evacCountryLabels,
          selected: _countryFilter,
          onToggle: _onCountryToggle,
        ),
        const SizedBox(height: 6),
        // Category toggles
        _buildCategoryToggles(),
        const SizedBox(height: 6),
        // City filter (linked to selected country)
        if (_availableCities.length > 2) ...[
          _buildSubFilterRow(
            icon: Icons.location_city,
            label: 'CITY',
            labels: _availableCities,
            selected: _cityFilter,
            onToggle: _onCityToggle,
          ),
        ],
        // Nationality filter (embassies only)
        if (_availableNationalities.isNotEmpty) ...[
          _buildSubFilterRow(
            icon: Icons.flag,
            label: 'NATIONALITY',
            labels: _availableNationalities,
            selected: _nationalityFilter,
            onToggle: _onNationalityToggle,
          ),
        ],
        const SizedBox(height: 4),
        // Stats bar
        _buildStatsPills(airportState),
        const SizedBox(height: 4),
        // Source label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const PulsingDot(size: 5),
              const SizedBox(width: 5),
              Text(
                'EVAC NETWORK — $_totalSites sites',
                style: AppTextStyles.mono(
                  size: 9,
                  color: Palantir.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (airportState.isLoading &&
                  _activeCategories.contains(EvacCategory.airports))
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
        // Mixed card list
        Expanded(
          child: RefreshIndicator(
            color: Palantir.accent,
            backgroundColor: Palantir.surface,
            onRefresh: () => ref.read(airportProvider.notifier).refresh(),
            child: _buildMixedList(airportState),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsPills(AirportState airportState) {
    final pills = <Widget>[];

    pills.add(_statPill('SITES', '$_totalSites', Palantir.info));

    if (_activeCategories.contains(EvacCategory.airports)) {
      pills.add(const SizedBox(width: 6));
      pills.add(
        _statPill('OPEN', '${airportState.openCount}', Palantir.success),
      );
    }

    if (_activeCategories.contains(EvacCategory.shelters)) {
      pills.add(const SizedBox(width: 6));
      pills.add(
        _statPill('SHELTER', '$_openShelterCount', Palantir.success),
      );
    }

    if (_activeCategories.contains(EvacCategory.embassies)) {
      pills.add(const SizedBox(width: 6));
      pills.add(
        _statPill('CONSULAR', '${_filteredEmbassies.length}', Palantir.info),
      );
    }

    if (_activeCategories.contains(EvacCategory.hospitals)) {
      pills.add(const SizedBox(width: 6));
      pills.add(
        _statPill('MEDICAL', '${_filteredHospitals.length}', Palantir.warning),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: pills),
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

  // ── Mixed list builder ────────────────────────────────────────────

  Widget _buildMixedList(AirportState airportState) {
    final liveMap = <String, AirportStatus>{};
    for (final a in airportState.airports) {
      liveMap[a.icao] = a;
    }

    final items = <_EvacItem>[];

    // Add airports
    for (final airport in _filteredAirports) {
      items.add(_EvacItem(
        category: EvacCategory.airports,
        airport: airport,
        airportLive: liveMap[airport.icao],
      ));
    }

    // Add embassies
    for (final embassy in _filteredEmbassies) {
      items.add(_EvacItem(
        category: EvacCategory.embassies,
        embassy: embassy,
      ));
    }

    // Add shelters
    for (final shelter in _filteredShelters) {
      items.add(_EvacItem(
        category: EvacCategory.shelters,
        shelter: shelter,
      ));
    }

    // Add hospitals
    for (final hospital in _filteredHospitals) {
      items.add(_EvacItem(
        category: EvacCategory.hospitals,
        hospital: hospital,
      ));
    }

    if (items.isEmpty) {
      return Center(
        child: Text(
          'NO EVAC SITES MATCH FILTERS',
          style: AppTextStyles.mono(
            size: 11,
            color: Palantir.textMuted,
            letterSpacing: 1.5,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        switch (item.category) {
          case EvacCategory.airports:
            return _buildAirportCard(item.airport!, item.airportLive);
          case EvacCategory.embassies:
            return _buildEmbassyCard(item.embassy!);
          case EvacCategory.shelters:
            return _buildShelterCard(item.shelter!);
          case EvacCategory.hospitals:
            return _buildHospitalCard(item.hospital!);
        }
      },
    );
  }

  // ── Category badge ────────────────────────────────────────────────

  Widget _categoryBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.mono(
          size: 7,
          weight: FontWeight.w700,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ── Airport card ──────────────────────────────────────────────────

  Widget _buildAirportCard(AirportData airport, AirportStatus? live) {
    final sColor = live != null ? _airportStatusColor(live.status) : Palantir.textMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PalantirCard(
        borderColor: sColor.withValues(alpha: 0.3),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top badges row
            Row(
              children: [
                _categoryBadge('AIRPORT', Palantir.cyan),
                const SizedBox(width: 6),
                if (live != null) ...[
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
                      color: _airportTrafficColor(live.traffic).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      live.traffic,
                      style: AppTextStyles.mono(
                        size: 9, weight: FontWeight.w600,
                        color: _airportTrafficColor(live.traffic), letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ] else ...[
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
                ],
                const Spacer(),
                if (live != null && live.notamCount > 0)
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
            // Airport info
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
            if (live != null && live.reason.isNotEmpty) ...[
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
            // Action buttons
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

  // ── Embassy card ──────────────────────────────────────────────────

  Widget _buildEmbassyCard(Embassy e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PalantirCard(
        borderColor: Palantir.border,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: category badge + flag + name + country
            Row(
              children: [
                _categoryBadge('EMBASSY', Palantir.info),
                const SizedBox(width: 6),
                Text(e.flag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.name,
                    style: AppTextStyles.sans(size: 13, weight: FontWeight.w600, color: Palantir.text),
                    overflow: TextOverflow.ellipsis,
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
            // Nationality badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Palantir.border,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                e.nationality,
                style: AppTextStyles.mono(size: 9, weight: FontWeight.w600, color: Palantir.textMuted, letterSpacing: 0.8),
              ),
            ),
            const SizedBox(height: 6),
            // Address
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
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _callPhone(e.phone),
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
                        _openUrl(
                          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('${e.name}, ${e.address}')}',
                        );
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

  // ── Shelter card ──────────────────────────────────────────────────

  Widget _buildShelterCard(Shelter shelter) {
    final sColor = _shelterStatusColor(shelter.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PalantirCard(
        borderColor: sColor.withValues(alpha: 0.3),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: category badge, status badge, type label
            Row(
              children: [
                _categoryBadge('SHELTER', Palantir.success),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: sColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    shelter.status.label,
                    style: AppTextStyles.mono(
                      size: 9, weight: FontWeight.w700, color: sColor, letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Palantir.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    shelter.type.label,
                    style: AppTextStyles.mono(
                      size: 9, weight: FontWeight.w600, color: Palantir.textMuted, letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatCapacity(shelter.capacity),
                  style: AppTextStyles.mono(
                    size: 12, weight: FontWeight.w700, color: Palantir.accent,
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
              style: AppTextStyles.sans(size: 13, weight: FontWeight.w600, color: Palantir.text),
            ),
            // Name AR (RTL)
            Text(
              shelter.nameAr,
              style: AppTextStyles.sans(size: 11, color: Palantir.textMuted),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 6),
            // Bottom: location + navigate button
            Row(
              children: [
                Icon(Icons.location_on, size: 10, color: Palantir.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${shelter.district}, ${shelter.region} — ${shelter.country.displayName}',
                    style: AppTextStyles.mono(size: 9, color: Palantir.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _openGoogleMaps(shelter.lat, shelter.lng, shelter.name),
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

  // ── Shared button builders ────────────────────────────────────────

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

  // ── Color helpers ─────────────────────────────────────────────────

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

  Color _shelterStatusColor(ShelterStatus status) {
    switch (status) {
      case ShelterStatus.open: return Palantir.success;
      case ShelterStatus.standby: return Palantir.accent;
      case ShelterStatus.full: return Palantir.warning;
      case ShelterStatus.damaged: return Palantir.danger;
    }
  }

  String _formatCapacity(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return '$n';
  }

  // ── MAP VIEW ──────────────────────────────────────────────────────

  Widget _buildMapView() {
    final airportState = ref.watch(airportProvider);
    final liveMap = <String, AirportStatus>{};
    for (final a in airportState.airports) {
      liveMap[a.icao] = a;
    }

    final allMarkers = <Marker>[];

    // Shelter markers
    for (final s in _filteredShelters) {
      allMarkers.add(_buildShelterMarker(s));
    }

    // Embassy markers
    for (final e in _filteredEmbassies) {
      if (e.lat != null && e.lng != null) {
        allMarkers.add(_buildEmbassyMarker(e));
      }
    }

    // Airport markers
    for (final a in _filteredAirports) {
      allMarkers.add(_buildAirportMarker(a, liveMap[a.icao]));
    }

    // Hospital markers
    for (final h in _filteredHospitals) {
      allMarkers.add(_buildHospitalMarker(h));
    }

    // Calculate center from all displayed points
    final allPoints = <LatLng>[];
    for (final s in _filteredShelters) {
      allPoints.add(LatLng(s.lat, s.lng));
    }
    for (final e in _filteredEmbassies) {
      if (e.lat != null && e.lng != null) {
        allPoints.add(LatLng(e.lat!, e.lng!));
      }
    }
    for (final a in _filteredAirports) {
      allPoints.add(LatLng(a.lat, a.lng));
    }
    for (final h in _filteredHospitals) {
      allPoints.add(LatLng(h.lat, h.lng));
    }

    return Column(
      children: [
        // Country filter chips
        FilterChipRow(
          labels: _evacCountryLabels,
          selected: _countryFilter,
          onToggle: _onCountryToggle,
        ),
        const SizedBox(height: 6),
        // Category toggles
        _buildCategoryToggles(),
        const SizedBox(height: 6),
        // City filter (linked to selected country)
        if (_availableCities.length > 2) ...[
          _buildSubFilterRow(
            icon: Icons.location_city,
            label: 'CITY',
            labels: _availableCities,
            selected: _cityFilter,
            onToggle: _onCityToggle,
          ),
        ],
        // Nationality filter (embassies only)
        if (_availableNationalities.isNotEmpty) ...[
          _buildSubFilterRow(
            icon: Icons.flag,
            label: 'NATIONALITY',
            labels: _availableNationalities,
            selected: _nationalityFilter,
            onToggle: _onNationalityToggle,
          ),
        ],
        const SizedBox(height: 4),
        // Map legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.verified, size: 10, color: Palantir.success),
              const SizedBox(width: 4),
              Text(
                '${allMarkers.length} sites displayed',
                style: AppTextStyles.mono(size: 10, color: Palantir.textMuted),
              ),
              const Spacer(),
              if (_activeCategories.contains(EvacCategory.airports))
                _legendDot(Palantir.cyan, 'AIR'),
              if (_activeCategories.contains(EvacCategory.airports))
                const SizedBox(width: 8),
              if (_activeCategories.contains(EvacCategory.embassies))
                _legendDot(Palantir.info, 'EMB'),
              if (_activeCategories.contains(EvacCategory.embassies))
                const SizedBox(width: 8),
              if (_activeCategories.contains(EvacCategory.shelters))
                _legendDot(Palantir.success, 'SHL'),
              if (_activeCategories.contains(EvacCategory.hospitals))
                const SizedBox(width: 8),
              if (_activeCategories.contains(EvacCategory.hospitals))
                _legendDot(Palantir.warning, 'MED'),
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
                    initialCenter: _mapCenter(allPoints),
                    initialZoom: _mapZoom(allPoints),
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
                    MarkerLayer(markers: [
                      ...allMarkers,
                      // User location marker (blue pulsing dot)
                      if (_userLat != null && _userLng != null)
                        Marker(
                          point: LatLng(_userLat!, _userLng!),
                          width: 28,
                          height: 28,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: NatoColors.friendly.withValues(alpha: 0.2),
                            ),
                            child: Center(
                              child: Container(
                                width: 12, height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: NatoColors.friendly,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: NatoColors.friendly.withValues(alpha: 0.5),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ]),
                  ],
                ),
                // Locate me FAB
                Positioned(
                  bottom: 30,
                  right: 12,
                  child: GestureDetector(
                    onTap: _centerOnUser,
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Palantir.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: Palantir.border),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4),
                        ],
                      ),
                      child: Icon(
                        Icons.my_location,
                        size: 18,
                        color: _userLat != null ? NatoColors.friendly : Palantir.textMuted,
                      ),
                    ),
                  ),
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

  LatLng _mapCenter(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(27.0, 48.0);
    final avgLat = points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    final avgLng = points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
    return LatLng(avgLat, avgLng);
  }

  double _mapZoom(List<LatLng> points) {
    if (points.isEmpty) return 5;
    if (points.length == 1) return 12;
    // Check spread to determine zoom
    final lats = points.map((p) => p.latitude);
    final lngs = points.map((p) => p.longitude);
    final latSpread = lats.reduce((a, b) => a > b ? a : b) - lats.reduce((a, b) => a < b ? a : b);
    final lngSpread = lngs.reduce((a, b) => a > b ? a : b) - lngs.reduce((a, b) => a < b ? a : b);
    final maxSpread = latSpread > lngSpread ? latSpread : lngSpread;
    if (maxSpread < 1) return 12;
    if (maxSpread < 3) return 8;
    if (maxSpread < 10) return 6;
    return 5;
  }

  // ── Shelter marker ────────────────────────────────────────────────

  Marker _buildShelterMarker(Shelter shelter) {
    final color = _shelterStatusColor(shelter.status);

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
            CustomPaint(
              size: const Size(8, 6),
              painter: _EvacTrianglePainter(color),
            ),
          ],
        ),
      ),
    );
  }

  // ── Embassy marker ────────────────────────────────────────────────

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
              painter: _EvacTrianglePainter(Palantir.info),
            ),
          ],
        ),
      ),
    );
  }

  // ── Airport marker ────────────────────────────────────────────────

  Marker _buildAirportMarker(AirportData airport, AirportStatus? live) {
    final Color markerColor;
    if (airport.isMilitary) {
      markerColor = Colors.pinkAccent;
    } else if (live != null) {
      markerColor = _airportStatusColor(live.status);
    } else {
      markerColor = Palantir.cyan;
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
              painter: _EvacTrianglePainter(markerColor),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shelter popup ─────────────────────────────────────────────────

  void _showShelterPopup(Shelter shelter) {
    final sColor = _shelterStatusColor(shelter.status);
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
            // Status + type row
            Row(
              children: [
                _categoryBadge('SHELTER', Palantir.success),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: sColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    shelter.status.label,
                    style: AppTextStyles.mono(size: 9, weight: FontWeight.w700, color: sColor, letterSpacing: 1.0),
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
                    style: AppTextStyles.mono(size: 9, weight: FontWeight.w600, color: Palantir.textMuted),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_formatCapacity(shelter.capacity)} capacity',
                  style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.accent),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              shelter.name,
              style: AppTextStyles.sans(size: 16, weight: FontWeight.w700, color: Palantir.text),
            ),
            Text(
              shelter.nameAr,
              style: AppTextStyles.sans(size: 13, color: Palantir.textMuted),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Palantir.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${shelter.district}, ${shelter.region} — ${shelter.country.displayName}',
                    style: AppTextStyles.mono(size: 10, color: Palantir.textMuted),
                  ),
                ),
              ],
            ),
            if (shelter.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                shelter.notes,
                style: AppTextStyles.mono(size: 9, color: Palantir.textMuted),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      showCompassNavSheet(
                        context: context,
                        targetLat: shelter.lat,
                        targetLng: shelter.lng,
                        targetName: shelter.name,
                      );
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
                          Icon(Icons.explore, size: 12, color: Palantir.cyan),
                          const SizedBox(width: 4),
                          Text('COMPASS', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.cyan, letterSpacing: 1.0)),
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
                      _openLiveNav(shelter.lat, shelter.lng, shelter.name);
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
                          Text('NAVIGATE', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.accent, letterSpacing: 1.0)),
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

  // ── Embassy popup ─────────────────────────────────────────────────

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
                _categoryBadge('EMBASSY', Palantir.info),
                const SizedBox(width: 8),
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
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _callPhone(embassy.phone);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Palantir.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Palantir.success.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call, size: 12, color: Palantir.success),
                          const SizedBox(width: 4),
                          Text('CALL', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.success)),
                        ],
                      ),
                    ),
                  ),
                ),
                if (embassy.lat != null && embassy.lng != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        showCompassNavSheet(
                          context: context,
                          targetLat: embassy.lat!,
                          targetLng: embassy.lng!,
                          targetName: embassy.name,
                        );
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
                            Icon(Icons.explore, size: 12, color: Palantir.cyan),
                            const SizedBox(width: 4),
                            Text('COMPASS', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.cyan)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      if (embassy.lat != null && embassy.lng != null) {
                        _openLiveNav(embassy.lat!, embassy.lng!, embassy.name);
                      } else {
                        _openUrl(
                          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('${embassy.name}, ${embassy.address}')}',
                        );
                      }
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
                          Text('NAVIGATE', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.accent, letterSpacing: 1.0)),
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

  // ── Airport popup ─────────────────────────────────────────────────

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
            // Category + status badges
            Row(
              children: [
                _categoryBadge('AIRPORT', Palantir.cyan),
                if (live != null) ...[
                  const SizedBox(width: 8),
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
                          Text('FR24', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.cyan)),
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
                      showCompassNavSheet(
                        context: context,
                        targetLat: airport.lat,
                        targetLng: airport.lng,
                        targetName: airport.name,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Palantir.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Palantir.info.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.explore, size: 12, color: Palantir.info),
                          const SizedBox(width: 4),
                          Text('COMPASS', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.info)),
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
                      _openLiveNav(airport.lat, airport.lng, airport.name);
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
                          Text('NAV', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.accent, letterSpacing: 1.0)),
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

  // ── Hospital card ───────────────────────────────────────────────────

  Widget _buildHospitalCard(Hospital hospital) {
    final typeColor = hospital.type == HospitalType.hospital
        ? Palantir.warning
        : hospital.type == HospitalType.clinic
            ? Colors.amber
            : Palantir.danger;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PalantirCard(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top badges
          Row(
            children: [
              _categoryBadge(hospital.type.label, typeColor),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Palantir.border,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  hospital.country.displayName,
                  style: AppTextStyles.mono(size: 8, weight: FontWeight.w600, color: Palantir.textMuted),
                ),
              ),
              const Spacer(),
              Text(
                hospital.country.flag,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Name
          Text(
            hospital.name,
            style: AppTextStyles.sans(size: 14, weight: FontWeight.w700, color: Palantir.text),
          ),
          if (hospital.nameAr.isNotEmpty)
            Text(
              hospital.nameAr,
              style: AppTextStyles.sans(size: 11, color: Palantir.textMuted),
              textDirection: TextDirection.rtl,
            ),
          const SizedBox(height: 6),
          // City
          Row(
            children: [
              Icon(Icons.location_on, size: 11, color: Palantir.textMuted),
              const SizedBox(width: 4),
              Text(
                '${hospital.city}, ${hospital.country.displayName}',
                style: AppTextStyles.mono(size: 10, color: Palantir.textMuted),
              ),
            ],
          ),
          // Phone
          if (hospital.phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _callPhone(hospital.phone),
              child: Row(
                children: [
                  Icon(Icons.phone, size: 11, color: Palantir.accent),
                  const SizedBox(width: 4),
                  Text(hospital.phone, style: AppTextStyles.mono(size: 10, color: Palantir.accent)),
                ],
              ),
            ),
          ],
          // Emergency
          if (hospital.emergency.isNotEmpty) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _callPhone(hospital.emergency),
              child: Row(
                children: [
                  Icon(Icons.emergency, size: 11, color: Palantir.danger),
                  const SizedBox(width: 4),
                  Text(
                    'EMERGENCY: ${hospital.emergency}',
                    style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.danger),
                  ),
                ],
              ),
            ),
          ],
          // Notes
          if (hospital.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              hospital.notes,
              style: AppTextStyles.mono(size: 9, color: Palantir.textMuted),
            ),
          ],
          const SizedBox(height: 8),
          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _callPhone(hospital.phone),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Palantir.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Palantir.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.call, size: 12, color: Palantir.success),
                        const SizedBox(width: 4),
                        Text('CALL', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.success)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => showCompassNavSheet(
                    context: context,
                    targetLat: hospital.lat,
                    targetLng: hospital.lng,
                    targetName: hospital.name,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Palantir.cyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Palantir.cyan.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.explore, size: 12, color: Palantir.cyan),
                        const SizedBox(width: 4),
                        Text('COMPASS', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.cyan)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _openGoogleMaps(hospital.lat, hospital.lng, hospital.name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
                        Text('NAV', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.accent, letterSpacing: 1.0)),
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

  // ── Hospital marker ─────────────────────────────────────────────────

  Marker _buildHospitalMarker(Hospital hospital) {
    return Marker(
      point: LatLng(hospital.lat, hospital.lng),
      width: 24,
      height: 30,
      child: GestureDetector(
        onTap: () => _showHospitalPopup(hospital),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: Palantir.warning,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Palantir.warning.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.local_hospital, size: 12, color: Colors.white),
            ),
            CustomPaint(
              size: const Size(8, 5),
              painter: _EvacTrianglePainter(Palantir.warning),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hospital popup ──────────────────────────────────────────────────

  void _showHospitalPopup(Hospital hospital) {
    final typeColor = hospital.type == HospitalType.hospital
        ? Palantir.warning
        : hospital.type == HospitalType.clinic
            ? Colors.amber
            : Palantir.danger;

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
            // Type + country badges
            Row(
              children: [
                _categoryBadge(hospital.type.label, typeColor),
                const SizedBox(width: 8),
                Text(hospital.country.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hospital.name,
                    style: AppTextStyles.sans(size: 16, weight: FontWeight.w700, color: Palantir.text),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Palantir.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(hospital.country.displayName, style: AppTextStyles.mono(size: 9, weight: FontWeight.w600, color: Palantir.warning)),
                ),
              ],
            ),
            if (hospital.nameAr.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(hospital.nameAr, style: AppTextStyles.sans(size: 13, color: Palantir.textMuted), textDirection: TextDirection.rtl),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Palantir.textMuted),
                const SizedBox(width: 4),
                Text('${hospital.city}, ${hospital.country.displayName}', style: AppTextStyles.mono(size: 10, color: Palantir.textMuted)),
              ],
            ),
            if (hospital.phone.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.phone, size: 12, color: Palantir.textMuted),
                  const SizedBox(width: 4),
                  Text(hospital.phone, style: AppTextStyles.mono(size: 10, color: Palantir.accent)),
                ],
              ),
            ],
            if (hospital.emergency.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.emergency, size: 12, color: Palantir.danger),
                  const SizedBox(width: 4),
                  Text('EMERGENCY: ${hospital.emergency}', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.danger)),
                ],
              ),
            ],
            if (hospital.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(hospital.notes, style: AppTextStyles.mono(size: 9, color: Palantir.textMuted)),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _callPhone(hospital.phone);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Palantir.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Palantir.success.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call, size: 12, color: Palantir.success),
                          const SizedBox(width: 4),
                          Text('CALL', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.success)),
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
                      showCompassNavSheet(
                        context: context,
                        targetLat: hospital.lat,
                        targetLng: hospital.lng,
                        targetName: hospital.name,
                      );
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
                          Icon(Icons.explore, size: 12, color: Palantir.cyan),
                          const SizedBox(width: 4),
                          Text('COMPASS', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.cyan)),
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
                      _openLiveNav(hospital.lat, hospital.lng, hospital.name);
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
                          Text('NAV', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.accent, letterSpacing: 1.0)),
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

class _EvacTrianglePainter extends CustomPainter {
  final Color color;
  _EvacTrianglePainter(this.color);

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
  bool shouldRepaint(covariant _EvacTrianglePainter old) => old.color != color;
}

// ── Internal item wrapper for mixed list ────────────────────────────

class _EvacItem {
  final EvacCategory category;
  final AirportData? airport;
  final AirportStatus? airportLive;
  final Embassy? embassy;
  final Shelter? shelter;
  final Hospital? hospital;

  const _EvacItem({
    required this.category,
    this.airport,
    this.airportLive,
    this.embassy,
    this.shelter,
    this.hospital,
  });
}
