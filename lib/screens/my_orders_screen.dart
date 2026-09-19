import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/page_result.dart';
import '../state/app_store.dart';
import '../widgets/states.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  PageResult? result;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final store = context.read<AppStore>();
      final data = await store.api.list(
        'orders',
        perPage: 100,
        filter: 'user="${store.user!.id}" && deleted=false',
        sort: '-id',
      );
      if (!mounted) return;
      setState(() {
        result = data;
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
    final items = result?.items ?? [];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Мои заказы', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(text: 'Заказов пока нет')
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final order = items[index];
                      final total = (order['total'] as num? ?? 0).toDouble();
                      return Card(
                        child: ListTile(
                          title: Text(order['number']?.toString() ?? ''),
                          subtitle: Text(order['status']?.toString() ?? ''),
                          trailing: Text('${total.toStringAsFixed(0)} ₽'),
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
