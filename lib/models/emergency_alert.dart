// =============================================================================
// BRE4CH - Emergency Alert Model
// =============================================================================

enum AlertLevel { extreme, severe, moderate }

enum AlertAuthority { ncema, moi, mod, centcom, idf, coalition }

class EmergencyAlert {
  final String id;
  final AlertLevel level;
  final String headline;
  final String? headlineAr;
  final String body;
  final String? bodyAr;
  final String source;
  final String? sourceUrl;
  final AlertAuthority authority;
  final int timestamp;
  final String region;
  final bool dismissed;
  final int? readAt;
  final int expiresAt;

  const EmergencyAlert({
    required this.id,
    required this.level,
    required this.headline,
    this.headlineAr,
    required this.body,
    this.bodyAr,
    required this.source,
    this.sourceUrl,
    required this.authority,
    required this.timestamp,
    required this.region,
    this.dismissed = false,
    this.readAt,
    required this.expiresAt,
  });

  factory EmergencyAlert.fromJson(Map<String, dynamic> json) {
    return EmergencyAlert(
      id: json['id'] as String,
      level: AlertLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => AlertLevel.moderate,
      ),
      headline: json['headline'] as String,
      headlineAr: json['headlineAr'] as String?,
      body: json['body'] as String,
      bodyAr: json['bodyAr'] as String?,
      source: json['source'] as String,
      sourceUrl: json['sourceUrl'] as String?,
      authority: AlertAuthority.values.firstWhere(
        (e) => e.name == json['authority'],
        orElse: () => AlertAuthority.ncema,
      ),
      timestamp: json['timestamp'] as int,
      region: json['region'] as String,
      dismissed: json['dismissed'] as bool? ?? false,
      readAt: json['readAt'] as int?,
      expiresAt: json['expiresAt'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level.name,
      'headline': headline,
      'headlineAr': headlineAr,
      'body': body,
      'bodyAr': bodyAr,
      'source': source,
      'sourceUrl': sourceUrl,
      'authority': authority.name,
      'timestamp': timestamp,
      'region': region,
      'dismissed': dismissed,
      'readAt': readAt,
      'expiresAt': expiresAt,
    };
  }

  EmergencyAlert copyWith({
    String? id,
    AlertLevel? level,
    String? headline,
    String? headlineAr,
    String? body,
    String? bodyAr,
    String? source,
    String? sourceUrl,
    AlertAuthority? authority,
    int? timestamp,
    String? region,
    bool? dismissed,
    int? readAt,
    int? expiresAt,
  }) {
    return EmergencyAlert(
      id: id ?? this.id,
      level: level ?? this.level,
      headline: headline ?? this.headline,
      headlineAr: headlineAr ?? this.headlineAr,
      body: body ?? this.body,
      bodyAr: bodyAr ?? this.bodyAr,
      source: source ?? this.source,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      authority: authority ?? this.authority,
      timestamp: timestamp ?? this.timestamp,
      region: region ?? this.region,
      dismissed: dismissed ?? this.dismissed,
      readAt: readAt ?? this.readAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  bool get isExpired => DateTime.now().millisecondsSinceEpoch > expiresAt;
}
