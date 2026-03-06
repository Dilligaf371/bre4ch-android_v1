// =============================================================================
// OPERATION ROAR OF THE LION - EPIC FURY
// Command & Control Data Layer
// BRE4CH
// =============================================================================

import 'dart:math';

import '../models/attack_event.dart';
import '../models/infrastructure.dart';
import '../models/military_position.dart';

// --------------- CONSTANTS ---------------

const List<double> iranCenter = [32.4279, 53.688];
const List<List<double>> iranBounds = [
  [25.0, 44.0],
  [40.0, 63.5],
];

/// Operation Epic Fury / Roar of the Lion began Feb 28, 2026 ~02:00 UTC
final int missionStart = DateTime.utc(2026, 2, 28, 2, 0, 0).millisecondsSinceEpoch;
const String currentPhase = 'PHASE IV - EXPLOIT';
const String threatLevel = 'CRITICAL';

// --------------- INFRASTRUCTURE DATA ---------------
// Iranian critical infrastructure targets (23 items)

const List<InfrastructurePoint> infrastructure = [
  // Nuclear facilities
  InfrastructurePoint(id: 'inf-01', name: 'Natanz', nameEn: 'Natanz Enrichment', type: InfraType.nuclear, lat: 33.7233, lng: 51.7233, status: InfraStatus.unknown, priority: 1, description: 'Iran IAEA ambassador confirms targeted -- IAEA: no confirmed damage as of Mar 2 -- cannot rule out radiological release (Reuters/Al Jazeera)', defenseLevel: 50),
  InfrastructurePoint(id: 'inf-02', name: 'Fordow', nameEn: 'Fordow Underground', type: InfraType.nuclear, lat: 34.7083, lng: 51.5833, status: InfraStatus.damaged, priority: 1, description: 'Already damaged by June 2025 strikes -- almost all sensitive equipment destroyed (IAEA Sep 2025) -- current status unknown', defenseLevel: 40),
  InfrastructurePoint(id: 'inf-03', name: 'Bushehr', nameEn: 'Bushehr NPP', type: InfraType.nuclear, lat: 28.8333, lng: 50.8833, status: InfraStatus.active, priority: 2, description: 'Nuclear power plant -- VVER-1000 -- NOT targeted (Russian-built civilian reactor -- Reuters)', defenseLevel: 72),
  InfrastructurePoint(id: 'inf-04', name: 'Isfahan UCF', nameEn: 'Isfahan Nuclear Tech', type: InfraType.nuclear, lat: 32.6546, lng: 51.6680, status: InfraStatus.damaged, priority: 2, description: 'Uranium conversion -- damaged in June 2025 strikes -- part of 24/31 provinces hit (IDF)', defenseLevel: 30),
  InfrastructurePoint(id: 'inf-05', name: 'Arak', nameEn: 'Arak Heavy Water', type: InfraType.nuclear, lat: 34.0493, lng: 49.2433, status: InfraStatus.unknown, priority: 1, description: 'Heavy water reactor IR-40 -- no specific confirmed reports from verified sources', defenseLevel: 50),

  // Command & Control
  InfrastructurePoint(id: 'inf-06', name: 'Tehran HQ IRGC', nameEn: 'IRGC Supreme Command', type: InfraType.command, lat: 35.6892, lng: 51.3890, status: InfraStatus.damaged, priority: 1, description: '40+ senior leaders killed incl. Khamenei -- 7 security leaders confirmed KIA (Reuters/IDF)', defenseLevel: 40),
  InfrastructurePoint(id: 'inf-07', name: 'Parchin', nameEn: 'Parchin Military Complex', type: InfraType.command, lat: 35.5175, lng: 51.7711, status: InfraStatus.unknown, priority: 1, description: 'Military complex -- part of 1,000+ targets hit (Reuters) -- no specific BDA from verified sources', defenseLevel: 50),

  // Airbases
  InfrastructurePoint(id: 'inf-08', name: 'Shiraz AFB', nameEn: 'Shiraz Air Base', type: InfraType.airbase, lat: 29.5392, lng: 52.5898, status: InfraStatus.unknown, priority: 2, description: 'Tactical air base -- within 24/31 provinces hit (IDF) -- no specific BDA confirmed', defenseLevel: 50),
  InfrastructurePoint(id: 'inf-09', name: 'Tabriz AFB', nameEn: 'Tabriz Air Base', type: InfraType.airbase, lat: 38.0667, lng: 46.2833, status: InfraStatus.unknown, priority: 3, description: 'Northern air base -- within 24/31 provinces hit (IDF) -- no specific BDA confirmed', defenseLevel: 50),
  InfrastructurePoint(id: 'inf-10', name: 'Isfahan AFB', nameEn: 'Isfahan 8th TAB', type: InfraType.airbase, lat: 32.7500, lng: 51.8612, status: InfraStatus.unknown, priority: 2, description: '8th tactical air base -- within 24/31 provinces hit (IDF) -- no specific BDA confirmed', defenseLevel: 50),
  InfrastructurePoint(id: 'inf-11', name: 'Mehrabad', nameEn: 'Mehrabad Air Base', type: InfraType.airbase, lat: 35.6894, lng: 51.3113, status: InfraStatus.unknown, priority: 2, description: 'Tehran joint-use base -- no specific BDA confirmed from verified sources', defenseLevel: 50),

  // Naval
  InfrastructurePoint(id: 'inf-12', name: 'Bandar Abbas', nameEn: 'Bandar Abbas Naval HQ', type: InfraType.naval, lat: 27.1833, lng: 56.2667, status: InfraStatus.damaged, priority: 1, description: 'Naval HQ "largely destroyed" -- 9 ships sunk -- naval presence denied in Gulf of Oman within 48h (Reuters)', defenseLevel: 25),
  InfrastructurePoint(id: 'inf-13', name: 'Jask', nameEn: 'Jask Naval Forward', type: InfraType.naval, lat: 25.6514, lng: 57.7711, status: InfraStatus.unknown, priority: 2, description: 'Forward naval base -- Strait of Hormuz declared closed (Al Jazeera) -- EW activity detected (Fox News)', defenseLevel: 40),

  // Missile sites
  InfrastructurePoint(id: 'inf-14', name: 'Khorramabad', nameEn: 'Khorramabad MRBM', type: InfraType.missile, lat: 33.4878, lng: 48.3558, status: InfraStatus.unknown, priority: 1, description: 'Ballistic missile base -- IRGC still launching True Promise 4 waves (Al Jazeera)', defenseLevel: 50),
  InfrastructurePoint(id: 'inf-15', name: 'Tabriz Missiles', nameEn: 'Tabriz Missile Base', type: InfraType.missile, lat: 37.8500, lng: 46.3500, status: InfraStatus.unknown, priority: 2, description: 'Northwest missile base -- within 24/31 provinces hit (IDF)', defenseLevel: 50),
  InfrastructurePoint(id: 'inf-16', name: 'Semnan', nameEn: 'Semnan Space/Missile', type: InfraType.missile, lat: 35.5833, lng: 53.4167, status: InfraStatus.unknown, priority: 1, description: 'Space/missile center -- within 24/31 provinces hit (IDF) -- no specific BDA confirmed', defenseLevel: 50),

  // Oil / Energy
  InfrastructurePoint(id: 'inf-17', name: 'Abadan', nameEn: 'Abadan Refinery', type: InfraType.oil, lat: 30.3472, lng: 48.2933, status: InfraStatus.unknown, priority: 2, description: 'Oil refinery -- no specific confirmed reports from Reuters/Fox/IDF/Al Jazeera', defenseLevel: 50),
  InfrastructurePoint(id: 'inf-18', name: 'Kharg Island', nameEn: 'Kharg Oil Terminal', type: InfraType.oil, lat: 29.2333, lng: 50.3167, status: InfraStatus.unknown, priority: 1, description: 'Offshore terminal -- oil exports disrupted -- no specific BDA from verified sources', defenseLevel: 50),

  // Radar / Air Defense
  InfrastructurePoint(id: 'inf-19', name: 'S-300 Tehran', nameEn: 'Tehran AD Network', type: InfraType.radar, lat: 35.7500, lng: 51.5000, status: InfraStatus.unknown, priority: 1, description: 'S-300PMU2 -- IDF confirms 30+ strike ops vs BM and AD arrays -- specific BDA unconfirmed', defenseLevel: 50),
  InfrastructurePoint(id: 'inf-20', name: 'Bavar-373', nameEn: 'Bavar-373 Isfahan', type: InfraType.radar, lat: 32.8000, lng: 51.9000, status: InfraStatus.unknown, priority: 2, description: 'Bavar-373 system -- part of AD arrays targeted by 30+ IDF strike ops -- specific BDA unconfirmed', defenseLevel: 50),

  // Military bases
  InfrastructurePoint(id: 'inf-21', name: 'Qom IRGC', nameEn: 'Qom IRGC Base', type: InfraType.military, lat: 34.6401, lng: 50.8764, status: InfraStatus.unknown, priority: 1, description: 'IRGC base -- within 24/31 provinces hit (IDF) -- no specific BDA confirmed', defenseLevel: 50),
  InfrastructurePoint(id: 'inf-22', name: 'Kerman', nameEn: 'Kerman Military', type: InfraType.military, lat: 30.2839, lng: 57.0834, status: InfraStatus.unknown, priority: 3, description: 'Eastern military base -- within 24/31 provinces hit (IDF) -- no specific BDA confirmed', defenseLevel: 50),

  // State Media
  InfrastructurePoint(id: 'inf-23', name: 'IRIB Tehran', nameEn: 'State Broadcaster', type: InfraType.command, lat: 35.7000, lng: 51.4200, status: InfraStatus.neutralized, priority: 2, description: 'Iranian state broadcaster -- struck and dismantled (IDF confirmed)', defenseLevel: 0),
];

