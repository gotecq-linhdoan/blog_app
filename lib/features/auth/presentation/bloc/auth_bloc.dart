import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blog_app/core/common/cubit/app_user/app_user_cubit.dart';
import 'package:flutter_blog_app/core/usecase/usecase.dart';
import 'package:flutter_blog_app/core/common/entity/user.dart';
import 'package:flutter_blog_app/features/auth/domain/usecases/current_user.dart';
import 'package:flutter_blog_app/features/auth/domain/usecases/user_sign_in.dart';
import 'package:flutter_blog_app/features/auth/domain/usecases/user_sign_up.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserSignIn _userSignIn;
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;

  void _emitAuthSuccess(
    User user,
    Emitter<AuthState> emit,
  ) {
    _appUserCubit.updatedUser(user);
    emit(AuthSuccess(user));
  }

  AuthBloc({
    required UserSignUp userSignUp,
    required UserSignIn userSignIn,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
  })  : _userSignUp = userSignUp,
        _userSignIn = userSignIn,
        _currentUser = currentUser,
        _appUserCubit = appUserCubit,
        super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignUp>((event, emit) async {
      emit(AuthLoading());
      final res = await _userSignUp(UserSignUpParams(
        email: event.email,
        name: event.name,
        password: event.password,
      ));
      res.fold(
        (l) => emit(AuthFailure(l.failMessage)),
        (user) => _emitAuthSuccess(user, emit),
      );
    });
    on<AuthSignIn>((event, emit) async {
      emit(AuthLoading());
      final res = await _userSignIn(UserSignInParams(
        email: event.email,
        password: event.password,
      ));
      res.fold(
        (l) => emit(AuthFailure(l.failMessage)),
        (user) => _emitAuthSuccess(user, emit),
      );
    });
    on<AuthIsUserLoggedIn>((event, emit) async {
      final res = await _currentUser(NoParams());
      res.fold(
        (l) => emit(AuthFailure(l.failMessage)),
        (user) => _emitAuthSuccess(user, emit),
      );
    });
  }
}
