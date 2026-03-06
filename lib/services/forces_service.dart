// ── Forces Service ───────────────────────────────────────────────
// Fetches axis + coalition force feeds from the backend.
// Falls back to hardcoded data if backend is unreachable.

import '../config/api.dart';
import '../models/attack_stats.dart';
import '../data/axis_feeds.dart' as fallback_axis;
import '../data/coalition_feeds.dart' as fallback_coalition;
import 'api_service.dart';

class ForcesService {
  ForcesService._();
  static final ForcesService instance = ForcesService._();

  final _api = ApiService.instance;

  /// Fetch Axis of Resistance feeds.
  Future<List<CountryFeed>> fetchAxisFeeds() async {
    try {
      final response = await _api.get<dynamic>(Api.forcesAxis);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final feeds = data['feeds'];
        if (feeds is List) {
          return feeds
              .map((e) => CountryFeed.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return fallback_axis.axisFeeds;
    } catch (_) {
      return fallback_axis.axisFeeds;
    }
  }

  /// Fetch Coalition feeds.
  Future<List<CountryFeed>> fetchCoalitionFeeds() async {
    try {
      final response = await _api.get<dynamic>(Api.forcesCoalition);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final feeds = data['feeds'];
        if (feeds is List) {
          return feeds
              .map((e) => CountryFeed.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return fallback_coalition.coalitionFeeds;
    } catch (_) {
      return fallback_coalition.coalitionFeeds;
    }
  }
}