// --------------- EPIC FURY FORCE POSITIONS (36 items) ---------------

const List<MilitaryPosition> epicFuryPositions = [
  // === ALLIED FORCE POSITIONS ===
  // US NAVY: CARRIER STRIKE GROUPS
  MilitaryPosition(id: 'ef-01', callsign: 'LINCOLN-CSG3', type: ForceType.allied, lat: 23.5, lng: 59.0, unit: 'CVN-72 Abraham Lincoln CSG-3', branch: 'US Navy', strength: 100, readiness: 100, lastUpdate: 'LIVE', mission: 'Carrier Strike Group 3 - Arabian Sea - CVW-9 embarked (VFA-14 F/A-18E, VFA-41 F/A-18F, VFA-151 F/A-18E, VMFA-314 F-35C, VAQ-133 EA-18G, VAW-117 E-2D) - redirected from INDOPACOM Jan 2026'),
  MilitaryPosition(id: 'ef-02', callsign: 'FORD-CSG12', type: ForceType.allied, lat: 34.5, lng: 32.0, unit: 'CVN-78 Gerald R. Ford CSG-12', branch: 'US Navy', strength: 100, readiness: 100, lastUpdate: 'LIVE', mission: 'Carrier Strike Group 12 - Eastern Med / en route 5th Fleet AOR via Suez - ordered to join Lincoln'),

  // US NAVY: DESTROYERS & SURFACE COMBATANTS
  MilitaryPosition(id: 'ef-03', callsign: 'DESRON21-A', type: ForceType.allied, lat: 23.8, lng: 58.5, unit: 'DDG-121 USS Frank E. Petersen Jr.', branch: 'US Navy', strength: 95, readiness: 98, lastUpdate: 'LIVE', mission: 'DESRON 21 escort - Abraham Lincoln CSG - Arabian Sea patrol'),
  MilitaryPosition(id: 'ef-04', callsign: 'DESRON21-B', type: ForceType.allied, lat: 26.2, lng: 56.8, unit: 'DDG-112 USS Michael Murphy', branch: 'US Navy', strength: 95, readiness: 98, lastUpdate: 'LIVE', mission: 'DESRON 21 - Strait of Hormuz patrol / Persian Gulf'),
  MilitaryPosition(id: 'ef-05', callsign: 'DESRON21-C', type: ForceType.allied, lat: 24.0, lng: 58.0, unit: 'DDG-111 USS Spruance', branch: 'US Navy', strength: 95, readiness: 97, lastUpdate: 'LIVE', mission: 'DESRON 21 escort - CSG-3 screen - Arabian Sea'),
  MilitaryPosition(id: 'ef-06', callsign: 'GULF-DDG1', type: ForceType.allied, lat: 26.5, lng: 55.5, unit: 'DDG-57 USS Mitscher', branch: 'US Navy', strength: 92, readiness: 96, lastUpdate: 'LIVE', mission: 'Persian Gulf patrol - Strait of Hormuz maritime security'),
  MilitaryPosition(id: 'ef-07', callsign: 'NARABSEA-1', type: ForceType.allied, lat: 24.5, lng: 60.0, unit: 'DDG-74 USS McFaul', branch: 'US Navy', strength: 90, readiness: 95, lastUpdate: 'LIVE', mission: 'North Arabian Sea independent ops - BMD capable'),
  MilitaryPosition(id: 'ef-08', callsign: 'NARABSEA-2', type: ForceType.allied, lat: 24.8, lng: 61.5, unit: 'DDG-113 USS John Finn', branch: 'US Navy', strength: 92, readiness: 96, lastUpdate: 'LIVE', mission: 'North Arabian Sea - BMD / ISR screen'),
  MilitaryPosition(id: 'ef-09', callsign: 'NARABSEA-3', type: ForceType.allied, lat: 24.2, lng: 59.5, unit: 'DDG-119 USS Delbert D. Black', branch: 'US Navy', strength: 91, readiness: 95, lastUpdate: 'LIVE', mission: 'North Arabian Sea - anti-surface / BMD ops'),
  MilitaryPosition(id: 'ef-10', callsign: 'NARABSEA-4', type: ForceType.allied, lat: 23.0, lng: 60.5, unit: 'DDG-91 USS Pinckney', branch: 'US Navy', strength: 90, readiness: 94, lastUpdate: 'LIVE', mission: 'Arabian Sea patrol - ASW / surface warfare'),

  // US NAVY: LITTORAL COMBAT SHIPS
  MilitaryPosition(id: 'ef-11', callsign: 'MCM-LCS1', type: ForceType.allied, lat: 26.2, lng: 50.6, unit: 'LCS-30 USS Canberra', branch: 'US Navy', strength: 85, readiness: 90, lastUpdate: 'LIVE', mission: 'Mine countermeasures - Persian Gulf / Strait of Hormuz - homeport NSA Bahrain'),
  MilitaryPosition(id: 'ef-12', callsign: 'MCM-LCS2', type: ForceType.allied, lat: 26.3, lng: 50.5, unit: 'LCS-16 USS Tulsa', branch: 'US Navy', strength: 85, readiness: 90, lastUpdate: 'LIVE', mission: 'Mine countermeasures mission package - 5th Fleet Bahrain'),
  MilitaryPosition(id: 'ef-13', callsign: 'MCM-LCS3', type: ForceType.allied, lat: 26.25, lng: 50.55, unit: 'LCS-32 USS Santa Barbara', branch: 'US Navy', strength: 85, readiness: 88, lastUpdate: 'LIVE', mission: 'Mine countermeasures - first operational MCM deployment - 5th Fleet'),

  // US NAVY: 5TH FLEET HQ
  MilitaryPosition(id: 'ef-14', callsign: 'FIFTHFLT-HQ', type: ForceType.allied, lat: 26.2330, lng: 50.5860, unit: 'NAVCENT / 5th Fleet HQ', branch: 'US Navy', strength: 100, readiness: 100, lastUpdate: 'LIVE', mission: 'Naval Support Activity Bahrain - Juffair - NAVCENT/5th Fleet HQ - maritime C2 for Gulf, Red Sea, Arabian Sea - reduced to <100 mission-critical personnel Feb 26'),

  // US NAVY: SSGN SUBMARINE
  MilitaryPosition(id: 'ef-15', callsign: 'HOTEL-SSGN', type: ForceType.allied, lat: 23.0, lng: 58.0, unit: 'SSGN-729 USS Georgia (est.)', branch: 'US Navy', strength: 100, readiness: 100, lastUpdate: 'LIVE', mission: 'Ohio-class SSGN - 154x Tomahawk TLAM capacity - participated in June 2025 strikes on Isfahan - Arabian Sea / Gulf of Oman patrol area (exact position classified)'),

  // USAF BASES
  MilitaryPosition(id: 'ef-16', callsign: 'UDEID-MAIN', type: ForceType.allied, lat: 25.1173, lng: 51.3150, unit: '379th AEW / CENTCOM Fwd HQ', branch: 'USAF', strength: 100, readiness: 100, lastUpdate: 'LIVE', mission: 'Al Udeid Air Base - largest US base in Middle East - ~10,000 personnel - AFCENT HQ - CENTCOM forward HQ - KC-135 tankers, ISR, C2 platforms - 83 EAG RAF also stationed'),
  MilitaryPosition(id: 'ef-17', callsign: 'DHAFRA-OPS', type: ForceType.allied, lat: 24.2481, lng: 54.5472, unit: 'USAF Al Dhafra Detachment', branch: 'USAF', strength: 92, readiness: 96, lastUpdate: 'LIVE', mission: 'Al Dhafra Air Base, Abu Dhabi - ~3,500 personnel - surveillance, refueling, F-35A, RQ-4 Global Hawk, U-2 Dragon Lady ISR - joint with UAE AF'),
  MilitaryPosition(id: 'ef-18', callsign: 'PSAB-AMD', type: ForceType.allied, lat: 24.0627, lng: 47.5805, unit: 'USAF Prince Sultan AB / Patriot-THAAD', branch: 'USAF', strength: 90, readiness: 95, lastUpdate: 'LIVE', mission: 'Prince Sultan Air Base - ~2,700 personnel - 16x KC-135 + 6x KC-46A tankers + 3x E-11A BACN + E-3 AWACS - Patriot PAC-3 & THAAD batteries - air/missile defense coordination'),
  MilitaryPosition(id: 'ef-19', callsign: 'MSAB-STRIKE', type: ForceType.allied, lat: 31.8267, lng: 36.7822, unit: '332nd AEW / 494th EFS', branch: 'USAF', strength: 100, readiness: 100, lastUpdate: 'LIVE', mission: 'Muwaffaq Salti AB, Azraq Jordan - 332nd AEW - 24x F-15E (48th FW/494th EFS RAF Lakenheath) + 30x F-35A + A-10s - THAAD - 60+ combat aircraft total - primary strike staging platform'),
  MilitaryPosition(id: 'ef-20', callsign: 'RAPTOR-ISR', type: ForceType.allied, lat: 29.9403, lng: 34.9358, unit: 'F-22A Raptor Squadron (Ovda)', branch: 'USAF', strength: 100, readiness: 100, lastUpdate: 'LIVE', mission: 'Ovda Airbase, southern Israel (Negev) - 12x F-22A Raptors (up to 24 planned) - first-ever US offensive aircraft deployment in Israel - air dominance / SEAD/DEAD - deployed from RAF Lakenheath Feb 25'),

  // US ARMY
  MilitaryPosition(id: 'ef-21', callsign: 'ARIFJAN-HQ', type: ForceType.allied, lat: 28.9597, lng: 48.0987, unit: 'ARCENT Fwd HQ / Camp Arifjan', branch: 'US Army', strength: 96, readiness: 97, lastUpdate: 'LIVE', mission: 'Camp Arifjan - Army Central fwd HQ - ~10,000 capacity - logistics hub / APS-5 prepositioned stocks - nerve center for all CENTCOM ground ops across 21 nations'),
  MilitaryPosition(id: 'ef-22', callsign: 'ALSALEM-AIR', type: ForceType.allied, lat: 29.3467, lng: 47.5208, unit: '386th AEW / Ali Al Salem AB', branch: 'USAF', strength: 90, readiness: 95, lastUpdate: 'LIVE', mission: 'Ali Al Salem Air Base - 386th AEW - primary airlift hub/gateway for combat power delivery - MQ-9 Reaper drones - C-17 / C-130 airlift ops - part of ~13,500 US in Kuwait'),
  MilitaryPosition(id: 'ef-23', callsign: 'BUEHRING-STG', type: ForceType.allied, lat: 29.7833, lng: 47.6667, unit: 'Camp Buehring Staging Base', branch: 'US Army', strength: 85, readiness: 92, lastUpdate: 'LIVE', mission: 'Camp Buehring - troop staging / rotation base for deployments into Iraq & Syria - part of Kuwait 13,500 US personnel footprint'),
  MilitaryPosition(id: 'ef-24', callsign: 'ERBIL-KRG', type: ForceType.allied, lat: 36.6208, lng: 43.9625, unit: 'US Forces Erbil / Harir AB', branch: 'US Army', strength: 75, readiness: 88, lastUpdate: 'LIVE', mission: 'Harir Air Base / Erbil - ~1,500 coalition troops relocated from federal Iraq - remaining until Sep 2026 per agreement - training / ISR / SOF coordination - attacked by Iran-backed drones Mar 1'),
  MilitaryPosition(id: 'ef-25', callsign: 'INCIRLIK-AB', type: ForceType.allied, lat: 37.0021, lng: 35.4259, unit: 'USAF 39th ABW / Incirlik AB', branch: 'USAF', strength: 85, readiness: 90, lastUpdate: 'LIVE', mission: 'Incirlik Air Base, Adana Turkey - 39th Air Base Wing - strategic depth from Iranian territory - Eastern Med access - ~5,000 personnel - B61 nuclear weapons storage (reported)'),

  // US MISSILE DEFENSE
  MilitaryPosition(id: 'ef-26', callsign: 'AMD-QATAR', type: ForceType.allied, lat: 25.2, lng: 51.4, unit: 'AN/TPY-2 Radar / THAAD Qatar', branch: 'US Army', strength: 95, readiness: 98, lastUpdate: 'LIVE', mission: 'THAAD battery & AN/TPY-2 X-band radar at Al Udeid - layered BMD architecture - part of Gulf-wide integrated air/missile defense'),
  MilitaryPosition(id: 'ef-27', callsign: 'AMD-UAE', type: ForceType.allied, lat: 24.3, lng: 54.6, unit: 'THAAD / Patriot Al Dhafra UAE', branch: 'US Army', strength: 95, readiness: 98, lastUpdate: 'LIVE', mission: 'THAAD & Patriot batteries at Al Dhafra / UAE - hit-to-kill BMD - proven in Jan 2022 Houthi intercept & Feb 2026 Iranian strikes'),
  MilitaryPosition(id: 'ef-28', callsign: 'AMD-JORDAN', type: ForceType.allied, lat: 31.9, lng: 36.8, unit: 'THAAD Battery / Muwaffaq Salti', branch: 'US Army', strength: 95, readiness: 98, lastUpdate: 'LIVE', mission: 'THAAD anti-ballistic missile system deployed at MSAB Jordan - confirmed by satellite imagery - layered defense with Patriot PAC-3'),
  MilitaryPosition(id: 'ef-29', callsign: 'JEBALI-PORT', type: ForceType.allied, lat: 25.0042, lng: 55.0580, unit: 'Jebel Ali Port Facility', branch: 'US Navy', strength: 70, readiness: 85, lastUpdate: 'LIVE', mission: 'Jebel Ali Port, Dubai - largest USN port of call in Middle East - logistics / replenishment / crew rest'),

  // === ISRAELI MILITARY ASSETS ===
  MilitaryPosition(id: 'ef-30', callsign: 'NEVATIM-F35', type: ForceType.allied, lat: 31.2083, lng: 34.9222, unit: 'IAF Nevatim AB - F-35I Adir', branch: 'IAF', strength: 100, readiness: 100, lastUpdate: 'LIVE', mission: 'Nevatim Airbase (AFB 28), Negev - 48x F-35I Adir (116th "Lions of South", 140th "Golden Eagle", 117th sqns) - most important IAF base - underground strategic command post - US AN/TPY-2 X-band radar'),
  MilitaryPosition(id: 'ef-31', callsign: 'RAMON-F16', type: ForceType.allied, lat: 30.7761, lng: 34.6667, unit: 'IAF Ramon AB - F-16I Sufa', branch: 'IAF', strength: 95, readiness: 98, lastUpdate: 'LIVE', mission: 'Ramon Airbase, southern Negev - F-16I Sufa multirole fighters (4 squadrons x 25 jets) - long-range strike capability with conformal fuel tanks'),
  MilitaryPosition(id: 'ef-32', callsign: 'HATZERIM-AB', type: ForceType.allied, lat: 31.2344, lng: 34.6628, unit: 'IAF Hatzerim AB', branch: 'IAF', strength: 90, readiness: 95, lastUpdate: 'LIVE', mission: 'Hatzerim Airbase near Beersheba - F-16C/D fleet - IAF flight school - operational interceptor squadrons'),
  MilitaryPosition(id: 'ef-33', callsign: 'HAIFA-NAVY', type: ForceType.allied, lat: 32.8184, lng: 34.9885, unit: 'Israeli Navy HQ / Haifa', branch: 'Israeli Navy', strength: 92, readiness: 96, lastUpdate: 'LIVE', mission: "Haifa Naval Base - main IDF naval base - 7th Fleet (5x Dolphin-class submarines w/ AIP, nuclear-capable SLCMs) - 3rd Fleet (Sa'ar 6 corvettes w/ Iron Dome & Barak-8) - missile boat squadrons"),

  // === HOSTILE (IRGC) POSITIONS ===
  MilitaryPosition(id: 'hst-01', callsign: 'IRGC-QF', type: ForceType.hostile, lat: 34.2, lng: 51.5, unit: 'Quds Force', branch: 'IRGC', strength: 50, readiness: 50, lastUpdate: 'LIVE', mission: 'Leadership decimated -- 40+ senior leaders killed including Khamenei (Reuters) -- 7 security leaders confirmed KIA (IDF)'),
  MilitaryPosition(id: 'hst-02', callsign: 'IRGC-GF', type: ForceType.hostile, lat: 33.5, lng: 50.5, unit: 'IRGC Ground Forces', branch: 'IRGC', strength: 60, readiness: 50, lastUpdate: 'LIVE', mission: '555 killed across Iran (Red Crescent via Reuters) -- 1,000+ US targets hit (Reuters)'),
  MilitaryPosition(id: 'hst-03', callsign: 'IRGC-ASF', type: ForceType.hostile, lat: 35.3, lng: 51.8, unit: 'IRGC Aerospace Force', branch: 'IRGC', strength: 50, readiness: 50, lastUpdate: 'LIVE', mission: 'True Promise 4 ongoing -- 7th/8th waves launched (Al Jazeera) -- 27 US bases targeted'),
  MilitaryPosition(id: 'hst-04', callsign: 'IRGCN-1', type: ForceType.hostile, lat: 26.9, lng: 56.0, unit: 'IRGC Navy', branch: 'IRGCN', strength: 30, readiness: 30, lastUpdate: 'LIVE', mission: '9 ships sunk -- naval HQ largely destroyed -- Hormuz declared closed -- EW activity (Reuters/Al Jazeera/Fox News)'),
  MilitaryPosition(id: 'hst-05', callsign: 'BASIJ-1', type: ForceType.hostile, lat: 32.8, lng: 52.0, unit: 'Basij Resistance', branch: 'Basij', strength: 60, readiness: 50, lastUpdate: 'LIVE', mission: 'Civil defense -- 158 students killed Minab school (Al Jazeera) -- martial law reported'),

  // === NEUTRAL POSITIONS (Civilian / Humanitarian) ===
  MilitaryPosition(id: 'ntl-01', callsign: 'ICRC-TEHRAN', type: ForceType.neutral, lat: 35.72, lng: 51.42, unit: 'ICRC Delegation Tehran', branch: 'ICRC', strength: 100, readiness: 100, lastUpdate: 'LIVE', mission: 'International Committee of the Red Cross -- humanitarian coordination -- POW access monitoring'),
  MilitaryPosition(id: 'ntl-02', callsign: 'WHO-IRAN', type: ForceType.neutral, lat: 35.75, lng: 51.41, unit: 'WHO Iran Country Office', branch: 'WHO', strength: 100, readiness: 95, lastUpdate: 'LIVE', mission: 'World Health Organization -- medical supply coordination -- hospital damage assessment'),
  MilitaryPosition(id: 'ntl-03', callsign: 'UNHCR-KER', type: ForceType.neutral, lat: 30.28, lng: 57.08, unit: 'UNHCR Kerman Field Office', branch: 'UNHCR', strength: 80, readiness: 85, lastUpdate: 'LIVE', mission: 'Afghan refugee protection -- 3.4M refugees in Iran -- displacement monitoring'),
  MilitaryPosition(id: 'ntl-04', callsign: 'IAEA-VIE', type: ForceType.neutral, lat: 48.23, lng: 16.41, unit: 'IAEA HQ Vienna', branch: 'IAEA', strength: 100, readiness: 100, lastUpdate: 'LIVE', mission: 'Nuclear site monitoring -- Natanz/Fordow inspections suspended -- radiological release assessment'),

  // === UNKNOWN / UNVERIFIED POSITIONS ===
  MilitaryPosition(id: 'unk-01', callsign: 'UNK-SUB', type: ForceType.unknown, lat: 25.5, lng: 57.5, unit: 'Unidentified Submarine Contact', branch: 'Unknown', strength: 0, readiness: 0, lastUpdate: 'LIVE', mission: 'Sonar contact -- Strait of Hormuz -- classification pending -- could be Iranian Ghadir-class or commercial vessel'),
  MilitaryPosition(id: 'unk-02', callsign: 'UNK-UAV', type: ForceType.unknown, lat: 28.0, lng: 53.0, unit: 'Unidentified UAV Swarm', branch: 'Unknown', strength: 0, readiness: 0, lastUpdate: 'LIVE', mission: 'Radar track -- 12+ contacts -- flight profile inconsistent with known types -- IFF negative'),
  MilitaryPosition(id: 'unk-03', callsign: 'UNK-VESSEL', type: ForceType.unknown, lat: 26.0, lng: 56.5, unit: 'Suspect Vessel - AIS Off', branch: 'Unknown', strength: 0, readiness: 0, lastUpdate: 'LIVE', mission: 'AIS transponder disabled -- IRGCN fast boat profile -- mine-laying activity suspected -- P-3C tracking'),
];

