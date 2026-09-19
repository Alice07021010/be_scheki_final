import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/page_result.dart';
import '../services/api_client.dart';
import '../state/app_store.dart';
import '../widgets/states.dart';

class ShopScreen extends StatefulWidget {
  final Map<String, String> query;

  const ShopScreen({super.key, this.query = const {}});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final search = TextEditingController();
  PageResult? result;
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> brands = [];
  bool loading = true;
  String? error;
  String? category;
  String? brand;
  String? hardness;
  int page = 1;
  String sort = 'name';

  ApiClient get api => context.read<AppStore>().api;

  @override
  void initState() {
    super.initState();
    _readQuery();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRefs());
  }

  @override
  void didUpdateWidget(covariant ShopScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query.toString() != widget.query.toString()) {
      _readQuery();
      _load();
    }
  }

  void _readQuery() {
    search.text = widget.query['q'] ?? '';
    category = widget.query['category'];
    brand = widget.query['brand'];
    hardness = widget.query['hardness'];
    page = int.tryParse(widget.query['page'] ?? '') ?? 1;
    sort = widget.query['sort'] ?? 'name';
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> _loadRefs() async {
    try {
      final data = await Future.wait([
        api.list('categories', perPage: 200, filter: 'deleted=false', sort: 'name'),
        api.list('brands', perPage: 200, filter: 'deleted=false', sort: 'name'),
      ]);
      if (!mounted) return;
      categories = data[0].items;
      brands = data[1].items;
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = '$e';
      });
    }
  }

  void _go({bool resetPage = true}) {
    final query = <String, String>{
      if (search.text.trim().isNotEmpty) 'q': search.text.trim(),
      if (category != null) 'category': category!,
      if (brand != null) 'brand': brand!,
      if (hardness != null) 'hardness': hardness!,
      if (sort != 'name') 'sort': sort,
      if (!resetPage && page > 1) 'page': '$page',
    };
    context.go(Uri(path: '/shop', queryParameters: query).toString());
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    final filters = <String>['deleted=false', 'stock>0'];
    final text = search.text.trim().replaceAll('"', '\\"');
    if (text.isNotEmpty) filters.add('name~"$text"');
    if (category != null) filters.add('category="$category"');
    if (brand != null) filters.add('brand="$brand"');
    if (hardness != null) filters.add('hardness="$hardness"');
    try {
      final data = await api.list(
        'products',
        page: page,
        perPage: 12,
        filter: filters.join(' && '),
        sort: sort,
        expand: 'category,brand',
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

  Future<void> _add(Map<String, dynamic> product) async {
    final store = context.read<AppStore>();
    final userId = store.user!.id;
    try {
      final carts = await api.list('carts', perPage: 1, filter: 'user="$userId" && deleted=false');
      String cartId;
      if (carts.items.isEmpty) {
        final cart = await api.create('carts', {'user': userId, 'deleted': false});
        cartId = cart['id'].toString();
      } else {
        cartId = carts.items.first['id'].toString();
      }
      final productId = product['id'].toString();
      final items = await api.list(
        'cart_items',
        perPage: 1,
        filter: 'cart="$cartId" && product="$productId" && deleted=false',
      );
      if (items.items.isEmpty) {
        await api.create('cart_items', {
          'cart': cartId,
          'product': productId,
          'quantity': 1,
          'deleted': false,
        });
      } else {
        final item = items.items.first;
        final quantity = (item['quantity'] as num? ?? 0).toInt() + 1;
        await api.update('cart_items', item['id'].toString(), {'quantity': quantity});
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Добавлено в корзину')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Каталог', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 260,
                child: TextField(
                  controller: search,
                  onSubmitted: (_) => _go(),
                  decoration: const InputDecoration(labelText: 'Поиск', prefixIcon: Icon(Icons.search)),
                ),
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String?>(
                  key: ValueKey('category-$category'),
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Категория'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Все')),
                    ...categories.map((e) => DropdownMenuItem(value: e['id'].toString(), child: Text(e['name'].toString()))),
                  ],
                  onChanged: (value) {
                    category = value;
                    _go();
                  },
                ),
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String?>(
                  key: ValueKey('brand-$brand'),
                  initialValue: brand,
                  decoration: const InputDecoration(labelText: 'Бренд'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Все')),
                    ...brands.map((e) => DropdownMenuItem(value: e['id'].toString(), child: Text(e['name'].toString()))),
                  ],
                  onChanged: (value) {
                    brand = value;
                    _go();
                  },
                ),
              ),
              SizedBox(
                width: 170,
                child: DropdownButtonFormField<String?>(
                  key: ValueKey('hardness-$hardness'),
                  initialValue: hardness,
                  decoration: const InputDecoration(labelText: 'Жёсткость'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Все')),
                    DropdownMenuItem(value: 'Мягкая', child: Text('Мягкая')),
                    DropdownMenuItem(value: 'Средняя', child: Text('Средняя')),
                    DropdownMenuItem(value: 'Жёсткая', child: Text('Жёсткая')),
                  ],
                  onChanged: (value) {
                    hardness = value;
                    _go();
                  },
                ),
              ),
              DropdownButton<String>(
                value: sort,
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('По названию')),
                  DropdownMenuItem(value: 'price', child: Text('Сначала дешевле')),
                  DropdownMenuItem(value: '-price', child: Text('Сначала дороже')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  sort = value;
                  _go();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _body()),
          if (result != null && !loading) _pages(),
        ],
      ),
    );
  }

  Widget _body() {
    if (loading) return const LoadingState();
    if (error != null) return ErrorState(message: error!, onRetry: _load);
    if (result == null || result!.items.isEmpty) return const EmptyState();
    final width = MediaQuery.sizeOf(context).width;
    final count = width >= 1200 ? 4 : width >= 850 ? 3 : width >= 600 ? 2 : 1;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: result!.items.length,
      itemBuilder: (context, index) {
        final product = result!.items[index];
        final price = (product['price'] as num? ?? 0).toDouble();
        final stock = (product['stock'] as num? ?? 0).toInt();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'].toString(), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('${product['hardness']} жёсткость'),
                Text('В наличии: $stock'),
                const Spacer(),
                Text('${price.toStringAsFixed(0)} ₽', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(onPressed: () => _add(product), child: const Text('В корзину')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pages() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: result!.page > 1
              ? () {
                  page--;
                  _go(resetPage: false);
                }
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text('${result!.page} / ${result!.totalPages}'),
        IconButton(
          onPressed: result!.page < result!.totalPages
              ? () {
                  page++;
                  _go(resetPage: false);
                }
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
