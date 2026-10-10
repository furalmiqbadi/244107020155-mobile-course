import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/api_errors.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController(text: 'mhs@polinema.ac.id');
  final _pass = TextEditingController(text: '123456');

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authStateProvider);

    ref.listen(authStateProvider, (prev, next) {
      if (prev is AsyncLoading && next is AsyncData && next.value == true) {
        context.go(AppRoutes.home);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Login Kampus')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'mhs@polinema.ac.id',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pass,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Kata sandi (min 6)',
              ),
            ),
            const SizedBox(height: 16),
            if (authAsync.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  friendlyApiMessage(authAsync.error!),
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: authAsync.isLoading
                    ? null
                    : () => ref
                          .read(authStateProvider.notifier)
                          .login(_email.text.trim(), _pass.text),
                child: authAsync.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Masuk'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
