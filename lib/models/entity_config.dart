enum FieldKind { text, number, email, select, relation, boolean, multiline }

class FieldSpec {
  final String name;
  final String label;
  final FieldKind kind;
  final bool requiredField;
  final double? min;
  final double? max;
  final List<String> options;
  final String? relationCollection;
  final bool multiple;
  final bool searchable;

  const FieldSpec({
    required this.name,
    required this.label,
    this.kind = FieldKind.text,
    this.requiredField = false,
    this.min,
    this.max,
    this.options = const [],
    this.relationCollection,
    this.multiple = false,
    this.searchable = false,
  });
}

class EntityConfig {
  final String collection;
  final String title;
  final String singular;
  final List<FieldSpec> fields;
  final List<String> listFields;

  const EntityConfig({
    required this.collection,
    required this.title,
    required this.singular,
    required this.fields,
    required this.listFields,
  });

  FieldSpec field(String name) => fields.firstWhere((e) => e.name == name);
}
