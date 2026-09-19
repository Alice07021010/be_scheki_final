class AdvisorResult {
  final String category;
  final String hardness;
  final String text;

  const AdvisorResult({required this.category, required this.hardness, required this.text});
}

class AdvisorService {
  static AdvisorResult pick({
    required bool child,
    required bool sensitive,
    required bool electric,
  }) {
    final category = child ? 'Детские' : electric ? 'Электрические' : 'Мануальные';
    final hardness = sensitive || child ? 'Мягкая' : 'Средняя';
    final text = 'Подойдёт категория «$category» и $hardness жёсткость.';
    return AdvisorResult(category: category, hardness: hardness, text: text);
  }
}
