// =============================================================================
// BRE4CH - Offline Map Provider
// State management for offline map downloads
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/map_regions.dart';
import '../services/offline_map_service.dart';

class OfflineMapState {
  final Set<String> downloadedRegions;
  final String? currentlyDownloading;
  final double downloadProgress;
  final bool offlineEnabled;
  final int storageUsedBytes;

  const OfflineMapState({
    this.downloadedRegions = const {},
    this.currentlyDownloading,
    this.downloadProgress = 0.0,
    this.offlineEnabled = false,
    this.storageUsedBytes = 0,
  });

  OfflineMapState copyWith({
    Set<String>? downloadedRegions,
    String? currentlyDownloading,
    double? downloadProgress,
    bool? offlineEnabled,
    int? storageUsedBytes,
    bool clearCurrentDownload = false,
  }) {
    return OfflineMapState(
      downloadedRegions: downloadedRegions ?? this.downloadedRegions,
      currentlyDownloading: clearCurrentDownload ? null : (currentlyDownloading ?? this.currentlyDownloading),
      downloadProgress: downloadProgress ?? this.downloadProgress,
      offlineEnabled: offlineEnabled ?? this.offlineEnabled,
      storageUsedBytes: storageUsedBytes ?? this.storageUsedBytes,
    );
  }

  String get storageUsedLabel {
    if (storageUsedBytes < 1024 * 1024) {
      return '${(storageUsedBytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${(storageUsedBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class OfflineMapNotifier extends StateNotifier<OfflineMapState> {
  final OfflineMapService _service = OfflineMapService.instance;

  OfflineMapNotifier() : super(const OfflineMapState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final downloaded = await _service.getDownloadedRegions();
    final enabled = await _service.isOfflineEnabled();
    final storage = await _service.getStorageUsedBytes();
    state = state.copyWith(
      downloadedRegions: downloaded,
      offlineEnabled: enabled,
      storageUsedBytes: storage,
    );
  }

  Future<void> toggleOffline(bool enabled) async {
    await _service.setOfflineEnabled(enabled);
    state = state.copyWith(offlineEnabled: enabled);
  }

  Future<void> downloadRegion(MapRegion region) async {
    if (state.currentlyDownloading != null) return;

    state = state.copyWith(
      currentlyDownloading: region.id,
      downloadProgress: 0.0,
    );

    await _service.downloadRegion(
      region,
      onProgress: (progress) {
        state = state.copyWith(downloadProgress: progress);
      },
    );

    final downloaded = await _service.getDownloadedRegions();
    final storage = await _service.getStorageUsedBytes();
    state = state.copyWith(
      downloadedRegions: downloaded,
      storageUsedBytes: storage,
      clearCurrentDownload: true,
      downloadProgress: 0.0,
    );
  }

  void cancelDownload() {
    _service.cancelDownload();
    state = state.copyWith(clearCurrentDownload: true, downloadProgress: 0.0);
  }

  Future<void> deleteRegion(String regionId) async {
    await _service.deleteRegion(regionId);
    final downloaded = await _service.getDownloadedRegions();
    final storage = await _service.getStorageUsedBytes();
    state = state.copyWith(
      downloadedRegions: downloaded,
      storageUsedBytes: storage,
    );
  }

  Future<void> deleteAll() async {
    await _service.deleteAllData();
    state = state.copyWith(
      downloadedRegions: {},
      storageUsedBytes: 0,
    );
  }

  Future<void> refresh() async {
    await _loadState();
  }
}

final offlineMapProvider =
    StateNotifierProvider<OfflineMapNotifier, OfflineMapState>(
  (ref) => OfflineMapNotifier(),
);
