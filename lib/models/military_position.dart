// =============================================================================
// BRE4CH - Military Position Model
// Force disposition tracking — NATO APP-6 symbology
// =============================================================================

import 'package:flutter/material.dart';
import '../config/theme.dart';

enum ForceType { allied, hostile, neutral, unknown }

extension ForceTypeNato on ForceType {
  Color get natoColor {
    switch (this) {
      case ForceType.allied:  return NatoColors.friendly;
      case ForceType.hostile: return NatoColors.hostile;
      case ForceType.neutral: return NatoColors.neutral;
      case ForceType.unknown: return NatoColors.unknown;
    }
  }

  String get natoLabel {
    switch (this) {
      case ForceType.allied:  return 'FRIENDLY';
      case ForceType.hostile: return 'HOSTILE';
      case ForceType.neutral: return 'NEUTRAL';
      case ForceType.unknown: return 'UNKNOWN';
    }
  }

  /// NATO APP-6 frame shape: rectangle(friendly), diamond(hostile),
  /// square(neutral), trefoil/quatrefoil(unknown)
  IconData get natoIcon {
    switch (this) {
      case ForceType.allied:  return Icons.crop_square;      // Rectangle
      case ForceType.hostile: return Icons.diamond_outlined;  // Diamond
      case ForceType.neutral: return Icons.square_outlined;   // Square
      case ForceType.unknown: return Icons.help_outline;      // Quatrefoil
    }
  }
}

class MilitaryPosition {
  final String id;
  final String callsign;
  final ForceType type;
  final double lat;
  final double lng;
  final String unit;
  final String branch;
  final int strength;
  final int readiness;
  final String lastUpdate;
  final String mission;

  const MilitaryPosition({
    required this.id,
    required this.callsign,
    required this.type,
    required this.lat,
    required this.lng,
    required this.unit,
    required this.branch,
    required this.strength,
    required this.readiness,
    required this.lastUpdate,
    required this.mission,
  });

  factory MilitaryPosition.fromJson(Map<String, dynamic> json) {
    return MilitaryPosition(
      id: json['id'] as String,
      callsign: json['callsign'] as String,
      type: ForceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ForceType.allied,
      ),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      unit: json['unit'] as String,
      branch: json['branch'] as String,
      strength: json['strength'] as int,
      readiness: json['readiness'] as int,
      lastUpdate: json['lastUpdate'] as String,
      mission: json['mission'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'callsign': callsign,
      'type': type.name,
      'lat': lat,
      'lng': lng,
      'unit': unit,
      'branch': branch,
      'strength': strength,
      'readiness': readiness,
      'lastUpdate': lastUpdate,
      'mission': mission,
    };
  }

  MilitaryPosition copyWith({
    String? id,
    String? callsign,
    ForceType? type,
    double? lat,
    double? lng,
    String? unit,
    String? branch,
    int? strength,
    int? readiness,
    String? lastUpdate,
    String? mission,
  }) {
    return MilitaryPosition(
      id: id ?? this.id,
      callsign: callsign ?? this.callsign,
      type: type ?? this.type,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      unit: unit ?? this.unit,
      branch: branch ?? this.branch,
      strength: strength ?? this.strength,
      readiness: readiness ?? this.readiness,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      mission: mission ?? this.mission,
    );
  }
}
