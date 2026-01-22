import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/localization_provider.dart';
import '../../../core/services/razorpay_service.dart';
import '../../../core/services/api_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late RazorpayService _razorpayService;
  bool _isUpgradeLoading = false;
  bool _isTrialLoading = false;

  bool get _isAnyLoading => _isUpgradeLoading || _isTrialLoading;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
    _razorpayService.onPaymentSuccess = _handlePaymentSuccess;
    _razorpayService.onPaymentFailure = _handlePaymentFailure;
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      _isUpgradeLoading = false;
      _isTrialLoading = false;
    });
    
    final currentUser = ref.read(authProvider).user;
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(isSubscribed: true);
      await ref.read(authProvider.notifier).setUser(updatedUser);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(child: Text('Subscription activated!')),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    setState(() {
      _isUpgradeLoading = false;
      _isTrialLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Failed: ${response.message ?? "Unknown error"}'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  Future<void> _handleUpgrade({bool isTrial = false}) async {
    final user = ref.read(authProvider).user;

    setState(() {
      if (isTrial) {
        _isTrialLoading = true;
      } else {
        _isUpgradeLoading = true;
      }
    });

    final success = await _razorpayService.openNativeCheckout(
      customerName: user?.name ?? 'User',
      customerEmail: '',
      customerPhone: '',
      isTrial: isTrial,
    );

    if (!success && mounted) {
      setState(() {
        _isUpgradeLoading = false;
        _isTrialLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not start payment. Please try again.'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  String _getLanguageName(String code) {
    const names = {
      'en': 'English', 'hi': 'हिन्दी', 'bn': 'বাংলা', 'te': 'తెలుగు',
      'mr': 'मराठी', 'ta': 'தமிழ்', 'gu': 'ગુજરાતી', 'kn': 'ಕನ್ನಡ',
      'ml': 'മലയാളം', 'pa': 'ਪੰਜਾਬੀ', 'or': 'ଓଡ଼ିଆ', 'as': 'অসমীয়া',
    };
    return names[code] ?? 'English';
  }

  void _toggleTheme(WidgetRef ref) {
    final current = ref.read(themeProvider);
    ref.read(themeProvider.notifier).setTheme(
      current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'hi', 'name': 'हिन्दी (Hindi)'},
      {'code': 'bn', 'name': 'বাংলা (Bengali)'},
      {'code': 'te', 'name': 'తెలుగు (Telugu)'},
      {'code': 'mr', 'name': 'मराठी (Marathi)'},
      {'code': 'ta', 'name': 'தமிழ் (Tamil)'},
      {'code': 'gu', 'name': 'ગુજરાતી (Gujarati)'},
      {'code': 'kn', 'name': 'ಕನ್ನಡ (Kannada)'},
      {'code': 'ml', 'name': 'മലയാളം (Malayalam)'},
      {'code': 'pa', 'name': 'ਪੰਜਾਬੀ (Punjabi)'},
      {'code': 'or', 'name': 'ଓଡ଼ିଆ (Odia)'},
      {'code': 'as', 'name': 'অসমীয়া (Assamese)'},
    ];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (ctx) => ListView.builder(
        shrinkWrap: true,
        itemCount: languages.length,
        itemBuilder: (ctx, i) {
          final lang = languages[i];
          final isSelected = ref.read(localizationProvider).languageCode == lang['code'];
          return ListTile(
            title: Text(lang['name']!, style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.accent : null,
            )),
            trailing: isSelected ? const Icon(Icons.check, color: AppColors.accent) : null,
            onTap: () {
              ref.read(localizationProvider.notifier).setLocale(Locale(lang['code']!));
              Navigator.pop(ctx);
            },
          );
        },
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(context.tr('helpSupport'), style: AppTypography.h4),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: support@bhagya.app', style: AppTypography.body),
            const SizedBox(height: 8),
            Text('WhatsApp: +91 9876543210', style: AppTypography.body),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('done'), style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 20;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(context.tr('profile')),
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
            Text(context.tr('settings'), style: AppTypography.cardTitle),
            const SizedBox(height: AppSpacing.md),
            _buildSettingsCard([
              _SettingsRow(
                icon: Icons.notifications,
                label: context.tr('notifications'),
                onTap: () => context.push('/notification-settings'),
              ),
              _SettingsRow(
                icon: Icons.language,
                label: context.tr('language'),
                value: _getLanguageName(ref.watch(localizationProvider).languageCode),
                onTap: () => _showLanguagePicker(context, ref),
              ),
              _SettingsRow(
                icon: ref.watch(themeProvider) == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                label: context.tr('theme'),
                value: ref.watch(themeProvider) == ThemeMode.dark ? context.tr('dark') : context.tr('light'),
                onTap: () => _toggleTheme(ref),
              ),
            ]),
            const SizedBox(height: AppSpacing.xl2),
            Text(context.tr('account'), style: AppTypography.cardTitle),
            const SizedBox(height: AppSpacing.md),
            _buildSettingsCard([
              _SettingsRow(
                icon: Icons.help_outline,
                label: context.tr('helpSupport'),
                onTap: () => _showHelpDialog(context),
              ),
              _SettingsRow(
                icon: Icons.description,
                label: context.tr('termsOfService'),
                onTap: () => _launchUrl('https://bhagya.app/terms'),
              ),
              _SettingsRow(
                icon: Icons.shield,
                label: context.tr('privacyPolicy'),
                onTap: () => _launchUrl('https://bhagya.app/privacy'),
              ),
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
            color: Colors.black.withAlpha(38),
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
              Icon(
                isSubscribed ? Icons.workspace_premium : Icons.star_border,
                size: 24,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  isSubscribed ? 'Premium Member' : 'Free Trial',
                  style: AppTypography.h4.copyWith(color: AppColors.accent),
                ),
              ),
              if (isSubscribed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(50),
                    borderRadius: BorderRadius.circular(AppBorderRadius.full),
                  ),
                  child: Text(
                    'Active',
                    style: AppTypography.small.copyWith(color: AppColors.success),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (isSubscribed) ...[
            Text(
              'You have full access to all premium features',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Plan', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                      Text('Monthly', style: AppTypography.body),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Amount', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                      Text('₹99/month', style: AppTypography.body.copyWith(color: AppColors.accent)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Payment', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                      Text('UPI AutoPay', style: AppTypography.body),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              'Upgrade to unlock all premium features',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isAnyLoading ? null : () => _handleUpgrade(isTrial: false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  disabledBackgroundColor: AppColors.secondary.withAlpha(128),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isUpgradeLoading) ...[
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Text('Processing...'),
                    ] else
                      const Text('Upgrade Now - ₹99/month'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _isAnyLoading ? null : () => _handleUpgrade(isTrial: true),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _isAnyLoading ? AppColors.textSecondary : AppColors.accent,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isTrialLoading) ...[
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppColors.accent),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text('Processing...', style: TextStyle(color: AppColors.accent)),
                    ] else
                      Text(
                        'Start 7-Day Free Trial',
                        style: TextStyle(color: _isAnyLoading ? AppColors.textSecondary : AppColors.accent),
                      ),
                  ],
                ),
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
              if (!isLast) Divider(color: Colors.white.withAlpha(25), height: 1),
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
              await ApiService.logout();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
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
