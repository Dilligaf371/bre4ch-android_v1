// ── Cyber Service ────────────────────────────────────────────────
// Fetches cyber ops + threat group data from the backend.
// Falls back to hardcoded data if backend is unreachable.

import '../config/api.dart';
import '../data/cyber_ops.dart';
import '../models/attack_stats.dart';
import 'api_service.dart';

class CyberService {
  CyberService._();
  static final CyberService instance = CyberService._();

  final _api = ApiService.instance;

  /// Fetch full cyber metrics (allied ops + Iranian threats).
  Future<CyberMetrics> fetchCyberMetrics() async {
    try {
      final response = await _api.get<dynamic>(Api.cyber);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final alliedMeta = data['alliedMeta'] as Map<String, dynamic>?;
        final ops = data['alliedOps'] as List<dynamic>?;
        final iranianMeta = data['iranianMeta'] as Map<String, dynamic>?;
        final groups = data['iranianGroups'] as List<dynamic>?;

        return CyberMetrics(
          alliedMeta: CyberSide(
            label: alliedMeta?['label'] as String? ?? 'ALLIED CYBER/EW OPS',
            color: alliedMeta?['color'] as String? ?? 'text-green-400',
          ),
          alliedOps: ops
                  ?.map((e) => CyberOp.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              alliedCyberOps,
          iranianMeta: CyberSide(
            label: iranianMeta?['label'] as String? ?? 'IRANIAN CYBER THREATS',
            color: iranianMeta?['color'] as String? ?? 'text-red-400',
          ),
          iranianGroups: groups
                  ?.map((e) =>
                      CyberThreatGroup.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              iranianThreatGroups,
        );
      }
      return cyberMetrics;
    } catch (_) {
      return cyberMetrics;
    }
  }
}
