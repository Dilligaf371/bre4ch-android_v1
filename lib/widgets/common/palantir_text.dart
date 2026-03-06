// =============================================================================
// BRE4CH - PalantirText Widget
// Text helper for consistent typography
// =============================================================================

import 'package:flutter/material.dart';
import '../../config/theme.dart';

class PalantirText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool mono;
  final double? size;
  final Color? color;
  final FontWeight? weight;
  final double? letterSpacing;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const PalantirText(
    this.text, {
    super.key,
    this.style,
    this.mono = true,
    this.size,
    this.color,
    this.weight,
    this.letterSpacing,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  /// Convenience constructor for mono text
  const PalantirText.mono(
    this.text, {
    super.key,
    this.size = 12,
    this.color = Palantir.text,
    this.weight = FontWeight.w400,
    this.letterSpacing,
    this.textAlign,
    this.maxLines,
    this.overflow,
  })  : mono = true,
        style = null;

  /// Convenience constructor for sans text
  const PalantirText.sans(
    this.text, {
    super.key,
    this.size = 14,
    this.color = Palantir.text,
    this.weight = FontWeight.w400,
    this.letterSpacing,
    this.textAlign,
    this.maxLines,
    this.overflow,
  })  : mono = false,
        style = null;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ??
        (mono
            ? AppTextStyles.mono(
                size: size ?? 12,
                weight: weight ?? FontWeight.w400,
                color: color ?? Palantir.text,
                letterSpacing: letterSpacing,
              )
            : AppTextStyles.sans(
                size: size ?? 14,
                weight: weight ?? FontWeight.w400,
                color: color ?? Palantir.text,
                letterSpacing: letterSpacing,
              ));

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
