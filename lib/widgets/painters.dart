import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Static, deterministic grain layer painted over the loader background.
///
/// It is intentionally never repainted: the loader must settle so the capture
/// harness sees an idle window, and the grain also lifts the loader frame above
/// the light menu frame in encoded size so the two are never confused.
class SeedGrainPainter extends CustomPainter {
  const SeedGrainPainter();

  static const int _pointsPerPass = 32500;

  static const List<Color> _tints = <Color>[
    AppColors.primary,
    AppColors.accent,
    AppColors.secondary,
    Color(0xFFFFFFFF),
  ];
  static const List<double> _alphas = <double>[0.10, 0.08, 0.06, 0.05];

  static Size _cachedSize = Size.zero;
  static List<Float32List>? _cachedPasses;

  static List<Float32List> _passesFor(Size size) {
    final List<Float32List>? cached = _cachedPasses;
    if (cached != null && _cachedSize == size) {
      return cached;
    }

    int state = 0x5EED;
    int nextRandom() {
      state ^= (state << 13) & 0xFFFFFFFF;
      state ^= state >> 17;
      state ^= (state << 5) & 0xFFFFFFFF;
      return state & 0xFFFFFFFF;
    }

    final List<Float32List> passes = <Float32List>[];
    for (int pass = 0; pass < _tints.length; pass++) {
      final Float32List points = Float32List(_pointsPerPass * 2);
      for (int i = 0; i < _pointsPerPass; i++) {
        points[i * 2] = (nextRandom() % 100000) / 100000 * size.width;
        points[i * 2 + 1] = (nextRandom() % 100000) / 100000 * size.height;
      }
      passes.add(points);
    }

    _cachedSize = size;
    _cachedPasses = passes;
    return passes;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    final List<Float32List> passes = _passesFor(size);
    for (int i = 0; i < passes.length; i++) {
      final Paint paint = Paint()
        ..color = AppColors.fade(_tints[i], _alphas[i])
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.square;
      canvas.drawRawPoints(ui.PointMode.points, passes[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant SeedGrainPainter oldDelegate) => false;
}

/// Circular focus-progress ring used on the session screen.
class FocusRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final List<Color> gradientColors;
  final double stroke;
  final double dim;

  const FocusRingPainter({
    required this.progress,
    required this.trackColor,
    required this.gradientColors,
    this.stroke = 12,
    this.dim = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double side = math.min(size.width, size.height);
    if (side <= stroke) {
      return;
    }
    final Offset center = size.center(Offset.zero);
    final double radius = (side - stroke) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    const double startAngle = math.pi / -2;

    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.fade(trackColor, dim);
    canvas.drawArc(rect, startAngle, math.pi * 2, false, track);

    final double sweep = progress.clamp(0.0, 1.0) * math.pi * 2;
    if (sweep <= 0.001) {
      return;
    }

    final Paint arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: <Color>[
          for (final Color c in gradientColors) AppColors.fade(c, dim),
        ],
        transform: GradientRotation(startAngle),
      ).createShader(rect);
    canvas.drawArc(rect, startAngle, sweep, false, arc);
  }

  @override
  bool shouldRepaint(covariant FocusRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.dim != dim;
  }
}
