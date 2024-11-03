import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sms_auth_firebase/src/presentation/state/auth_state.dart';

import '../data/models/userSMS_model.dart';

class AuthCheckScreen extends ConsumerWidget {
  final Widget Function(UserSMS) mainScreen;
  final Widget Function() registerScreen;

  const AuthCheckScreen({
    super.key,
    required this.mainScreen,
    required this.registerScreen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const CircularProgressIndicator(),
      authenticated: (user) => mainScreen(user),
      unauthenticated: () => registerScreen(),
    );
  }
}