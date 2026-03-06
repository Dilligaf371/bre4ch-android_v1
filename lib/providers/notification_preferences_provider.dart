// =============================================================================
// BRE4CH - Notification Preferences Provider
// Manages user push notification preferences with persistence
// =============================================================================

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/push_notification_service.dart';

// ── Preference State ────────────────────────────────────────────────

class NotificationPreferences {
  final bool enabled;
  final Set<String> countries;
  final Set<String> cities;
  final Set<String> types;
  final Set<String> severities;

  const NotificationPreferences({
    this.enabled = false,
    this.countries = const {},
    this.cities = const {},
    this.types = const {'danger'},
    this.severities = const {'extreme', 'severe'},
  });

  NotificationPreferences copyWith({
    bool? enabled,
    Set<String>? countries,
    Set<String>? cities,
    Set<String>? types,
    Set<String>? severities,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      countries: countries ?? this.countries,
      cities: cities ?? this.cities,
      types: types ?? this.types,
      severities: severities ?? this.severities,
    );
  }
}

// ── Available Options ───────────────────────────────────────────────

const Map<String, String> availableCountries = {
  'uae': '🇦🇪  UAE',
  'israel': '🇮🇱  Israel',
  'iran': '🇮🇷  Iran',
  'ksa': '🇸🇦  Saudi Arabia',
  'kuwait': '🇰🇼  Kuwait',
  'bahrain': '🇧🇭  Bahrain',
  'qatar': '🇶🇦  Qatar',
  'oman': '🇴🇲  Oman',
  'jordan': '🇯🇴  Jordan',
  'lebanon': '🇱🇧  Lebanon',
};

const Map<String, Map<String, String>> citiesByCountry = {
  'uae': {
    'dubai': 'Dubai',
    'abu_dhabi': 'Abu Dhabi',
    'sharjah': 'Sharjah',
    'ajman': 'Ajman',
    'rak': 'Ras Al Khaimah',
    'fujairah': 'Fujairah',
  },
  'israel': {
    'tel_aviv': 'Tel Aviv',
    'jerusalem': 'Jerusalem',
    'haifa': 'Haifa',
    'beer_sheva': "Be'er Sheva",
    'netanya': 'Netanya',
  },
  'ksa': {
    'riyadh': 'Riyadh',
    'jeddah': 'Jeddah',
    'dammam': 'Dammam',
  },
  'qatar': {'doha': 'Doha'},
  'bahrain': {'manama': 'Manama'},
  'kuwait': {'kuwait_city': 'Kuwait City'},
  'oman': {'muscat': 'Muscat'},
  'jordan': {'amman': 'Amman'},
  'lebanon': {'beirut': 'Beirut'},
  'iran': {'tehran': 'Tehran', 'isfahan': 'Isfahan'},
};

const Map<String, String> availableTypes = {
  'danger': '⚠️  Immediate Danger',
  'shelter': '🛡️  Shelters',
  'embassy': '🏛️  Embassies',
  'airport': '✈️  Airports',
};

const Map<String, String> availableSeverities = {
  'extreme': '🔴  EXTREME',
  'severe': '🟠  SEVERE',
  'moderate': '🟡  MODERATE',
};

// ── Notifier ────────────────────────────────────────────────────────

