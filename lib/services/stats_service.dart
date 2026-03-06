// ── Stats Service ────────────────────────────────────────────────
// Fetches baseline attack stats from the backend.
// Falls back to hardcoded baseline if backend is unreachable.

import '../config/api.dart';
import '../models/attack_stats.dart';
import 'api_service.dart';

class StatsService {
  StatsService._();
  static final StatsService instance = StatsService._();

  final _api = ApiService.instance;

  /// Fetch baseline attack statistics.
  Future<AttackStats?> fetchBaseline() async {
    try {
      final response = await _api.get<dynamic>(Api.statsBaseline);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return AttackStats.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
