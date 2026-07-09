import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/mock/mock_data.dart';
import '../models/user.dart';

/// 自用模式 —— 无需注册登录，默认以演示用户身份进入
class AuthState {
  const AuthState({this.user, this.isLoading = false});
  final User? user;
  final bool isLoading;

  AuthState copyWith({User? user, bool? isLoading}) =>
    AuthState(user: user ?? this.user, isLoading: isLoading ?? this.isLoading);
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(user: MockData.demoUser));

  void setUser(User user) => state = state.copyWith(user: user);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