class NotificationPreferencesNotifier
    extends StateNotifier<NotificationPreferences> {
  NotificationPreferencesNotifier() : super(const NotificationPreferences()) {
    _load();
  }

  // Lazy — avoid touching Firebase on web (not initialized)
  PushNotificationService? get _push => kIsWeb ? null : PushNotificationService.instance;

  static const _prefsPrefix = 'notif_pref_';

  Future<void> _load() async {
    try {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('${_prefsPrefix}enabled') ?? false;
    final countries =
        (prefs.getStringList('${_prefsPrefix}countries') ?? []).toSet();
    final cities =
        (prefs.getStringList('${_prefsPrefix}cities') ?? []).toSet();
    final types =
        (prefs.getStringList('${_prefsPrefix}types') ?? ['danger']).toSet();
    final severities =
        (prefs.getStringList('${_prefsPrefix}severities') ?? ['extreme', 'severe'])
            .toSet();

    state = NotificationPreferences(
      enabled: enabled,
      countries: countries,
      cities: cities,
      types: types,
      severities: severities,
    );
    } catch (e) {
      debugPrint('[NOTIF] Prefs load error: $e');
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prefsPrefix}enabled', state.enabled);
    await prefs.setStringList(
        '${_prefsPrefix}countries', state.countries.toList());
    await prefs.setStringList('${_prefsPrefix}cities', state.cities.toList());
    await prefs.setStringList('${_prefsPrefix}types', state.types.toList());
    await prefs.setStringList(
        '${_prefsPrefix}severities', state.severities.toList());
  }

  Future<void> toggleEnabled(bool value) async {
    state = state.copyWith(enabled: value);
    await _save();
    // FCM sync in background — don't block UI
    if (value) {
      _push?.initialize().then((_) => _syncAllSubscriptions()).catchError((e) {
        debugPrint('[NOTIF] Enable sync error: $e');
      });
    } else {
      _unsubscribeAll().catchError((e) {
        debugPrint('[NOTIF] Disable sync error: $e');
      });
    }
  }

  Future<void> toggleCountry(String code, bool subscribe) async {
    final updated = Set<String>.from(state.countries);
    if (subscribe) {
      updated.add(code);
    } else {
      updated.remove(code);
      // Also remove cities of this country
      final countryCities = citiesByCountry[code]?.keys ?? [];
      final updatedCities = Set<String>.from(state.cities)
        ..removeAll(countryCities);
      state = state.copyWith(cities: updatedCities);
    }
    state = state.copyWith(countries: updated);
    await _save();
    // FCM sync in background
    _syncFcm(() async {
      if (subscribe) {
        await _push?.subscribeToCountry(code);
      } else {
        await _push?.unsubscribeFromCountry(code);
        for (final city in citiesByCountry[code]?.keys ?? <String>[]) {
          await _push?.unsubscribeFromCity(city);
        }
      }
    });
  }

  Future<void> toggleCity(String slug, bool subscribe) async {
    final updated = Set<String>.from(state.cities);
    if (subscribe) {
      updated.add(slug);
    } else {
      updated.remove(slug);
    }
    state = state.copyWith(cities: updated);
    await _save();
    _syncFcm(() async => subscribe
        ? await _push?.subscribeToCity(slug)
        : await _push?.unsubscribeFromCity(slug));
  }

  Future<void> toggleType(String type, bool subscribe) async {
    final updated = Set<String>.from(state.types);
    if (subscribe) {
      updated.add(type);
    } else {
      updated.remove(type);
    }
    state = state.copyWith(types: updated);
    await _save();
    _syncFcm(() async => subscribe
        ? await _push?.subscribeToType(type)
        : await _push?.unsubscribeFromType(type));
  }

  Future<void> toggleSeverity(String level, bool subscribe) async {
    final updated = Set<String>.from(state.severities);
    if (subscribe) {
      updated.add(level);
    } else {
      updated.remove(level);
    }
    state = state.copyWith(severities: updated);
    await _save();
    _syncFcm(() async => subscribe
        ? await _push?.subscribeToSeverity(level)
        : await _push?.unsubscribeFromSeverity(level));
  }

  /// Fire-and-forget FCM sync — never blocks UI
  void _syncFcm(Future<void> Function() action) {
    if (!state.enabled || _push == null) return;
    action().catchError((e) {
      debugPrint('[NOTIF] FCM sync error: $e');
    });
  }

  Future<void> _syncAllSubscriptions() async {
    for (final c in state.countries) {
      try { await _push?.subscribeToCountry(c); } catch (_) {}
    }
    for (final c in state.cities) {
      try { await _push?.subscribeToCity(c); } catch (_) {}
    }
    for (final t in state.types) {
      try { await _push?.subscribeToType(t); } catch (_) {}
    }
    for (final s in state.severities) {
      try { await _push?.subscribeToSeverity(s); } catch (_) {}
    }
    debugPrint('[NOTIF] Synced all subscriptions');
  }

  Future<void> _unsubscribeAll() async {
    for (final c in state.countries) {
      try { await _push?.unsubscribeFromCountry(c); } catch (_) {}
    }
    for (final c in state.cities) {
      try { await _push?.unsubscribeFromCity(c); } catch (_) {}
    }
    for (final t in state.types) {
      try { await _push?.unsubscribeFromType(t); } catch (_) {}
    }
    for (final s in state.severities) {
      try { await _push?.unsubscribeFromSeverity(s); } catch (_) {}
    }
    debugPrint('[NOTIF] Unsubscribed from all');
  }
}

// ── Provider ────────────────────────────────────────────────────────

final notificationPreferencesProvider = StateNotifierProvider<
    NotificationPreferencesNotifier, NotificationPreferences>((ref) {
  return NotificationPreferencesNotifier();
});
