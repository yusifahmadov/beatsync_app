class LogoutRequestDTO {
  final String token;

  LogoutRequestDTO({required this.token});

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}
