class Validators {
  static String? requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Заполните поле «$label»';
    return null;
  }

  static String? email(String? value) {
    final required = requiredText(value, 'E-mail');
    if (required != null) return required;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim());
    return ok ? null : 'Введите корректный e-mail';
  }

  static String? number(String? value, String label, {double? min, double? max}) {
    final required = requiredText(value, label);
    if (required != null) return required;
    final parsed = double.tryParse(value!.replaceAll(',', '.'));
    if (parsed == null) return 'Введите число';
    if (min != null && parsed < min) return 'Минимум: ${_pretty(min)}';
    if (max != null && parsed > max) return 'Максимум: ${_pretty(max)}';
    return null;
  }

  static String _pretty(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toString();
}
