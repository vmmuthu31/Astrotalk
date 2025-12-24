import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/user.dart';

const String _userKey = '@bhagya_user';
const String _onboardedKey = '@bhagya_onboarded';

class AuthState {
  final User? user;
  final bool isLoading;
  final bool isOnboarded;

  const AuthState({
    this.user,
    this.isLoading = true,
    this.isOnboarded = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isOnboarded,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      final onboarded = prefs.getBool(_onboardedKey) ?? false;

      User? user;
      if (userJson != null) {
        user = User.fromJson(jsonDecode(userJson));
      }

      state = state.copyWith(
        user: user,
        isLoading: false,
        isOnboarded: onboarded,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      state = state.copyWith(user: user);
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  Future<void> setOnboarded(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardedKey, value);
      state = state.copyWith(isOnboarded: value);
    } catch (e) {
      print('Error saving onboarded state: $e');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_onboardedKey);
      state = const AuthState(isLoading: false, isOnboarded: false);
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
