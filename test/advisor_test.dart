import 'package:be_scheki_final/services/advisor_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('для ребёнка выбирается мягкая', () {
    final result = AdvisorService.pick(child: true, sensitive: false, electric: false);
    expect(result.category, 'Детские');
    expect(result.hardness, 'Мягкая');
  });

  test('для чувствительных дёсен выбирается мягкая', () {
    final result = AdvisorService.pick(child: false, sensitive: true, electric: false);
    expect(result.hardness, 'Мягкая');
  });

  test('электрическая категория', () {
    final result = AdvisorService.pick(child: false, sensitive: false, electric: true);
    expect(result.category, 'Электрические');
  });
}
