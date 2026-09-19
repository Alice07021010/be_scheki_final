import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_store.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final width = MediaQuery.sizeOf(context).width;
    final items = _items(store.role);
    final location = GoRouterState.of(context).uri.path;
    final selected = items.indexWhere((e) => location.startsWith(e.route));

    if (width < 700) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ЗАО «Бе щеки»'),
          actions: [
            IconButton(onPressed: store.logout, icon: const Icon(Icons.logout)),
          ],
        ),
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selected < 0 ? 0 : selected,
          onDestinationSelected: (index) => context.go(items[index].route),
          destinations: items
              .map((e) => NavigationDestination(icon: Icon(e.icon), label: e.label))
              .toList(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ЗАО «Бе щеки»'),
        actions: [
          Center(child: Text('${store.user?.name ?? ''} · ${_roleName(store.role)}')),
          const SizedBox(width: 12),
          IconButton(onPressed: store.logout, icon: const Icon(Icons.logout)),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            extended: width >= 1150,
            selectedIndex: selected < 0 ? 0 : selected,
            onDestinationSelected: (index) => context.go(items[index].route),
            destinations: items
                .map((e) => NavigationRailDestination(icon: Icon(e.icon), label: Text(e.label)))
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  List<_NavItem> _items(String role) {
    if (role == 'buyer') {
      return const [
        _NavItem('Каталог', Icons.storefront_outlined, '/shop'),
        _NavItem('Корзина', Icons.shopping_bag_outlined, '/cart'),
        _NavItem('Заказы', Icons.receipt_long_outlined, '/my-orders'),
        _NavItem('Подбор', Icons.auto_awesome_outlined, '/advisor'),
      ];
    }
    if (role == 'manager') {
      return const [
        _NavItem('Товары', Icons.inventory_2_outlined, '/manage/products'),
        _NavItem('Заказы', Icons.receipt_long_outlined, '/manage/orders'),
        _NavItem('Поставщики', Icons.local_shipping_outlined, '/manage/suppliers'),
        _NavItem('Приёмка', Icons.add_box_outlined, '/manage/receiving'),
      ];
    }
    return const [
      _NavItem('Пользователи', Icons.manage_accounts_outlined, '/admin/users'),
      _NavItem('Данные', Icons.storage_outlined, '/admin/data'),
      _NavItem('Статистика', Icons.bar_chart_outlined, '/admin/stats'),
    ];
  }

  String _roleName(String role) {
    if (role == 'buyer') return 'Покупатель';
    if (role == 'manager') return 'Менеджер';
    return 'Администратор';
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  const _NavItem(this.label, this.icon, this.route);
}
