import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../services/pricing_service.dart';
import '../state/app_store.dart';
import '../widgets/states.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool loading = true;
  String? error;
  String? cartId;
  List<Map<String, dynamic>> items = [];

  ApiClient get api => context.read<AppStore>().api;

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
      final userId = context.read<AppStore>().user!.id;
      final carts = await api.list('carts', perPage: 1, filter: 'user="$userId" && deleted=false');
      if (carts.items.isEmpty) {
        if (!mounted) return;
        setState(() {
          loading = false;
          items = [];
        });
        return;
      }
      cartId = carts.items.first['id'].toString();
      final data = await api.list(
        'cart_items',
        perPage: 100,
        filter: 'cart="$cartId" && deleted=false',
        expand: 'product',
      );
      if (!mounted) return;
      setState(() {
        items = data.items;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = '$e';
      });
    }
  }

  Map<String, dynamic> _product(Map<String, dynamic> item) {
    final expand = item['expand'];
    if (expand is Map && expand['product'] is Map) {
      return Map<String, dynamic>.from(expand['product'] as Map);
    }
    return {};
  }

  PriceResult get price {
    final lines = items.map((item) {
      final product = _product(item);
      return (
        price: (product['price'] as num? ?? 0).toDouble(),
        quantity: (item['quantity'] as num? ?? 0).toInt(),
      );
    }).toList();
    return PricingService.calculate(lines);
  }

  Future<void> _change(Map<String, dynamic> item, int delta) async {
    final current = (item['quantity'] as num? ?? 0).toInt();
    final next = current + delta;
    if (next <= 0) {
      await api.delete('cart_items', item['id'].toString());
    } else {
      await api.update('cart_items', item['id'].toString(), {'quantity': next});
    }
    await _load();
  }

  Future<void> _checkout() async {
    if (items.isEmpty) return;
    setState(() => loading = true);
    try {
      final store = context.read<AppStore>();
      for (final item in items) {
        final product = _product(item);
        final stock = (product['stock'] as num? ?? 0).toInt();
        final quantity = (item['quantity'] as num? ?? 0).toInt();
        if (quantity > stock) {
          throw ApiException(409, 'Недостаточно товара «${product['name']}»');
        }
      }
      final p = price;
      final order = await api.create('orders', {
        'user': store.user!.id,
        'number': 'BS-${DateTime.now().millisecondsSinceEpoch}',
        'status': 'Новый',
        'subtotal': p.subtotal,
        'discount': p.discount,
        'delivery': p.delivery,
        'total': p.total,
        'deleted': false,
      });
      for (final item in items) {
        final product = _product(item);
        final quantity = (item['quantity'] as num? ?? 0).toInt();
        await api.create('order_items', {
          'order': order['id'].toString(),
          'product': product['id'].toString(),
          'quantity': quantity,
          'price': (product['price'] as num? ?? 0).toDouble(),
          'deleted': false,
        });
        await api.delete('cart_items', item['id'].toString());
      }
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заказ оформлен')));
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
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
          Text('Корзина', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(text: 'Корзина пуста')
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final product = _product(item);
                      final quantity = (item['quantity'] as num? ?? 0).toInt();
                      final price = (product['price'] as num? ?? 0).toDouble();
                      return Card(
                        child: ListTile(
                          title: Text(product['name']?.toString() ?? 'Товар'),
                          subtitle: Text('${price.toStringAsFixed(0)} ₽ · $quantity шт.'),
                          trailing: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              IconButton(onPressed: () => _change(item, -1), icon: const Icon(Icons.remove)),
                              Text('$quantity'),
                              IconButton(onPressed: () => _change(item, 1), icon: const Icon(Icons.add)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (items.isNotEmpty) ...[
            const Divider(),
            Text('Товары: ${price.subtotal.toStringAsFixed(0)} ₽'),
            Text('Скидка: ${price.discount.toStringAsFixed(0)} ₽'),
            Text('Доставка: ${price.delivery.toStringAsFixed(0)} ₽'),
            const SizedBox(height: 6),
            Text('Итого: ${price.total.toStringAsFixed(0)} ₽', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            FilledButton(onPressed: _checkout, child: const Text('Оформить заказ')),
          ],
        ],
      ),
    );
  }
}
