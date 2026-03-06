// =============================================================================
// BRE4CH - Coalition Epic Fury (US-Led) Feeds
// Day 3 (Mar 3, 2026) -- Operation Epic Fury / Roar of the Lion
// NATO STANAG 2022: [A-F] Reliability / [1-6] Credibility
// OFF = Offensive ops | DEF = Defensive ops
// =============================================================================

import '../models/attack_stats.dart';

const List<CountryFeed> coalitionFeeds = [
  // --- USA (CENTCOM) ---
  CountryFeed(
    id: 'usa',
    name: 'USA (CENTCOM)',
    flag: '\u{1F1FA}\u{1F1F8}',
    color: 'text-blue-400',
    borderColor: 'border-blue-500/30',
    bgColor: 'from-blue-500/10',
    offensive: [
      StatItem(label: 'TGT DESTROYED [BDA]', value: '1,000+', color: 'text-orange-400', bgColor: 'bg-orange-500/20'),
      StatItem(label: 'OCA/SEAD SORTIES', value: 247, color: 'text-blue-400', bgColor: 'bg-blue-500/20'),
      StatItem(label: 'TLAM SALVOS', value: 312, color: 'text-orange-400', bgColor: 'bg-orange-500/20'),
      StatItem(label: 'IRGCN VESSELS SUNK', value: 9, color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'BANDAR ABBAS NHQ', value: 'DESTROYED', color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'ENEMY KIA [EST]', value: '555+', color: 'text-red-400', bgColor: 'bg-red-500/20'),
    ],
    defensive: [
      StatItem(label: 'AEGIS BMD INTERCEPT', value: 23, color: 'text-green-400', bgColor: 'bg-green-500/20'),
      StatItem(label: 'C-RAM ACTIVATIONS', value: 47, color: 'text-green-400', bgColor: 'bg-green-500/20'),
      StatItem(label: 'KIA', value: 6, color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'WIA', value: 34, color: 'text-orange-400', bgColor: 'bg-orange-500/20'),
    ],
    source: 'CENTCOM / Reuters [A2]',
  ),

  // --- ISRAEL (IDF/IAF) ---
  CountryFeed(
    id: 'israel',
    name: 'ISRAEL (IDF/IAF)',
    flag: '\u{1F1EE}\u{1F1F1}',
    color: 'text-cyan-400',
    borderColor: 'border-cyan-500/30',
    bgColor: 'from-cyan-500/10',
    offensive: [
      StatItem(label: 'PGM DELIVERED', value: '1,200+', color: 'text-orange-400', bgColor: 'bg-orange-500/20'),
      StatItem(label: 'IAF OCA SORTIES', value: '30+', color: 'text-blue-400', bgColor: 'bg-blue-500/20'),
      StatItem(label: 'PROVINCES STRUCK', value: '24/31', color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'HVT NEUTRALIZED', value: 7, color: 'text-red-400', bgColor: 'bg-red-500/20'),
    ],
    defensive: [
      StatItem(label: 'ARROW-3 BMD', value: 89, color: 'text-green-400', bgColor: 'bg-green-500/20'),
      StatItem(label: 'IRON DOME INTERCEPT', value: 312, color: 'text-green-400', bgColor: 'bg-green-500/20'),
      StatItem(label: 'KIA', value: 9, color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'WIA', value: 121, color: 'text-orange-400', bgColor: 'bg-orange-500/20'),
    ],
    source: 'IDF [B2]',
  ),

  // --- UNITED KINGDOM ---
  CountryFeed(
    id: 'uk',
    name: 'UNITED KINGDOM',
    flag: '\u{1F1EC}\u{1F1E7}',
    color: 'text-indigo-400',
    borderColor: 'border-indigo-500/30',
    bgColor: 'from-indigo-500/10',
    offensive: [
      StatItem(label: 'RAF TYPHOON SORTIES', value: 48, color: 'text-blue-400', bgColor: 'bg-blue-500/20'),
      StatItem(label: 'STORM SHADOW CRUISE', value: 24, color: 'text-orange-400', bgColor: 'bg-orange-500/20'),
      StatItem(label: 'HARPOON NAVAL STRIKE', value: 6, color: 'text-red-400', bgColor: 'bg-red-500/20'),
    ],
    defensive: [
      StatItem(label: 'TYPE 45 SEA VIPER', value: 12, color: 'text-green-400', bgColor: 'bg-green-500/20'),
      StatItem(label: 'PHALANX C-UAS', value: 8, color: 'text-green-400', bgColor: 'bg-green-500/20'),
    ],
    source: 'UK MoD [B2]',
  ),

  // --- UAE ---
  CountryFeed(
    id: 'uae',
    name: 'UAE',
    flag: '\u{1F1E6}\u{1F1EA}',
    color: 'text-red-400',
    borderColor: 'border-red-500/30',
    bgColor: 'from-red-500/10',
    offensive: [
      StatItem(label: 'F-16E BLK60 ISR', value: 12, color: 'text-blue-400', bgColor: 'bg-blue-500/20'),
      StatItem(label: 'EW SUPPORT OPS', value: 3, color: 'text-purple-400', bgColor: 'bg-purple-500/20'),
    ],
    defensive: [
      StatItem(label: 'THAAD INTERCEPT', value: 97, color: 'text-green-400', bgColor: 'bg-green-500/20'),
      StatItem(label: 'PATRIOT PAC-3 [BM]', value: 165, color: 'text-green-400', bgColor: 'bg-green-500/20'),
      StatItem(label: 'C-UAS INTERCEPT', value: 541, color: 'text-green-400', bgColor: 'bg-green-500/20'),
      StatItem(label: 'UAS PENETRATIONS', value: 21, color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'KIA', value: 3, color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'WIA', value: 58, color: 'text-orange-400', bgColor: 'bg-orange-500/20'),
    ],
    source: 'UAE MoD / Al Jazeera [A2]',
  ),

  // --- KSA ---
  CountryFeed(
    id: 'ksa',
    name: 'KSA',
    flag: '\u{1F1F8}\u{1F1E6}',
    color: 'text-emerald-400',
    borderColor: 'border-emerald-500/30',
    bgColor: 'from-emerald-500/10',
    offensive: [
      StatItem(label: 'PSAB LOG SUPPORT', value: 'ACTIVE', color: 'text-blue-400', bgColor: 'bg-blue-500/20'),
      StatItem(label: 'AAR SORTIES', value: 36, color: 'text-blue-400', bgColor: 'bg-blue-500/20'),
    ],
    defensive: [
      StatItem(label: 'PATRIOT/THAAD STATUS', value: 'HIGH ALERT', color: 'text-yellow-400', bgColor: 'bg-yellow-500/20'),
      StatItem(label: 'CONFIRMED ATTACKS', value: 'NIL', color: 'text-gray-400', bgColor: 'bg-white/5'),
    ],
    source: 'NO VERIFIED SOURCE [D5]',
  ),

  // --- KUWAIT ---
  CountryFeed(
    id: 'kuwait',
    name: 'KUWAIT',
    flag: '\u{1F1F0}\u{1F1FC}',
    color: 'text-green-400',
    borderColor: 'border-green-500/30',
    bgColor: 'from-green-500/10',
    offensive: [
      StatItem(label: 'ALI AL SALEM HNS', value: 'ACTIVE', color: 'text-blue-400', bgColor: 'bg-blue-500/20'),
    ],
    defensive: [
      StatItem(label: 'PATRIOT BMD', value: 97, color: 'text-green-400', bgColor: 'bg-green-500/20'),
      StatItem(label: 'C-UAS INTERCEPT', value: 283, color: 'text-green-400', bgColor: 'bg-green-500/20'),
      StatItem(label: 'KIA', value: 1, color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'WIA', value: 32, color: 'text-orange-400', bgColor: 'bg-orange-500/20'),
    ],
    source: 'Kuwait govt / Al Jazeera [A2]',
  ),

  // --- BAHRAIN ---
  CountryFeed(
    id: 'bahrain',
    name: 'BAHRAIN',
    flag: '\u{1F1E7}\u{1F1ED}',
    color: 'text-yellow-400',
    borderColor: 'border-yellow-500/30',
    bgColor: 'from-yellow-500/10',
    offensive: [
      StatItem(label: 'NSA BAHRAIN 5TH FLT', value: 'LOG SUPPORT', color: 'text-blue-400', bgColor: 'bg-blue-500/20'),
    ],
    defensive: [
      StatItem(label: 'IAMD INTERCEPT', value: 45, color: 'text-green-400', bgColor: 'bg-green-500/20'),
      StatItem(label: 'C-UAS', value: 9, color: 'text-green-400', bgColor: 'bg-green-500/20'),
      StatItem(label: 'KIA', value: 1, color: 'text-red-400', bgColor: 'bg-red-500/20'),
      StatItem(label: 'WIA', value: 4, color: 'text-orange-400', bgColor: 'bg-orange-500/20'),
    ],
    source: 'Al Jazeera [B2]',
  ),

  // --- QATAR ---
  CountryFeed(
    id: 'qatar',
    name: 'QATAR',
    flag: '\u{1F1F6}\u{1F1E6}',
    color: 'text-purple-400',
    borderColor: 'border-purple-500/30',
    bgColor: 'from-purple-500/10',
    offensive: [
      StatItem(label: 'AL UDEID CAOC', value: 'ACTIVE', color: 'text-blue-400', bgColor: 'bg-blue-500/20'),
      StatItem(label: 'E-3 AWACS SUPPORT', value: 'ACTIVE', color: 'text-purple-400', bgColor: 'bg-purple-500/20'),
    ],
    defensive: [
      StatItem(label: 'IAMD INTERCEPT', value: 65, color: 'text-green-400', bgColor: 'bg-green-500/20'),
      StatItem(label: 'C-UAS', value: 12, color: 'text-green-400', bgColor: 'bg-green-500/20'),
      StatItem(label: 'WIA', value: 16, color: 'text-orange-400', bgColor: 'bg-orange-500/20'),
    ],
    source: 'Al Jazeera [B2]',
  ),
];
