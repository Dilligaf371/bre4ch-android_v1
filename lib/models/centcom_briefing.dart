// =============================================================================
// BRE4CH - CENTCOM Briefing Model
// BRE4CH
// =============================================================================

import 'package:intl/intl.dart';

enum CentcomCategory { pressRelease, news, statement }

enum CentcomPriority { flash, immediate, priority, routine }

class CentcomBriefing {
  final String id;
  final String title;
  final CentcomCategory category;
  final CentcomPriority priority;
  final int timestamp; // milliseconds epoch
  final String pubDate;
  final String link;
  final String summary;

  const CentcomBriefing({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.timestamp,
    required this.pubDate,
    required this.link,
    this.summary = '',
  });

  factory CentcomBriefing.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? '';
    final summary = json['summary'] as String? ?? '';
    final category = _parseCategory(json['category'] as String? ?? '');
    final pubDate = json['pubDate'] as String? ?? '';
    int ts;
    try {
      ts = _parsePubDate(pubDate).millisecondsSinceEpoch ~/ 1000;
    } catch (_) {
      ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }

    return CentcomBriefing(
      id: json['id'] as String? ?? 'centcom-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
      priority: classifyPriority(title, summary),
      timestamp: ts,
      pubDate: pubDate,
      link: json['link'] as String? ?? '',
      summary: summary,
    );
  }

  /// Parse RFC 2822 ("Tue, 03 Mar 2026 23:10:51 GMT") or ISO 8601 dates.
  static DateTime _parsePubDate(String s) {
    // Try ISO 8601 first
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;
    // Try RFC 2822: "Tue, 03 Mar 2026 23:10:51 GMT"
    try {
      final fmt = DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en_US');
      final cleaned = s.replaceAll(' GMT', '').replaceAll(' UTC', '').trim();
      return fmt.parseUtc(cleaned);
    } catch (_) {}
    // Try without day-of-week: "03 Mar 2026 23:10:51 GMT"
    try {
      final fmt = DateFormat('dd MMM yyyy HH:mm:ss', 'en_US');
      final cleaned = s.replaceAll(' GMT', '').replaceAll(' UTC', '').trim();
      return fmt.parseUtc(cleaned);
    } catch (_) {}
    throw FormatException('Cannot parse date: $s');
  }

  static CentcomCategory _parseCategory(String s) {
    switch (s) {
      case 'press-release':
        return CentcomCategory.pressRelease;
      case 'news':
        return CentcomCategory.news;
      case 'statement':
        return CentcomCategory.statement;
      default:
        return CentcomCategory.pressRelease;
    }
  }

  static CentcomPriority classifyPriority(String title, String summary) {
    final lower = '$title $summary'.toLowerCase();
    if (lower.contains('breaking') ||
        lower.contains('killed') ||
        lower.contains('strike') ||
        lower.contains('attack') ||
        lower.contains('casualties') ||
        lower.contains('intercept')) {
      return CentcomPriority.flash;
    } else if (lower.contains('iran') ||
        lower.contains('military') ||
        lower.contains('missile') ||
        lower.contains('operation') ||
        lower.contains('drone') ||
        lower.contains('threat')) {
      return CentcomPriority.immediate;
    } else if (lower.contains('deployment') ||
        lower.contains('exercise') ||
        lower.contains('coalition') ||
        lower.contains('security') ||
        lower.contains('partnership')) {
      return CentcomPriority.priority;
    }
    return CentcomPriority.routine;
  }

  CentcomBriefing copyWith({
    String? id,
    String? title,
    CentcomCategory? category,
    CentcomPriority? priority,
    int? timestamp,
    String? pubDate,
    String? link,
    String? summary,
  }) {
    return CentcomBriefing(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      pubDate: pubDate ?? this.pubDate,
      link: link ?? this.link,
      summary: summary ?? this.summary,
    );
  }
}
