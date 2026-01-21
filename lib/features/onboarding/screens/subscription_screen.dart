import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/razorpay_service.dart';
import '../../../shared/widgets/star_field.dart';
import '../../../shared/models/user.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isSubscribeLoading = false;
  bool _isTrialLoading = false;
  late RazorpayService _razorpayService;

  bool get _isAnyLoading => _isSubscribeLoading || _isTrialLoading;

  Map<String, dynamic> get _params =>
      GoRouterState.of(context).extra as Map<String, dynamic>? ?? {};

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    _razorpayService.onPaymentSuccess = _handlePaymentSuccess;
    _razorpayService.onPaymentFailure = _handlePaymentFailure;
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      _isSubscribeLoading = false;
      _isTrialLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Payment Successful! ID: ${response.paymentId}'),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    
    await _completeOnboarding(isSubscribed: true);
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    setState(() {
      _isSubscribeLoading = false;
      _isTrialLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Failed: ${response.message ?? "Unknown error"}'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  Future<void> _handleSubscribe({bool isTrial = false}) async {
    setState(() {
      if (isTrial) {
        _isTrialLoading = true;
      } else {
        _isSubscribeLoading = true;
      }
    });

    final success = await _razorpayService.openNativeCheckout(
      customerName: _params['name'] ?? 'User',
      customerEmail: '',
      customerPhone: '',
      isTrial: isTrial,
    );

    if (!success && mounted) {
      setState(() {
        _isSubscribeLoading = false;
        _isTrialLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not start payment. Please try again.'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _handleSkip() async {
    await _completeOnboarding(isSubscribed: false);
  }

  Future<void> _completeOnboarding({bool isSubscribed = false}) async {
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _params['name'] ?? 'User',
      birthDate: _params['birthDate'],
      birthTime: _params['birthTime'],
      birthPlace: _params['birthPlace'],
      nakshatra: _params['nakshatra'],
      rashi: _params['rashi'],
      isSubscribed: isSubscribed,
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
                      onTap: _isAnyLoading ? null : _handleSkip,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Text(
                          context.tr('skip'),
                          style: AppTypography.body.copyWith(
                            color: _isAnyLoading ? AppColors.textSecondary.withAlpha(100) : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    context.tr('unlockDailyBhagya'),
                    style: AppTypography.h2.copyWith(color: AppColors.accent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.tr('personalizedGuidance'),
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl2),
                  _buildPricingCard(),
                  const SizedBox(height: AppSpacing.xl2),
                  _buildFeatureList(),
                  const SizedBox(height: AppSpacing.xl2),
                  _buildSubscribeButton(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildFreeTrialButton(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    context.tr('securedByRazorpay'),
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
              Text('₹', style: AppTypography.h4.copyWith(color: AppColors.accent)),
              const Text(
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
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance, size: 16, color: AppColors.accent),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'via UPI AutoPay',
                  style: AppTypography.small.copyWith(color: AppColors.accent),
                ),
              ],
            ),
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
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
        onPressed: _isAnyLoading ? null : () => _handleSubscribe(isTrial: false),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          disabledBackgroundColor: AppColors.secondary.withAlpha(128),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSubscribeLoading) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Processing...',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.buttonText,
                ),
              ),
            ] else ...[
              const Icon(Icons.account_balance, size: 20, color: AppColors.buttonText),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Subscribe with UPI AutoPay',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.buttonText,
                ),
              ),
            ],
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
        onPressed: _isAnyLoading ? null : () => _handleSubscribe(isTrial: true),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: _isAnyLoading ? AppColors.textSecondary : AppColors.accent, 
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isTrialLoading) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Processing...',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ] else ...[
              Text(
                'Start 7-Day Free Trial',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _isAnyLoading ? AppColors.textSecondary : AppColors.accent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
