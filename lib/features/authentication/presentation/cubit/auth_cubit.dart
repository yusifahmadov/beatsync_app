

import 'package:beatsync_app/core/usecases/usecase.dart';
import 'package:beatsync_app/features/authentication/domain/entities/user_entity.dart';
import 'package:beatsync_app/features/authentication/domain/repositories/auth_repository.dart'; 
import 'package:beatsync_app/features/authentication/domain/usecases/get_auth_status_usecase.dart';
import 'package:beatsync_app/features/authentication/domain/usecases/get_current_user_usecase.dart'; 
import 'package:beatsync_app/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:beatsync_app/features/authentication/presentation/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final GetAuthStatusUsecase _getAuthStatusUsecase;
  final GetCurrentUserUsecase _getCurrentUserUsecase; 
  final LogoutUsecase _logoutUsecase;

  AuthCubit({
    required GetAuthStatusUsecase getAuthStatusUsecase,
    required GetCurrentUserUsecase getCurrentUserUsecase, 
    required LogoutUsecase logoutUsecase,
  })  : _getAuthStatusUsecase = getAuthStatusUsecase,
        _getCurrentUserUsecase = getCurrentUserUsecase, 
        _logoutUsecase = logoutUsecase,
        super(AuthInitial());

  Future<void> checkAuthStatus() async {

    if (state is! Authenticated || (state as Authenticated).user == null) {
      emit(AuthLoading());
    }
    final statusResult = await _getAuthStatusUsecase(NoParams());

    await statusResult.fold(
      (failure) async {
        emit(Unauthenticated());
      },
      (status) async {
        if (status == AuthStatus.authenticated) {

          if (state is Authenticated && (state as Authenticated).user != null) {
            emit(
                Authenticated(user: (state as Authenticated).user)); 
          } else {

            await loadUserProfile();



            if (state is! Authenticated) {
              emit(Authenticated(user: null));
            }
          }
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> loadUserProfile() async {






    if (state is! Authenticated) return;
    final currentUser = (state as Authenticated).user;




    final failureOrUser = await _getCurrentUserUsecase(NoParams());
    failureOrUser.fold(
      (failure) {


        emit(Authenticated(user: null));
        print("AuthCubit: Failed to load user profile: $failure"); 
      },
      (user) {

        emit(Authenticated(user: user));
      },
    );
  }

  void loggedIn(UserEntity user) {
    emit(Authenticated(user: user));
  }

  Future<void> loggedOut() async {
    emit(AuthLoading());
    final result = await _logoutUsecase(NoParams());
    result.fold(
      (failure) {
        emit(Unauthenticated());
      },
      (_) {
        emit(Unauthenticated());
      },
    );
  }
}
