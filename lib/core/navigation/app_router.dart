import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/onboarding/screens/email_entry_screen.dart';
import '../../features/onboarding/screens/onboarding_otp_screen.dart';
import '../../features/onboarding/screens/language_selection_screen.dart';
import '../../features/onboarding/screens/birth_details_screen.dart';
import '../../features/onboarding/screens/nakshatra_mapping_screen.dart';
import '../../features/onboarding/screens/subscription_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/nakshatra/screens/nakshatra_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/notification_settings_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(authProvider.notifier);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(notifier.stream),
    initialLocation: '/welcome',
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      if (authState.isLoading) return null;
      
      final isOnboarding = state.matchedLocation.startsWith('/welcome') ||
          state.matchedLocation.startsWith('/email-entry') ||
          state.matchedLocation.startsWith('/onboarding-otp') ||
          state.matchedLocation.startsWith('/language') ||
          state.matchedLocation.startsWith('/birth-details') ||
          state.matchedLocation.startsWith('/nakshatra-mapping') ||
          state.matchedLocation.startsWith('/subscription') ||
          state.matchedLocation.startsWith('/login');

      debugPrint('Router Redirect Check:');
      debugPrint('  Path: ${state.matchedLocation}');
      debugPrint('  isOnboarded: ${authState.isOnboarded}');
      debugPrint('  isOnboarding Route: $isOnboarding');

      if (!authState.isOnboarded && !isOnboarding) {
        debugPrint('  -> Redirecting to /welcome');
        return '/welcome';
      }

      if (authState.isOnboarded && state.matchedLocation == '/welcome') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/email-entry',
        builder: (context, state) => const EmailEntryScreen(),
      ),
      GoRoute(
        path: '/onboarding-otp',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>? ?? {};
          return OnboardingOtpScreen(email: params['email'] ?? '');
        },
      ),
      GoRoute(
        path: '/language',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/birth-details',
        builder: (context, state) {
          final language = state.extra as String? ?? 'en';
          return BirthDetailsScreen(language: language);
        },
      ),
      GoRoute(
        path: '/nakshatra-mapping',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>? ?? {};
          return NakshatraMappingScreen(
            name: params['name'] ?? '',
            birthDate: params['birthDate'] ?? '',
            birthTime: params['birthTime'] ?? '',
            birthPlace: params['birthPlace'] ?? '',
            language: params['language'] ?? 'en',
          );
        },
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/nakshatra',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NakshatraScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
            routes: [
              GoRoute(
                path: 'edit',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const EditProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/notification-settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) {
          final params = state.extra as Map<String, dynamic>? ?? {};
          return OtpVerificationScreen(
            email: params['email'] ?? '',
            isLogin: params['isLogin'] ?? false,
          );
        },
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
