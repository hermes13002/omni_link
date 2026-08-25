import 'package:flutter/material.dart';

class OmniFadedGridBackground extends StatelessWidget {
  final Widget child;
  const OmniFadedGridBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface,
                  colorScheme.primaryContainer.withAlpha(76), // 0.3 alpha roughly
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                  Colors.transparent,
                  Colors.transparent,
                ],
                stops: [0.0, 0.3, 0.4, 0.6, 0.7, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: CustomPaint(
              painter: _GridPainter(
                color: colorScheme.onSurface.withAlpha(10), // 0.04 alpha roughly
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;

  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double gridSize = 48.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
