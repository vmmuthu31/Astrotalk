import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';

class NakshatraScreen extends ConsumerWidget {
  const NakshatraScreen({super.key});

  static const Map<String, Map<String, String>> _nakshatraInfo = {
    'Ashwini': {'ruler': 'Ketu', 'deity': 'Ashwini Kumaras', 'element': 'Earth', 'symbol': 'Horse Head'},
    'Bharani': {'ruler': 'Venus', 'deity': 'Yama', 'element': 'Earth', 'symbol': 'Yoni'},
    'Krittika': {'ruler': 'Sun', 'deity': 'Agni', 'element': 'Earth', 'symbol': 'Razor'},
    'Rohini': {'ruler': 'Moon', 'deity': 'Brahma', 'element': 'Earth', 'symbol': 'Cart'},
    'Mrigashira': {'ruler': 'Mars', 'deity': 'Soma', 'element': 'Earth', 'symbol': 'Deer Head'},
    'Ardra': {'ruler': 'Rahu', 'deity': 'Rudra', 'element': 'Water', 'symbol': 'Teardrop'},
    'Punarvasu': {'ruler': 'Jupiter', 'deity': 'Aditi', 'element': 'Water', 'symbol': 'Bow'},
    'Pushya': {'ruler': 'Saturn', 'deity': 'Brihaspati', 'element': 'Water', 'symbol': 'Flower'},
    'Ashlesha': {'ruler': 'Mercury', 'deity': 'Nagas', 'element': 'Water', 'symbol': 'Serpent'},
    'Magha': {'ruler': 'Ketu', 'deity': 'Pitris', 'element': 'Water', 'symbol': 'Throne'},
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    final nakshatra = user?.nakshatra ?? 'Ashwini';
    final rashi = user?.rashi ?? 'Aries';
    final info = _nakshatraInfo[nakshatra] ?? _nakshatraInfo['Ashwini']!;

    return Scaffold(
      backgroundColor: AppColors.backgroundRoot,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Your Nakshatra'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChartCard(nakshatra, rashi),
            const SizedBox(height: AppSpacing.xl2),
            Text('Nakshatra Details', style: AppTypography.h4.copyWith(color: AppColors.accent)),
            const SizedBox(height: AppSpacing.lg),
            _buildDetailsCard([
              _DetailRow(icon: Icons.star, label: 'Ruling Planet', value: info['ruler']!),
              _DetailRow(icon: Icons.wb_sunny, label: 'Deity', value: info['deity']!),
              _DetailRow(icon: Icons.air, label: 'Element', value: info['element']!),
              _DetailRow(icon: Icons.adjust, label: 'Symbol', value: info['symbol']!),
            ]),
            const SizedBox(height: AppSpacing.xl2),
            Text('Birth Details', style: AppTypography.h4.copyWith(color: AppColors.accent)),
            const SizedBox(height: AppSpacing.lg),
            _buildDetailsCard([
              _DetailRow(icon: Icons.person, label: 'Name', value: user?.name ?? '-'),
              _DetailRow(icon: Icons.calendar_today, label: 'Birth Date', value: user?.birthDate ?? '-'),
              _DetailRow(icon: Icons.access_time, label: 'Birth Time', value: user?.birthTime ?? '-'),
              _DetailRow(icon: Icons.location_on, label: 'Birth Place', value: user?.birthPlace ?? '-'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String nakshatra, String rashi) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl2),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(38),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(painter: _ConstellationPainter()),
            ),
            const SizedBox(height: AppSpacing.xl2),
            Text(
              nakshatra,
              style: AppTypography.h2.copyWith(color: AppColors.accent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Rashi: $rashi',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(List<_DetailRow> rows) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final isLast = entry.key == rows.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(entry.value.icon, size: 18, color: AppColors.accent),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          entry.value.label,
                          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Text(
                      entry.value.value,
                      style: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              if (!isLast) Divider(color: Colors.white.withOpacity(0.1), height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _DetailRow {
  final IconData icon;
  final String label;
  final String value;

  _DetailRow({required this.icon, required this.label, required this.value});
}

class _ConstellationPainter extends CustomPainter {
  static const List<Offset> _points = [
    Offset(0.5, 0.15),
    Offset(0.3, 0.3),
    Offset(0.7, 0.3),
    Offset(0.2, 0.5),
    Offset(0.8, 0.5),
    Offset(0.35, 0.7),
    Offset(0.65, 0.7),
    Offset(0.5, 0.85),
  ];

  static const List<List<int>> _lines = [
    [0, 1], [0, 2], [1, 3], [2, 4], [1, 2],
    [3, 5], [4, 6], [5, 6], [5, 7], [6, 7],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.accent.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final starPaint = Paint()..color = AppColors.text;
    final mainStarPaint = Paint()..color = AppColors.accent;

    for (final line in _lines) {
      final start = Offset(_points[line[0]].dx * size.width, _points[line[0]].dy * size.height);
      final end = Offset(_points[line[1]].dx * size.width, _points[line[1]].dy * size.height);
      canvas.drawLine(start, end, linePaint);
    }

    for (int i = 0; i < _points.length; i++) {
      final point = Offset(_points[i].dx * size.width, _points[i].dy * size.height);
      final radius = i == 0 ? 8.0 : 5.0;
      canvas.drawCircle(point, radius, i == 0 ? mainStarPaint : starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
