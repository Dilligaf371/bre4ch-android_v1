// =============================================================================
// BRE4CH - Push Notification Settings Screen
// Configure country, city, type, and severity alert preferences
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../widgets/common/header_bar.dart';
import '../widgets/common/palantir_card.dart';
import '../providers/notification_preferences_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPreferencesProvider);
    final notifier = ref.read(notificationPreferencesProvider.notifier);

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
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back_ios, size: 14, color: Palantir.accent),
                          const SizedBox(width: 4),
                          Text('SETTINGS', style: AppTextStyles.mono(size: 11, color: Palantir.accent)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text('PUSH NOTIFICATIONS',
                        style: AppTextStyles.mono(size: 16, weight: FontWeight.w700, color: Palantir.text, letterSpacing: 2)),
                    const SizedBox(height: 4),
                    Text('Configure real-time alert delivery',
                        style: AppTextStyles.sans(size: 12, color: Palantir.textMuted)),
                    const SizedBox(height: 20),

                    // Master toggle
                    _buildMasterToggle(prefs, notifier),
                    const SizedBox(height: 16),

                    // Severity
                    _buildSeveritySection(prefs, notifier),
                    const SizedBox(height: 16),

                    // Alert types
                    _buildTypeSection(prefs, notifier),
                    const SizedBox(height: 16),

                    // Countries
                    _buildCountrySection(prefs, notifier),
                    const SizedBox(height: 16),

                    // Cities (only show if countries selected)
                    if (prefs.countries.isNotEmpty)
                      _buildCitySection(prefs, notifier),

                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Notifications are delivered via Firebase Cloud Messaging',
                        style: AppTextStyles.mono(size: 9, color: Palantir.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterToggle(NotificationPreferences prefs, NotificationPreferencesNotifier notifier) {
    return PalantirCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: prefs.enabled
                  ? Palantir.accent.withValues(alpha: 0.15)
                  : Palantir.border,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              prefs.enabled ? Icons.notifications_active : Icons.notifications_off,
              color: prefs.enabled ? Palantir.accent : Palantir.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Push Notifications',
                    style: AppTextStyles.mono(size: 14, weight: FontWeight.w600, color: Palantir.text)),
                const SizedBox(height: 2),
                Text(
                  prefs.enabled ? 'Active — receiving alerts' : 'Disabled — no alerts',
                  style: AppTextStyles.sans(size: 11, color: prefs.enabled ? Palantir.success : Palantir.textMuted),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: prefs.enabled,
            onChanged: (v) => notifier.toggleEnabled(v),
            activeColor: Palantir.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildSeveritySection(NotificationPreferences prefs, NotificationPreferencesNotifier notifier) {
    return PalantirCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MINIMUM SEVERITY', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 4),
          Text('Which alert levels trigger a notification',
              style: AppTextStyles.sans(size: 11, color: Palantir.textMuted)),
          const SizedBox(height: 12),
          ...availableSeverities.entries.map((e) => _toggleRow(
            label: e.value,
            value: prefs.severities.contains(e.key),
            enabled: prefs.enabled,
            color: e.key == 'extreme' ? Palantir.danger
                 : e.key == 'severe' ? Palantir.orange
                 : Palantir.warning,
            onChanged: (v) => notifier.toggleSeverity(e.key, v),
          )),
        ],
      ),
    );
  }

  Widget _buildTypeSection(NotificationPreferences prefs, NotificationPreferencesNotifier notifier) {
    return PalantirCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ALERT TYPES', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 4),
          Text('What categories of alerts to receive',
              style: AppTextStyles.sans(size: 11, color: Palantir.textMuted)),
          const SizedBox(height: 12),
          ...availableTypes.entries.map((e) => _toggleRow(
            label: e.value,
            value: prefs.types.contains(e.key),
            enabled: prefs.enabled,
            color: e.key == 'danger' ? Palantir.danger
                 : e.key == 'shelter' ? Palantir.success
                 : e.key == 'airport' ? Palantir.info
                 : Palantir.purple,
            onChanged: (v) => notifier.toggleType(e.key, v),
          )),
        ],
      ),
    );
  }

  Widget _buildCountrySection(NotificationPreferences prefs, NotificationPreferencesNotifier notifier) {
    return PalantirCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COUNTRIES', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 4),
          Text('Receive alerts for selected countries',
              style: AppTextStyles.sans(size: 11, color: Palantir.textMuted)),
          const SizedBox(height: 12),
          ...availableCountries.entries.map((e) => _toggleRow(
            label: e.value,
            value: prefs.countries.contains(e.key),
            enabled: prefs.enabled,
            color: Palantir.accent,
            onChanged: (v) => notifier.toggleCountry(e.key, v),
          )),
        ],
      ),
    );
  }

  Widget _buildCitySection(NotificationPreferences prefs, NotificationPreferencesNotifier notifier) {
    // Build list of cities from selected countries
    final cities = <MapEntry<String, String>>[];
    for (final country in prefs.countries) {
      final countryCities = citiesByCountry[country];
      if (countryCities != null) {
        final countryLabel = availableCountries[country] ?? country;
        for (final city in countryCities.entries) {
          cities.add(MapEntry(city.key, '$countryLabel  ${city.value}'));
        }
      }
    }

    if (cities.isEmpty) return const SizedBox.shrink();

    return PalantirCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CITIES', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 4),
          Text('Fine-tune by city (optional)',
              style: AppTextStyles.sans(size: 11, color: Palantir.textMuted)),
          const SizedBox(height: 12),
          ...cities.map((e) => _toggleRow(
            label: e.value,
            value: prefs.cities.contains(e.key),
            enabled: prefs.enabled,
            color: Palantir.cyan,
            onChanged: (v) => notifier.toggleCity(e.key, v),
          )),
        ],
      ),
    );
  }

  Widget _toggleRow({
    required String label,
    required bool value,
    required bool enabled,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => onChanged(!value) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.sans(
                  size: 13,
                  color: enabled ? Palantir.text : Palantir.textMuted,
                ),
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }
}