// --------------- EVENT TEMPLATES ---------------

const Map<String, List<String>> eventTemplates = {
  'intercept': [
    'Shahab-3 ballistic missile intercepted by SM-3 - sector {sector}',
    'Shahed-136 drone neutralized by CIWS Phalanx - {sector}',
    'Soumar cruise missile intercepted by Patriot PAC-3 - {sector}',
    'Drone swarm (x{count}) neutralized by EW jamming - {sector}',
    'Emad IRBM intercepted in terminal phase - THAAD - {sector}',
    'Fateh-110 SRBM intercepted by Arrow-2 - trajectory from {sector}',
    'Kaman-22 UAV engaged by F/A-18E AIM-9X - {sector} corridor',
    'Mobin MRBM intercepted mid-course - Aegis BMD - {sector}',
    'Houthi Toufan drone neutralized over Red Sea - Iron Dome - {sector}',
    'IRGC Arash loitering munition engaged by C-RAM - {sector}',
  ],
  'strike': [
    'Tomahawk strike confirmed on {target} - BDA ongoing',
    'B-2 Spirit sortie - GBU-57 MOP munitions on {target}',
    'F-35A strike package confirmed on {target} - objective neutralized',
    'JDAM strike from F/A-18E on {target} - impact confirmed',
    'Successful cyber attack on C2 network - {target} offline',
    'F-35I Adir - SDB II strike on mobile TEL near {target} - BDA: destroyed',
    'B-52H CALCM salvo - 12x AGM-86C on {target} - secondary explosions',
    'F-15E Strike Eagle - GBU-28 bunker buster on {target} underground facility',
    'MQ-9 Reaper Hellfire strike - IRGC convoy near {target} - 4 vehicles destroyed',
    'Tomahawk Block V strike on {target} - mission kill confirmed via IMINT',
  ],
  'intel': [
    'SIGINT: IRGC communications intercepted - TEL movement toward {sector}',
    'IMINT: Satellite imagery confirms abnormal activity at {target}',
    'HUMINT: Source CARDINAL reports HVT movement toward {sector}',
    'ELINT: New SA-20 radar detected at {sector} - freq {freq}MHz',
    'OSINT: Abnormal Iranian network traffic detected - possible cyber counter-attack',
    'SIGINT: IRGC Quds Force encrypted burst to Hezbollah - sector {sector}',
    'IMINT: BDA confirms {target} runway cratered - non-operational',
    'MASINT: Seismic activity consistent with underground detonation near {target}',
    'SIGINT: Iranian civil defense frequency active - evacuation order {sector}',
    'ELINT: Iranian EW jamming detected - GPS denied zone expanding {sector}',
  ],
  'alert': [
    'ALERT: Launch detected from {sector} - tracking in progress',
    'ALERT: S-300 activation detected sector {sector}',
    'ALERT: Hostile force movement detected - {sector}',
    'ALERT: GPS jamming detected zone {sector} - high intensity',
    'ALERT: Unidentified submarine activity - Strait of Hormuz',
    'ALERT: IRGCN mine-laying activity detected - Strait of Hormuz sector {sector}',
    'ALERT: Proxy rocket barrage from southern Iraq - targeting {sector}',
    'ALERT: Iranian Ghadir midget submarine contact - Gulf of Oman',
    'ALERT: IRGC mobile TEL emerging from tunnel - {sector} - time-sensitive target',
    'ALERT: Houthi anti-ship missile launched toward Red Sea shipping - {sector}',
  ],
  'cyber': [
    'SCADA intrusion successful - Natanz centrifuges - 12% degradation',
    'DDoS launched on IRGC telecom infrastructure - 47 nodes impacted',
    'Malware deployed on Iranian air C2 network - data exfiltration',
    'IRGC tactical communications jammed - sector {sector}',
    'Bavar-373 radar system compromised - false echoes injected',
    'Iranian banking SWIFT node disrupted - financial C2 degraded',
    'Power grid SCADA access - Isfahan province rolling blackouts initiated',
    'IRGC drone command frequency hijacked - 3 Shahed-136 redirected',
    'Iranian state TV broadcast interrupted - replaced with coalition message',
    'CyberAv3ngers counter-op detected and neutralized - no damage',
  ],
};

