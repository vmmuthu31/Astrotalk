import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/star_field.dart';
import '../../../shared/models/user.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isProcessing = false;

  Map<String, dynamic> get _params =>
      GoRouterState.of(context).extra as Map<String, dynamic>? ?? {};

  void _handleSubscribe() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _isProcessing = false);
    await _completeOnboarding();
  }

  void _handleSkip() async {
    await _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _params['name'] ?? 'User',
      birthDate: _params['birthDate'],
      birthTime: _params['birthTime'],
      birthPlace: _params['birthPlace'],
      nakshatra: _params['nakshatra'],
      rashi: _params['rashi'],
    );

    await ref.read(authProvider.notifier).setUser(user);
    await ref.read(authProvider.notifier).setOnboarded(true);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundRoot,
      body: Stack(
        children: [
          const StarField(count: 40),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _handleSkip,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Text(
                          'Skip',
                          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Unlock Your Daily Bhagya',
                    style: AppTypography.h2.copyWith(color: AppColors.accent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Get personalized cosmic guidance every day',
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl3),
                  _buildPricingCard(),
                  const SizedBox(height: AppSpacing.xl3),
                  _buildFeatureList(),
                  const SizedBox(height: AppSpacing.xl3),
                  _buildSubscribeButton(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFreeTrialButton(),
                  const SizedBox(height: AppSpacing.xl2),
                  Text(
                    'By subscribing, you agree to our Terms of Service and Privacy Policy. Cancel anytime.',
                    style: AppTypography.small.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppBorderRadius.full),
            ),
            child: Text(
              'Most Popular',
              style: AppTypography.small.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.buttonText,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Monthly Plan', style: AppTypography.h4),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Rs.', style: AppTypography.h4.copyWith(color: AppColors.accent)),
              Text(
                '99',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
              Text(
                '/month',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'via UPI AutoPay',
            style: AppTypography.small.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      'Daily Lucky Color & Number',
      'Auspicious Direction Guidance',
      'Personalized Lucky Time',
      'Daily Mantra Recommendations',
      'Push Notifications',
      'Nakshatra Birth Chart',
    ];

    return Column(
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 20, color: AppColors.success),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(feature, style: AppTypography.body)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSubscribeButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handleSubscribe,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.credit_card, size: 20, color: AppColors.buttonText),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _isProcessing ? 'Processing...' : 'Subscribe with UPI AutoPay',
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.buttonText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreeTrialButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: OutlinedButton(
        onPressed: _handleSkip,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.accent, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
        ),
        child: Text(
          'Start 7-Day Free Trial',
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
