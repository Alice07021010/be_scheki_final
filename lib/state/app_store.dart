import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../services/api_client.dart';

class AppStore extends ChangeNotifier {
  final ApiClient api;
  final SharedPreferences prefs;

  AppUser? user;
  bool ready = false;

  AppStore(this.api, this.prefs);

  bool get loggedIn => user != null;
  String get role => user?.role ?? '';

  Future<void> init() async {
    final savedToken = prefs.getString('auth_token');
    if (savedToken != null && savedToken.isNotEmpty) {
      api.token = savedToken;
      try {
        final result = await api.refresh();
        _saveAuth(result);
      } catch (_) {
        await logout();
      }
    }
    ready = true;
    notifyListeners();
  }

  Future<bool> login(String identity, String password) async {
    try {
      final result = await api.login(identity.trim(), password);
      _saveAuth(result);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> register(String name, String email, String password) async {
    try {
      await api.register(name: name.trim(), email: email.trim(), password: password);
      final ok = await login(email, password);
      return ok ? null : 'Пользователь создан, но войти не получилось';
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Не удалось зарегистрироваться';
    }
  }

  Future<void> logout() async {
    user = null;
    api.token = null;
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
    notifyListeners();
  }

  void _saveAuth(Map<String, dynamic> result) {
    final token = result['token']?.toString() ?? '';
    final record = result['record'];
    if (record is! Map || token.isEmpty) return;
    api.token = token;
    user = AppUser.fromJson(Map<String, dynamic>.from(record));
    prefs.setString('auth_token', token);
  }
}
