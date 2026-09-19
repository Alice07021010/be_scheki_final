import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/entity_configs.dart';

class DataHubScreen extends StatelessWidget {
  const DataHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Данные', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: allEntityConfigs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final config = allEntityConfigs[index];
                return Card(
                  child: ListTile(
                    title: Text(config.title),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/admin/data/${config.collection}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
