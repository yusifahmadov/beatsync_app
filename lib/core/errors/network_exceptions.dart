abstract class NetworkException implements Exception {
  final String? message;
  final StackTrace? stackTrace;
  final dynamic error;

  NetworkException({this.message, this.stackTrace, this.error});

  @override
  String toString() {
    String result = runtimeType.toString();
    if (message != null) {
      result += ': $message';
    }
    return result;
  }
}

class NoInternetException extends NetworkException {
  NoInternetException(
      {super.message = 'No internet connection detected.',
      super.stackTrace,
      super.error});
}

class TimeoutException extends NetworkException {
  TimeoutException(
      {super.message = 'The connection has timed out.', super.stackTrace, super.error});
}

class BadRequestException extends NetworkException {
  final dynamic errors;
  BadRequestException(
      {super.message = 'Bad request.', this.errors, super.stackTrace, super.error});
}

class UnauthorizedException extends NetworkException {
  UnauthorizedException(
      {super.message = 'Unauthorized access.', super.stackTrace, super.error});
}

class ForbiddenException extends NetworkException {
  ForbiddenException(
      {super.message = 'Forbidden access.', super.stackTrace, super.error});
}

class NotFoundException extends NetworkException {
  NotFoundException(
      {super.message = 'The requested resource was not found.',
      super.stackTrace,
      super.error});
}

class ConflictException extends NetworkException {
  ConflictException(
      {super.message = 'Conflict occurred.', super.stackTrace, super.error});
}

class ServerException extends NetworkException {
  ServerException(
      {super.message = 'An internal server error occurred.',
      super.stackTrace,
      super.error});
}

class DataParsingException extends NetworkException {
  DataParsingException(
      {super.message = 'Error parsing data.', super.stackTrace, super.error});
}

class UnexpectedException extends NetworkException {
  UnexpectedException(
      {super.message = 'An unexpected error occurred.', super.stackTrace, super.error});
}
