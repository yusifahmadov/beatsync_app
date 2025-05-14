import 'package:equatable/equatable.dart';

class TokenEntity extends Equatable {
  final String accessToken;
  final String expiresAt;

  const TokenEntity({
    required this.accessToken,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [accessToken, expiresAt];
}
