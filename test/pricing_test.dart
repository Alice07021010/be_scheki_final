import 'package:be_scheki_final/services/pricing_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('без скидки', () {
    final result = PricingService.calculate([(price: 500.0, quantity: 2)]);
    expect(result.discount, 0);
    expect(result.delivery, 199);
    expect(result.total, 1199);
  });

  test('скидка 5 процентов', () {
    final result = PricingService.calculate([(price: 500.0, quantity: 3)]);
    expect(result.discount, 75);
  });

  test('скидка 10 процентов', () {
    final result = PricingService.calculate([(price: 700.0, quantity: 5)]);
    expect(result.discount, 350);
    expect(result.delivery, 0);
  });
}
