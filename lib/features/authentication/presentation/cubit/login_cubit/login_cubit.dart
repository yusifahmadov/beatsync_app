import 'package:beatsync_app/features/authentication/domain/usecases/login_usecase.dart';
import 'package:beatsync_app/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:beatsync_app/features/authentication/presentation/cubit/login_cubit/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUsecase _loginUsecase;
  final AuthCubit _authCubit;

  LoginCubit({
    required LoginUsecase loginUsecase,
    required AuthCubit authCubit,
  })  : _loginUsecase = loginUsecase,
        _authCubit = authCubit,
        super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    final result = await _loginUsecase(LoginParams(email: email, password: password));
    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (user) {
        _authCubit.loggedIn(user);
        emit(LoginSuccess(user));
      },
    );
  }
}
