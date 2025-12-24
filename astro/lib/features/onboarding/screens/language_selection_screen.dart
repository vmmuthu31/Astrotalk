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
  String _selectedLanguage = 'en';

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
                    onPressed: () => context.pop(),
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
                    onTap: () {
                      setState(() => _selectedLanguage = 'en');
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (mounted) context.go('/birth-details', extra: 'en');
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _LanguageOption(
                    title: 'हिन्दी',
                    subtitle: 'हिन्दी में जारी रखें',
                    isSelected: _selectedLanguage == 'hi',
                    onTap: () {
                      setState(() => _selectedLanguage = 'hi');
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (mounted) context.go('/birth-details', extra: 'hi');
                      });
                    },
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
