class UserModel {
  final String id;
  final String email;
  final bool isAdmin;
  final String createdAt;
  final String? name;
  final String? phone;
  final int diagnosisCount;

  UserModel({
    required this.id,
    required this.email,
    required this.isAdmin,
    required this.createdAt,
    this.name,
    this.phone,
    this.diagnosisCount = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, {int diagnosisCount = 0}) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      createdAt: map['createdAt'] ?? '',
      name: map['name'],
      phone: map['phone'],
      diagnosisCount: diagnosisCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'isAdmin': isAdmin,
      'createdAt': createdAt,
      'name': name,
      'phone': phone,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    bool? isAdmin,
    String? createdAt,
    String? name,
    String? phone,
    int? diagnosisCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      diagnosisCount: diagnosisCount ?? this.diagnosisCount,
    );
  }
}