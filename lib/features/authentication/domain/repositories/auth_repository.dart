import 'package:beatsync_app/core/errors/failures.dart';
import 'package:beatsync_app/features/authentication/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

enum AuthStatus {
  authenticated,
  unauthenticated,
  unknown,
}

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, AuthStatus>> getAuthStatus();

  Future<Either<Failure, UserEntity?>> getCurrentUser();
}
