import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/entity_config.dart';
import '../repositories/crud_repository.dart';
import '../services/api_client.dart';
import '../services/validators.dart';
import '../state/app_store.dart';
import '../state/crud_notifier.dart';
import '../widgets/states.dart';

class CrudScreen extends StatefulWidget {
  final EntityConfig config;
  const CrudScreen({super.key, required this.config});

  @override
  State<CrudScreen> createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  CrudNotifier? notifier;
  final search = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (notifier == null) {
      final api = context.read<AppStore>().api;
      notifier = CrudNotifier(CrudRepository(api, widget.config));
      notifier!.load();
    }
  }

  @override
  void dispose() {
    search.dispose();
    notifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = notifier;
    if (n == null) return const LoadingState();
    return AnimatedBuilder(
      animation: n,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(widget.config.title, style: Theme.of(context).textTheme.headlineMedium),
                  SizedBox(
                    width: 260,
                    child: TextField(
                      controller: search,
                      onSubmitted: (value) {
                        n.search = value;
                        n.page = 1;
                        n.load();
                      },
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Поиск'),
                    ),
                  ),
                  FilterChip(
                    label: const Text('Удалённые'),
                    selected: n.showDeleted,
                    onSelected: (value) {
                      n.showDeleted = value;
                      n.page = 1;
                      n.load();
                    },
                  ),
                  DropdownButton<String>(
                    value: n.sort,
                    items: [
                      const DropdownMenuItem(value: 'id', child: Text('ID по возрастанию')),
                      const DropdownMenuItem(value: '-id', child: Text('ID по убыванию')),
                      if (widget.config.fields.any((e) => e.name == 'name'))
                        const DropdownMenuItem(value: 'name', child: Text('По названию')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      n.sort = value;
                      n.load();
                    },
                  ),
                  FilledButton.icon(
                    onPressed: () => _openForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить'),
                  ),
                  if (n.selected.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: n.removeSelected,
                      icon: const Icon(Icons.delete_outline),
                      label: Text('Удалить (${n.selected.length})'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: _body(n)),
              if (n.result != null && !n.loading) _pagination(n),
            ],
          ),
        );
      },
    );
  }

  Widget _body(CrudNotifier n) {
    if (n.loading) return const LoadingState();
    if (n.error != null) return ErrorState(message: n.error!, onRetry: n.load);
    final result = n.result;
    if (result == null || result.items.isEmpty) return const EmptyState();
    final narrow = MediaQuery.sizeOf(context).width < 850;
    if (narrow) {
      return ListView.builder(
        itemCount: result.items.length,
        itemBuilder: (context, index) => _card(n, result.items[index]),
      );
    }
    return SingleChildScrollView(
      child: DataTable(
        columns: [
          const DataColumn(label: Text('')),
          ...widget.config.listFields.map((name) => DataColumn(label: Text(widget.config.field(name).label))),
          const DataColumn(label: Text('Действия')),
        ],
        rows: result.items.map((record) {
          final id = record['id'].toString();
          return DataRow(
            cells: [
              DataCell(Checkbox(value: n.selected.contains(id), onChanged: (v) => n.toggle(id, v ?? false))),
              ...widget.config.listFields.map((name) => DataCell(Text(_value(record, widget.config.field(name))))),
              DataCell(_actions(n, record)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _card(CrudNotifier n, Map<String, dynamic> record) {
    final id = record['id'].toString();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(value: n.selected.contains(id), onChanged: (v) => n.toggle(id, v ?? false)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.config.listFields
                    .map((name) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('${widget.config.field(name).label}: ${_value(record, widget.config.field(name))}'),
                        ))
                    .toList(),
              ),
            ),
            _actions(n, record),
          ],
        ),
      ),
    );
  }

  Widget _actions(CrudNotifier n, Map<String, dynamic> record) {
    final id = record['id'].toString();
    final deleted = record['deleted'] == true;
    final admin = context.read<AppStore>().role == 'admin';
    return Wrap(
      spacing: 2,
      children: [
        if (!deleted)
          IconButton(onPressed: () => _openForm(record), icon: const Icon(Icons.edit_outlined)),
        if (!deleted)
          IconButton(onPressed: () => n.remove(id), icon: const Icon(Icons.archive_outlined)),
        if (deleted)
          IconButton(onPressed: () => n.restore(id), icon: const Icon(Icons.restore)),
        if (admin)
          IconButton(onPressed: () => _confirmHardDelete(n, id), icon: const Icon(Icons.delete_forever)),
      ],
    );
  }

  Widget _pagination(CrudNotifier n) {
    final result = n.result!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: result.page > 1
              ? () {
                  n.page--;
                  n.load();
                }
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text('${result.page} / ${result.totalPages} · ${result.totalItems}'),
        IconButton(
          onPressed: result.page < result.totalPages
              ? () {
                  n.page++;
                  n.load();
                }
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: n.perPage,
          items: const [10, 20, 50].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
          onChanged: (value) {
            if (value == null) return;
            n.perPage = value;
            n.page = 1;
            n.load();
          },
        ),
      ],
    );
  }

  String _value(Map<String, dynamic> record, FieldSpec field) {
    if (field.kind == FieldKind.relation) {
      final expand = record['expand'];
      if (expand is Map && expand[field.name] != null) {
        final value = expand[field.name];
        if (value is List) {
          return value.map((e) => e is Map ? _recordName(Map<String, dynamic>.from(e)) : '$e').join(', ');
        }
        if (value is Map) return _recordName(Map<String, dynamic>.from(value));
      }
    }
    final value = record[field.name];
    if (value == null || value == '') return '—';
    if (value is List) return value.join(', ');
    if (field.kind == FieldKind.number && value is num) return value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
    return '$value';
  }

  String _recordName(Map<String, dynamic> record) {
    return record['name']?.toString() ??
        record['number']?.toString() ??
        record['email']?.toString() ??
        record['id']?.toString() ??
        '—';
  }

  Future<void> _confirmHardDelete(CrudNotifier n, String id) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Удалить навсегда?'),
            content: const Text('Запись нельзя будет восстановить.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
            ],
          ),
        ) ??
        false;
    if (ok) await n.remove(id, hard: true);
  }

  Future<void> _openForm([Map<String, dynamic>? record]) async {
    final api = context.read<AppStore>().api;
    final options = <String, List<Map<String, dynamic>>>{};
    for (final field in widget.config.fields.where((e) => e.kind == FieldKind.relation)) {
      final collection = field.relationCollection!;
      try {
        final result = await api.list(
          collection,
          perPage: 200,
          filter: collection == 'users' ? null : 'deleted=false',
        );
        options[field.name] = result.items;
      } catch (_) {
        options[field.name] = [];
      }
    }
    if (!mounted) return;
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _EntityFormDialog(config: widget.config, record: record, options: options),
    );
    if (data == null) return;
    try {
      await notifier!.save(record?['id']?.toString(), data);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}

