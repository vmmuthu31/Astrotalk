import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../shared/widgets/star_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/services/api_service.dart';
import '../../../core/providers/auth_provider.dart';

class BirthDetailsScreen extends StatefulWidget {
  final String language;

  const BirthDetailsScreen({super.key, this.language = 'en'});

  @override
  ConsumerState<BirthDetailsScreen> createState() => _BirthDetailsScreenState();
}

class _BirthDetailsScreenState extends ConsumerState<BirthDetailsScreen> {
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  bool _isLoading = false;
  DateTime _birthDate = DateTime(1995, 1, 1);
  DateTime _birthTime = DateTime(1995, 1, 1, 6, 0);

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty && _placeController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(
          color: AppColors.backgroundDefault,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
        ),
        child: Column(
          children: [
            Text(context.tr('selectDateOfBirth'), style: AppTypography.h4),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _birthDate,
                maximumDate: DateTime.now(),
                minimumDate: DateTime(1920),
                onDateTimeChanged: (date) => setState(() => _birthDate = date),
              ),
            ),
            AppButton(
              text: context.tr('done'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: const BoxDecoration(
          color: AppColors.backgroundDefault,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
        ),
        child: Column(
          children: [
            Text(context.tr('selectTimeOfBirth'), style: AppTypography.h4),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: _birthTime,
                onDateTimeChanged: (time) => setState(() => _birthTime = time),
              ),
            ),
            AppButton(
              text: context.tr('done'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignUp() async {
    if (!_isFormValid) return;

    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signIn();
      
      if (account != null) {
        final auth = await account.authentication;
        if (auth.idToken != null) {
          final authData = await ApiService.googleLogin(auth.idToken!);
          
          if (mounted) {
            final userId = authData['user']['id'];
            await ApiService.updateProfile(userId, {
              'name': _nameController.text.trim(),
              'birthPlace': _placeController.text.trim(),
              'birthDate': DateFormat('yyyy-MM-dd').format(_birthDate),
              'birthTime': DateFormat('HH:mm').format(_birthTime),
              'language': widget.language,
            });

            await ref.read(authProvider.notifier).refreshUser();
            await ref.read(authProvider.notifier).setOnboarded(true);

            if (mounted) context.go('/subscription');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundRoot,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const StarField(count: 40),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => context.go('/language'),
                    icon: const Icon(Icons.arrow_back, color: AppColors.text),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(context.tr('birthDetails'), style: AppTypography.h2),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.tr('birthDetailsSubtitle'),
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xl3),
                  _buildInputLabel(context.tr('yourName')),
                  TextField(
                    controller: _nameController,
                    style: AppTypography.body,
                    decoration: InputDecoration(hintText: context.tr('enterName')),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.xl2),
                  _buildInputLabel(context.tr('dateOfBirth')),
                  _buildPickerButton(
                    icon: Icons.calendar_today,
                    text: DateFormat('d MMMM yyyy').format(_birthDate),
                    onTap: _showDatePicker,
                  ),
                  const SizedBox(height: AppSpacing.xl2),
                  _buildInputLabel(context.tr('timeOfBirth')),
                  _buildPickerButton(
                    icon: Icons.access_time,
                    text: DateFormat('hh:mm a').format(_birthTime),
                    onTap: _showTimePicker,
                  ),
                  const SizedBox(height: AppSpacing.xl2),
                  _buildInputLabel(context.tr('placeOfBirth')),
                  TextField(
                    controller: _placeController,
                    style: AppTypography.body,
                    decoration: InputDecoration(hintText: context.tr('placeholderPlace')),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.xl3),
                  _isLoading 
                      ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                      : AppButton(
                          text: 'Confirm & Sign in with Google',
                          onPressed: _isFormValid ? _handleGoogleSignUp : null,
                          backgroundColor: _isFormValid ? AppColors.secondary : AppColors.backgroundSecondary,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text, style: AppTypography.small),
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSpacing.inputHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.backgroundDefault,
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.accent),
            const SizedBox(width: AppSpacing.md),
            Text(text, style: AppTypography.body),
          ],
        ),
      ),
    );
  }
}
