import 'package:flutter/foundation.dart';

import '../models/page_result.dart';
import '../repositories/crud_repository.dart';

class CrudNotifier extends ChangeNotifier {
  final CrudRepository repository;

  PageResult? result;
  bool loading = false;
  String? error;
  String search = '';
  bool showDeleted = false;
  int page = 1;
  int perPage = 10;
  String sort = 'id';
  final Set<String> selected = {};

  CrudNotifier(this.repository);

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      result = await repository.load(
        page: page,
        perPage: perPage,
        search: search,
        showDeleted: showDeleted,
        sort: sort,
      );
    } catch (e) {
      error = '$e';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> save(String? id, Map<String, dynamic> data) async {
    if (id == null) {
      await repository.create(data);
    } else {
      await repository.update(id, data);
    }
    await load();
  }

  Future<void> remove(String id, {bool hard = false}) async {
    if (hard) {
      await repository.hardDelete(id);
    } else {
      await repository.softDelete(id);
    }
    selected.remove(id);
    await load();
  }

  Future<void> restore(String id) async {
    await repository.restore(id);
    await load();
  }

  Future<void> removeSelected() async {
    await repository.softDeleteMany(selected);
    selected.clear();
    await load();
  }

  void toggle(String id, bool value) {
    value ? selected.add(id) : selected.remove(id);
    notifyListeners();
  }
}
