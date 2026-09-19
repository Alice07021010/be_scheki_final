import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/entity_configs.dart';
import 'screens/advisor_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/crud_screen.dart';
import 'screens/data_hub_screen.dart';
import 'screens/forbidden_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_orders_screen.dart';
import 'screens/receiving_screen.dart';
import 'screens/register_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/users_screen.dart';
import 'state/app_store.dart';
import 'widgets/app_shell.dart';

class BeSchekiApp extends StatefulWidget {
  final AppStore store;
  const BeSchekiApp({super.key, required this.store});

  @override
  State<BeSchekiApp> createState() => _BeSchekiAppState();
}

class _BeSchekiAppState extends State<BeSchekiApp> {
  late final GoRouter router;

  @override
  void initState() {
    super.initState();
    router = GoRouter(
      refreshListenable: widget.store,
      initialLocation: '/',
      redirect: (context, state) {
        final path = state.uri.path;
        final public = path == '/login' || path == '/register';
        if (!widget.store.ready) return null;
        if (!widget.store.loggedIn && !public) return '/login';
        if (widget.store.loggedIn && public) return '/';
        if (!widget.store.loggedIn) return null;
        final role = widget.store.role;
        if (path.startsWith('/admin') && role != 'admin') return '/forbidden';
        if (path.startsWith('/manage') && role != 'manager') return '/forbidden';
        if ((path == '/shop' || path == '/cart' || path == '/my-orders' || path == '/advisor') && role != 'buyer') {
          return '/forbidden';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/forbidden', builder: (_, __) => const ForbiddenScreen()),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
            GoRoute(path: '/shop', builder: (_, state) => ShopScreen(query: state.uri.queryParameters)),
            GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
            GoRoute(path: '/my-orders', builder: (_, __) => const MyOrdersScreen()),
            GoRoute(path: '/advisor', builder: (_, __) => const AdvisorScreen()),
            GoRoute(path: '/manage/products', builder: (_, __) => const CrudScreen(config: productsConfig)),
            GoRoute(path: '/manage/orders', builder: (_, __) => const CrudScreen(config: ordersConfig)),
            GoRoute(path: '/manage/suppliers', builder: (_, __) => const CrudScreen(config: suppliersConfig)),
            GoRoute(path: '/manage/receiving', builder: (_, __) => const ReceivingScreen()),
            GoRoute(path: '/admin/users', builder: (_, __) => const UsersScreen()),
            GoRoute(path: '/admin/data', builder: (_, __) => const DataHubScreen()),
            GoRoute(
              path: '/admin/data/:collection',
              builder: (_, state) {
                final name = state.pathParameters['collection']!;
                final config = allEntityConfigs.firstWhere((e) => e.collection == name);
                return CrudScreen(config: config);
              },
            ),
            GoRoute(path: '/admin/stats', builder: (_, __) => const StatsScreen()),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.store,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'ЗАО «Бе щеки»',
        routerConfig: router,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6B8E7B),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F6F2),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
