part of 'auth_bloc.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final User user;
  const AuthSuccess(this.user);
}

final class AuthSignOutSuccess extends AuthState {}

final class AuthFailure extends AuthState {
  final String error;
  const AuthFailure(this.error);
}
