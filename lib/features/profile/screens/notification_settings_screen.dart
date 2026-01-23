import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/notification_service.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool _dailyEnabled = true;
  bool _weeklyEnabled = false;
  DateTime _notificationTime = DateTime(2024, 1, 1, 8, 0);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final user = ref.read(authProvider).user;
    if (user != null) {
      _dailyEnabled = user.notificationsEnabled;
      
      final parts = user.notificationTime.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 8;
        final minute = int.tryParse(parts[1]) ?? 0;
        final now = DateTime.now();
        _notificationTime = DateTime(now.year, now.month, now.day, hour, minute);
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).user;
      if (user == null) return;

      final timeString = '${_notificationTime.hour.toString().padLeft(2, '0')}:${_notificationTime.minute.toString().padLeft(2, '0')}';
      
      await ApiService.updateProfile(user.id, {
        'notificationsEnabled': _dailyEnabled,
        'notificationTime': timeString,
      });

      await ref.read(authProvider.notifier).refreshUser();

      await NotificationService().scheduleDailyNotification(
        time: TimeOfDay(hour: _notificationTime.hour, minute: _notificationTime.minute),
        enabled: _dailyEnabled,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('settingsSaved'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  void _showTimePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.backgroundDefault,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(context.tr('cancel'), style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                ),
                Flexible(
                  child: Text(context.tr('notificationTime'), style: AppTypography.h4, overflow: TextOverflow.ellipsis),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _saveSettings();
                  },
                  child: Text(context.tr('done'), style: AppTypography.body.copyWith(color: AppColors.accent)),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: _notificationTime,
                onDateTimeChanged: (time) => setState(() => _notificationTime = time),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.tr('notificationSettings')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const LinearProgressIndicator(color: AppColors.accent, backgroundColor: Colors.transparent),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.tr('dailyNotifications'),
              style: AppTypography.cardTitle,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildCard(
              children: [
                _buildSettingsRow(
                  icon: Icons.wb_sunny,
                  title: context.tr('dailyLuckyPredictions'),
                  description: context.tr('dailyPredictionsDesc'),
                  trailing: Switch.adaptive(
                    value: _dailyEnabled,
                    onChanged: (v) {
                      setState(() => _dailyEnabled = v);
                      _saveSettings();
                    },
                    activeColor: AppColors.secondary,
                    activeTrackColor: AppColors.secondary.withAlpha(128),
                    inactiveTrackColor: AppColors.backgroundSecondary,
                  ),
                ),
                if (_dailyEnabled) ...[
                  Container(
                    height: 1,
                    color: Colors.white.withAlpha(26),
                  ),
                  _buildTimeRow(),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xl2),
            Text(
              context.tr('otherNotifications'),
              style: AppTypography.cardTitle,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildCard(
              children: [
                _buildSettingsRow(
                  icon: Icons.calendar_today,
                  title: context.tr('weeklySummary'),
                  description: context.tr('weeklySummaryDesc'),
                  trailing: Switch.adaptive(
                    value: _weeklyEnabled,
                    onChanged: (v) => setState(() => _weeklyEnabled = v),
                    activeColor: AppColors.secondary,
                    activeTrackColor: AppColors.secondary.withAlpha(128),
                    inactiveTrackColor: AppColors.backgroundSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl2),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      context.tr('notificationInfoText'),
                      style: AppTypography.small.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl2),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required String description,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.text),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.body),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTypography.small.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildTimeRow() {
    return GestureDetector(
      onTap: _showTimePicker,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 20, color: AppColors.text),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notification Time', style: AppTypography.body),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'When to send daily predictions',
                    style: AppTypography.small.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  _formatTime(_notificationTime),
                  style: AppTypography.body.copyWith(color: AppColors.accent),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
