// =============================================================================
// BRE4CH - Formatting Utilities
// Timestamps, numbers, durations
// =============================================================================

/// Formats a Unix timestamp (seconds) as relative time.
///
/// Returns "just now", "2m ago", "1h ago", "3d ago", etc.
String formatTimestamp(int timestamp) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final diff = now - timestamp;

  if (diff < 60) return 'just now';
  if (diff < 3600) return '${diff ~/ 60}m ago';
  if (diff < 86400) return '${diff ~/ 3600}h ago';
  if (diff < 604800) return '${diff ~/ 86400}d ago';
  return '${diff ~/ 604800}w ago';
}

/// Formats a large number with commas or K/M suffix.
///
/// Under 10,000: "1,500"
/// 10K-999K: "12.3K"
/// 1M+: "1.2M"
String formatNumber(int n) {
  if (n < 0) return '-${formatNumber(-n)}';
  if (n < 10000) {
    // Add commas
    final s = n.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
  if (n < 1000000) {
    final k = n / 1000;
    return k >= 100 ? '${k.round()}K' : '${k.toStringAsFixed(1)}K';
  }
  final m = n / 1000000;
  return m >= 100 ? '${m.round()}M' : '${m.toStringAsFixed(1)}M';
}

/// Formats a Duration as "Xd HH:MM:SS".
///
/// Days are omitted if zero.
String formatDuration(Duration d) {
  final days = d.inDays;
  final hours = d.inHours.remainder(24);
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60);

  final hh = hours.toString().padLeft(2, '0');
  final mm = minutes.toString().padLeft(2, '0');
  final ss = seconds.toString().padLeft(2, '0');

  if (days > 0) {
    return '${days}d $hh:$mm:$ss';
  }
  return '$hh:$mm:$ss';
}
