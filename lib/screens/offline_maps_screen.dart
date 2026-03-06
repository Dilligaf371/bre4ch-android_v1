// =============================================================================
// BRE4CH - Offline Maps Screen
// Download and manage offline map regions
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../data/map_regions.dart';
import '../providers/offline_map_provider.dart';
import '../services/offline_map_service.dart';
import '../widgets/common/header_bar.dart';
import '../widgets/common/palantir_card.dart';

class OfflineMapsScreen extends ConsumerWidget {
  const OfflineMapsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(offlineMapProvider);
    final notifier = ref.read(offlineMapProvider.notifier);

    return Scaffold(
      backgroundColor: Palantir.bg,
      body: SafeArea(
        child: Column(
          children: [
            const HeaderBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.arrow_back_ios, color: Palantir.textMuted, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text('OFFLINE MAPS', style: AppTextStyles.headline),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Enable toggle + storage info
                    PalantirCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.cloud_download_outlined, color: Palantir.accent, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'ENABLE OFFLINE MAPS',
                                  style: AppTextStyles.mono(
                                    size: 13,
                                    weight: FontWeight.w600,
                                    color: Palantir.text,
                                  ),
                                ),
                              ),
                              Switch.adaptive(
                                value: state.offlineEnabled,
                                onChanged: (v) => notifier.toggleOffline(v),
                                activeColor: Palantir.accent,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.storage, color: Palantir.textMuted, size: 14),
                              const SizedBox(width: 8),
                              Text(
                                'Storage: ${state.storageUsedLabel}',
                                style: AppTextStyles.mono(size: 11, color: Palantir.textMuted),
                              ),
                              const Spacer(),
                              Text(
                                '${state.downloadedRegions.length} / ${mapRegions.length} regions',
                                style: AppTextStyles.mono(size: 11, color: Palantir.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Region list
                    ...mapRegions.map((region) => _buildRegionTile(context, region, state, notifier)),
                    const SizedBox(height: 12),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _actionButton(
                            'DELETE ALL',
                            Icons.delete_outline,
                            Palantir.danger,
                            state.downloadedRegions.isEmpty ? null : () => _confirmDeleteAll(context, notifier),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _actionButton(
                            'DOWNLOAD ALL',
                            Icons.download,
                            Palantir.accent,
                            state.currentlyDownloading != null ? null : () => _downloadAll(notifier),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionTile(BuildContext context, MapRegion region, OfflineMapState state, OfflineMapNotifier notifier) {
    final isDownloaded = state.downloadedRegions.contains(region.id);
    final isDownloading = state.currentlyDownloading == region.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PalantirCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(region.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        region.name,
                        style: AppTextStyles.mono(size: 13, weight: FontWeight.w600, color: Palantir.text),
                      ),
                      Text(
                        '~${region.estimatedSizeMB} MB',
                        style: AppTextStyles.mono(size: 10, color: Palantir.textMuted),
                      ),
                    ],
                  ),
                ),
                if (isDownloaded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Palantir.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: Palantir.success, size: 12),
                        const SizedBox(width: 4),
                        Text('SAVED', style: AppTextStyles.mono(size: 9, weight: FontWeight.w700, color: Palantir.success)),
                      ],
                    ),
                  )
                else if (isDownloading)
                  GestureDetector(
                    onTap: () => notifier.cancelDownload(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Palantir.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stop, color: Palantir.accent, size: 12),
                          const SizedBox(width: 4),
                          Text('CANCEL', style: AppTextStyles.mono(size: 9, weight: FontWeight.w700, color: Palantir.accent)),
                        ],
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: state.currentlyDownloading != null ? null : () => notifier.downloadRegion(region),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: state.currentlyDownloading != null
                            ? Palantir.border
                            : Palantir.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.download,
                            color: state.currentlyDownloading != null ? Palantir.textMuted : Palantir.accent,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'DOWNLOAD',
                            style: AppTextStyles.mono(
                              size: 9,
                              weight: FontWeight.w700,
                              color: state.currentlyDownloading != null ? Palantir.textMuted : Palantir.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (isDownloading) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: state.downloadProgress,
                  backgroundColor: Palantir.border,
                  valueColor: const AlwaysStoppedAnimation(Palantir.accent),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(state.downloadProgress * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.mono(size: 10, color: Palantir.accent),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: onTap != null ? color.withValues(alpha: 0.12) : Palantir.border,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onTap != null ? color.withValues(alpha: 0.3) : Palantir.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: onTap != null ? color : Palantir.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.mono(
                size: 11,
                weight: FontWeight.w700,
                color: onTap != null ? color : Palantir.textMuted,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context, OfflineMapNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Palantir.surface,
        title: Text('DELETE ALL MAPS', style: AppTextStyles.mono(size: 14, weight: FontWeight.w700, color: Palantir.danger)),
        content: Text(
          'This will remove all downloaded map data. Continue?',
          style: AppTextStyles.sans(size: 13, color: Palantir.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: AppTextStyles.mono(size: 12, color: Palantir.textMuted)),
          ),
          TextButton(
            onPressed: () {
              notifier.deleteAll();
              Navigator.pop(ctx);
            },
            child: Text('DELETE', style: AppTextStyles.mono(size: 12, color: Palantir.danger)),
          ),
        ],
      ),
    );
  }

  void _downloadAll(OfflineMapNotifier notifier) async {
    for (final region in mapRegions) {
      final downloaded = await OfflineMapService.instance.isRegionDownloaded(region.id);
      if (!downloaded) {
        await notifier.downloadRegion(region);
      }
    }
  }
}
