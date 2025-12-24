import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';


class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _dailyPredictions = true;
  bool _luckyReminders = true;
  bool _specialEvents = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 7, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundRoot,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Save', style: AppTypography.body.copyWith(color: AppColors.accent)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notification Time', style: AppTypography.h4.copyWith(color: AppColors.accent)),
            const SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: _showTimePicker,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: AppColors.accent),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daily Notification', style: AppTypography.body),
                          Text(
                            _notificationTime.format(context),
                            style: AppTypography.small.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl2),
            Text('Notification Types', style: AppTypography.h4.copyWith(color: AppColors.accent)),
            const SizedBox(height: AppSpacing.lg),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
              child: Column(
                children: [
                  _buildToggleRow(
                    'Daily Predictions',
                    'Get your lucky color, number & direction',
                    _dailyPredictions,
                    (v) => setState(() => _dailyPredictions = v),
                  ),
                  Divider(color: Colors.white.withOpacity(0.1), height: 1),
                  _buildToggleRow(
                    'Lucky Time Reminders',
                    'Reminders during your auspicious hours',
                    _luckyReminders,
                    (v) => setState(() => _luckyReminders = v),
                  ),
                  Divider(color: Colors.white.withOpacity(0.1), height: 1),
                  _buildToggleRow(
                    'Special Events',
                    'Festivals and astrological events',
                    _specialEvents,
                    (v) => setState(() => _specialEvents = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.body),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: AppTypography.small.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  void _showTimePicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.backgroundDefault,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => _notificationTime = time);
    }
  }
}
