import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/star_field.dart';
import '../../../shared/widgets/app_button.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundRoot,
      body: Stack(
        children: [
          const StarField(count: 30),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl2),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () => _completeOnboarding(context, ref),
                      child: Text(
                        'Skip',
                        style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildPremiumCard(),
                  const SizedBox(height: AppSpacing.xl3),
                  _buildFeatureList(),
                  const Spacer(),
                  AppButton(
                    text: 'Start 7-Day Free Trial',
                    onPressed: () => _completeOnboarding(context, ref),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Then ₹99/month • Cancel anytime',
                    style: AppTypography.small.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
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

  Widget _buildPremiumCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withOpacity(0.2),
            ),
            child: const Icon(Icons.auto_awesome, size: 40, color: AppColors.accent),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Bhagya Premium', style: AppTypography.h3.copyWith(color: AppColors.accent)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Unlock your complete cosmic potential',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      'Personalized daily predictions',
      'Lucky color, number & direction',
      'Auspicious time calculations',
      'Daily mantras & guidance',
      'Ad-free experience',
    ];

    return Column(
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                      ),
                      child: const Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(feature, style: AppTypography.body),
                  ],
                ),
              ))
          .toList(),
    );
  }

  void _completeOnboarding(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).setOnboarded(true);
    if (context.mounted) context.go('/home');
  }
}
