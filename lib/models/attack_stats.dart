// =============================================================================
// BRE4CH - Attack Stats Models
// War state feeds, statistics, and country-level data
// =============================================================================

class AttackStats {
  final int total;
  final int ballistic;
  final int drone;
  final int cyber;
  final int artillery;
  final int cruise;
  final int sabotage;
  final int intercepted;
  final int last24h;
  final int sorties;
  final int targetsDamaged;
  final int targetsNeutralized;

  const AttackStats({
    required this.total,
    required this.ballistic,
    required this.drone,
    required this.cyber,
    required this.artillery,
    required this.cruise,
    required this.sabotage,
    required this.intercepted,
    required this.last24h,
    required this.sorties,
    required this.targetsDamaged,
    required this.targetsNeutralized,
  });

  factory AttackStats.fromJson(Map<String, dynamic> json) {
    return AttackStats(
      total: json['total'] as int? ?? 0,
      ballistic: json['ballistic'] as int? ?? 0,
      drone: json['drone'] as int? ?? 0,
      cyber: json['cyber'] as int? ?? 0,
      artillery: json['artillery'] as int? ?? 0,
      cruise: json['cruise'] as int? ?? 0,
      sabotage: json['sabotage'] as int? ?? 0,
      intercepted: json['intercepted'] as int? ?? 0,
      last24h: json['last24h'] as int? ?? 0,
      sorties: json['sorties'] as int? ?? 0,
      targetsDamaged: json['targetsDamaged'] as int? ?? 0,
      targetsNeutralized: json['targetsNeutralized'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'ballistic': ballistic,
      'drone': drone,
      'cyber': cyber,
      'artillery': artillery,
      'cruise': cruise,
      'sabotage': sabotage,
      'intercepted': intercepted,
      'last24h': last24h,
      'sorties': sorties,
      'targetsDamaged': targetsDamaged,
      'targetsNeutralized': targetsNeutralized,
    };
  }

  AttackStats copyWith({
    int? total,
    int? ballistic,
    int? drone,
    int? cyber,
    int? artillery,
    int? cruise,
    int? sabotage,
    int? intercepted,
    int? last24h,
    int? sorties,
    int? targetsDamaged,
    int? targetsNeutralized,
  }) {
    return AttackStats(
      total: total ?? this.total,
      ballistic: ballistic ?? this.ballistic,
      drone: drone ?? this.drone,
      cyber: cyber ?? this.cyber,
      artillery: artillery ?? this.artillery,
      cruise: cruise ?? this.cruise,
      sabotage: sabotage ?? this.sabotage,
      intercepted: intercepted ?? this.intercepted,
      last24h: last24h ?? this.last24h,
      sorties: sorties ?? this.sorties,
      targetsDamaged: targetsDamaged ?? this.targetsDamaged,
      targetsNeutralized: targetsNeutralized ?? this.targetsNeutralized,
    );
  }
}

class StatsHistory {
  final int timestamp;
  final int total;
  final int intercepted;

  const StatsHistory({
    required this.timestamp,
    required this.total,
    required this.intercepted,
  });

  factory StatsHistory.fromJson(Map<String, dynamic> json) {
    return StatsHistory(
      timestamp: json['timestamp'] as int,
      total: json['total'] as int,
      intercepted: json['intercepted'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'total': total,
      'intercepted': intercepted,
    };
  }

  StatsHistory copyWith({int? timestamp, int? total, int? intercepted}) {
    return StatsHistory(
      timestamp: timestamp ?? this.timestamp,
      total: total ?? this.total,
      intercepted: intercepted ?? this.intercepted,
    );
  }
}

class StatItem {
  final String label;
  final dynamic value;
  final String color;
  final String bgColor;

  const StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  factory StatItem.fromJson(Map<String, dynamic> json) {
    return StatItem(
      label: json['label'] as String,
      value: json['value'],
      color: json['color'] as String,
      bgColor: json['bgColor'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'color': color,
      'bgColor': bgColor,
    };
  }

  StatItem copyWith({String? label, dynamic value, String? color, String? bgColor}) {
    return StatItem(
      label: label ?? this.label,
      value: value ?? this.value,
      color: color ?? this.color,
      bgColor: bgColor ?? this.bgColor,
    );
  }
}

class CountryFeed {
  final String id;
  final String name;
  final String flag;
  final String color;
  final String borderColor;
  final String bgColor;
  final List<StatItem> offensive;
  final List<StatItem> defensive;
  final String source;

  const CountryFeed({
    required this.id,
    required this.name,
    required this.flag,
    required this.color,
    required this.borderColor,
    required this.bgColor,
    required this.offensive,
    required this.defensive,
    required this.source,
  });

  factory CountryFeed.fromJson(Map<String, dynamic> json) {
    return CountryFeed(
      id: json['id'] as String,
      name: json['name'] as String,
      flag: json['flag'] as String,
      color: json['color'] as String,
      borderColor: json['borderColor'] as String,
      bgColor: json['bgColor'] as String,
      offensive: (json['offensive'] as List<dynamic>)
          .map((e) => StatItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      defensive: (json['defensive'] as List<dynamic>)
          .map((e) => StatItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      source: json['source'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'flag': flag,
      'color': color,
      'borderColor': borderColor,
      'bgColor': bgColor,
      'offensive': offensive.map((e) => e.toJson()).toList(),
      'defensive': defensive.map((e) => e.toJson()).toList(),
      'source': source,
    };
  }

  CountryFeed copyWith({
    String? id,
    String? name,
    String? flag,
    String? color,
    String? borderColor,
    String? bgColor,
    List<StatItem>? offensive,
    List<StatItem>? defensive,
    String? source,
  }) {
    return CountryFeed(
      id: id ?? this.id,
      name: name ?? this.name,
      flag: flag ?? this.flag,
      color: color ?? this.color,
      borderColor: borderColor ?? this.borderColor,
      bgColor: bgColor ?? this.bgColor,
      offensive: offensive ?? this.offensive,
      defensive: defensive ?? this.defensive,
      source: source ?? this.source,
    );
  }
}

class CyberThreatGroup {
  final String name;
  final String target;
  final String status;
  final String severity;

  const CyberThreatGroup({
    required this.name,
    required this.target,
    required this.status,
    required this.severity,
  });

  factory CyberThreatGroup.fromJson(Map<String, dynamic> json) {
    return CyberThreatGroup(
      name: json['name'] as String,
      target: json['target'] as String,
      status: json['status'] as String,
      severity: json['severity'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'target': target,
      'status': status,
      'severity': severity,
    };
  }

  CyberThreatGroup copyWith({String? name, String? target, String? status, String? severity}) {
    return CyberThreatGroup(
      name: name ?? this.name,
      target: target ?? this.target,
      status: status ?? this.status,
      severity: severity ?? this.severity,
    );
  }
}
