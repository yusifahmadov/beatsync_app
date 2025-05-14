import 'package:beatsync_app/features/authentication/domain/entities/token_entity.dart';

class TokenModel extends TokenEntity {
  const TokenModel({
    required super.accessToken,
    required super.expiresAt,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    if (json['token'] == null || json['expires_at'] == null) {
      throw const FormatException(
          'Missing required fields in Token JSON (token, expires_at)');
    }
    return TokenModel(
      accessToken: json['token'] as String,
      expiresAt: json['expires_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'expires_at': expiresAt,
    };
  }
}
