// =============================================================================
// BRE4CH - Attack Flow Corridors
// Source -> Target definitions for Norse-style animated attack arcs
// =============================================================================

import '../models/attack_corridor.dart';

// Colour palette per attack type (Norse-inspired neon on dark)
const Map<AttackFlowType, String> flowColors = {
  AttackFlowType.ballistic: '#ef4444', // red
  AttackFlowType.cruise: '#f97316',    // orange
  AttackFlowType.drone: '#06b6d4',     // cyan
  AttackFlowType.artillery: '#eab308', // yellow
  AttackFlowType.cyber: '#a855f7',     // purple
  AttackFlowType.sabotage: '#ec4899',  // pink
};

// --------------- Conventional corridors (15) ---------------

const List<AttackCorridor> conventionalCorridors = [
  // Iran -> Israel / GCC
  AttackCorridor(
    id: 'ir-bm-il',
    category: FlowCategory.conventional,
    type: AttackFlowType.ballistic,
    label: 'IRGC BM -> Tel Aviv',
    source: LatLngName(lat: 35.6762, lng: 51.4358, name: 'Tehran'),
    target: LatLngName(lat: 32.0853, lng: 34.7818, name: 'Tel Aviv'),
  ),
  AttackCorridor(
    id: 'ir-bm-dimona',
    category: FlowCategory.conventional,
    type: AttackFlowType.ballistic,
    label: 'IRGC BM -> Dimona',
    source: LatLngName(lat: 33.4839, lng: 48.3534, name: 'Khorramabad'),
    target: LatLngName(lat: 31.0700, lng: 35.2100, name: 'Dimona'),
  ),
  AttackCorridor(
    id: 'ir-cruise-uae',
    category: FlowCategory.conventional,
    type: AttackFlowType.cruise,
    label: 'IRGC Cruise -> Al Dhafra',
    source: LatLngName(lat: 27.1832, lng: 56.2764, name: 'Bandar Abbas'),
    target: LatLngName(lat: 24.2500, lng: 54.5500, name: 'Al Dhafra AB'),
  ),
  AttackCorridor(
    id: 'ir-drone-kw',
    category: FlowCategory.conventional,
    type: AttackFlowType.drone,
    label: 'IRGC UAS -> Arifjan',
    source: LatLngName(lat: 30.4400, lng: 48.3500, name: 'Abadan'),
    target: LatLngName(lat: 29.0700, lng: 48.0800, name: 'Camp Arifjan'),
  ),
  AttackCorridor(
    id: 'ir-cruise-qa',
    category: FlowCategory.conventional,
    type: AttackFlowType.cruise,
    label: 'IRGC Cruise -> Al Udeid',
    source: LatLngName(lat: 27.1832, lng: 56.2764, name: 'Bandar Abbas'),
    target: LatLngName(lat: 25.1175, lng: 51.3150, name: 'Al Udeid AB'),
  ),
  AttackCorridor(
    id: 'ir-bm-bh',
    category: FlowCategory.conventional,
    type: AttackFlowType.ballistic,
    label: 'IRGC BM -> Bahrain NSA',
    source: LatLngName(lat: 32.6546, lng: 51.6680, name: 'Isfahan'),
    target: LatLngName(lat: 26.2361, lng: 50.6225, name: 'NSA Bahrain'),
  ),
  // Houthis
  AttackCorridor(
    id: 'hou-ascm-red',
    category: FlowCategory.conventional,
    type: AttackFlowType.cruise,
    label: 'Houthi ASCM -> Red Sea',
    source: LatLngName(lat: 14.8000, lng: 42.9500, name: 'Al Hudaydah'),
    target: LatLngName(lat: 13.5000, lng: 42.5000, name: 'Bab el-Mandeb'),
  ),
  AttackCorridor(
    id: 'hou-drone-ksa',
    category: FlowCategory.conventional,
    type: AttackFlowType.drone,
    label: 'Houthi UAS -> Aramco',
    source: LatLngName(lat: 15.3694, lng: 44.1910, name: "Sana'a"),
    target: LatLngName(lat: 25.3800, lng: 49.6900, name: 'Abqaiq'),
  ),
  // Hezbollah
  AttackCorridor(
    id: 'hzb-arty-haifa',
    category: FlowCategory.conventional,
    type: AttackFlowType.artillery,
    label: 'Hezbollah Rockets -> Haifa',
    source: LatLngName(lat: 33.8547, lng: 35.8623, name: 'Baalbek'),
    target: LatLngName(lat: 32.7940, lng: 34.9896, name: 'Haifa'),
  ),
  AttackCorridor(
    id: 'hzb-atgm-golan',
    category: FlowCategory.conventional,
    type: AttackFlowType.artillery,
    label: 'Hezbollah ATGM -> Golan',
    source: LatLngName(lat: 33.2774, lng: 35.5000, name: 'S. Lebanon'),
    target: LatLngName(lat: 33.0000, lng: 35.7500, name: 'Golan Heights'),
  ),
  // PMF / Iraq
  AttackCorridor(
    id: 'pmf-drone-erbil',
    category: FlowCategory.conventional,
    type: AttackFlowType.drone,
    label: 'PMF UAS -> Erbil',
    source: LatLngName(lat: 33.3128, lng: 44.3615, name: 'Baghdad'),
    target: LatLngName(lat: 36.1912, lng: 44.0094, name: 'Erbil AB'),
  ),
  AttackCorridor(
    id: 'pmf-arty-asad',
    category: FlowCategory.conventional,
    type: AttackFlowType.artillery,
    label: 'PMF Rockets -> Ain al-Asad',
    source: LatLngName(lat: 33.4500, lng: 43.2700, name: 'W. Anbar'),
    target: LatLngName(lat: 33.7860, lng: 42.4410, name: 'Ain al-Asad AB'),
  ),
  // Coalition return fire
  AttackCorridor(
    id: 'us-tlam-isfahan',
    category: FlowCategory.conventional,
    type: AttackFlowType.cruise,
    label: 'USN TLAM -> Isfahan',
    source: LatLngName(lat: 26.0000, lng: 56.0000, name: 'USS Bataan CSG'),
    target: LatLngName(lat: 32.6546, lng: 51.6680, name: 'Isfahan'),
  ),
  AttackCorridor(
    id: 'us-pgm-tehran',
    category: FlowCategory.conventional,
    type: AttackFlowType.cruise,
    label: 'USAF PGM -> Tehran AD',
    source: LatLngName(lat: 32.0000, lng: 47.0000, name: 'Jordan / CAOC'),
    target: LatLngName(lat: 35.6762, lng: 51.4358, name: 'Tehran'),
  ),
  AttackCorridor(
    id: 'il-sead-syria',
    category: FlowCategory.conventional,
    type: AttackFlowType.sabotage,
    label: 'IAF SEAD -> Damascus',
    source: LatLngName(lat: 31.8000, lng: 34.6500, name: 'Nevatim AB'),
    target: LatLngName(lat: 33.5138, lng: 36.2765, name: 'Damascus'),
  ),
  AttackCorridor(
    id: 'us-tlam-bandar',
    category: FlowCategory.conventional,
    type: AttackFlowType.cruise,
    label: 'USN TLAM -> Bandar Abbas',
    source: LatLngName(lat: 25.0000, lng: 57.0000, name: 'USS Ford CSG'),
    target: LatLngName(lat: 27.1832, lng: 56.2764, name: 'Bandar Abbas'),
  ),
];

