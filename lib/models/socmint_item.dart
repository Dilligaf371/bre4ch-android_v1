// ── SOCMINT Item Model ───────────────────────────────────────────

enum SocmintPlatform { telegram, snapchat, x }

enum SocmintSeverity { critical, high, medium, low }

class SocmintItem {
  final String id;
  final SocmintPlatform platform;
  final String source;
  final String content;
  final int timestamp;
  final SocmintSeverity severity;
  final String language;
  final String? location;
  final bool flagged;

  const SocmintItem({
    required this.id,
    required this.platform,
    required this.source,
    required this.content,
    required this.timestamp,
    required this.severity,
    required this.language,
    this.location,
    required this.flagged,
  });

  SocmintItem copyWith({
    String? id,
    SocmintPlatform? platform,
    String? source,
    String? content,
    int? timestamp,
    SocmintSeverity? severity,
    String? language,
    String? location,
    bool? flagged,
  }) {
    return SocmintItem(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      source: source ?? this.source,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      language: language ?? this.language,
      location: location ?? this.location,
      flagged: flagged ?? this.flagged,
    );
  }
}
