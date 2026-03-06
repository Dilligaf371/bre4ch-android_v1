// ── Liveuamap Service ────────────────────────────────────────────
import '../config/api.dart';
import 'api_service.dart';

class LiveuamapService {
  LiveuamapService._();
  static final LiveuamapService instance = LiveuamapService._();

  final _api = ApiService.instance;

  /// Fetch liveuamap events from the backend proxy.
  /// Returns a list of event maps: {id, name, lat, lng, time, source, url, region}.
  Future<List<Map<String, dynamic>>> fetchEvents({
    String region = 'middleeast',
    int count = 20,
  }) async {
    try {
      final response = await _api.get<dynamic>(
        Api.liveuamap,
        queryParameters: {'region': region, 'count': count},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final events = data['events'];
        if (events is List) {
          return events.cast<Map<String, dynamic>>();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