const List<String> sectors = ['Alpha', 'Bravo', 'Charlie', 'Delta', 'Echo', 'Foxtrot', 'Golf', 'Hotel'];

List<String> get targetsNames => infrastructure.map((i) => i.name).toList();

const List<int> freqs = [2400, 3100, 5800, 8900, 9200, 10400, 14200];

// --------------- INTEL TICKER MESSAGES ---------------

const List<String> tickerMessages = [
  // Leadership -- Reuters
  'FLASH // Khamenei killed in coalition strikes -- 40+ senior Iranian leaders killed in opening wave (Reuters)',
  'FLASH // 7 Iranian security leaders confirmed killed by IDF strikes (IDF)',
  // US operations -- Reuters
  'FLASH // US forces hit 1,000+ targets in first 2 days of Operation Epic Fury (Reuters)',
  'FLASH // 9 Iranian naval ships sunk -- naval HQ "largely destroyed" (Reuters)',
  'IMMEDIATE // Iranian naval presence denied in Gulf of Oman within 48 hours (Reuters)',
  'PRIORITY // 6 US aircrew killed -- F-15Es shot down by Kuwaiti Patriot battery -- friendly fire [A2] (Reuters)',
  'IMMEDIATE // Trump: operation could take "four to five weeks" (Reuters)',
  'IMMEDIATE // Oil hits \$155/barrel -- Iranian exports disrupted -- global energy crisis deepening (Reuters)',
  // IDF operations -- IDF
  'FLASH // IAF drops 1,200+ munitions across 24 of 31 Iranian provinces -- 30+ strike operations (IDF)',
  'FLASH // IDF strikes and dismantles Iranian state broadcaster (IDF)',
  // Iran True Promise 4 -- Al Jazeera
  'FLASH // Iran True Promise 4 launched -- 27 US bases targeted -- 7th/8th waves ongoing (Al Jazeera)',
  'FLASH // IRGC claims targeting USS Abraham Lincoln with 4 ballistic missiles (Al Jazeera)',
  'IMMEDIATE // Explosions reported in Dubai, Doha, Manama for 3 consecutive days (Al Jazeera)',
  'FLASH // Warhead landed near Temple Mount -- 40+ buildings damaged in Tel Aviv (Al Jazeera)',
  'IMMEDIATE // Strait of Hormuz declared closed by Iranian general (Al Jazeera)',
  // Gulf state damage -- Al Jazeera
  'IMMEDIATE // UAE: 165 BM + 2 cruise + 541 drones fired -- 3 KIA 58 WIA -- 21 drones penetrated (Al Jazeera / UAE MoD)',
  'IMMEDIATE // Kuwait: 97 BM + 283 drones intercepted -- Kuwait airport hit by drone -- 1 KIA 32 WIA (Al Jazeera)',
  'PRIORITY // Bahrain: 45 missiles + 9 drones shot down -- 5th Fleet HQ targeted -- 1 KIA 4 WIA (Al Jazeera)',
  'PRIORITY // Qatar: 65 missiles + 12 drones -- most intercepted -- 16 injured (Al Jazeera)',
  // Israel -- IDF / Al Jazeera
  'FLASH // Israel: 9+ KIA 121 WIA from Iranian strikes -- Arrow-3 exo-atmospheric intercepts confirmed (IDF / Al Jazeera)',
  // Iran casualties -- Reuters / Al Jazeera
  'IMMEDIATE // 555 killed in Iran per Red Crescent [B3] -- 158 students killed in Minab [D4 Iran claim] (Reuters / Al Jazeera)',
  // IAEA -- Reuters / Al Jazeera
  'PRIORITY // Iran IAEA ambassador confirms Natanz targeted -- IAEA: no confirmed damage to nuclear facilities as of Mar 2 (Reuters / Al Jazeera)',
  'PRIORITY // IAEA: "cannot rule out radiological release" from strikes near nuclear sites (Reuters)',
  // Regional escalation -- Al Jazeera
  'FLASH // Hezbollah fires rockets at northern Israel -- first since Nov 2024 ceasefire -- IDF retaliates on Beirut suburbs (Al Jazeera)',
  'IMMEDIATE // 31 killed, 149 wounded in Lebanon from Israeli retaliatory strikes (Al Jazeera)',
  'IMMEDIATE // Dubai International Airport damaged and shut down -- regional airspace closures across 7 countries (Fox News / Al Jazeera)',
  'PRIORITY // Cyprus: drone hits British air base -- limited damage (Al Jazeera)',
  // Fox News
  'IMMEDIATE // Electronic warfare activity detected in Strait of Hormuz (Fox News)',
  'PRIORITY // Burj Al Arab minor fire from intercepted drone debris -- Jebel Ali Port berth fire (Al Jazeera)',
];

