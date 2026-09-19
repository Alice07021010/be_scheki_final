import 'package:flutter/material.dart';

import '../services/advisor_service.dart';

class AdvisorScreen extends StatefulWidget {
  const AdvisorScreen({super.key});

  @override
  State<AdvisorScreen> createState() => _AdvisorScreenState();
}

class _AdvisorScreenState extends State<AdvisorScreen> {
  bool child = false;
  bool sensitive = false;
  bool electric = false;
  AdvisorResult? result;

  void pick() {
    setState(() {
      result = AdvisorService.pick(child: child, sensitive: sensitive, electric: electric);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Подбор щётки', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 14),
                  SwitchListTile(value: child, onChanged: (v) => setState(() => child = v), title: const Text('Для ребёнка')),
                  SwitchListTile(value: sensitive, onChanged: (v) => setState(() => sensitive = v), title: const Text('Чувствительные дёсны')),
                  SwitchListTile(value: electric, onChanged: (v) => setState(() => electric = v), title: const Text('Хочу электрическую щётку')),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: pick, child: const Text('Подобрать')),
                  if (result != null) ...[
                    const SizedBox(height: 18),
                    Text(result!.text, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
