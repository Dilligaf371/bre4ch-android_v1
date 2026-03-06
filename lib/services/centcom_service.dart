// ── CENTCOM Briefing Service ─────────────────────────────────────
import '../config/api.dart';
import '../models/centcom_briefing.dart';
import 'api_service.dart';

class CentcomService {
  CentcomService._();
  static final CentcomService instance = CentcomService._();

  final _api = ApiService.instance;

  /// Fetch CENTCOM briefings from the backend.
  /// Optionally filter by [category] query param.
  Future<List<CentcomBriefing>> fetchBriefings({String? category}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;

      final response = await _api.get<dynamic>(
        Api.centcomBriefings,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final items = data['items'];
        if (items is List) {
          return items
              .map((e) => CentcomBriefing.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (_) {
      // Backend offline — return empty
      return [];
    }
  }
}