class _EntityFormDialog extends StatefulWidget {
  final EntityConfig config;
  final Map<String, dynamic>? record;
  final Map<String, List<Map<String, dynamic>>> options;

  const _EntityFormDialog({required this.config, required this.record, required this.options});

  @override
  State<_EntityFormDialog> createState() => _EntityFormDialogState();
}

class _EntityFormDialogState extends State<_EntityFormDialog> {
  final formKey = GlobalKey<FormState>();
  final controllers = <String, TextEditingController>{};
  final values = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    for (final field in widget.config.fields) {
      final initial = widget.record?[field.name];
      if (field.kind == FieldKind.text ||
          field.kind == FieldKind.multiline ||
          field.kind == FieldKind.email ||
          field.kind == FieldKind.number) {
        controllers[field.name] = TextEditingController(text: initial?.toString() ?? '');
      } else if (field.multiple) {
        values[field.name] = initial is List ? initial.map((e) => e.toString()).toList() : <String>[];
      } else {
        values[field.name] = initial;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.record == null ? 'Добавить ${widget.config.singular}' : 'Редактировать'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.config.fields.map(_field).toList(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        FilledButton(onPressed: _save, child: const Text('Сохранить')),
      ],
    );
  }

  Widget _field(FieldSpec field) {
    if (field.kind == FieldKind.select) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          initialValue: values[field.name]?.toString(),
          decoration: InputDecoration(labelText: field.label),
          items: field.options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          validator: (v) => field.requiredField && (v == null || v.isEmpty) ? 'Выберите значение' : null,
          onChanged: (value) => values[field.name] = value,
        ),
      );
    }
    if (field.kind == FieldKind.relation) {
      final options = widget.options[field.name] ?? [];
      if (field.multiple) {
        final selected = values[field.name] as List<String>;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FormField<List<String>>(
            initialValue: selected,
            validator: (v) => field.requiredField && (v == null || v.isEmpty) ? 'Выберите значение' : null,
            builder: (state) => InputDecorator(
              decoration: InputDecoration(labelText: field.label, errorText: state.errorText),
              child: Wrap(
                spacing: 6,
                children: options.map((record) {
                  final id = record['id'].toString();
                  return FilterChip(
                    label: Text(_name(record)),
                    selected: selected.contains(id),
                    onSelected: (value) {
                      setState(() {
                        value ? selected.add(id) : selected.remove(id);
                        state.didChange(List<String>.from(selected));
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          initialValue: values[field.name]?.toString().isEmpty == false ? values[field.name]?.toString() : null,
          decoration: InputDecoration(labelText: field.label),
          items: options
              .map((record) => DropdownMenuItem(value: record['id'].toString(), child: Text(_name(record))))
              .toList(),
          validator: (v) => field.requiredField && (v == null || v.isEmpty) ? 'Выберите значение' : null,
          onChanged: (value) => values[field.name] = value,
        ),
      );
    }
    if (field.kind == FieldKind.boolean) {
      return SwitchListTile(
        value: values[field.name] == true,
        title: Text(field.label),
        onChanged: (value) => setState(() => values[field.name] = value),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controllers[field.name],
        maxLines: field.kind == FieldKind.multiline ? 3 : 1,
        keyboardType: field.kind == FieldKind.number ? const TextInputType.numberWithOptions(decimal: true) : null,
        decoration: InputDecoration(labelText: field.label),
        validator: (value) {
          if (field.kind == FieldKind.email) return Validators.email(value);
          if (field.kind == FieldKind.number) {
            return Validators.number(value, field.label, min: field.min, max: field.max);
          }
          if (field.requiredField) return Validators.requiredText(value, field.label);
          return null;
        },
      ),
    );
  }

  String _name(Map<String, dynamic> record) {
    return record['name']?.toString() ?? record['number']?.toString() ?? record['email']?.toString() ?? record['id'].toString();
  }

  void _save() {
    if (!formKey.currentState!.validate()) return;
    final data = <String, dynamic>{};
    for (final field in widget.config.fields) {
      if (controllers.containsKey(field.name)) {
        final text = controllers[field.name]!.text.trim();
        if (field.kind == FieldKind.number) {
          final value = double.parse(text.replaceAll(',', '.'));
          data[field.name] = value == value.roundToDouble() ? value.toInt() : value;
        } else {
          data[field.name] = text;
        }
      } else {
        data[field.name] = values[field.name];
      }
    }
    Navigator.pop(context, data);
  }
}
