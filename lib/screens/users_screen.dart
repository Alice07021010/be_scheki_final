import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../services/validators.dart';
import '../state/app_store.dart';
import '../widgets/states.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> users = [];

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
      final result = await api.list('users', perPage: 200, sort: 'name');
      if (!mounted) return;
      setState(() {
        users = result.items;
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

  Future<void> _open([Map<String, dynamic>? record]) async {
    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _UserDialog(record: record),
    );
    if (data == null) return;
    try {
      if (record == null) {
        await api.create('users', data);
      } else {
        await api.update('users', record['id'].toString(), data);
      }
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _delete(Map<String, dynamic> record) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Удалить пользователя?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    await api.delete('users', record['id'].toString());
    await _load();
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
          Row(
            children: [
              Expanded(child: Text('Пользователи', style: Theme.of(context).textTheme.headlineMedium)),
              FilledButton.icon(onPressed: () => _open(), icon: const Icon(Icons.add), label: const Text('Добавить')),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: users.isEmpty
                ? const EmptyState()
                : ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        child: ListTile(
                          title: Text(user['name']?.toString() ?? user['email']?.toString() ?? ''),
                          subtitle: Text('${user['email']} · ${_role(user['role']?.toString() ?? '')}'),
                          trailing: Wrap(
                            children: [
                              IconButton(onPressed: () => _open(user), icon: const Icon(Icons.edit_outlined)),
                              IconButton(onPressed: () => _delete(user), icon: const Icon(Icons.delete_outline)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _role(String role) {
    if (role == 'buyer') return 'Покупатель';
    if (role == 'manager') return 'Менеджер';
    return 'Администратор';
  }
}

class _UserDialog extends StatefulWidget {
  final Map<String, dynamic>? record;
  const _UserDialog({this.record});

  @override
  State<_UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<_UserDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController email;
  final password = TextEditingController();
  String role = 'buyer';

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.record?['name']?.toString() ?? '');
    email = TextEditingController(text: widget.record?['email']?.toString() ?? '');
    role = widget.record?['role']?.toString() ?? 'buyer';
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.record == null ? 'Новый пользователь' : 'Редактирование'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                validator: (v) => Validators.requiredText(v, 'Имя'),
                decoration: const InputDecoration(labelText: 'Имя'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: email,
                validator: Validators.email,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
              if (widget.record == null) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: password,
                  obscureText: true,
                  validator: (v) {
                    final required = Validators.requiredText(v, 'Пароль');
                    if (required != null) return required;
                    return v!.length < 8 ? 'Минимум 8 символов' : null;
                  },
                  decoration: const InputDecoration(labelText: 'Пароль'),
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Роль'),
                items: const [
                  DropdownMenuItem(value: 'buyer', child: Text('Покупатель')),
                  DropdownMenuItem(value: 'manager', child: Text('Менеджер')),
                  DropdownMenuItem(value: 'admin', child: Text('Администратор')),
                ],
                onChanged: (v) => role = v ?? role,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        FilledButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            final data = <String, dynamic>{
              'name': name.text.trim(),
              'email': email.text.trim(),
              'emailVisibility': true,
              'role': role,
            };
            if (widget.record == null) {
              data['password'] = password.text;
              data['passwordConfirm'] = password.text;
            }
            Navigator.pop(context, data);
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
