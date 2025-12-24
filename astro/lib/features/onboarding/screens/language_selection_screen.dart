import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/star_field.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;

  void _selectLanguage(String language) {
    setState(() => _selectedLanguage = language);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) context.push('/birth-details', extra: language);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundRoot,
      body: Stack(
        children: [
          const StarField(count: 40),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => context.go('/welcome'),
                    icon: const Icon(Icons.arrow_back, color: AppColors.text),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Choose Language', style: AppTypography.h2),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'भाषा चुनें',
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xl3),
                  _LanguageOption(
                    title: 'English',
                    subtitle: 'Continue in English',
                    isSelected: _selectedLanguage == 'en',
                    onTap: () => _selectLanguage('en'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _LanguageOption(
                    title: 'हिन्दी',
                    subtitle: 'हिन्दी में जारी रखें',
                    isSelected: _selectedLanguage == 'hi',
                    onTap: () => _selectLanguage('hi'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _LanguageOption(
                    title: 'தமிழ்',
                    subtitle: 'தமிழில் தொடரவும்',
                    isSelected: _selectedLanguage == 'ta',
                    onTap: () => _selectLanguage('ta'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _LanguageOption(
                    title: 'తెలుగు',
                    subtitle: 'తెలుగులో కొనసాగించండి',
                    isSelected: _selectedLanguage == 'te',
                    onTap: () => _selectLanguage('te'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.h4),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTypography.small.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                ),
                child: const Icon(Icons.check, size: 16, color: AppColors.backgroundRoot),
              ),
          ],
        ),
      ),
    );
  }
}
