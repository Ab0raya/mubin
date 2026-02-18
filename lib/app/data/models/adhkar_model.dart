class AdhkarCategory {
  final String category;
  final List<AdhkarItem> items;

  AdhkarCategory({required this.category, required this.items});

  factory AdhkarCategory.fromMap(String key, Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<AdhkarItem> itemsList = list
        .map((i) => AdhkarItem.fromJson(i))
        .toList();

    return AdhkarCategory(category: key, items: itemsList);
  }
}

class AdhkarItem {
  final String text;
  final int count;
  final String? description;
  final String? reference;

  AdhkarItem({
    required this.text,
    required this.count,
    this.description,
    this.reference,
  });

  factory AdhkarItem.fromJson(Map<String, dynamic> json) {
    return AdhkarItem(
      text: json['content'] ?? '',
      count: int.tryParse(json['count'].toString()) ?? 1,
      description: json['description'],
      reference: json['reference'],
    );
  }
}
