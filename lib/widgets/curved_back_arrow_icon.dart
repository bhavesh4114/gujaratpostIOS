import 'dart:math';
import 'package:flutter/material.dart';

/// Custom widget recreating the exact curved return/back arrow icon
/// from the reference design.
///
/// Geometry:
///   • ViewBox: 165 × 128 (aspect ratio ~1.289)
///   • Left-facing arrowhead with subtle tip curvature and rounded back corners
///   • Smooth U-shaped loop (upper bar, 180° right bend, lower bar)
///   • Thick, uniform 30px stroke with a semicircular rounded end cap on the lower bar
class CurvedBackArrowIcon extends StatelessWidget {
  final double width;
  final double? height;
  final Color color;

  const CurvedBackArrowIcon({
    super.key,
    this.width = 26.0,
    this.height,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final h = height ?? (width * 128.0 / 165.0);
    return CustomPaint(
      size: Size(width, h),
      painter: CurvedBackArrowPainter(color: color),
    );
  }
}

/// CustomPainter rendering the exact geometric path of the curved back arrow.
class CurvedBackArrowPainter extends CustomPainter {
  final Color color;

  const CurvedBackArrowPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Base reference coordinate system: 165 × 128
    const double refW = 165.0;
    const double refH = 128.0;

    final double scale = (size.width / refW < size.height / refH)
        ? size.width / refW
        : size.height / refH;

    final double dx = (size.width - refW * scale) / 2.0;
    final double dy = (size.height - refH * scale) / 2.0;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final path = Path();

    // ── 1. Arrowhead ─────────────────────────────────────────────────────────
    // Subtle rounded tip:
    path.moveTo(3.0, 36.2);
    path.arcToPoint(
      const Offset(3.0, 40.8),
      radius: const Radius.circular(2.5),
      clockwise: false,
    );
    // Sloping down towards bottom-right corner:
    path.lineTo(42.0, 76.0);
    // Rounded bottom-right corner:
    path.arcToPoint(
      const Offset(48.0, 70.0),
      radius: const Radius.circular(6.0),
      clockwise: false,
    );
    // Vertical back edge of arrowhead to upper bar's bottom edge:
    path.lineTo(48.0, 53.5);

    // ── 2. U-Tube Inner Path ────────────────────────────────────────────────
    // Inner upper horizontal stroke:
    path.lineTo(112.5, 53.5);
    // Inner semicircular arc (radius 22.0, centered at 112.5, 75.5):
    path.arcTo(
      Rect.fromCircle(center: const Offset(112.5, 75.5), radius: 22.0),
      -pi / 2, // -90 deg
      pi,      // +180 deg (clockwise)
      false,
    );
    // Inner lower horizontal stroke extending left:
    path.lineTo(31.0, 97.5);

    // ── 3. Lower Rounded Cap ────────────────────────────────────────────────
    // Semicircular end cap (radius 15.0, centered at 31.0, 112.5):
    path.arcTo(
      Rect.fromCircle(center: const Offset(31.0, 112.5), radius: 15.0),
      -pi / 2, // -90 deg
      -pi,     // -180 deg (counter-clockwise)
      false,
    );

    // ── 4. U-Tube Outer Path ────────────────────────────────────────────────
    // Outer lower horizontal stroke extending right:
    path.lineTo(112.5, 127.5);
    // Outer semicircular arc (radius 52.0, centered at 112.5, 75.5):
    path.arcTo(
      Rect.fromCircle(center: const Offset(112.5, 75.5), radius: 52.0),
      pi / 2,  // +90 deg
      -pi,     // -180 deg (counter-clockwise)
      false,
    );
    // Outer upper horizontal stroke extending left:
    path.lineTo(48.0, 23.5);

    // ── 5. Top-Right of Arrowhead ───────────────────────────────────────────
    // Back edge upwards to top-right corner:
    path.lineTo(48.0, 7.0);
    // Rounded top-right corner:
    path.arcToPoint(
      const Offset(42.0, 1.0),
      radius: const Radius.circular(6.0),
      clockwise: false,
    );
    // Sloping down back to tip:
    path.lineTo(3.0, 36.2);

    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CurvedBackArrowPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
