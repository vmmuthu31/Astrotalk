import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl2),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (constraints.maxHeight - AppSpacing.xl2 * 2) > 0 
                          ? (constraints.maxHeight - AppSpacing.xl2 * 2) 
                          : 0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: AppSpacing.xl2),
                        _buildLogoSection(context),
                        const SizedBox(height: AppSpacing.xl4),
                        _buildFeatureSection(context),
                        const SizedBox(height: AppSpacing.xl4),
                        AppButton(
                          text: context.tr('getStarted'),
                          onPressed: () => context.push('/language'),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6B21A8),
                Color(0xFF4A148C),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withAlpha(77),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/icon.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.auto_awesome,
                size: 70,
                color: AppColors.accent,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl2),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.accent, Color(0xFFFFA500)],
          ).createShader(bounds),
          child: Text(
            'Bhagya',
            style: AppTypography.h1.copyWith(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.tr('tagline'),
          style: AppTypography.h4.copyWith(color: AppColors.text),
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

  Widget _buildFeatureSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      child: Column(
        children: [
          _FeatureItem(icon: Icons.wb_sunny, text: context.tr('featureLuckyColor')),
          const SizedBox(height: AppSpacing.lg),
          _FeatureItem(icon: Icons.explore, text: context.tr('featureAuspiciousDirection')),
          const SizedBox(height: AppSpacing.lg),
          _FeatureItem(icon: Icons.access_time, text: context.tr('featureLuckyTime')),
          const SizedBox(height: AppSpacing.lg),
          _FeatureItem(icon: Icons.notifications, text: context.tr('featureDailyNotifications')),
        ],
      ),
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
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: Icon(icon, size: 22, color: AppColors.accent),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(text, style: AppTypography.body),
        ),
      ],
    );
  }
}
