// =============================================================================
// BRE4CH - Source Status & Mission Time Models
// =============================================================================

class SourceInfo {
  final String status;
  final int? lastFetch;
  final int? events;
  final int? items;
  final String? error;

  const SourceInfo({
    required this.status,
    this.lastFetch,
    this.events,
    this.items,
    this.error,
  });

  factory SourceInfo.fromJson(Map<String, dynamic> json) {
    return SourceInfo(
      status: json['status'] as String? ?? 'unknown',
      lastFetch: json['lastFetch'] as int?,
      events: json['events'] as int?,
      items: json['items'] as int?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'lastFetch': lastFetch,
      'events': events,
      'items': items,
      'error': error,
    };
  }

  SourceInfo copyWith({
    String? status,
    int? lastFetch,
    int? events,
    int? items,
    String? error,
  }) {
    return SourceInfo(
      status: status ?? this.status,
      lastFetch: lastFetch ?? this.lastFetch,
      events: events ?? this.events,
      items: items ?? this.items,
      error: error ?? this.error,
    );
  }
}

class SourceStatus {
  final int? lastRefresh;
  final int? nextRefresh;
  final int refreshCount;
  final Map<String, SourceInfo> sources;
  final bool running;
  final int intervalMs;
  final int headlineCount;

  const SourceStatus({
    this.lastRefresh,
    this.nextRefresh,
    this.refreshCount = 0,
    this.sources = const {},
    this.running = false,
    this.intervalMs = 30000,
    this.headlineCount = 0,
  });

  factory SourceStatus.fromJson(Map<String, dynamic> json) {
    final sourcesMap = <String, SourceInfo>{};
    if (json['sources'] is Map) {
      (json['sources'] as Map<String, dynamic>).forEach((key, value) {
        sourcesMap[key] = SourceInfo.fromJson(value as Map<String, dynamic>);
      });
    }
    return SourceStatus(
      lastRefresh: json['lastRefresh'] as int?,
      nextRefresh: json['nextRefresh'] as int?,
      refreshCount: json['refreshCount'] as int? ?? 0,
      sources: sourcesMap,
      running: json['running'] as bool? ?? false,
      intervalMs: json['intervalMs'] as int? ?? 30000,
      headlineCount: json['headlineCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastRefresh': lastRefresh,
      'nextRefresh': nextRefresh,
      'refreshCount': refreshCount,
      'sources': sources.map((key, value) => MapEntry(key, value.toJson())),
      'running': running,
      'intervalMs': intervalMs,
      'headlineCount': headlineCount,
    };
  }

  SourceStatus copyWith({
    int? lastRefresh,
    int? nextRefresh,
    int? refreshCount,
    Map<String, SourceInfo>? sources,
    bool? running,
    int? intervalMs,
    int? headlineCount,
  }) {
    return SourceStatus(
      lastRefresh: lastRefresh ?? this.lastRefresh,
      nextRefresh: nextRefresh ?? this.nextRefresh,
      refreshCount: refreshCount ?? this.refreshCount,
      sources: sources ?? this.sources,
      running: running ?? this.running,
      intervalMs: intervalMs ?? this.intervalMs,
      headlineCount: headlineCount ?? this.headlineCount,
    );
  }
}

class MissionTime {
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final String formatted;
  final String washingtonTime;
  final String tehranTime;
  final String abuDhabiTime;

  const MissionTime({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.formatted,
    required this.washingtonTime,
    required this.tehranTime,
    required this.abuDhabiTime,
  });

  factory MissionTime.fromJson(Map<String, dynamic> json) {
    return MissionTime(
      days: json['days'] as int,
      hours: json['hours'] as int,
      minutes: json['minutes'] as int,
      seconds: json['seconds'] as int,
      formatted: json['formatted'] as String,
      washingtonTime: json['washingtonTime'] as String,
      tehranTime: json['tehranTime'] as String,
      abuDhabiTime: json['abuDhabiTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'formatted': formatted,
      'washingtonTime': washingtonTime,
      'tehranTime': tehranTime,
      'abuDhabiTime': abuDhabiTime,
    };
  }

  MissionTime copyWith({
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
    String? formatted,
    String? washingtonTime,
    String? tehranTime,
    String? abuDhabiTime,
  }) {
    return MissionTime(
      days: days ?? this.days,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
      formatted: formatted ?? this.formatted,
      washingtonTime: washingtonTime ?? this.washingtonTime,
      tehranTime: tehranTime ?? this.tehranTime,
      abuDhabiTime: abuDhabiTime ?? this.abuDhabiTime,
    );
  }
}
