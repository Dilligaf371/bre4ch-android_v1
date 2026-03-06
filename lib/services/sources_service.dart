// ── Sources Service ──────────────────────────────────────────────
import '../config/api.dart';
import 'api_service.dart';

class SourcesService {
  SourcesService._();
  static final SourcesService instance = SourcesService._();

  final _api = ApiService.instance;

  /// Fetch current source status from backend.
  Future<Map<String, dynamic>> fetchStatus() async {
    try {
      final response = await _api.get<dynamic>(Api.sourcesStatus);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  /// Force a refresh of all RSS sources.
  Future<Map<String, dynamic>> forceRefresh() async {
    try {
      final response = await _api.post<dynamic>(Api.sourcesRefresh);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {};
    } catch (_) {
      return {};
    }
  }
}
