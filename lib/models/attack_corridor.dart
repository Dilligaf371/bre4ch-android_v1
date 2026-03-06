// =============================================================================
// BRE4CH - Attack Corridor Model
// Norse-style animated attack flow definitions
// =============================================================================

enum FlowCategory { conventional, cyber }

enum AttackFlowType { ballistic, cruise, drone, artillery, cyber, sabotage }

class LatLngName {
  final double lat;
  final double lng;
  final String name;

  const LatLngName({
    required this.lat,
    required this.lng,
    required this.name,
  });

  factory LatLngName.fromJson(Map<String, dynamic> json) {
    return LatLngName(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'name': name,
    };
  }

  LatLngName copyWith({double? lat, double? lng, String? name}) {
    return LatLngName(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      name: name ?? this.name,
    );
  }
}

class AttackCorridor {
  final String id;
  final FlowCategory category;
  final AttackFlowType type;
  final String label;
  final LatLngName source;
  final LatLngName target;

  const AttackCorridor({
    required this.id,
    required this.category,
    required this.type,
    required this.label,
    required this.source,
    required this.target,
  });

  factory AttackCorridor.fromJson(Map<String, dynamic> json) {
    return AttackCorridor(
      id: json['id'] as String,
      category: FlowCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => FlowCategory.conventional,
      ),
      type: AttackFlowType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AttackFlowType.ballistic,
      ),
      label: json['label'] as String,
      source: LatLngName.fromJson(json['source'] as Map<String, dynamic>),
      target: LatLngName.fromJson(json['target'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'type': type.name,
      'label': label,
      'source': source.toJson(),
      'target': target.toJson(),
    };
  }

  AttackCorridor copyWith({
    String? id,
    FlowCategory? category,
    AttackFlowType? type,
    String? label,
    LatLngName? source,
    LatLngName? target,
  }) {
    return AttackCorridor(
      id: id ?? this.id,
      category: category ?? this.category,
      type: type ?? this.type,
      label: label ?? this.label,
      source: source ?? this.source,
      target: target ?? this.target,
    );
  }
}
