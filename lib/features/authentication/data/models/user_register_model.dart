import 'package:equatable/equatable.dart';

class UserRegisterModel extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;
  final String firstName;
  final String lastName;

  const UserRegisterModel({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
      'first_name': firstName,
      'last_name': lastName,
    };
  }

  @override
  List<Object?> get props => [
        email,
        password,
        confirmPassword,
        firstName,
        lastName,
      ];
}
