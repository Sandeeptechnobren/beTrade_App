class CategoryModel {
  final String uuid;
  final String name;

  CategoryModel({
    required this.uuid,
    required this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      uuid: json['uuid'] ?? "",
      name: json['name'] ?? "",
    );
  }
}