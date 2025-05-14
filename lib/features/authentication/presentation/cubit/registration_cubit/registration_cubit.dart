

import 'package:beatsync_app/core/errors/failures.dart';
import 'package:beatsync_app/features/authentication/domain/usecases/params/register_params.dart';
import 'package:beatsync_app/features/authentication/domain/usecases/register_usecase.dart';

import 'package:beatsync_app/features/authentication/presentation/cubit/registration_cubit/registration_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterCubit extends Cubit<RegistrationState> {
  final RegisterUsecase _registerUsecase;



  RegisterCubit(this._registerUsecase)
      : super(RegistrationInitial()); 

  Future<void> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    emit(RegistrationLoading());

    final params = RegisterParams(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    final result = await _registerUsecase(params);

    result.fold(
      (failure) {
        String errorMessage = failure.message;

        if (failure is EmailAlreadyInUseFailure) {
          errorMessage = 'This email address is already registered.';
        }
        emit(RegistrationFailure(errorMessage));
      },
      (user) {




        emit(const RegistrationSuccess());
      },
    );
  }
}
