import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../services/validators.dart';
import '../state/app_store.dart';
import '../widgets/states.dart';

class ReceivingScreen extends StatefulWidget {
  const ReceivingScreen({super.key});

  @override
  State<ReceivingScreen> createState() => _ReceivingScreenState();
}

class _ReceivingScreenState extends State<ReceivingScreen> {
  final formKey = GlobalKey<FormState>();
  final quantity = TextEditingController();
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> suppliers = [];
  String? productId;
  String? supplierId;
  bool loading = true;
  String? error;

  ApiClient get api => context.read<AppStore>().api;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    quantity.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await Future.wait([
        api.list('products', perPage: 200, filter: 'deleted=false', sort: 'name'),
        api.list('suppliers', perPage: 200, filter: 'deleted=false', sort: 'name'),
      ]);
      if (!mounted) return;
      setState(() {
        products = data[0].items;
        suppliers = data[1].items;
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

  Future<void> _save() async {
    if (!formKey.currentState!.validate() || productId == null || supplierId == null) return;
    final product = products.firstWhere((e) => e['id'].toString() == productId);
    final add = int.parse(quantity.text);
    final stock = (product['stock'] as num? ?? 0).toInt();
    final current = (product['suppliers'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    if (!current.contains(supplierId)) current.add(supplierId!);
    try {
      await api.update('products', productId!, {'stock': stock + add, 'suppliers': current});
      if (!mounted) return;
      quantity.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Остаток обновлён')));
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const LoadingState();
    if (error != null) return ErrorState(message: error!, onRetry: _load);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Приёмка товара', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: productId,
                      decoration: const InputDecoration(labelText: 'Товар'),
                      items: products.map((e) => DropdownMenuItem(value: e['id'].toString(), child: Text(e['name'].toString()))).toList(),
                      validator: (v) => v == null ? 'Выберите товар' : null,
                      onChanged: (v) => productId = v,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: supplierId,
                      decoration: const InputDecoration(labelText: 'Поставщик'),
                      items: suppliers.map((e) => DropdownMenuItem(value: e['id'].toString(), child: Text(e['name'].toString()))).toList(),
                      validator: (v) => v == null ? 'Выберите поставщика' : null,
                      onChanged: (v) => supplierId = v,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: quantity,
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.number(v, 'Количество', min: 1),
                      decoration: const InputDecoration(labelText: 'Количество'),
                    ),
                    const SizedBox(height: 18),
                    FilledButton(onPressed: _save, child: const Text('Принять товар')),
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
