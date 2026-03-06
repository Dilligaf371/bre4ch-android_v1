// =============================================================================
// BRE4CH - Shelter Model
// Coalition Emergency Shelter System
// Sources: NCEMA, Pikud HaOref, Kuwait MOI, Bahrain NEMC, Civil Defence
// =============================================================================

enum ShelterStatus { open, full, standby, damaged }

enum ShelterType { underground, basement, bunker, interior, publicShelter }

enum ShelterCountry { uae, israel, ksa, bahrain, qatar, kuwait, oman, jordan }

class Shelter {
  final String id;
  final String name;
  final String nameAr;
  final ShelterCountry country;
  final String region; // city / emirate / governorate
  final ShelterType type;
  final String district;
  final int capacity;
  final ShelterStatus status;
  final int levels;
  final double lat;
  final double lng;
  final String notes;

  const Shelter({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.country,
    required this.region,
    required this.type,
    required this.district,
    required this.capacity,
    required this.status,
    required this.levels,
    required this.lat,
    required this.lng,
    required this.notes,
  });

  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String,
      country: ShelterCountry.values.firstWhere(
        (e) => e.name == json['country'],
        orElse: () => ShelterCountry.uae,
      ),
      region: json['region'] as String? ?? '',
      type: ShelterType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ShelterType.underground,
      ),
      district: json['district'] as String,
      capacity: json['capacity'] as int,
      status: ShelterStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ShelterStatus.standby,
      ),
      levels: json['levels'] as int,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      notes: json['notes'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'country': country.name,
      'region': region,
      'type': type.name,
      'district': district,
      'capacity': capacity,
      'status': status.name,
      'levels': levels,
      'lat': lat,
      'lng': lng,
      'notes': notes,
    };
  }

  Shelter copyWith({
    String? id,
    String? name,
    String? nameAr,
    ShelterCountry? country,
    String? region,
    ShelterType? type,
    String? district,
    int? capacity,
    ShelterStatus? status,
    int? levels,
    double? lat,
    double? lng,
    String? notes,
  }) {
    return Shelter(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      country: country ?? this.country,
      region: region ?? this.region,
      type: type ?? this.type,
      district: district ?? this.district,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      levels: levels ?? this.levels,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      notes: notes ?? this.notes,
    );
  }
}

// =============================================================================
// Extension methods
// =============================================================================

extension ShelterCountryExtension on ShelterCountry {
  String get displayName {
    switch (this) {
      case ShelterCountry.uae:
        return 'UAE';
      case ShelterCountry.israel:
        return 'Israel';
      case ShelterCountry.ksa:
        return 'KSA';
      case ShelterCountry.bahrain:
        return 'Bahrain';
      case ShelterCountry.qatar:
        return 'Qatar';
      case ShelterCountry.kuwait:
        return 'Kuwait';
      case ShelterCountry.oman:
        return 'Oman';
      case ShelterCountry.jordan:
        return 'Jordan';
    }
  }

  String get flag {
    switch (this) {
      case ShelterCountry.uae:
        return '\u{1F1E6}\u{1F1EA}';
      case ShelterCountry.israel:
        return '\u{1F1EE}\u{1F1F1}';
      case ShelterCountry.ksa:
        return '\u{1F1F8}\u{1F1E6}';
      case ShelterCountry.bahrain:
        return '\u{1F1E7}\u{1F1ED}';
      case ShelterCountry.qatar:
        return '\u{1F1F6}\u{1F1E6}';
      case ShelterCountry.kuwait:
        return '\u{1F1F0}\u{1F1FC}';
      case ShelterCountry.oman:
        return '\u{1F1F4}\u{1F1F2}';
      case ShelterCountry.jordan:
        return '\u{1F1EF}\u{1F1F4}';
    }
  }

  String get emergencyNumber {
    switch (this) {
      case ShelterCountry.uae:
        return '999';
      case ShelterCountry.israel:
        return '104';
      case ShelterCountry.ksa:
        return '998';
      case ShelterCountry.bahrain:
        return '999';
      case ShelterCountry.qatar:
        return '999';
      case ShelterCountry.kuwait:
        return '112';
      case ShelterCountry.oman:
        return '999';
      case ShelterCountry.jordan:
        return '911';
    }
  }

  String get civilDefenseAgency {
    switch (this) {
      case ShelterCountry.uae:
        return 'NCEMA / Civil Defence';
      case ShelterCountry.israel:
        return 'Pikud HaOref (Home Front Command)';
      case ShelterCountry.ksa:
        return 'General Directorate of Civil Defense';
      case ShelterCountry.bahrain:
        return 'NEMC / Civil Defense';
      case ShelterCountry.qatar:
        return 'GA Civil Defence (MOI)';
      case ShelterCountry.kuwait:
        return 'GD Civil Defence (MOI)';
      case ShelterCountry.oman:
        return 'PACDA (Royal Oman Police)';
      case ShelterCountry.jordan:
        return 'Civil Defense Directorate (PSD)';
    }
  }
}

extension ShelterTypeExtension on ShelterType {
  String get label {
    switch (this) {
      case ShelterType.underground:
        return 'UG PARKING';
      case ShelterType.basement:
        return 'BASEMENT';
      case ShelterType.bunker:
        return 'BUNKER';
      case ShelterType.interior:
        return 'INTERIOR';
      case ShelterType.publicShelter:
        return 'PUBLIC SHELTER';
    }
  }
}

extension ShelterStatusExtension on ShelterStatus {
  String get label {
    switch (this) {
      case ShelterStatus.open:
        return 'OPEN';
      case ShelterStatus.full:
        return 'FULL';
      case ShelterStatus.standby:
        return 'STANDBY';
      case ShelterStatus.damaged:
        return 'DAMAGED';
    }
  }
}
