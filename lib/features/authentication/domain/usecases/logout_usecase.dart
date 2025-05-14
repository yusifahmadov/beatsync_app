import 'package:beatsync_app/core/errors/failures.dart';
import 'package:beatsync_app/core/usecases/usecase.dart';
import 'package:beatsync_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LogoutUsecase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}
