class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final DateTime? registerDate;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.registerDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      registerDate: json['registerDate'] != null ? DateTime.tryParse(json['registerDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'registerDate': registerDate?.toIso8601String(),
    };
  }
}
