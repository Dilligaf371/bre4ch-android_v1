// =============================================================================
// BRE4CH - Bezier Curve Utilities
// Quadratic bezier interpolation for arc rendering
// =============================================================================

/// Computes a point on a quadratic bezier curve at parameter [t].
///
/// P = (1-t)^2 * A + 2(1-t)t * C + t^2 * B
///
/// [ax],[ay] = start point A
/// [bx],[by] = end point B
/// [cx],[cy] = control point C
/// [t] = interpolation parameter in [0, 1]
({double x, double y}) getArcPoint(
  double ax,
  double ay,
  double bx,
  double by,
  double cx,
  double cy,
  double t,
) {
  final oneMinusT = 1.0 - t;
  final oneMinusTSq = oneMinusT * oneMinusT;
  final tSq = t * t;

  return (
    x: oneMinusTSq * ax + 2.0 * oneMinusT * t * cx + tSq * bx,
    y: oneMinusTSq * ay + 2.0 * oneMinusT * t * cy + tSq * by,
  );
}

/// Generates a list of points along a quadratic bezier curve.
///
/// [segments] controls the resolution (number of line segments).
List<({double x, double y})> getArcPoints(
  double ax,
  double ay,
  double bx,
  double by,
  double cx,
  double cy, {
  int segments = 40,
}) {
  return List.generate(
    segments + 1,
    (i) => getArcPoint(ax, ay, bx, by, cx, cy, i / segments),
  );
}
