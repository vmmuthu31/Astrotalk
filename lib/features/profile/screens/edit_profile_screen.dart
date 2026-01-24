import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/vedic_astrology_service.dart';
import '../../../shared/widgets/app_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _placeController;
  late DateTime _birthDate;
  late DateTime _birthTime;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    
    _nameController = TextEditingController(text: user?.name ?? '');
    _placeController = TextEditingController(text: user?.birthPlace ?? '');
    
    if (user?.birthDate != null) {
      try {
        _birthDate = DateFormat('yyyy-MM-dd').parse(user!.birthDate!);
      } catch (_) {
        _birthDate = DateTime(1995, 1, 1);
      }
    } else {
      _birthDate = DateTime(1995, 1, 1);
    }
    
    if (user?.birthTime != null) {
      try {
        final parts = user!.birthTime!.split(':');
        final hour = int.tryParse(parts[0]) ?? 6;
        final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
        _birthTime = DateTime(1995, 1, 1, hour, minute);
      } catch (_) {
        _birthTime = DateTime(1995, 1, 1, 6, 0);
      }
    } else {
      _birthTime = DateTime(1995, 1, 1, 6, 0);
    }
    
    _nameController.addListener(_onFieldChanged);
    _placeController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty && _placeController.text.trim().isNotEmpty;

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
                onDateTimeChanged: (date) {
                  setState(() {
                    _birthDate = date;
                    _hasChanges = true;
                  });
                },
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
                onDateTimeChanged: (time) {
                  setState(() {
                    _birthTime = time;
                    _hasChanges = true;
                  });
                },
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

  Future<void> _handleSave() async {
    if (!_isFormValid || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authProvider).user;
      if (user == null) {
        throw Exception('User not found');
      }

      final birthDateStr = DateFormat('yyyy-MM-dd').format(_birthDate);
      final birthTimeStr = DateFormat('HH:mm').format(_birthTime);
      
      final newRashi = VedicAstrologyService.calculateRashi(_birthDate, birthTimeStr);
      final newNakshatra = VedicAstrologyService.calculateNakshatra(_birthDate, birthTimeStr);

      final updateData = {
        'name': _nameController.text.trim(),
        'birthDate': birthDateStr,
        'birthTime': birthTimeStr,
        'birthPlace': _placeController.text.trim(),
        'rashi': newRashi,
        'nakshatra': newNakshatra,
      };

      await ApiService.updateProfile(user.id, updateData);

      final updatedUser = user.copyWith(
        name: _nameController.text.trim(),
        birthDate: birthDateStr,
        birthTime: birthTimeStr,
        birthPlace: _placeController.text.trim(),
        rashi: newRashi,
        nakshatra: newNakshatra,
      );
      await ref.read(authProvider.notifier).setUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(context.tr('profileUpdated'))),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) context.go('/profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.tr('error')}: ${e.toString()}'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(context.tr('editProfile')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isFormValid && !_isLoading ? _handleSave : null,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      context.tr('save'),
                      style: TextStyle(
                        color: _isFormValid ? AppColors.accent : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputLabel(context.tr('yourName')),
            TextField(
              controller: _nameController,
              style: AppTypography.body,
              decoration: InputDecoration(hintText: context.tr('enterName')),
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
            ),
            const SizedBox(height: AppSpacing.xl3),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(50),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(color: AppColors.accent.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      context.tr('rashiRecalculateNote'),
                      style: AppTypography.small.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
