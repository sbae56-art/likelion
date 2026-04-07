import 'dart:math' as math;
import 'package:flutter/material.dart';

class OralMapWidget extends StatelessWidget {
  const OralMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 210,
      child: CustomPaint(
        painter: _OralMapPainter(),
      ),
    );
  }
}

class _OralMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F2F4)
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += 16) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += 16) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final jawPaint = Paint()
      ..color = const Color(0xFF8FC8CC)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final upperRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 18),
      width: 130,
      height: 82,
    );

    final lowerRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 + 20),
      width: 130,
      height: 82,
    );

    canvas.drawArc(
      upperRect,
      _deg(198),
      _deg(144),
      false,
      jawPaint,
    );

    canvas.drawArc(
      lowerRect,
      _deg(18),
      _deg(144),
      false,
      jawPaint,
    );

    _drawTeeth(
      canvas,
      center: Offset(size.width / 2, size.height / 2 - 18),
      radiusX: 58,
      radiusY: 34,
      startDeg: 202,
      endDeg: 338,
      isUpper: true,
      highlightedIndexes: const [],
    );

    _drawTeeth(
      canvas,
      center: Offset(size.width / 2, size.height / 2 + 20),
      radiusX: 58,
      radiusY: 34,
      startDeg: 22,
      endDeg: 158,
      isUpper: false,
      highlightedIndexes: const [9, 10, 11],
    );

    _drawQuadrantLabel(canvas, 'UL', Offset(size.width / 2 - 34, size.height / 2 - 18), const Color(0xFFD0D4D8));
    _drawQuadrantLabel(canvas, 'UR', Offset(size.width / 2 + 24, size.height / 2 - 18), const Color(0xFFD0D4D8));
    _drawQuadrantLabel(canvas, 'LL', Offset(size.width / 2 - 34, size.height / 2 + 28), const Color(0xFFD0D4D8));
    _drawQuadrantLabel(canvas, 'LR', Offset(size.width / 2 + 24, size.height / 2 + 28), const Color(0xFFFFB0A8));

    _drawDottedPointer(
      canvas,
      start: Offset(size.width - 28, size.height / 2 + 30),
      end: Offset(size.width / 2 + 44, size.height / 2 + 64),
    );
  }

  void _drawTeeth(
    Canvas canvas, {
    required Offset center,
    required double radiusX,
    required double radiusY,
    required double startDeg,
    required double endDeg,
    required bool isUpper,
    required List<int> highlightedIndexes,
  }) {
    const count = 14;

    for (int i = 0; i < count; i++) {
      final t = count == 1 ? 0.0 : i / (count - 1);
      final angle = _deg(startDeg + (endDeg - startDeg) * t);

      final px = center.dx + radiusX * math.cos(angle);
      final py = center.dy + radiusY * math.sin(angle);

      final toothRect = Rect.fromCenter(
        center: Offset(px, py),
        width: 8,
        height: 13,
      );

      final fillColor = highlightedIndexes.contains(i)
          ? const Color(0xFFFFE2DE)
          : Colors.white;

      final strokeColor = highlightedIndexes.contains(i)
          ? const Color(0xFFFFB6AF)
          : const Color(0xFF9FD1D4);

      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = strokeColor
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(angle + (isUpper ? math.pi / 2 : -math.pi / 2));
      final localRect = Rect.fromCenter(
        center: Offset.zero,
        width: 8,
        height: 13,
      );
      final rrect = RRect.fromRectAndRadius(localRect, const Radius.circular(3));
      canvas.drawRRect(rrect, fillPaint);
      canvas.drawRRect(rrect, strokePaint);
      canvas.restore();
    }
  }

  void _drawQuadrantLabel(Canvas canvas, String text, Offset offset, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 8,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(canvas, offset);
  }

  void _drawDottedPointer(Canvas canvas, {required Offset start, required Offset end}) {
    const dotCount = 9;
    for (int i = 0; i < dotCount; i++) {
      final t = i / (dotCount - 1);
      final x = start.dx + (end.dx - start.dx) * t;
      final y = start.dy + (end.dy - start.dy) * t;
      final radius = i == dotCount - 1 ? 2.2 : 1.4;

      final paint = Paint()
        ..color = const Color(0xFFFF7E73).withOpacity(0.9 - (t * 0.25));

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  double _deg(double degree) => degree * math.pi / 180;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}