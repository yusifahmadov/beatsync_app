class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException(
    this.message, {
    this.statusCode,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'ServerException: $statusCode - $message';
    }
    return 'ServerException: $message';
  }
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}


class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}
