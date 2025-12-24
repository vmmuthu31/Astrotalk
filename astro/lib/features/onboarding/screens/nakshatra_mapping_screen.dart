import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class NakshatraMappingScreen extends StatefulWidget {
  final String name;
  final String birthDate;
  final String birthTime;
  final String birthPlace;
  final String language;

  const NakshatraMappingScreen({
    super.key,
    required this.name,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    required this.language,
  });

  @override
  State<NakshatraMappingScreen> createState() => _NakshatraMappingScreenState();
}

class _NakshatraMappingScreenState extends State<NakshatraMappingScreen>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _progressController;
  final List<_StarPoint> _stars = [];
  final Random _random = Random();
  String _statusText = 'Reading the stars...';

  static const List<String> _nakshatras = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni',
    'Uttara Phalguni', 'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha',
    'Jyeshtha', 'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana',
    'Dhanishta', 'Shatabhisha', 'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
  ];

  static const List<String> _rashis = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  @override
  void initState() {
    super.initState();
    _initStars();
    
    _starController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _progressController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..addListener(_updateStatus);

    _progressController.forward();
    _navigateAfterAnimation();
  }

  void _initStars() {
    for (int i = 0; i < 8; i++) {
      _stars.add(_StarPoint(
        x: 0.2 + _random.nextDouble() * 0.6,
        y: 0.2 + _random.nextDouble() * 0.6,
        delay: i * 0.15,
      ));
    }
  }

  void _updateStatus() {
    final progress = _progressController.value;
    String newStatus;
    if (progress < 0.25) {
      newStatus = 'Reading the stars...';
    } else if (progress < 0.5) {
      newStatus = 'Mapping your constellation...';
    } else if (progress < 0.75) {
      newStatus = 'Calculating planetary positions...';
    } else {
      newStatus = 'Preparing your cosmic guide...';
    }
    if (newStatus != _statusText) {
      setState(() => _statusText = newStatus);
    }
  }

  void _navigateAfterAnimation() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    final nakshatra = _nakshatras[_random.nextInt(_nakshatras.length)];
    final rashi = _rashis[_random.nextInt(_rashis.length)];

    context.go('/subscription', extra: {
      'name': widget.name,
      'birthDate': widget.birthDate,
      'birthTime': widget.birthTime,
      'birthPlace': widget.birthPlace,
      'nakshatra': nakshatra,
      'rashi': rashi,
    });
  }

  @override
  void dispose() {
    _starController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundRoot,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 280,
              height: 280,
              child: AnimatedBuilder(
                animation: _starController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ConstellationPainter(
                      stars: _stars,
                      progress: _starController.value,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return Column(
                  children: [
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        value: _progressController.value,
                        backgroundColor: AppColors.backgroundSecondary,
                        valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(_statusText, style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StarPoint {
  final double x;
  final double y;
  final double delay;

  _StarPoint({required this.x, required this.y, required this.delay});
}

class _ConstellationPainter extends CustomPainter {
  final List<_StarPoint> stars;
  final double progress;

  _ConstellationPainter({required this.stars, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()..color = AppColors.accent;
    final linePaint = Paint()
      ..color = AppColors.accent.withAlpha(128)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final connections = [
      [0, 1], [0, 2], [1, 3], [2, 4], [1, 2],
      [3, 5], [4, 6], [5, 6], [5, 7], [6, 7],
    ];

    for (final connection in connections) {
      if (connection[0] < stars.length && connection[1] < stars.length) {
        final start = Offset(stars[connection[0]].x * size.width, stars[connection[0]].y * size.height);
        final end = Offset(stars[connection[1]].x * size.width, stars[connection[1]].y * size.height);
        canvas.drawLine(start, end, linePaint);
      }
    }

    for (int i = 0; i < stars.length; i++) {
      final star = stars[i];
      final animatedProgress = ((progress - star.delay) % 1.0).clamp(0.0, 1.0);
      final opacity = 0.5 + 0.5 * sin(animatedProgress * pi * 2);
      
      starPaint.color = AppColors.accent.withAlpha((opacity * 255).toInt());
      final radius = i == 0 ? 8.0 : 5.0;
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        radius,
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) => true;
}
