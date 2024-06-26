import 'package:flutter_blog_app/core/error/exception.dart';
import 'package:flutter_blog_app/core/error/failure.dart';
import 'package:flutter_blog_app/core/network/check_network_connection.dart';
import 'package:flutter_blog_app/foundation/api/auth_data_source/auth_remote_data_source.dart';
import 'package:flutter_blog_app/foundation/model/auth_model/user_model.dart';
import 'package:flutter_blog_app/foundation/repositories/auth_repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import '../../entities/user_entity/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  const AuthRepositoryImpl(this.remoteDataSource, this.connectionChecker);

  Future<Either<Failure, User>> _getUser(
    Future<User> Function() fn,
  ) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure('No internet connection!'));
      }
      final user = await fn();
      return right(user);
    } on ServerExceptions catch (e) {
      return left(Failure(e.excMessage));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.signInWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final session = remoteDataSource.currentUserSession;
        if (session == null) {
          return left(Failure('User not logged in!!'));
        }
        return right(UserModel(
            id: session.user.id, email: session.user.email ?? '', name: ''));
      }
      final user = await remoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(Failure('User not logged in!!'));
      }
      return right(user);
    } on ServerExceptions catch (e) {
      return left(Failure(e.excMessage));
    }
  }

  @override
  Future<Either<Failure, String>> signOut() async {
    try {
      return right(await remoteDataSource.signOutUser());
    } on ServerExceptions catch (e) {
      return left(Failure(e.excMessage));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getUserList() async {
    try {
      return right(await remoteDataSource.getAllUserData());
    } on ServerExceptions catch (e) {
      return left(Failure(e.excMessage));
    }
  }
}
