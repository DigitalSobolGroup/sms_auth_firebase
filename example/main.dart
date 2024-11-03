import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sms_auth_firebase/sms_auth_firebase.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthCheckScreen(),
    );
  }
}

class AuthCheckScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    return FutureBuilder<bool>(
      future: authService.isUserRegistered(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
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
        title: Text('Пример регистрации'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Номер телефона'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  _uuid = await authService
                      .sendPhoneNumber(_phoneNumberController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('СМС отправлен')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: Text('Отправить СМС'),
            ),
            if (_uuid != null) ...[
              TextField(
                controller: _smsCodeController,
                decoration: InputDecoration(labelText: 'Код из СМС'),
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
                      SnackBar(content: Text('Пользователь зарегистрирован')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                child: Text('Проверить код из СМС'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Главный экран'),
      ),
      body: Center(
        child: Text('Типа главный экран'),
      ),
    );
  }
}
