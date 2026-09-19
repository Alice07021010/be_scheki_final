import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_store.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AppStore>().role;
    if (role == 'buyer') return const _Home(title: 'Покупатель', items: _buyerItems);
    if (role == 'manager') return const _Home(title: 'Менеджер', items: _managerItems);
    return const _Home(title: 'Администратор', items: _adminItems);
  }
}

const _buyerItems = [
  _HomeItem('Каталог', 'Выбрать зубную щётку', Icons.storefront_outlined, '/shop'),
  _HomeItem('Корзина', 'Товары перед оформлением', Icons.shopping_bag_outlined, '/cart'),
  _HomeItem('Мои заказы', 'История покупок', Icons.receipt_long_outlined, '/my-orders'),
  _HomeItem('Подбор щётки', 'Короткий подбор по параметрам', Icons.auto_awesome_outlined, '/advisor'),
];

const _managerItems = [
  _HomeItem('Товары', 'Каталог и остатки', Icons.inventory_2_outlined, '/manage/products'),
  _HomeItem('Заказы', 'Обработка заказов', Icons.receipt_long_outlined, '/manage/orders'),
  _HomeItem('Поставщики', 'Контакты поставщиков', Icons.local_shipping_outlined, '/manage/suppliers'),
  _HomeItem('Приёмка', 'Пополнение остатков', Icons.add_box_outlined, '/manage/receiving'),
];

const _adminItems = [
  _HomeItem('Пользователи', 'Учётные записи и роли', Icons.manage_accounts_outlined, '/admin/users'),
  _HomeItem('Данные', 'Все сущности проекта', Icons.storage_outlined, '/admin/data'),
  _HomeItem('Статистика', 'Сводные показатели', Icons.bar_chart_outlined, '/admin/stats'),
];

class _Home extends StatelessWidget {
  final String title;
  final List<_HomeItem> items;
  const _Home({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1050),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 18),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.sizeOf(context).width >= 950 ? 3 : MediaQuery.sizeOf(context).width >= 600 ? 2 : 1,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.9,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      child: InkWell(
                        onTap: () => context.go(item.route),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Icon(item.icon, size: 34),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                                    const SizedBox(height: 4),
                                    Text(item.subtitle),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  const _HomeItem(this.title, this.subtitle, this.icon, this.route);
}
