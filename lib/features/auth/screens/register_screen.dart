import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/api_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendOTP() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email'), backgroundColor: AppColors.warning),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.sendOTP(_emailController.text.trim());
      if (mounted) {
        context.push('/otp-verification', extra: {
          'email': _emailController.text.trim(),
          'isLogin': false,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP: $e'), backgroundColor: AppColors.warning),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundRoot,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('createAccount'), style: AppTypography.h1),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Enter your email to receive a verification code',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl2),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTypography.body,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.backgroundSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    borderSide: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl2),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Send OTP',
                          style: AppTypography.body.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                ),
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    context.tr('alreadyHaveAccount'),
                    style: AppTypography.body.copyWith(color: AppColors.accent),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: TextButton(
                  onPressed: () => _showTermsDialog(context),
                  child: Text(
                    'Terms and Conditions',
                    style: AppTypography.small.copyWith(
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Terms and Conditions', style: AppTypography.h4),
        content: SingleChildScrollView(
          child: Text(
            'Terms and Conditions\n\n1. Acceptance of Terms\nBy accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.\n\n2. Use License\nPermission is granted to temporarily download one copy of the materials (information or software) on Bhagya for personal, non-commercial transitory viewing only.\n\n3. Disclaimer\nThe materials on Bhagya are provided on an \'as is\' basis. Bhagya makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
            style: AppTypography.body,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}
