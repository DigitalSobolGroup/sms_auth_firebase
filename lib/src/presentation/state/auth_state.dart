import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sms_auth_firebase/src/domain/repositories/user_repository.dart';

import '../../data/models/userSMS_model.dart';
import '../../data/user_data_source_impl.dart';
import '../../domain/user_repository_impl.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  // Provide an instance of UserRepository here
  // For example, you can use UserRepositoryImpl if you have implemented it
  return UserRepositoryImpl(UserDataSourceImpl());
});

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>(
      (ref) => AuthStateNotifier(ref.watch(userRepositoryProvider)),
);

class AuthStateNotifier extends StateNotifier<AuthState> {
  final UserRepository _userRepository;

  AuthStateNotifier(this._userRepository) : super(AuthState.loading()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final user = await _userRepository.getUserData();
    if (user != null) {
      state = AuthState.authenticated(user);
    } else {
      state = AuthState.unauthenticated();
    }
  }

  Future<void> login(UserSMS user) async {
    await _userRepository.saveOrUpdateUser(user);
    state = AuthState.authenticated(user);
  }

  Future<void> logout() async {
    await _userRepository.deleteUser(state.user!.id);
    state = AuthState.unauthenticated();
  }
}

class AuthState {
  final bool isLoading;
  final UserSMS? user;

  const AuthState._({required this.isLoading, this.user});

  const AuthState.loading() : this._(isLoading: true);

  const AuthState.authenticated(UserSMS user)
      : this._(isLoading: false, user: user);

  const AuthState.unauthenticated() : this._(isLoading: false);

  T when<T>({
    required T Function() loading,
    required T Function(UserSMS user) authenticated,
    required T Function() unauthenticated,
  }) {
    if (isLoading) {
      return loading();
    } else if (user != null) {
      return authenticated(user!);
    } else {
      return unauthenticated();
    }
  }
}