import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/star_field.dart';
import '../../../shared/widgets/app_button.dart';

class Language {
  final String code;
  final String name;
  final String nativeName;

  const Language({required this.code, required this.name, required this.nativeName});
}

const List<Language> _languages = [
  Language(code: 'en', name: 'English', nativeName: 'English'),
  Language(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
  Language(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
  Language(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
  Language(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
  Language(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
  Language(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી'),
  Language(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
  Language(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം'),
  Language(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ'),
  Language(code: 'or', name: 'Odia', nativeName: 'ଓଡ଼ିଆ'),
  Language(code: 'as', name: 'Assamese', nativeName: 'অসমীয়া'),
];

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'en';

  void _handleContinue() {
    context.push('/birth-details', extra: _selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundRoot,
      body: Stack(
        children: [
          const StarField(count: 50),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Choose Your Language',
                          style: AppTypography.h2,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'अपनी भाषा चुनें',
                          style: AppTypography.h4.copyWith(color: AppColors.accent),
                        ),
                        const SizedBox(height: AppSpacing.xl2),
                        _buildLanguageGrid(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: AppButton(
                    text: 'Continue',
                    onPressed: _handleContinue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.6,
      ),
      itemCount: _languages.length,
      itemBuilder: (context, index) {
        final lang = _languages[index];
        final isSelected = _selectedLanguage == lang.code;

        return GestureDetector(
          onTap: () => setState(() => _selectedLanguage = lang.code),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondary : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              border: Border.all(
                color: isSelected ? AppColors.secondary : AppColors.backgroundSecondary,
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          lang.nativeName,
                          style: AppTypography.h4.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.text,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          lang.name,
                          style: AppTypography.small.copyWith(
                            color: isSelected
                                ? Colors.white.withAlpha(204)
                                : AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(77),
                      ),
                      child: const Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
