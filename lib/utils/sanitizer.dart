// ── MED-05 FIX: RSS/API Content Sanitizer ───────────────────────
// Strips HTML tags, neutralizes XSS payloads, and cleans RSS content.

import 'package:html_unescape/html_unescape.dart';

final _unescape = HtmlUnescape();

// Strip all HTML tags
final _htmlTagRegex = RegExp(r'<[^>]*>', multiLine: true);

// Remove event handler attributes (onclick, onerror, etc.)
final _eventHandlerRegex = RegExp(r'\bon\w+\s*=', caseSensitive: false);

// Remove javascript: protocol
final _jsProtocolRegex = RegExp(r'javascript\s*:', caseSensitive: false);

/// Strip all HTML tags from a string.
String stripHtmlTags(String input) {
  return input.replaceAll(_htmlTagRegex, '');
}

/// Sanitize a single content string: strip HTML, decode entities, remove XSS vectors.
String sanitizeContent(String input) {
  if (input.isEmpty) return input;

  var result = input;

  // Strip HTML tags
  result = stripHtmlTags(result);

  // Decode HTML entities (&amp; → &, etc.)
  result = _unescape.convert(result);

  // Remove event handlers and javascript: protocols
  result = result.replaceAll(_eventHandlerRegex, '');
  result = result.replaceAll(_jsProtocolRegex, '');

  // Trim whitespace
  result = result.trim();

  return result;
}

/// Sanitize a headline map from the API.
Map<String, dynamic> sanitizeHeadline(Map<String, dynamic> headline) {
  return {
    'title': sanitizeContent(headline['title'] as String? ?? ''),
    'source': sanitizeContent(headline['source'] as String? ?? ''),
    'pubDate': headline['pubDate'] as String? ?? '',
    'link': headline['link'] as String? ?? '',
  };
}
