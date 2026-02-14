class AstrologyTypeModel {
  final int astrologyTypeId;
  final String astrologyTypeName;
  bool isChecked;
  final String description;
  final String astrologyTypeStatus;
  final String regDate;

  AstrologyTypeModel({
    required this.astrologyTypeId,
    required this.astrologyTypeName,
    this.isChecked = false,
    required this.description,
    required this.astrologyTypeStatus,
    required this.regDate,
  });

  factory AstrologyTypeModel.fromJson(Map<String, dynamic> json) {
    return AstrologyTypeModel(
      astrologyTypeId: json['astrologyTypeId'] ?? 0,
      astrologyTypeName: json['astrologyTypeName'] ?? '',
      isChecked: json['isChecked'] ?? false,
      description: json['description'] ?? '',
      astrologyTypeStatus: json['astrologyTypeStatus'] ?? '',
      regDate: json['regDate'] ?? '',
    );
  }
}