// =============================================================================
// BRE4CH - Compass Navigation Sheet
// Offline compass-style navigation to a target POI with distance and ETA
// Uses GPS + magnetometer — works 100% offline
// =============================================================================

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../utils/geo_utils.dart';

/// Shows a persistent compass navigation bottom sheet.
///
/// Tracks user's GPS + compass heading, displays:
/// - Directional arrow pointing toward the target
/// - Real-time distance
/// - ETA for walking (~5 km/h) and driving (~40 km/h)
Future<void> showCompassNavSheet({
  required BuildContext context,
  required double targetLat,
  required double targetLng,
  required String targetName,
}) async {
  // Check location permission first
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission required for compass navigation')),
        );
      }
      return;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission permanently denied. Enable in Settings.')),
      );
    }
    return;
  }

  if (!context.mounted) return;

  showModalBottomSheet(
    context: context,
    backgroundColor: Palantir.surface,
    isDismissible: true,
    enableDrag: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _CompassNavContent(
      targetLat: targetLat,
      targetLng: targetLng,
      targetName: targetName,
    ),
  );
}

class _CompassNavContent extends StatefulWidget {
  final double targetLat;
  final double targetLng;
  final String targetName;

  const _CompassNavContent({
    required this.targetLat,
    required this.targetLng,
    required this.targetName,
  });

  @override
  State<_CompassNavContent> createState() => _CompassNavContentState();
}

class _CompassNavContentState extends State<_CompassNavContent> {
  StreamSubscription<Position>? _positionSub;
  StreamSubscription<CompassEvent>? _compassSub;

  double? _currentLat;
  double? _currentLng;
  double _heading = 0;   // device magnetic heading in degrees
  double _bearing = 0;   // bearing to target in degrees
  double _distanceKm = 0;
  bool _hasPosition = false;
  bool _hasCompass = false;

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
        distanceFilter: 5, // update every 5 meters
      ),
    ).listen((Position pos) {
      if (!mounted) return;
      setState(() {
        _currentLat = pos.latitude;
        _currentLng = pos.longitude;
        _hasPosition = true;
        _recalculate();
      });
    });

    // Compass stream
    _compassSub = FlutterCompass.events?.listen((CompassEvent event) {
      if (!mounted) return;
      if (event.heading != null) {
        setState(() {
          _heading = event.heading!;
          _hasCompass = true;
        });
      }
    });

    // Get initial position
    Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).then((pos) {
      if (!mounted) return;
      setState(() {
        _currentLat = pos.latitude;
        _currentLng = pos.longitude;
        _hasPosition = true;
        _recalculate();
      });
    }).catchError((_) {});
  }

  void _recalculate() {
    if (_currentLat == null || _currentLng == null) return;
    _distanceKm = haversineDistance(
      _currentLat!, _currentLng!,
      widget.targetLat, widget.targetLng,
    );
    _bearing = calculateBearing(
      _currentLat!, _currentLng!,
      widget.targetLat, widget.targetLng,
    );
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _compassSub?.cancel();
    super.dispose();
  }

  /// Angle of the arrow: bearing - heading (relative to phone orientation)
  double get _arrowAngle {
    return (_bearing - _heading) * pi / 180;
  }

  Future<void> _openGoogleMaps() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${widget.targetLat},${widget.targetLng}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Palantir.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Title
          Row(
            children: [
              Icon(Icons.explore, size: 16, color: Palantir.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'NAVIGATE TO: ${widget.targetName}',
                  style: AppTextStyles.mono(
                    size: 11,
                    weight: FontWeight.w700,
                    color: Palantir.accent,
                    letterSpacing: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Compass arrow
          if (!_hasPosition)
            Column(
              children: [
                SizedBox(
                  width: 30, height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Palantir.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ACQUIRING GPS...',
                  style: AppTextStyles.mono(size: 10, color: Palantir.textMuted, letterSpacing: 1.5),
                ),
              ],
            )
          else ...[
            // Compass ring
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Palantir.accent.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  // Cardinal markers
                  Positioned(top: 4, child: Text('N', style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.accent))),
                  Positioned(bottom: 4, child: Text('S', style: AppTextStyles.mono(size: 10, color: Palantir.textMuted))),
                  Positioned(left: 6, child: Text('W', style: AppTextStyles.mono(size: 10, color: Palantir.textMuted))),
                  Positioned(right: 6, child: Text('E', style: AppTextStyles.mono(size: 10, color: Palantir.textMuted))),
                  // Directional arrow
                  Transform.rotate(
                    angle: _arrowAngle,
                    child: Icon(
                      Icons.navigation,
                      size: 56,
                      color: Palantir.accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Distance
            Text(
              formatDistance(_distanceKm),
              style: AppTextStyles.mono(
                size: 28,
                weight: FontWeight.w800,
                color: Palantir.text,
              ),
            ),
            if (!_hasCompass)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'COMPASS UNAVAILABLE — DISTANCE ONLY',
                  style: AppTextStyles.mono(size: 8, color: Palantir.warning, letterSpacing: 1.0),
                ),
              ),
            const SizedBox(height: 12),
            // ETA row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Walking
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Palantir.bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Palantir.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_walk, size: 16, color: Palantir.success),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatEta(_distanceKm, 5.0),
                            style: AppTextStyles.mono(size: 14, weight: FontWeight.w700, color: Palantir.success),
                          ),
                          Text('~5 km/h', style: AppTextStyles.mono(size: 8, color: Palantir.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Driving
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Palantir.bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Palantir.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_car, size: 16, color: Palantir.cyan),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatEta(_distanceKm, 40.0),
                            style: AppTextStyles.mono(size: 14, weight: FontWeight.w700, color: Palantir.cyan),
                          ),
                          Text('~40 km/h', style: AppTextStyles.mono(size: 8, color: Palantir.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Palantir.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Palantir.danger.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, size: 14, color: Palantir.danger),
                        const SizedBox(width: 4),
                        Text(
                          'STOP NAV',
                          style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.danger, letterSpacing: 1.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: _openGoogleMaps,
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
                        Icon(Icons.map, size: 14, color: Palantir.accent),
                        const SizedBox(width: 4),
                        Text(
                          'OPEN MAPS',
                          style: AppTextStyles.mono(size: 10, weight: FontWeight.w700, color: Palantir.accent, letterSpacing: 1.0),
                        ),
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
    );
  }
}
