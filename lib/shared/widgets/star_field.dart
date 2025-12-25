import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StarField extends StatelessWidget {
  final int count;

  const StarField({super.key, this.count = 50});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _StarFieldPainter(count: count),
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  final int count;
  final List<_Star> _stars;
  
  _StarFieldPainter({required this.count}) : _stars = [] {
    final random = Random(42);
    for (int i = 0; i < count; i++) {
      _stars.add(_Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 1 + random.nextDouble() * 2.5,
        opacity: 0.3 + random.nextDouble() * 0.7,
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    
    final paint = Paint();
    
    for (final star in _stars) {
      paint.color = AppColors.accent.withAlpha((star.opacity * 255).toInt());
      
      final shadowPaint = Paint()
        ..color = AppColors.accent.withAlpha((star.opacity * 128).toInt())
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.size * 2);
      
      final offset = Offset(star.x * size.width, star.y * size.height);
      
      canvas.drawCircle(offset, star.size * 2, shadowPaint);
      canvas.drawCircle(offset, star.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) => false;
}

class _Star {
  final double x;
  final double y;
  final double size;
  final double opacity;

  _Star({required this.x, required this.y, required this.size, required this.opacity});
}
