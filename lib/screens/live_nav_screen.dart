// =============================================================================
// BRE4CH - Live Navigation Screen
// Real-time map navigation with GPS position + compass heading
// Uses FlutterMap + Geolocator + FlutterCompass
// =============================================================================

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../utils/geo_utils.dart';
import '../services/cached_tile_provider.dart';
import '../widgets/common/compass_nav_sheet.dart';

class LiveNavScreen extends StatefulWidget {
  final double targetLat;
  final double targetLng;
  final String targetName;

  const LiveNavScreen({
    super.key,
    required this.targetLat,
    required this.targetLng,
    required this.targetName,
  });

  @override
  State<LiveNavScreen> createState() => _LiveNavScreenState();
}

class _LiveNavScreenState extends State<LiveNavScreen> {
  final MapController _mapController = MapController();

  StreamSubscription<Position>? _positionSub;
  StreamSubscription<CompassEvent>? _compassSub;

  double? _userLat;
  double? _userLng;
  double _heading = 0;
  double _distanceKm = 0;
  bool _hasPosition = false;
  bool _autoCenter = true;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() {
    // GPS stream
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3, // update every 3 meters for smooth tracking
      ),
    ).listen((Position pos) {
      if (!mounted) return;
      setState(() {
        _userLat = pos.latitude;
        _userLng = pos.longitude;
        _hasPosition = true;
        _recalculate();
      });
      if (_autoCenter) {
        _mapController.move(LatLng(pos.latitude, pos.longitude), _mapController.camera.zoom);
      }
    });

    // Compass stream
    _compassSub = FlutterCompass.events?.listen((CompassEvent event) {
      if (!mounted) return;
      if (event.heading != null) {
        setState(() {
          _heading = event.heading!;
        });
      }
    });

    // Get initial position
    Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).then((pos) {
      if (!mounted) return;
      setState(() {
        _userLat = pos.latitude;
        _userLng = pos.longitude;
        _hasPosition = true;
        _recalculate();
      });
      _mapController.move(LatLng(pos.latitude, pos.longitude), 15);
    }).catchError((_) {});
  }

  void _recalculate() {
    if (_userLat == null || _userLng == null) return;
    _distanceKm = haversineDistance(
      _userLat!, _userLng!,
      widget.targetLat, widget.targetLng,
    );
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _compassSub?.cancel();
    super.dispose();
  }

  Future<void> _openGoogleMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${widget.targetLat},${widget.targetLng}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openCompass() {
    showCompassNavSheet(
      context: context,
      targetLat: widget.targetLat,
      targetLng: widget.targetLng,
      targetName: widget.targetName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetPoint = LatLng(widget.targetLat, widget.targetLng);

    // Build markers
    final markers = <Marker>[
      // Target marker (red pulsing)
      Marker(
        point: targetPoint,
        width: 36,
        height: 36,
        child: _TargetMarker(),
      ),
    ];

    // User position marker
    if (_hasPosition) {
      markers.add(
        Marker(
          point: LatLng(_userLat!, _userLng!),
          width: 40,
          height: 40,
          child: Transform.rotate(
            angle: _heading * pi / 180,
            child: const _UserMarker(),
          ),
        ),
      );
    }

    // Path polyline
    final polylines = <Polyline>[];
    if (_hasPosition) {
      polylines.add(
        Polyline(
          points: [LatLng(_userLat!, _userLng!), targetPoint],
          strokeWidth: 2,
          color: Palantir.accent.withValues(alpha: 0.6),
          pattern: const StrokePattern.dotted(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Palantir.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Palantir.surface,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, color: Palantir.textMuted, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.navigation, size: 14, color: Palantir.accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.targetName,
                      style: AppTextStyles.mono(
                        size: 12,
                        weight: FontWeight.w700,
                        color: Palantir.accent,
                        letterSpacing: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Auto-center toggle
                  GestureDetector(
                    onTap: () {
                      setState(() => _autoCenter = !_autoCenter);
                      if (_autoCenter && _hasPosition) {
                        _mapController.move(LatLng(_userLat!, _userLng!), _mapController.camera.zoom);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _autoCenter
                            ? Palantir.accent.withValues(alpha: 0.15)
                            : Palantir.border,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.my_location,
                        size: 16,
                        color: _autoCenter ? Palantir.accent : Palantir.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Map
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: targetPoint,
                      initialZoom: 13,
                      minZoom: 3,
                      maxZoom: 18,
                      backgroundColor: const Color(0xFF0A0E17),
                      onPositionChanged: (pos, hasGesture) {
                        if (hasGesture) {
                          setState(() => _autoCenter = false);
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.breach',
                        retinaMode: true,
                        tileProvider: createCachedTileProvider(),
                      ),
                      PolylineLayer(polylines: polylines),
                      MarkerLayer(markers: markers),
                    ],
                  ),
                  // Attribution
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
                  // GPS acquiring overlay
                  if (!_hasPosition)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Palantir.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 30, height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Palantir.accent,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'ACQUIRING GPS...',
                              style: AppTextStyles.mono(size: 11, color: Palantir.accent, letterSpacing: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Bottom info panel
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Palantir.surface,
                border: Border(top: BorderSide(color: Palantir.border, width: 1)),
              ),
              child: Column(
                children: [
                  // Distance + ETA
                  if (_hasPosition)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _infoChip(Icons.straighten, formatDistance(_distanceKm), Palantir.text),
                          _infoChip(Icons.directions_walk, formatEta(_distanceKm, 5.0), Palantir.success),
                          _infoChip(Icons.directions_car, formatEta(_distanceKm, 40.0), Palantir.cyan),
                        ],
                      ),
                    ),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _actionBtn('STOP', Icons.close, Palantir.danger, () => Navigator.pop(context)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _actionBtn('COMPASS', Icons.explore, Palantir.cyan, _openCompass),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _actionBtn('MAPS', Icons.map, Palantir.accent, _openGoogleMaps),
                      ),
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

  Widget _infoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.mono(size: 14, weight: FontWeight.w700, color: color)),
      ],
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: color, letterSpacing: 1.0),
            ),
          ],
        ),
      ),
    );
  }
}

// ── User position marker (blue arrow with direction) ─────────────

class _UserMarker extends StatelessWidget {
  const _UserMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: NatoColors.friendly.withValues(alpha: 0.15),
          ),
        ),
        // Inner dot
        Container(
          width: 14, height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: NatoColors.friendly,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: NatoColors.friendly.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        // Direction arrow
        Positioned(
          top: 2,
          child: Icon(Icons.navigation, size: 10, color: Colors.white),
        ),
      ],
    );
  }
}

// ── Target marker (red pulsing dot) ──────────────────────────────

class _TargetMarker extends StatefulWidget {
  @override
  State<_TargetMarker> createState() => _TargetMarkerState();
}

class _TargetMarkerState extends State<_TargetMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing ring
            Container(
              width: 36 * _animation.value,
              height: 36 * _animation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: NatoColors.hostile.withValues(alpha: 0.2 * (1 - _animation.value)),
                border: Border.all(
                  color: NatoColors.hostile.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            // Inner dot
            Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: NatoColors.hostile,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: NatoColors.hostile.withValues(alpha: 0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
