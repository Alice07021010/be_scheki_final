import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final login = TextEditingController();
  final password = TextEditingController();
  String? error;
  bool loading = false;

  @override
  void dispose() {
    login.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      loading = true;
      error = null;
    });
    final ok = await context.read<AppStore>().login(login.text, password.text);
    if (!mounted) return;
    setState(() => loading = false);
    if (ok) {
      context.go('/');
    } else {
      setState(() => error = 'Неверный логин или пароль');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('ЗАО «Бе щеки»', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 6),
                    const Text('Магазин зубных щёток'),
                    const SizedBox(height: 24),
                    TextField(
                      controller: login,
                      decoration: const InputDecoration(labelText: 'E-mail или логин'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: password,
                      obscureText: true,
                      onSubmitted: (_) => submit(),
                      decoration: const InputDecoration(labelText: 'Пароль'),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 10),
                      Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: loading ? null : submit,
                      child: Text(loading ? 'Вход...' : 'Войти'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(onPressed: () => context.go('/register'), child: const Text('Регистрация покупателя')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
