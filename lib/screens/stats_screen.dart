import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_store.dart';
import '../widgets/states.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool loading = true;
  String? error;
  final values = <String, int>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final api = context.read<AppStore>().api;
      final data = await Future.wait([
        api.list('products', perPage: 1, filter: 'deleted=false'),
        api.list('orders', perPage: 1, filter: 'deleted=false'),
        api.list('users', perPage: 1),
        api.list('reviews', perPage: 1, filter: 'deleted=false'),
        api.list('suppliers', perPage: 1, filter: 'deleted=false'),
      ]);
      if (!mounted) return;
      setState(() {
        values['Товаров'] = data[0].totalItems;
        values['Заказов'] = data[1].totalItems;
        values['Пользователей'] = data[2].totalItems;
        values['Отзывов'] = data[3].totalItems;
        values['Поставщиков'] = data[4].totalItems;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = '$e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const LoadingState();
    if (error != null) return ErrorState(message: error!, onRetry: _load);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Статистика', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: values.entries
                .map(
                  (e) => SizedBox(
                    width: 220,
                    height: 120,
                    child: Card(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${e.value}', style: Theme.of(context).textTheme.headlineMedium),
                            Text(e.key),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
