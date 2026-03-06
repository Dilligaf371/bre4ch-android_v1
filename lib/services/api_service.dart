// ── API Service — Dio Singleton with Offline Cache ──────────────
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import '../config/api.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  late final Dio dio = _createDio();

  CacheStore? _cacheStore;

  /// Resolves TTL for a given URL based on endpoint matching.
  Duration _ttlForUrl(String url) {
    if (url.contains('/headlines')) return CacheTtl.headlines;
    if (url.contains('/alerts')) return CacheTtl.alerts;
    if (url.contains('/airports/status')) return CacheTtl.airportsStatus;
    if (url.contains('/forces/')) return CacheTtl.forces;
    if (url.contains('/centcom')) return CacheTtl.centcom;
    if (url.contains('/liveuamap')) return CacheTtl.liveuamap;
    if (url.contains('/sources/status')) return CacheTtl.sourcesStatus;
    if (url.contains('/cyber')) return CacheTtl.cyber;
    if (url.contains('/stats')) return CacheTtl.stats;
    return CacheTtl.defaultTtl;
  }

  Dio _createDio() {
    final d = Dio(BaseOptions(
      baseUrl: Api.base,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      responseType: ResponseType.json,
    ));

    // Logging interceptor in debug mode
    if (kDebugMode) {
      d.interceptors.add(LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (o) => debugPrint('[DIO] $o'),
      ));
    }

    // Error handling interceptor
    d.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) {
        if (kDebugMode) {
          debugPrint('[DIO ERROR] ${e.type}: ${e.message}');
        }
        handler.next(e);
      },
    ));

    return d;
  }

  /// Initialize in-memory cache with stale fallback. Call once at app startup.
  Future<void> initCache() async {
    _cacheStore = MemCacheStore(maxSize: 50, maxEntrySize: 500000);

    final cacheOptions = CacheOptions(
      store: _cacheStore!,
      policy: CachePolicy.refreshForceCache,
      maxStale: const Duration(days: 7),
      hitCacheOnErrorExcept: [], // use cache on ALL error codes
    );

    dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));

    if (kDebugMode) {
      debugPrint('[CACHE] Memory cache initialized (maxSize=50)');
    }
  }

  /// GET request with per-endpoint TTL caching.
  Future<Response<T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    // Merge cache-specific options per endpoint
    final ttl = _ttlForUrl(url);
    final cacheExtra = _cacheStore != null
        ? CacheOptions(
            store: _cacheStore,
            maxStale: ttl,
          ).toExtra()
        : <String, dynamic>{};

    final merged = (options ?? Options()).copyWith(
      extra: {
        ...?options?.extra,
        ...cacheExtra,
      },
    );

    return dio.get<T>(
      url,
      queryParameters: queryParameters,
      options: merged,
    );
  }

  /// POST request with full URL (no caching — POST requests are write ops)
  Future<Response<T>> post<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.post<T>(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
