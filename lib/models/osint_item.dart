// ── OSINT Item Model ─────────────────────────────────────────────

enum OsintSource {
  // International wire services
  reuters, aljazeera, dod, idf, ap, centcom, flightradar, bloomberg,
  // GCC newspapers — UAE
  khaleejtimes, thenational, gulfnews, gulftoday, emirates247,
  // GCC newspapers — Saudi
  arabnews, saudigazette,
  // GCC newspapers — Qatar
  gulftimes, peninsulaQatar, qatarTribune,
  // GCC newspapers — Bahrain
  gulfDailyNews, dailyTribuneBh,
  // GCC newspapers — Oman
  timesOfOman, omanObserver,
  // GCC official news agencies
  wam, spa, qna, bna, kuna, omanNews,
  // Israel
  timesOfIsrael, jpost,
}

enum OsintPriority { flash, immediate, priority, routine }

class OsintSourceConfig {
  final String label;
  final int colorValue;

  const OsintSourceConfig({required this.label, required this.colorValue});
}

class OsintItem {
  final String id;
  final OsintSource source;
  final String title;
  final String summary;
  final int timestamp;
  final OsintPriority priority;
  final String region;
  final String? url;

  const OsintItem({
    required this.id,
    required this.source,
    required this.title,
    required this.summary,
    required this.timestamp,
    required this.priority,
    required this.region,
    this.url,
  });

  OsintItem copyWith({
    String? id,
    OsintSource? source,
    String? title,
    String? summary,
    int? timestamp,
    OsintPriority? priority,
    String? region,
    String? url,
  }) {
    return OsintItem(
      id: id ?? this.id,
      source: source ?? this.source,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      timestamp: timestamp ?? this.timestamp,
      priority: priority ?? this.priority,
      region: region ?? this.region,
      url: url ?? this.url,
    );
  }
}
