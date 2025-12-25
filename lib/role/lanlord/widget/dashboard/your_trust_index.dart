import 'dart:math' as math;

import 'package:flutter/material.dart';

class YourTrustIndex extends StatelessWidget {
  const YourTrustIndex({super.key, required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final normalized = score.clamp(0, 100);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Your Trust Index',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            width: 140,
            child: CustomPaint(
              painter: _RingPainter(progress: normalized / 100),
              child: Center(
                child: Text(
                  normalized.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00BFA6))))))]));
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 10.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide / 2) - strokeWidth;

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFE6E6E6)
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = const LinearGradient(
        colors: [Color(0xFF00E0C3), Color(0xFF00BFA6)]).createShader(rect)
      ..strokeCap = StrokeCap.round;


    canvas.drawCircle(center, radius, bgPaint);


    final sweep = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      fgPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
