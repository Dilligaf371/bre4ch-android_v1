// =============================================================================
// BRE4CH - Infrastructure Point Model
// Iranian Critical Infrastructure Targets
// =============================================================================

enum InfraType { nuclear, military, oil, airbase, naval, command, missile, radar, chemical }

enum InfraStatus { active, damaged, neutralized, unknown }

class InfrastructurePoint {
  final String id;
  final String name;
  final String nameEn;
  final InfraType type;
  final double lat;
  final double lng;
  final InfraStatus status;
  final int priority;
  final String description;
  final int defenseLevel;

  const InfrastructurePoint({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.type,
    required this.lat,
    required this.lng,
    required this.status,
    required this.priority,
    required this.description,
    required this.defenseLevel,
  });

  factory InfrastructurePoint.fromJson(Map<String, dynamic> json) {
    return InfrastructurePoint(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String,
      type: InfraType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InfraType.military,
      ),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      status: InfraStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InfraStatus.unknown,
      ),
      priority: json['priority'] as int,
      description: json['description'] as String,
      defenseLevel: json['defenseLevel'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'type': type.name,
      'lat': lat,
      'lng': lng,
      'status': status.name,
      'priority': priority,
      'description': description,
      'defenseLevel': defenseLevel,
    };
  }

  InfrastructurePoint copyWith({
    String? id,
    String? name,
    String? nameEn,
    InfraType? type,
    double? lat,
    double? lng,
    InfraStatus? status,
    int? priority,
    String? description,
    int? defenseLevel,
  }) {
    return InfrastructurePoint(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      type: type ?? this.type,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      defenseLevel: defenseLevel ?? this.defenseLevel,
    );
  }
}

const Map<InfraType, String> infraColors = {
  InfraType.nuclear: '#ef4444',
  InfraType.military: '#f59e0b',
  InfraType.oil: '#eab308',
  InfraType.airbase: '#3b82f6',
  InfraType.naval: '#06b6d4',
  InfraType.command: '#8b5cf6',
  InfraType.missile: '#f97316',
  InfraType.radar: '#14b8a6',
  InfraType.chemical: '#ec4899',
};

const Map<InfraStatus, String> statusColors = {
  InfraStatus.active: '#ef4444',
  InfraStatus.damaged: '#f59e0b',
  InfraStatus.neutralized: '#22c55e',
  InfraStatus.unknown: '#6b7280',
};
