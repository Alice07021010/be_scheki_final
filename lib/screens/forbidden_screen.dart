import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForbiddenScreen extends StatelessWidget {
  const ForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 52),
            const SizedBox(height: 12),
            const Text('Нет доступа'),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => context.go('/'), child: const Text('На главную')),
          ],
        ),
      ),
    );
  }
}
