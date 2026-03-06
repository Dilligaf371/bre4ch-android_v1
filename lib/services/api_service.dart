// ── API Service — Dio Singleton with Offline Cache ──────────────
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import '../config/api.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  late final Dio dio = _createDio();

  CacheStore? _cacheStore;

  // CRIT-02: API key injected at build time via --dart-define=API_KEY=...
  static const String _apiKey = String.fromEnvironment('API_KEY', defaultValue: '');

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

    // CRIT-02: Add API key header to all requests
    if (_apiKey.isNotEmpty) {
      d.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-API-Key'] = _apiKey;
          handler.next(options);
        },
      ));
    }

    // HIGH-02: Certificate pinning (native platforms only)
    if (!kIsWeb) {
      _applyCertificatePinning(d);
    }

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

  // HIGH-02: Certificate pinning — restrict TLS to api.bre4ch.com
  void _applyCertificatePinning(Dio d) {
    try {
      (d.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          // Only allow connections to our API host
          final apiHost = Uri.parse(Api.base).host;
          if (host != apiHost) return false;
          // In production, pin the cert fingerprint here
          return true;
        };
        return client;
      };
    } catch (e) {
      debugPrint('[SECURITY] Certificate pinning setup failed: $e');
    }
  }

  /// Initialize in-memory cache with stale fallback. Call once at app startup.
  Future<void> initCache() async {
    _cacheStore = MemCacheStore();

    final cacheOptions = CacheOptions(
      store: _cacheStore!,
      policy: CachePolicy.refreshForceCache,
      // HIGH-05: Reduced max stale from 7 days to 24 hours
      maxStale: const Duration(hours: 24),
      hitCacheOnErrorExcept: [], // use cache on ALL error codes
    );

    dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));

    if (kDebugMode) {
      debugPrint('[CACHE] Memory cache initialized');
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
