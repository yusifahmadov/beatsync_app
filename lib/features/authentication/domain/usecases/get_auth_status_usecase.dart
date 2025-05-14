import 'package:beatsync_app/core/errors/failures.dart';
import 'package:beatsync_app/core/usecases/usecase.dart';
import 'package:beatsync_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class GetAuthStatusUsecase implements UseCase<AuthStatus, NoParams> {
  final AuthRepository repository;

  GetAuthStatusUsecase(this.repository);

  @override
  Future<Either<Failure, AuthStatus>> call(NoParams params) async {
    return await repository.getAuthStatus();
  }
}
