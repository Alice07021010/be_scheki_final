import '../models/entity_config.dart';
import '../models/page_result.dart';
import '../services/api_client.dart';

class CrudRepository {
  final ApiClient api;
  final EntityConfig config;

  CrudRepository(this.api, this.config);

  Future<PageResult> load({
    int page = 1,
    int perPage = 10,
    String search = '',
    bool showDeleted = false,
    String sort = 'id',
  }) {
    final filters = <String>[];
    if (config.collection != 'users') {
      filters.add('deleted=${showDeleted ? 'true' : 'false'}');
    }
    if (search.trim().isNotEmpty) {
      final safe = search.trim().replaceAll('"', '\"');
      final searchable = config.fields.where((e) => e.searchable).toList();
      if (searchable.isNotEmpty) {
        filters.add('(${searchable.map((e) => '${e.name}~"$safe"').join(' || ')})');
      }
    }
    final relations = config.fields
        .where((e) => e.kind == FieldKind.relation)
        .map((e) => e.name)
        .join(',');
    return api.list(
      config.collection,
      page: page,
      perPage: perPage,
      filter: filters.join(' && '),
      sort: sort,
      expand: relations.isEmpty ? null : relations,
    );
  }

  Future<void> create(Map<String, dynamic> data) async {
    await api.create(config.collection, {...data, if (config.collection != 'users') 'deleted': false});
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await api.update(config.collection, id, data);
  }

  Future<void> softDelete(String id) async {
    await api.update(config.collection, id, {'deleted': true});
  }

  Future<void> restore(String id) async {
    await api.update(config.collection, id, {'deleted': false});
  }

  Future<void> hardDelete(String id) => api.delete(config.collection, id);

  Future<void> softDeleteMany(Iterable<String> ids) async {
    for (final id in ids) {
      await softDelete(id);
    }
  }
}
