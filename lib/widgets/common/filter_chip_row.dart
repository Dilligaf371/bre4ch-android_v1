// =============================================================================
// BRE4CH - FilterChipRow Widget
// Horizontal scrollable toggle chips
// =============================================================================

import 'package:flutter/material.dart';
import '../../config/theme.dart';

class FilterChipRow extends StatelessWidget {
  final List<String> labels;
  final Set<String> selected;
  final void Function(String) onToggle;
  final Color activeColor;
  final EdgeInsets? padding;

  const FilterChipRow({
    super.key,
    required this.labels,
    required this.selected,
    required this.onToggle,
    this.activeColor = Palantir.accent,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = labels[index];
          final isActive = selected.contains(label);

          return GestureDetector(
            onTap: () => onToggle(label),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? activeColor.withValues(alpha: 0.15)
                    : Palantir.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? activeColor.withValues(alpha: 0.6)
                      : Palantir.border,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTextStyles.mono(
                  size: 9,
                  weight: FontWeight.w600,
                  color: isActive ? activeColor : Palantir.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
