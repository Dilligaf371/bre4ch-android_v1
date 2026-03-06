// =============================================================================
// BRE4CH - Attack Event Model
// BRE4CH
// =============================================================================

enum AttackType { ballistic, drone, cyber, artillery, cruise, sabotage }

enum EventStatus { intercepted, impact, ongoing, neutralized }

class AttackEvent {
  final String id;
  final int timestamp;
  final AttackType type;
  final String origin;
  final String target;
  final EventStatus status;
  final String details;
  final String? source;
  final String? sourceUrl;

  const AttackEvent({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.origin,
    required this.target,
    required this.status,
    required this.details,
    this.source,
    this.sourceUrl,
  });

  factory AttackEvent.fromJson(Map<String, dynamic> json) {
    return AttackEvent(
      id: json['id'] as String,
      timestamp: json['timestamp'] as int,
      type: AttackType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AttackType.ballistic,
      ),
      origin: json['origin'] as String,
      target: json['target'] as String,
      status: EventStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EventStatus.ongoing,
      ),
      details: json['details'] as String,
      source: json['source'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'type': type.name,
      'origin': origin,
      'target': target,
      'status': status.name,
      'details': details,
      'source': source,
      'sourceUrl': sourceUrl,
    };
  }

  AttackEvent copyWith({
    String? id,
    int? timestamp,
    AttackType? type,
    String? origin,
    String? target,
    EventStatus? status,
    String? details,
    String? source,
    String? sourceUrl,
  }) {
    return AttackEvent(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      origin: origin ?? this.origin,
      target: target ?? this.target,
      status: status ?? this.status,
      details: details ?? this.details,
      source: source ?? this.source,
      sourceUrl: sourceUrl ?? this.sourceUrl,
    );
  }
}
