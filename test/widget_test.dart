import 'package:be_scheki_final/screens/advisor_screen.dart';
import 'package:be_scheki_final/screens/forbidden_screen.dart';
import 'package:be_scheki_final/widgets/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('экран загрузки', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: LoadingState())));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('пустое состояние', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: EmptyState())));
    expect(find.text('Ничего не найдено'), findsOneWidget);
  });

  testWidgets('состояние ошибки', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ErrorState(message: 'Ошибка', onRetry: () {}))));
    expect(find.text('Ошибка'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
  });

  testWidgets('экран запрета доступа', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ForbiddenScreen()));
    expect(find.text('Нет доступа'), findsOneWidget);
  });

  testWidgets('экран подбора щётки', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AdvisorScreen())));
    expect(find.text('Подбор щётки'), findsOneWidget);
    expect(find.text('Подобрать'), findsOneWidget);
  });
}
