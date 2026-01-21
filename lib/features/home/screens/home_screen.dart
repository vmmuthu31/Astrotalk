import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/localization_provider.dart';
import '../../../core/services/astrology_service.dart';
import '../../../shared/widgets/star_field.dart';
import '../widgets/lucky_card.dart';
import '../../../core/providers/theme_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerScale;
  late Animation<double> _headerOpacity;
  bool _isSpeaking = false;
  final FlutterTts _tts = FlutterTts();

  static const Map<String, IconData> _directionIcons = {
    'North': Icons.arrow_upward,
    'South': Icons.arrow_downward,
    'East': Icons.arrow_forward,
    'West': Icons.arrow_back,
    'North-East': Icons.north_east,
    'North-West': Icons.north_west,
    'South-East': Icons.south_east,
    'South-West': Icons.south_west,
  };

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _headerScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutBack),
    );
    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerController.forward();
    _initTts();
  }

  void _initTts() async {
    await _tts.setSpeechRate(0.4);
    _tts.setCompletionHandler(() => setState(() => _isSpeaking = false));
  }

  String _getTtsLanguage(String localeCode) {
    const langMap = {
      'en': 'en-IN', 'hi': 'hi-IN', 'bn': 'bn-IN', 'te': 'te-IN',
      'mr': 'mr-IN', 'ta': 'ta-IN', 'gu': 'gu-IN', 'kn': 'kn-IN',
      'ml': 'ml-IN', 'pa': 'pa-IN', 'or': 'or-IN', 'as': 'as-IN',
    };
    return langMap[localeCode] ?? 'hi-IN';
  }

  @override
  void dispose() {
    _headerController.dispose();
    _tts.stop();
    super.dispose();
  }

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.tr('greetingMorning');
    if (hour < 17) return context.tr('greetingAfternoon');
    return context.tr('greetingEvening');
  }

  String _currentMantra = '';

  void _playMantra(String mantra, String localeCode) async {
    _currentMantra = mantra;
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
    } else {
      await _tts.setLanguage(_getTtsLanguage(localeCode));
      setState(() => _isSpeaking = true);
      await _tts.speak(mantra);
    }
  }

  void _shareToWhatsApp(Map<String, dynamic> prediction) async {
    final message = '''${prediction['luckyColor']} is my lucky color today!

My Today's Bhagya:
Lucky Number: ${prediction['luckyNumber']}
Lucky Direction: ${prediction['luckyDirection']}
Lucky Time: ${prediction['luckyTime']}
${prediction['mantra'] != null ? '\nMantra: "${prediction['mantra']}"' : ''}

Discover your daily luck with Bhagya app!''';

    final whatsappUrl = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      await Share.share(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 20;

    final prediction = AstrologyService.generateDailyPrediction(
      rashi: user?.rashi ?? 'Mesha',
      date: DateTime.now(),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          const StarField(count: 30),
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.backgroundDefault,
              onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, bottomPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, user?.name ?? 'User'),
                    const SizedBox(height: AppSpacing.xl2),
                    _buildRashiCard(user?.rashi, user?.nakshatra),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDateCard(),
                    const SizedBox(height: AppSpacing.xl2),
                    Text(
                      context.tr('todaysLuckyGuide'),
                      style: AppTypography.h4.copyWith(color: AppColors.accent),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    LuckyCard(
                      title: context.tr('luckyColor'),
                      value: prediction['luckyColor'] as String,
                      icon: Icons.water_drop,
                      colorHex: prediction['luckyColorHex'] as String,
                      index: 0,
                    ),
                    LuckyCard(
                      title: context.tr('luckyNumber'),
                      value: prediction['luckyNumber'].toString(),
                      icon: Icons.tag,
                      color: AppColors.accent,
                      index: 1,
                    ),
                    LuckyCard(
                      title: context.tr('luckyDirection'),
                      value: prediction['luckyDirection'] as String,
                      icon: _directionIcons[prediction['luckyDirection']] ?? Icons.explore,
                      index: 2,
                    ),
                    LuckyCard(
                      title: context.tr('luckyTime'),
                      value: prediction['luckyTime'] as String,
                      icon: Icons.access_time,
                      index: 3,
                    ),
                    if (prediction['mantra'] != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _buildMantraCard(prediction['mantra'] as String),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    _buildShareButton(prediction),
                    const SizedBox(height: AppSpacing.lg),
                    _buildViralHint(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return Transform.scale(
          scale: _headerScale.value.clamp(0.0, 2.0),
          child: Opacity(
            opacity: _headerOpacity.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_getGreeting(context), style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
              IconButton(
                onPressed: () {
                  final themeMode = ref.read(themeProvider);
                  ref.read(themeProvider.notifier).setTheme(
                    themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
                  );
                },
                icon: Icon(
                  ref.watch(themeProvider) == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          Text(userName, style: AppTypography.h3),
        ],
      ),
    );
  }

  Widget _buildRashiCard(String? rashi, String? nakshatra) {
    final displayRashi = rashi != null ? '${AstrologyService.getRashiEnglish(rashi)} ($rashi)' : 'Not set';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent.withOpacity(0.2), AppColors.primary.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars, size: 24, color: AppColors.accent),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Rashi', style: AppTypography.small.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.xs),
                Text(displayRashi, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                if (nakshatra != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text('Nakshatra: $nakshatra', style: AppTypography.small.copyWith(color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 20, color: AppColors.accent),
          const SizedBox(width: AppSpacing.md),
          Text(
            DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }

  Widget _buildMantraCard(String mantra) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.tr('todaysMantra'), style: AppTypography.small.copyWith(color: AppColors.textSecondary)),
              GestureDetector(
                onTap: () => _playMantra(mantra, ref.read(localizationProvider).languageCode),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: _isSpeaking ? AppColors.accent : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppBorderRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isSpeaking ? Icons.pause : Icons.play_arrow,
                        size: 18,
                        color: _isSpeaking ? AppColors.backgroundRoot : AppColors.accent,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        _isSpeaking ? 'Stop' : 'Listen',
                        style: AppTypography.small.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _isSpeaking ? AppColors.backgroundRoot : AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            mantra,
            style: AppTypography.h4.copyWith(color: AppColors.accent, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(Map<String, dynamic> prediction) {
    return GestureDetector(
      onTap: () => _shareToWhatsApp(prediction),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.whatsappGreen,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.send, size: 20, color: Colors.white),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Share on WhatsApp',
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViralHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.star, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Share your luck with friends & family!',
          style: AppTypography.small.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
