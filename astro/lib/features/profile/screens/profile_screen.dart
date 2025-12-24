import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    return Scaffold(
      backgroundColor: AppColors.backgroundRoot,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(user?.name ?? 'User', user?.nakshatra ?? 'Nakshatra', user?.rashi ?? 'Rashi'),
            const SizedBox(height: AppSpacing.xl2),
            _buildSubscriptionCard(user?.isSubscribed ?? false),
            const SizedBox(height: AppSpacing.xl2),
            Text('Settings', style: AppTypography.cardTitle),
            const SizedBox(height: AppSpacing.md),
            _buildSettingsCard([
              _SettingsRow(
                icon: Icons.notifications,
                label: 'Notifications',
                onTap: () => context.push('/notification-settings'),
              ),
              _SettingsRow(icon: Icons.language, label: 'Language', value: 'English'),
              _SettingsRow(icon: Icons.dark_mode, label: 'Theme', value: 'Dark'),
            ]),
            const SizedBox(height: AppSpacing.xl2),
            Text('Account', style: AppTypography.cardTitle),
            const SizedBox(height: AppSpacing.md),
            _buildSettingsCard([
              _SettingsRow(icon: Icons.help_outline, label: 'Help & Support'),
              _SettingsRow(icon: Icons.description, label: 'Terms of Service'),
              _SettingsRow(icon: Icons.shield, label: 'Privacy Policy'),
            ]),
            const SizedBox(height: AppSpacing.xl2),
            _buildLogoutButton(context, ref),
            const SizedBox(height: AppSpacing.lg),
            _buildDeleteAccountButton(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(String name, String nakshatra, String rashi) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl2),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: const Icon(Icons.star, size: 32, color: AppColors.accent),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              name,
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$nakshatra - $rashi',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(bool isSubscribed) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium, size: 24, color: AppColors.accent),
              const SizedBox(width: AppSpacing.md),
              Text(
                isSubscribed ? 'Premium Member' : 'Free Trial',
                style: AppTypography.h4.copyWith(color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isSubscribed
                ? 'You have full access to all features'
                : 'Upgrade to unlock all premium features',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          if (!isSubscribed) ...[
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: const Text('Upgrade Now'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<_SettingsRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final isLast = entry.key == rows.length - 1;
          final row = entry.value;
          return Column(
            children: [
              InkWell(
                onTap: row.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Icon(row.icon, size: 20, color: AppColors.text),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: Text(row.label, style: AppTypography.body)),
                      if (row.value != null) ...[
                        Text(row.value!, style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              if (!isLast) Divider(color: Colors.white.withOpacity(0.1), height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context, ref),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 20, color: AppColors.warning),
            const SizedBox(width: AppSpacing.sm),
            Text('Logout', style: AppTypography.body.copyWith(fontWeight: FontWeight.w600, color: AppColors.warning)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context, WidgetRef ref) {
    return Center(
      child: TextButton(
        onPressed: () => _showDeleteDialog(context, ref),
        child: Text(
          'Delete Account',
          style: AppTypography.small.copyWith(
            color: AppColors.textSecondary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDefault,
        title: Text('Logout', style: AppTypography.h4),
        content: Text('Are you sure you want to logout?', style: AppTypography.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/welcome');
            },
            child: Text('Logout', style: AppTypography.body.copyWith(color: AppColors.warning)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDefault,
        title: Text('Delete Account', style: AppTypography.h4),
        content: Text(
          'This will permanently delete your account and all data. This action cannot be undone.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/welcome');
            },
            child: Text('Delete', style: AppTypography.body.copyWith(color: AppColors.warning)),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  _SettingsRow({required this.icon, required this.label, this.value, this.onTap});
}