// --------------- SOURCE ATTRIBUTION ---------------

class EventSource {
  final String name;
  final String url;
  const EventSource({required this.name, required this.url});
}

const List<EventSource> eventSources = [
  EventSource(name: 'CENTCOM', url: 'https://www.centcom.mil'),
  EventSource(name: 'IDF', url: 'https://www.idf.il'),
  EventSource(name: 'Reuters', url: 'https://www.reuters.com/world/middle-east/'),
  EventSource(name: 'Al Jazeera', url: 'https://www.aljazeera.com/tag/iran/'),
  EventSource(name: '@Conflicts', url: 'https://x.com/Conflicts'),
  EventSource(name: '@IntelCrab', url: 'https://x.com/IntelCrab'),
  EventSource(name: '@sentdefender', url: 'https://x.com/sentdefender'),
  EventSource(name: 'CYBERCOM', url: 'https://www.cybercom.mil'),
];

const Map<String, List<int>> categorySources = {
  'intercept': [0, 1, 2],       // CENTCOM, IDF, Reuters
  'strike': [0, 1, 4],          // CENTCOM, IDF, @Conflicts
  'intel': [5, 6, 4],           // @IntelCrab, @sentdefender, @Conflicts
  'alert': [0, 3, 2],           // CENTCOM, Al Jazeera, Reuters
  'cyber': [7, 0, 5],           // CYBERCOM, CENTCOM, @IntelCrab
};

