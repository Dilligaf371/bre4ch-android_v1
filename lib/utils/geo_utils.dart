// =============================================================================
// BRE4CH - Geo Utilities
// Haversine distance, bearing calculation, formatters for compass navigation
// =============================================================================

import 'dart:math';

/// Earth's mean radius in kilometres.
const double _earthRadiusKm = 6371.0;

/// Haversine distance between two points in kilometres.
double haversineDistance(double lat1, double lng1, double lat2, double lng2) {
  final dLat = _toRad(lat2 - lat1);
  final dLng = _toRad(lng2 - lng1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return _earthRadiusKm * c;
}

/// Initial bearing (forward azimuth) from point 1 to point 2, in degrees [0-360).
double calculateBearing(double lat1, double lng1, double lat2, double lng2) {
  final dLng = _toRad(lng2 - lng1);
  final rLat1 = _toRad(lat1);
  final rLat2 = _toRad(lat2);
  final y = sin(dLng) * cos(rLat2);
  final x = cos(rLat1) * sin(rLat2) - sin(rLat1) * cos(rLat2) * cos(dLng);
  final theta = atan2(y, x);
  return (_toDeg(theta) + 360) % 360;
}

/// Format distance for display — metres below 1 km, kilometres above.
String formatDistance(double km) {
  if (km < 0.01) return '< 10 m';
  if (km < 1.0) return '${(km * 1000).round()} m';
  if (km < 10.0) return '${km.toStringAsFixed(1)} km';
  return '${km.round()} km';
}

/// Format ETA given distance in km and speed in km/h.
String formatEta(double km, double speedKmh) {
  if (speedKmh <= 0) return '--';
  final minutes = (km / speedKmh * 60).round();
  if (minutes < 1) return '< 1 min';
  if (minutes < 60) return '$minutes min';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (m == 0) return '${h}h';
  return '${h}h ${m}min';
}

double _toRad(double deg) => deg * pi / 180;
double _toDeg(double rad) => rad * 180 / pi;
