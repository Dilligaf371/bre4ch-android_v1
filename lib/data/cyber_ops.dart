// =============================================================================
// BRE4CH - Cyber Operations Metrics
// Day 3 (Mar 3, 2026) -- Operation Epic Fury / Roar of the Lion
// Verified: Electronic warfare in Strait of Hormuz (Fox News)
// Verified: Iranian state broadcaster struck and dismantled (IDF)
// Iranian APT group names from public threat intel reporting
// =============================================================================

import '../models/attack_stats.dart';

// ---------------------------------------------------------------------------
// Allied Cyber / EW Operations
// ---------------------------------------------------------------------------

class CyberOp {
  final String label;
  final int value;
  final String desc;

  const CyberOp({
    required this.label,
    required this.value,
    required this.desc,
  });

  factory CyberOp.fromJson(Map<String, dynamic> json) {
    return CyberOp(
      label: json['label'] as String,
      value: json['value'] as int,
      desc: json['desc'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'desc': desc,
    };
  }

  CyberOp copyWith({String? label, int? value, String? desc}) {
    return CyberOp(
      label: label ?? this.label,
      value: value ?? this.value,
      desc: desc ?? this.desc,
    );
  }
}

// ---------------------------------------------------------------------------
// Cyber Metrics Aggregate
// ---------------------------------------------------------------------------

class CyberSide {
  final String label;
  final String color;

  const CyberSide({
    required this.label,
    required this.color,
  });
}

class CyberMetrics {
  final CyberSide alliedMeta;
  final List<CyberOp> alliedOps;
  final CyberSide iranianMeta;
  final List<CyberThreatGroup> iranianGroups;

  const CyberMetrics({
    required this.alliedMeta,
    required this.alliedOps,
    required this.iranianMeta,
    required this.iranianGroups,
  });
}

// ---------------------------------------------------------------------------
// Static Data
// ---------------------------------------------------------------------------

const List<CyberOp> alliedCyberOps = [
  CyberOp(
    label: 'EW Strait of Hormuz',
    value: 1,
    desc: 'Electronic warfare activity confirmed (Fox News)',
  ),
  CyberOp(
    label: 'State Broadcaster',
    value: 1,
    desc: 'Iranian state broadcaster struck and dismantled (IDF)',
  ),
];

const List<CyberThreatGroup> iranianThreatGroups = [
  CyberThreatGroup(
    name: 'CyberAv3ngers',
    target: 'US/GCC water & power SCADA',
    status: 'active',
    severity: 'critical',
  ),
  CyberThreatGroup(
    name: 'APT42 (Charming Kitten)',
    target: 'US/IL govt credentials phishing',
    status: 'active',
    severity: 'high',
  ),
  CyberThreatGroup(
    name: 'MuddyWater',
    target: 'GCC telecom/energy backdoors',
    status: 'active',
    severity: 'high',
  ),
  CyberThreatGroup(
    name: 'Void Manticore (Storm-842)',
    target: 'Israeli infrastructure wiper',
    status: 'active',
    severity: 'critical',
  ),
  CyberThreatGroup(
    name: 'Cotton Sandstorm',
    target: 'US social media disinfo ops',
    status: 'active',
    severity: 'high',
  ),
];

const CyberMetrics cyberMetrics = CyberMetrics(
  alliedMeta: CyberSide(
    label: 'ALLIED CYBER/EW OPS',
    color: 'text-green-400',
  ),
  alliedOps: alliedCyberOps,
  iranianMeta: CyberSide(
    label: 'IRANIAN CYBER THREATS',
    color: 'text-red-400',
  ),
  iranianGroups: iranianThreatGroups,
);