// --------------- HELPER FUNCTIONS ---------------

final _random = Random();

AttackEvent generateEvent() {
  const types = AttackType.values;
  const statuses = EventStatus.values;
  final type = types[_random.nextInt(types.length)];
  final status = _random.nextDouble() > 0.3
      ? EventStatus.intercepted
      : statuses[_random.nextInt(statuses.length)];

  final sector = sectors[_random.nextInt(sectors.length)];
  final target = targetsNames[_random.nextInt(targetsNames.length)];
  final freq = freqs[_random.nextInt(freqs.length)];
  final count = _random.nextInt(8) + 3;

  final categories = eventTemplates.keys.toList();
  final category = categories[_random.nextInt(categories.length)];
  final templates = eventTemplates[category]!;
  var detail = templates[_random.nextInt(templates.length)];
  detail = detail
      .replaceAll('{sector}', sector)
      .replaceAll('{target}', target)
      .replaceAll('{freq}', freq.toString())
      .replaceAll('{count}', count.toString());

  final sourceIndices = categorySources[category] ?? [0, 2, 3];
  final src = eventSources[sourceIndices[_random.nextInt(sourceIndices.length)]];

  final now = DateTime.now().millisecondsSinceEpoch;
  final id = 'evt-$now-${_random.nextInt(9999).toString().padLeft(4, '0')}';

  return AttackEvent(
    id: id,
    timestamp: now,
    type: type,
    origin: sector,
    target: target,
    status: status,
    details: detail,
    source: src.name,
    sourceUrl: src.url,
  );
}

Map<String, dynamic> generateIntel() {
  const classifications = ['TS', 'SECRET', 'CONFIDENTIAL'];
  const priorities = ['FLASH', 'IMMEDIATE', 'PRIORITY', 'ROUTINE'];
  const sources = ['SIGINT', 'IMINT', 'HUMINT', 'ELINT', 'OSINT', 'MASINT'];

  final sector = sectors[_random.nextInt(sectors.length)];
  final target = targetsNames[_random.nextInt(targetsNames.length)];

  final allTemplates = [
    ...eventTemplates['intel']!,
    ...eventTemplates['alert']!,
  ];
  var content = allTemplates[_random.nextInt(allTemplates.length)];
  content = content
      .replaceAll('{sector}', sector)
      .replaceAll('{target}', target)
      .replaceAll('{freq}', '9200');

  final now = DateTime.now().millisecondsSinceEpoch;
  final id = 'intel-$now-${_random.nextInt(9999).toString().padLeft(4, '0')}';

  return {
    'id': id,
    'timestamp': now,
    'classification': classifications[_random.nextInt(classifications.length)],
    'source': sources[_random.nextInt(sources.length)],
    'content': content,
    'priority': priorities[_random.nextInt(priorities.length)],
  };
}
