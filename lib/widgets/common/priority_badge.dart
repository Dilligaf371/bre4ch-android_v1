// =============================================================================
// BRE4CH - PriorityBadge Widget
// FLASH / IMMEDIATE / PRIORITY / ROUTINE badge for OSINT items
// =============================================================================

import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/osint_item.dart';

class PriorityBadge extends StatelessWidget {
  final OsintPriority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(
        _label,
        style: AppTextStyles.mono(
          size: 7,
          weight: FontWeight.w700,
          color: _color,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  String get _label {
    switch (priority) {
      case OsintPriority.flash:
        return 'FLASH';
      case OsintPriority.immediate:
        return 'IMMEDIATE';
      case OsintPriority.priority:
        return 'PRIORITY';
      case OsintPriority.routine:
        return 'ROUTINE';
    }
  }

  Color get _color {
    switch (priority) {
      case OsintPriority.flash:
        return Palantir.danger;
      case OsintPriority.immediate:
        return Palantir.orange;
      case OsintPriority.priority:
        return Palantir.warning;
      case OsintPriority.routine:
        return Palantir.textMuted;
    }
  }
}
