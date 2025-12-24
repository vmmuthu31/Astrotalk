import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StarField extends StatefulWidget {
  final int count;

  const StarField({super.key, this.count = 50});

  @override
  State<StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<StarField> with TickerProviderStateMixin {
  late List<Star> stars;

  @override
  void initState() {
    super.initState();
    stars = List.generate(widget.count, (_) => Star(this));
  }

  @override
  void dispose() {
    for (final star in stars) {
      star.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: stars.map((star) {
            return Positioned(
              left: star.x * constraints.maxWidth,
              top: star.y * constraints.maxHeight,
              child: AnimatedBuilder(
                animation: star.controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: star.opacity.value,
                    child: Container(
                      width: star.size,
                      height: star.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.5),
                            blurRadius: star.size * 2,
                            spreadRadius: star.size / 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final AnimationController controller;
  late Animation<double> opacity;

  Star(TickerProvider vsync)
      : x = Random().nextDouble(),
        y = Random().nextDouble(),
        size = 1 + Random().nextDouble() * 2.5,
        controller = AnimationController(
          duration: Duration(milliseconds: 1500 + Random().nextInt(1000)),
          vsync: vsync,
        ) {
    opacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
    controller.repeat(reverse: true);
    Future.delayed(Duration(milliseconds: Random().nextInt(2000)), () {
      if (controller.isAnimating == false) return;
      controller.forward();
    });
  }
}
