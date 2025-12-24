import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/onboarding/screens/language_selection_screen.dart';
import '../../features/onboarding/screens/birth_details_screen.dart';
import '../../features/onboarding/screens/nakshatra_mapping_screen.dart';
import '../../features/onboarding/screens/subscription_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/nakshatra/screens/nakshatra_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/notification_settings_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: authState.isOnboarded ? '/home' : '/welcome',
    redirect: (context, state) {
      if (authState.isLoading) return null;
      
      final isOnboarding = state.matchedLocation.startsWith('/welcome') ||
          state.matchedLocation.startsWith('/language') ||
          state.matchedLocation.startsWith('/birth-details') ||
          state.matchedLocation.startsWith('/nakshatra-mapping') ||
          state.matchedLocation.startsWith('/subscription');

      if (!authState.isOnboarded && !isOnboarding) {
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
          final params = state.extra as Map<String, dynamic>?;
          return NakshatraMappingScreen(
            name: params?['name'] ?? '',
            birthDate: params?['birthDate'] ?? '',
            birthTime: params?['birthTime'] ?? '',
            birthPlace: params?['birthPlace'] ?? '',
            language: params?['language'] ?? 'en',
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
          ),
        ],
      ),
      GoRoute(
        path: '/notification-settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
    ],
  );
});
