import 'package:beatsync_app/core/errors/failures.dart';
import 'package:beatsync_app/core/usecases/usecase.dart';
import 'package:beatsync_app/features/authentication/domain/entities/user_entity.dart';
import 'package:beatsync_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class GetCurrentUserUsecase implements UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUsecase(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
