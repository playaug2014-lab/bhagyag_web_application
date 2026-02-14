class ServiceTypeModel {
  final int id;
  final String name;
  final String imageUrl;

  ServiceTypeModel({required this.id, required this.name, required this.imageUrl});

  factory ServiceTypeModel.fromJson(Map<String, dynamic> json) {
    return ServiceTypeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['imageURl'] ?? '',
    );
  }
}