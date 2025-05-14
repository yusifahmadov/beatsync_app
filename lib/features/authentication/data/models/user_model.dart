import '../../domain/entities/user_entity.dart';



class UserDTO extends UserEntity {
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final String? phone;
  final String? createdAt;
  final String? updatedAt;

  const UserDTO({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });


  factory UserDTO.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null ||
        json['email'] == null ||
        json['first_name'] == null ||
        json['last_name'] == null) {
      throw const FormatException('Missing required fields in User JSON');
    }
    return UserDTO(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      phone: json['phone'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (phone != null) 'phone': phone,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }


  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
    );
  }
}
