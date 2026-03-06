// =============================================================================
// BRE4CH - Cached Tile Provider for Offline Maps
// Persistent tile cache via HiveCacheStore + fallback to MemCacheStore
// =============================================================================

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:path_provider/path_provider.dart';

CacheStore? _persistentStore;

/// Initialize persistent tile cache. Call once at app startup.
Future<void> initTileCache() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    _persistentStore = HiveCacheStore(
      '${dir.path}/tiles_cache',
      hiveBoxName: 'breach_tiles',
    );
    debugPrint('[TILES] Persistent cache initialized at ${dir.path}/tiles_cache');
  } catch (e) {
    debugPrint('[TILES] Failed to init persistent cache: $e');
  }
}

/// Returns the persistent cache store (or null if not initialized).
CacheStore? get persistentStore => _persistentStore;

/// Shared cached tile provider for all FlutterMap instances.
/// Uses persistent storage if initialized, otherwise falls back to memory.
CachedTileProvider createCachedTileProvider() {
  // Use default MemCacheStore() values (7MB/512KB) — guaranteed to pass assertion
  final store = _persistentStore ?? MemCacheStore();
  return CachedTileProvider(
    maxStale: const Duration(days: 365),
    store: store,
  );
}
