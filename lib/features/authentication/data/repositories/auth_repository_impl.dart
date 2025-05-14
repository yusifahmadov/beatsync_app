import 'package:beatsync_app/core/errors/exceptions.dart';
import 'package:beatsync_app/core/errors/failures.dart';
import 'package:beatsync_app/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:beatsync_app/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:beatsync_app/features/authentication/data/models/user_register_model.dart';
import 'package:beatsync_app/features/authentication/domain/entities/user_entity.dart';
import 'package:beatsync_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';



class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;


  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,

  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final loginResponse =
          await remoteDataSource.login(email: email, password: password);

      try {
        await localDataSource.cacheLoginResponse(loginResponse);
      } on CacheException catch (e) {
        print("Warning: Failed to cache login response: ${e.message}");
      }

      final userEntity = loginResponse.user.toEntity();
      return Right(userEntity);
    } on ServerException catch (e) {
      if (e.statusCode == 401) {
        return Left(InvalidCredentialsFailure(e.message));
      }

      if ((e.statusCode == 400 &&
              e.message.toLowerCase().contains('email already in use')) ||
          (e.statusCode == 400 &&
              e.message.toLowerCase().contains('email already exist'))) {
        return Left(EmailAlreadyInUseFailure(e.message));
      }
      return Left(ServerFailure('Login failed: ${e.message}', statusCode: e.statusCode));
    } catch (e) {
      print(e);
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}',
          statusCode: (e is ServerException ? e.statusCode : null)));
    }
  }

  @override
  Future<Either<Failure, void>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final userRegisterModel = UserRegisterModel(
        email: email,
        password: password,
        confirmPassword: password,
        firstName: firstName,
        lastName: lastName,
      );

      await remoteDataSource.register(userRegisterModel: userRegisterModel);
      return const Right(null);
    } on ServerException catch (e) {
      if ((e.statusCode == 400 &&
              e.message.toLowerCase().contains('email already in use')) ||
          (e.statusCode == 400 &&
              e.message.toLowerCase().contains('email already exist')) ||
          (e.statusCode == 400 &&
              e.message.toLowerCase().contains('user with this email already exists'))) {
        return Left(EmailAlreadyInUseFailure(e.message));
      }
      return Left(
          ServerFailure('Registration failed: ${e.message}', statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(
          'An unexpected error occurred during registration: ${e.toString()}',
          statusCode: (e is ServerException ? e.statusCode : null)));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearCachedLoginResponse();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure('Failed to clear local session data: ${e.message}'));
    } catch (e) {
      return Left(CacheFailure(
          'An unexpected error occurred clearing local session data: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthStatus>> getAuthStatus() async {
    try {
      final response = await localDataSource.getLastLoginResponse();
      if (response != null && response.token.isNotEmpty) {
        try {
          final expiryDate = DateTime.parse(response.expiresAt);
          if (expiryDate.isAfter(DateTime.now())) {
            return const Right(AuthStatus.authenticated);
          } else {
            await localDataSource.clearCachedLoginResponse();
            return const Right(AuthStatus.unauthenticated);
          }
        } catch (e) {
          print("Error parsing expiry date in getAuthStatus: $e");
          await localDataSource.clearCachedLoginResponse();
          return const Right(AuthStatus.unauthenticated);
        }
      }
      return const Right(AuthStatus.unauthenticated);
    } catch (e) {
      print("Error reading local login response in getAuthStatus: $e");
      return const Right(AuthStatus.unauthenticated);
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final response = await localDataSource.getLastLoginResponse();
      if (response != null && response.token.isNotEmpty) {
        try {
          final expiryDate = DateTime.parse(response.expiresAt);
          if (expiryDate.isAfter(DateTime.now())) {
            return Right(response.user.toEntity());
          } else {
            await localDataSource.clearCachedLoginResponse();
            return const Right(null);
          }
        } catch (e) {
          await localDataSource.clearCachedLoginResponse();
          return Left(
              ParsingFailure("Failed to parse cached user data: ${e.toString()}"));
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Could not check local session: ${e.toString()}'));
    }
  }
}
