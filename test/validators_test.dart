import 'package:be_scheki_final/services/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('обязательное поле', () {
    expect(Validators.requiredText('', 'Название'), isNotNull);
  });

  test('заполненное обязательное поле', () {
    expect(Validators.requiredText('Щётка', 'Название'), isNull);
  });

  test('корректный email', () {
    expect(Validators.email('user@example.com'), isNull);
  });

  test('некорректный email', () {
    expect(Validators.email('userexample.com'), isNotNull);
  });

  test('число меньше минимума', () {
    expect(Validators.number('0', 'Цена', min: 1), isNotNull);
  });

  test('число в диапазоне', () {
    expect(Validators.number('3', 'Оценка', min: 1, max: 5), isNull);
  });
}
