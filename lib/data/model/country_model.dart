class CountryModel {
  final int id;
  final String name;
  final String phoneCode;
  final String flag;

  CountryModel({
    required this.id,
    required this.name,
    required this.phoneCode,
    required this.flag,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'],
      name: json['name'],
      phoneCode: json['phone_code'],
      flag: json['flag'],
    );
  }
}