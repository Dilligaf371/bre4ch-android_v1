// =============================================================================
// BRE4CH - Offline Map Regions
// Bounding boxes for downloadable map regions
// =============================================================================

class MapRegion {
  final String id;
  final String name;
  final String flag;
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;
  final int estimatedSizeMB;

  const MapRegion({
    required this.id,
    required this.name,
    required this.flag,
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
    required this.estimatedSizeMB,
  });
}

const List<MapRegion> mapRegions = [
  // UAE
  MapRegion(id: 'uae', name: 'UAE', flag: '\u{1F1E6}\u{1F1EA}',
    minLat: 22.6, maxLat: 26.1, minLng: 51.5, maxLng: 56.4, estimatedSizeMB: 85),
  // Israel
  MapRegion(id: 'israel', name: 'Israel', flag: '\u{1F1EE}\u{1F1F1}',
    minLat: 29.5, maxLat: 33.3, minLng: 34.2, maxLng: 35.9, estimatedSizeMB: 45),
  // KSA — split by region
  MapRegion(id: 'ksa-riyadh', name: 'KSA — Riyadh', flag: '\u{1F1F8}\u{1F1E6}',
    minLat: 23.5, maxLat: 25.5, minLng: 45.5, maxLng: 47.5, estimatedSizeMB: 60),
  MapRegion(id: 'ksa-jeddah', name: 'KSA — Jeddah', flag: '\u{1F1F8}\u{1F1E6}',
    minLat: 20.5, maxLat: 22.5, minLng: 38.5, maxLng: 40.5, estimatedSizeMB: 50),
  MapRegion(id: 'ksa-eastern', name: 'KSA — Eastern', flag: '\u{1F1F8}\u{1F1E6}',
    minLat: 25.0, maxLat: 27.0, minLng: 49.0, maxLng: 51.0, estimatedSizeMB: 45),
  MapRegion(id: 'ksa-makkah', name: 'KSA — Makkah', flag: '\u{1F1F8}\u{1F1E6}',
    minLat: 20.5, maxLat: 22.0, minLng: 39.0, maxLng: 41.0, estimatedSizeMB: 40),
  // Bahrain
  MapRegion(id: 'bahrain', name: 'Bahrain', flag: '\u{1F1E7}\u{1F1ED}',
    minLat: 25.8, maxLat: 26.3, minLng: 50.3, maxLng: 50.8, estimatedSizeMB: 15),
  // Qatar
  MapRegion(id: 'qatar', name: 'Qatar', flag: '\u{1F1F6}\u{1F1E6}',
    minLat: 24.5, maxLat: 26.2, minLng: 50.7, maxLng: 51.7, estimatedSizeMB: 25),
  // Kuwait
  MapRegion(id: 'kuwait', name: 'Kuwait', flag: '\u{1F1F0}\u{1F1FC}',
    minLat: 28.5, maxLat: 30.1, minLng: 46.5, maxLng: 48.5, estimatedSizeMB: 30),
  // Oman
  MapRegion(id: 'oman', name: 'Oman', flag: '\u{1F1F4}\u{1F1F2}',
    minLat: 16.6, maxLat: 26.4, minLng: 52.0, maxLng: 59.8, estimatedSizeMB: 95),
  // Jordan
  MapRegion(id: 'jordan', name: 'Jordan', flag: '\u{1F1EF}\u{1F1F4}',
    minLat: 29.2, maxLat: 33.4, minLng: 34.9, maxLng: 39.3, estimatedSizeMB: 55),
  // Lebanon
  MapRegion(id: 'lebanon', name: 'Lebanon', flag: '\u{1F1F1}\u{1F1E7}',
    minLat: 33.0, maxLat: 34.7, minLng: 35.1, maxLng: 36.6, estimatedSizeMB: 25),
  // Iran
  MapRegion(id: 'iran', name: 'Iran', flag: '\u{1F1EE}\u{1F1F7}',
    minLat: 25.0, maxLat: 40.0, minLng: 44.0, maxLng: 63.5, estimatedSizeMB: 200),
];
