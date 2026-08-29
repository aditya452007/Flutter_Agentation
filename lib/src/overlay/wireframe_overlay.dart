import 'package:flutter/material.dart';

class WireframeOverlay extends StatelessWidget {
  const WireframeOverlay({super.key, required this.opacity, required this.child});

  final double opacity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0) return child;
    return Stack(
      children: [
        Opacity(opacity: 1 - opacity, child: child),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _GridPainter(opacity: opacity)),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.opacity});
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.12 * opacity)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const step = 24.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.opacity != opacity;
}
