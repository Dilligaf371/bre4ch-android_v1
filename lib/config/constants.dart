// ── Operation Constants ───────────────────────────────────────────

/// Mission start time: 28 FEB 2026 02:00:00 UTC
final DateTime missionStart = DateTime.utc(2026, 2, 28, 2, 0, 0);

const String operationName = 'BRE4CH';
const String operationSubtitle = 'BRE4CH // OPERATIONAL FUSION SECURITY';

// ── Mission Phases ────────────────────────────────────────────────
enum MissionPhase {
  phaseI('PHASE I - ISR', 'Intelligence, Surveillance & Reconnaissance'),
  phaseII('PHASE II - SEAD', 'Suppression of Enemy Air Defences'),
  phaseIII('PHASE III - STRIKE', 'Strategic Strike Operations'),
  phaseIV('PHASE IV - EXPLOIT', 'Exploitation & Consolidation'),
  phaseV('PHASE V - STABILIZE', 'Post-Conflict Stabilization');

  const MissionPhase(this.label, this.description);
  final String label;
  final String description;
}

const MissionPhase currentPhase = MissionPhase.phaseIV;

// ── Threat Levels ─────────────────────────────────────────────────
enum ThreatLevel {
  critical('CRITICAL', 0xFFEF4444),
  high('HIGH', 0xFFF97316),
  elevated('ELEVATED', 0xFFEAB308),
  guarded('GUARDED', 0xFF3B82F6),
  low('LOW', 0xFF22C55E);

  const ThreatLevel(this.label, this.colorValue);
  final String label;
  final int colorValue;
}

const ThreatLevel currentThreatLevel = ThreatLevel.critical;

// ── Google Maps API ───────────────────────────────────────────────
// CRIT-03 FIX: API key injected at build time via --dart-define=GOOGLE_MAPS_API_KEY=...
const String googleMapsApiKey = String.fromEnvironment(
  'GOOGLE_MAPS_API_KEY',
  defaultValue: '',
);

// ── Map Dark Style ────────────────────────────────────────────────
/// Same darkMapStyles JSON from the web app's MapView.tsx
const String mapStyleJson = '''
[
  {"elementType":"geometry","stylers":[{"color":"#0a0e14"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#0a0e14"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#6e7681"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#21262d"}]},
  {"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#8b949e"}]},
  {"featureType":"administrative.country","elementType":"geometry.stroke","stylers":[{"color":"#f59e0b"}]},
  {"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},
  {"featureType":"administrative.province","elementType":"geometry.stroke","stylers":[{"color":"#30363d"}]},
  {"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#0d1117"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#161b22"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#21262d"}]},
  {"featureType":"road.highway","elementType":"geometry.fill","stylers":[{"color":"#1a1f2b"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#040608"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#30363d"}]}
]
''';
