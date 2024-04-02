import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blog_app/core/common/cubit/app_user/app_user_cubit.dart';
import 'package:flutter_blog_app/core/usecase/usecase.dart';
import 'package:flutter_blog_app/foundation/entities/user_entity/user.dart';
import 'package:flutter_blog_app/foundation/usecase/auth_usecase/current_user.dart';
import 'package:flutter_blog_app/foundation/usecase/auth_usecase/sign_out.dart';
import 'package:flutter_blog_app/foundation/usecase/auth_usecase/user_sign_in.dart';
import 'package:flutter_blog_app/foundation/usecase/auth_usecase/user_sign_up.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserSignIn _userSignIn;
  final CurrentUser _currentUser;
  final UserSignOut _userSignOut;
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
    required UserSignOut userSignOut,
    required AppUserCubit appUserCubit,
  })  : _userSignUp = userSignUp,
        _userSignIn = userSignIn,
        _currentUser = currentUser,
        _appUserCubit = appUserCubit,
        _userSignOut = userSignOut,
        super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignUp>((event, emit) async {
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
    on<AuthSignOut>((event, emit) async {
      final res = await _userSignOut(NoParams());
      res.fold((l) => emit(AuthFailure(l.failMessage)), (r) {
        _appUserCubit.updatedUser(null);
        emit(AuthSignOutSuccess());
      });
    });
  }
}
