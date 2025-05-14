import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.stackTrace]);

  @override
  List<Object?> get props => [message, stackTrace];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(
    String message, {
    this.statusCode,
    StackTrace? stackTrace,
  }) : super(message, stackTrace);

  @override
  List<Object?> get props => [message, statusCode, stackTrace];
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.stackTrace]);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure(super.message, [super.stackTrace]);
}

class ParsingFailure extends Failure {
  const ParsingFailure(super.message, [super.stackTrace]);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, [super.stackTrace]);
}

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure(super.message, [super.stackTrace]);
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure(super.message, [super.stackTrace]);
}
