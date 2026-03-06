// =============================================================================
// BRE4CH - Axis of Resistance (Iran-Led) Feeds
// Day 3 (Mar 3, 2026) -- Operation Epic Fury / Roar of the Lion
// NATO STANAG 2022: [A-F] Reliability / [1-6] Credibility
// OFF = Offensive ops | DEF = Defensive / Losses
// =============================================================================

import '../models/attack_stats.dart';

const List<CountryFeed> axisFeeds = [
  // --- IRAN (IRGC/ARTESH) ---
  CountryFeed(
    id: 'iran',
    name: 'IRAN (IRGC/ARTESH)',
    flag: '\u{1F1EE}\u{1F1F7}',
    color: 'text-red-400',
    borderColor: 'border-red-500/30',
    bgColor: 'from-red-500/10',
    offensive: [
      StatItem(label: 'BM LAUNCHED', value: 482, color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'ASCM FIRED', value: 38, color: 'text-orange-400', bgColor: 'bg-orange-500/20'),
      StatItem(label: 'SHAHEED UAS', value: 967, color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'HORMUZ MINING OP', value: 'ACTIVE', color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'BM AT USS LINCOLN', value: '4 [CLAIMED]', color: 'text-red-400', bgColor: 'bg-red-500/20'),
    ],
    defensive: [
      StatItem(label: 'KIA [RED CRESCENT]', value: '555+', color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'IADS SITES DESTROYED', value: 14, color: 'text-orange-400', bgColor: 'bg-orange-500/20'),
      StatItem(label: 'NAVAL VESSELS LOST', value: 9, color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'PROVINCES UNDER STRIKE', value: '24/31', color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'NUCLEAR SITES TGT', value: 'NATANZ/FORDOW', color: 'text-red-400', bgColor: 'bg-red-500/20'),
    ],
    source: 'IRGC/IRNA [D4] \u2014 Cross-ref Reuters/CENTCOM',
  ),

  // --- HEZBOLLAH ---
  CountryFeed(
    id: 'hezbollah',
    name: 'HEZBOLLAH',
    flag: '\u{1F1F1}\u{1F1E7}',
    color: 'text-orange-400',
    borderColor: 'border-orange-500/30',
    bgColor: 'from-orange-500/10',
    offensive: [
      StatItem(label: 'ROCKET SALVOS (N. ISR)', value: '340+', color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'KORNET ATGM', value: 15, color: 'text-orange-400', bgColor: 'bg-orange-500/20'),
      StatItem(label: 'UAS LAUNCHED', value: 28, color: 'text-red-400', bgColor: 'bg-red-500/20'),
    ],
    defensive: [
      StatItem(label: 'IDF STRIKES (BEIRUT)', value: 'ONGOING', color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'LEADERSHIP TGT', value: 'CONFIRMED', color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'C2 NODES HIT', value: 12, color: 'text-orange-400', bgColor: 'bg-orange-500/20'),
    ],
    source: 'Al Jazeera / IDF [B3]',
  ),

  // --- HOUTHIS (ANSAR ALLAH) ---
  CountryFeed(
    id: 'houthis',
    name: 'HOUTHIS (ANSAR ALLAH)',
    flag: '\u{1F1FE}\u{1F1EA}',
    color: 'text-yellow-400',
    borderColor: 'border-yellow-500/30',
    bgColor: 'from-yellow-500/10',
    offensive: [
      StatItem(label: 'ASCM (RED SEA)', value: 12, color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'BM AT GCC', value: 8, color: 'text-orange-400', bgColor: 'bg-orange-500/20'),
      StatItem(label: 'SHAHEED UAS', value: 23, color: 'text-red-400', bgColor: 'bg-red-500/20'),
    ],
    defensive: [
      StatItem(label: 'COALITION CAS (HUDAYDAH)', value: 'ONGOING', color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'LAUNCH SITES BDA', value: 6, color: 'text-orange-400', bgColor: 'bg-orange-500/20'),
    ],
    source: 'CENTCOM / Reuters [A2]',
  ),

  // --- PMF / HASHD (IRAQ) ---
  CountryFeed(
    id: 'pmf',
    name: 'PMF / HASHD (IRAQ)',
    flag: '\u{1F1EE}\u{1F1F6}',
    color: 'text-amber-400',
    borderColor: 'border-amber-500/30',
    bgColor: 'from-amber-500/10',
    offensive: [
      StatItem(label: 'ROCKET ATK (US FOB)', value: 14, color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'ONE-WAY UAS', value: 8, color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'TGT: AIN AL-ASAD', value: 'CONFIRMED', color: 'text-orange-400', bgColor: 'bg-orange-500/20'),
    ],
    defensive: [
      StatItem(label: 'US PRECISION STRIKE', value: 'LAUNCH SITES', color: 'text-orange-400', bgColor: 'bg-orange-500/20'),
    ],
    source: 'CENTCOM [A2]',
  ),

  // --- RUSSIA ---
  CountryFeed(
    id: 'russia',
    name: 'RUSSIA',
    flag: '\u{1F1F7}\u{1F1FA}',
    color: 'text-gray-400',
    borderColor: 'border-gray-500/30',
    bgColor: 'from-gray-500/10',
    offensive: [
      StatItem(label: 'UNSC VETO', value: 'EXERCISED', color: 'text-gray-400', bgColor: 'bg-gray-500/20'),
      StatItem(label: 'INTEL SHARING [SUSP]', value: 'UNCONFIRMED', color: 'text-yellow-400', bgColor: 'bg-yellow-500/20'),
    ],
    defensive: [
      StatItem(label: 'DIPLOMATIC MEDIATION', value: 'ACTIVE', color: 'text-gray-400', bgColor: 'bg-gray-500/20'),
    ],
    source: 'Reuters [B3] \u2014 DIPLOMATIC SUPPORT',
  ),

  // --- CHINA ---
  CountryFeed(
    id: 'china',
    name: 'CHINA',
    flag: '\u{1F1E8}\u{1F1F3}',
    color: 'text-gray-400',
    borderColor: 'border-gray-500/30',
    bgColor: 'from-gray-500/10',
    offensive: [
      StatItem(label: 'UNSC VETO', value: 'EXERCISED', color: 'text-gray-400', bgColor: 'bg-gray-500/20'),
      StatItem(label: 'ECONOMIC PRESSURE', value: 'SANCTIONS BLOCK', color: 'text-yellow-400', bgColor: 'bg-yellow-500/20'),
    ],
    defensive: [
      StatItem(label: 'DIPLOMATIC STANCE', value: 'CEASEFIRE CALL', color: 'text-gray-400', bgColor: 'bg-gray-500/20'),
    ],
    source: 'Reuters [B3] \u2014 DIPLOMATIC SUPPORT',
  ),
];
