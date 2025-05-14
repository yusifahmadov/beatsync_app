import 'package:beatsync_app/core/errors/failures.dart';
import 'package:beatsync_app/core/usecases/usecase.dart';
import 'package:beatsync_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

import './params/register_params.dart';

class RegisterUsecase implements UseCase<void, RegisterParams> {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(RegisterParams params) async {
    return await repository.register(
      email: params.email,
      password: params.password,
      firstName: params.firstName,
      lastName: params.lastName,
    );
  }
}
