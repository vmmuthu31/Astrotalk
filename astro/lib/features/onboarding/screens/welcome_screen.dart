import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/star_field.dart';
import '../../../shared/widgets/app_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundRoot,
      body: Stack(
        children: [
          const StarField(count: 80),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl2),
              child: Column(
                children: [
                  const Spacer(),
                  _buildLogoSection(),
                  const SizedBox(height: AppSpacing.xl4),
                  _buildFeatureSection(),
                  const Spacer(),
                  AppButton(
                    text: 'Get Started',
                    onPressed: () => context.go('/language'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.auto_awesome,
            size: 60,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Bhagya',
          style: AppTypography.h1.copyWith(color: AppColors.accent),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your Daily Cosmic Guide',
          style: AppTypography.h4,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'आपका दैनिक भाग्य मार्गदर्शक',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildFeatureSection() {
    return Column(
      children: [
        _FeatureItem(icon: Icons.star, text: 'Daily Lucky Color & Number'),
        const SizedBox(height: AppSpacing.lg),
        _FeatureItem(icon: Icons.explore, text: 'Auspicious Directions'),
        const SizedBox(height: AppSpacing.lg),
        _FeatureItem(icon: Icons.access_time, text: 'Lucky Time Predictions'),
        const SizedBox(height: AppSpacing.lg),
        _FeatureItem(icon: Icons.notifications, text: 'Daily Notifications'),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: Icon(icon, size: 20, color: AppColors.accent),
        ),
        const SizedBox(width: AppSpacing.lg),
        Text(text, style: AppTypography.body),
      ],
    );
  }
}
