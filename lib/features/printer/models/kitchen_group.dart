/// A printer group from the website's Settings → Kitchen printers: the
/// item categories whose kitchen tickets go to one printer.
class KitchenGroup {
  final String id;
  final String name;
  final List<String> categoryIds;

  const KitchenGroup({
    required this.id,
    required this.name,
    this.categoryIds = const [],
  });

  factory KitchenGroup.fromJson(Map<String, dynamic> json) {
    return KitchenGroup(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      categoryIds: List<dynamic>.from(
        json['categoryIds'] ?? const [],
      ).map((id) => id.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'categoryIds': categoryIds,
  };
}
