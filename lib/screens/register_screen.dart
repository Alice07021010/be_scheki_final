import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/validators.dart';
import '../state/app_store.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  String? error;
  bool loading = false;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() {
      loading = true;
      error = null;
    });
    final result = await context.read<AppStore>().register(name.text, email.text, password.text);
    if (!mounted) return;
    setState(() {
      loading = false;
      error = result;
    });
    if (result == null) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Form(
              key: formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: name,
                        validator: (v) => Validators.requiredText(v, 'Имя'),
                        decoration: const InputDecoration(labelText: 'Имя'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: email,
                        validator: Validators.email,
                        decoration: const InputDecoration(labelText: 'E-mail'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: password,
                        obscureText: true,
                        validator: (v) {
                          final required = Validators.requiredText(v, 'Пароль');
                          if (required != null) return required;
                          if (v!.length < 8) return 'Минимум 8 символов';
                          if (!RegExp(r'\d').hasMatch(v)) return 'Добавьте цифру';
                          return null;
                        },
                        decoration: const InputDecoration(labelText: 'Пароль'),
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 10),
                        Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: loading ? null : submit,
                          child: Text(loading ? 'Сохранение...' : 'Создать аккаунт'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
