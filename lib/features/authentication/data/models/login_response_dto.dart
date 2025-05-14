import './user_model.dart'; 

class LoginResponseDTO {
  final String token;
  final String expiresAt;
  final UserDTO user;

  LoginResponseDTO({
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  factory LoginResponseDTO.fromJson(Map<String, dynamic> json) {
    if (json['token'] == null || json['expires_at'] == null || json['user'] == null) {
      throw const FormatException('Missing required fields in LoginResponse JSON');
    }
    return LoginResponseDTO(
      token: json['token'] as String,
      expiresAt: json['expires_at'] as String,
      user: UserDTO.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expires_at': expiresAt,
      'user': user.toJson(), 
    };
  }
}
