class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final bool isActive;
  final int itemCount;
  final int colorIndex;
  final String? shape;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.itemCount = 0,
    this.colorIndex = 0,
    this.shape,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    description: json['description']?.toString(),
    isActive: json['isActive'] != false,
    itemCount: int.tryParse(json['itemCount']?.toString() ?? '') ?? 0,
    colorIndex: int.tryParse(json['colorIndex']?.toString() ?? '') ?? 0,
    shape: json['shape']?.toString(),
  );
}