// --------------- Cyber corridors (8) ---------------

const List<AttackCorridor> cyberCorridors = [
  AttackCorridor(
    id: 'cy-apt-centcom',
    category: FlowCategory.cyber,
    type: AttackFlowType.cyber,
    label: 'APT33 -> CENTCOM C2',
    source: LatLngName(lat: 35.6762, lng: 51.4358, name: 'Tehran NOC'),
    target: LatLngName(lat: 28.3400, lng: -80.6600, name: 'CENTCOM Tampa'),
  ),
  AttackCorridor(
    id: 'cy-apt-gcc-scada',
    category: FlowCategory.cyber,
    type: AttackFlowType.cyber,
    label: 'APT34 -> GCC SCADA',
    source: LatLngName(lat: 35.6762, lng: 51.4358, name: 'Tehran NOC'),
    target: LatLngName(lat: 25.2769, lng: 55.2963, name: 'Dubai SCADA'),
  ),
  AttackCorridor(
    id: 'cy-apt-iec',
    category: FlowCategory.cyber,
    type: AttackFlowType.cyber,
    label: 'MuddyWater -> IEC Grid',
    source: LatLngName(lat: 32.6546, lng: 51.6680, name: 'Isfahan Cyber'),
    target: LatLngName(lat: 32.0853, lng: 34.7818, name: 'IEC Tel Aviv'),
  ),
  AttackCorridor(
    id: 'cy-apt-aramco',
    category: FlowCategory.cyber,
    type: AttackFlowType.cyber,
    label: 'APT33 -> Aramco IT',
    source: LatLngName(lat: 35.6762, lng: 51.4358, name: 'Tehran NOC'),
    target: LatLngName(lat: 26.3927, lng: 49.9777, name: 'Aramco Dhahran'),
  ),
  // Coalition cyber return
  AttackCorridor(
    id: 'cy-cmd-natanz',
    category: FlowCategory.cyber,
    type: AttackFlowType.cyber,
    label: 'CYBERCOM -> Natanz SCADA',
    source: LatLngName(lat: 39.1000, lng: -76.7300, name: 'Ft. Meade'),
    target: LatLngName(lat: 33.7258, lng: 51.7277, name: 'Natanz'),
  ),
  AttackCorridor(
    id: 'cy-cmd-irgc-c2',
    category: FlowCategory.cyber,
    type: AttackFlowType.cyber,
    label: 'CYBERCOM -> IRGC C2',
    source: LatLngName(lat: 39.1000, lng: -76.7300, name: 'Ft. Meade'),
    target: LatLngName(lat: 35.6762, lng: 51.4358, name: 'Tehran C2'),
  ),
  AttackCorridor(
    id: 'cy-il-telecom',
    category: FlowCategory.cyber,
    type: AttackFlowType.cyber,
    label: "Unit 8200 -> IR Telecom",
    source: LatLngName(lat: 31.8900, lng: 34.8100, name: "Be'er Sheva"),
    target: LatLngName(lat: 35.6762, lng: 51.4358, name: 'Tehran Telecom'),
  ),
  AttackCorridor(
    id: 'cy-uk-gchq',
    category: FlowCategory.cyber,
    type: AttackFlowType.cyber,
    label: 'GCHQ -> IRGC Navy C2',
    source: LatLngName(lat: 51.8985, lng: -2.1228, name: 'Cheltenham'),
    target: LatLngName(lat: 27.1832, lng: 56.2764, name: 'Bandar Abbas C2'),
  ),
];

// All corridors combined
const List<AttackCorridor> attackCorridors = [
  ...conventionalCorridors,
  ...cyberCorridors,
];
