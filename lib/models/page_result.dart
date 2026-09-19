class PageResult {
  final int page;
  final int perPage;
  final int totalItems;
  final int totalPages;
  final List<Map<String, dynamic>> items;

  const PageResult({
    required this.page,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
    required this.items,
  });

  factory PageResult.fromJson(Map<String, dynamic> json) {
    return PageResult(
      page: json['page'] as int? ?? 1,
      perPage: json['perPage'] as int? ?? 10,
      totalItems: json['totalItems'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }
}
