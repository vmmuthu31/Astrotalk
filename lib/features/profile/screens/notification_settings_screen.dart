import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _dailyEnabled = true;
  bool _weeklyEnabled = false;
  DateTime _notificationTime = DateTime(2024, 1, 1, 7, 0);

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
                  child: Text('Cancel', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                ),
                Text('Notification Time', style: AppTypography.h4),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Done', style: AppTypography.body.copyWith(color: AppColors.accent)),
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
      backgroundColor: AppColors.backgroundRoot,
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Daily Notifications',
              style: AppTypography.cardTitle,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildCard(
              children: [
                _buildSettingsRow(
                  icon: Icons.wb_sunny,
                  title: 'Daily Lucky Predictions',
                  description: 'Receive your daily color, number & direction',
                  trailing: Switch.adaptive(
                    value: _dailyEnabled,
                    onChanged: (v) => setState(() => _dailyEnabled = v),
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
              'Other Notifications',
              style: AppTypography.cardTitle,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildCard(
              children: [
                _buildSettingsRow(
                  icon: Icons.calendar_today,
                  title: 'Weekly Summary',
                  description: 'Get weekly overview every Sunday',
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
                      'Push notifications help you start your day with cosmic guidance. You can change these settings anytime.',
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
