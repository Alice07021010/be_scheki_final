class PriceResult {
  final double subtotal;
  final double discount;
  final double delivery;
  final double total;

  const PriceResult({
    required this.subtotal,
    required this.discount,
    required this.delivery,
    required this.total,
  });
}

class PricingService {
  static PriceResult calculate(List<({double price, int quantity})> items) {
    var subtotal = 0.0;
    var count = 0;
    for (final item in items) {
      subtotal += item.price * item.quantity;
      count += item.quantity;
    }
    var percent = 0.0;
    if (count >= 5) {
      percent = 0.10;
    } else if (count >= 3) {
      percent = 0.05;
    }
    final discount = subtotal * percent;
    final afterDiscount = subtotal - discount;
    final delivery = afterDiscount >= 3000 || subtotal == 0 ? 0.0 : 199.0;
    return PriceResult(
      subtotal: subtotal,
      discount: discount,
      delivery: delivery,
      total: afterDiscount + delivery,
    );
  }
}
