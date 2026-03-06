// =============================================================================
// BRE4CH - Offline Map Service
// Downloads map tiles for offline use, region by region
// =============================================================================

import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/map_regions.dart';

/// Tile coordinate helper
class TileCoord {
  final int x, y, z;
  const TileCoord(this.x, this.y, this.z);
}

class OfflineMapService {
  static final OfflineMapService instance = OfflineMapService._();
  OfflineMapService._();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static const _subdomains = ['a', 'b', 'c', 'd'];
  static const _prefsKey = 'offline_maps_downloaded';
  static const _prefsEnabledKey = 'offline_maps_enabled';

  // Zoom levels to download (5=continent, 13=street level)
  static const int _minZoom = 5;
  static const int _maxZoom = 13;

  bool _downloading = false;
  String? _currentRegionId;
  double _progress = 0.0;
  bool _cancelRequested = false;

  bool get isDownloading => _downloading;
  String? get currentRegionId => _currentRegionId;
  double get progress => _progress;

  // ── Tile coordinate math ──────────────────────────────────────

  static int lngToTileX(double lng, int zoom) {
    return ((lng + 180) / 360 * pow(2, zoom)).floor();
  }

  static int latToTileY(double lat, int zoom) {
    final latRad = lat * pi / 180;
    return ((1 - log(tan(latRad) + 1 / cos(latRad)) / pi) / 2 * pow(2, zoom)).floor();
  }

  /// Calculate all tile coordinates for a region at a given zoom level.
  static List<TileCoord> tilesForRegion(MapRegion region, int zoom) {
    final minX = lngToTileX(region.minLng, zoom);
    final maxX = lngToTileX(region.maxLng, zoom);
    final minY = latToTileY(region.maxLat, zoom);
    final maxY = latToTileY(region.minLat, zoom);

    final tiles = <TileCoord>[];
    for (int x = minX; x <= maxX; x++) {
      for (int y = minY; y <= maxY; y++) {
        tiles.add(TileCoord(x, y, zoom));
      }
    }
    return tiles;
  }

  /// Total tile count for a region across all zoom levels.
  static int totalTilesForRegion(MapRegion region) {
    int total = 0;
    for (int z = _minZoom; z <= _maxZoom; z++) {
      total += tilesForRegion(region, z).length;
    }
    return total;
  }

  // ── Download ──────────────────────────────────────────────────

  /// Download all tiles for a region and cache them via dio_cache_interceptor.
  Future<void> downloadRegion(
    MapRegion region, {
    Function(double)? onProgress,
  }) async {
    if (_downloading) return;

    _downloading = true;
    _currentRegionId = region.id;
    _progress = 0.0;
    _cancelRequested = false;

    try {
      int downloaded = 0;
      int totalTiles = totalTilesForRegion(region);
      int failed = 0;

      for (int z = _minZoom; z <= _maxZoom; z++) {
        final tiles = tilesForRegion(region, z);
        for (final tile in tiles) {
          if (_cancelRequested) {
            debugPrint('[OFFLINE] Download cancelled for ${region.id}');
            return;
          }

          final subdomain = _subdomains[(tile.x + tile.y) % _subdomains.length];
          final url = 'https://$subdomain.basemaps.cartocdn.com/dark_all/${tile.z}/${tile.x}/${tile.y}@2x.png';

          try {
            await _dio.get(url, options: Options(responseType: ResponseType.bytes));
          } catch (_) {
            failed++;
          }

          downloaded++;
          _progress = downloaded / totalTiles;
          onProgress?.call(_progress);
        }
      }

      // Mark as downloaded
      await _markDownloaded(region.id);
      debugPrint('[OFFLINE] Downloaded ${region.id}: $downloaded tiles ($failed failed)');
    } finally {
      _downloading = false;
      _currentRegionId = null;
      _progress = 0.0;
    }
  }

  void cancelDownload() {
    _cancelRequested = true;
  }

  // ── Storage management ────────────────────────────────────────

  Future<void> _markDownloaded(String regionId) async {
    final prefs = await SharedPreferences.getInstance();
    final downloaded = prefs.getStringList(_prefsKey) ?? [];
    if (!downloaded.contains(regionId)) {
      downloaded.add(regionId);
      await prefs.setStringList(_prefsKey, downloaded);
    }
  }

  Future<void> deleteRegion(String regionId) async {
    final prefs = await SharedPreferences.getInstance();
    final downloaded = prefs.getStringList(_prefsKey) ?? [];
    downloaded.remove(regionId);
    await prefs.setStringList(_prefsKey, downloaded);
  }

  Future<Set<String>> getDownloadedRegions() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_prefsKey) ?? []).toSet();
  }

  Future<bool> isRegionDownloaded(String regionId) async {
    final downloaded = await getDownloadedRegions();
    return downloaded.contains(regionId);
  }

  Future<bool> isOfflineEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsEnabledKey) ?? false;
  }

  Future<void> setOfflineEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsEnabledKey, enabled);
  }

  Future<int> getStorageUsedBytes() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${dir.path}/tiles_cache');
      if (!await cacheDir.exists()) return 0;

      int total = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          total += await entity.length();
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<void> deleteAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, []);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${dir.path}/tiles_cache');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('[OFFLINE] Error deleting cache: $e');
    }
  }
}
