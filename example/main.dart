import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sms_auth_firebase/sms_auth_firebase.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthCheckScreen(),
    );
  }
}

class AuthCheckScreen extends ConsumerWidget {
  const AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    return FutureBuilder<bool>(
      future: authService.isUserRegistered(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData && snapshot.data == true) {
          return MainScreen();
        } else {
          return RegisterScreen();
        }
      },
    );
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  String? _uuid;

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Пример регистрации'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: 'Номер телефона'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  _uuid = await authService
                      .sendPhoneNumber(_phoneNumberController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('СМС отправлен')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text('Отправить СМС'),
            ),
            if (_uuid != null) ...[
              TextField(
                controller: _smsCodeController,
                decoration: const InputDecoration(labelText: 'Код из СМС'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await authService.registerUser(
                      _phoneNumberController.text,
                      _uuid!,
                      _smsCodeController.text,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Пользователь зарегистрирован')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                child: const Text('Проверить код из СМС'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главный экран'),
      ),
      body: const Center(
        child: Text('Типа главный экран'),
      ),
    );
  }
}
