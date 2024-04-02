import 'package:flutter_blog_app/core/error/failure.dart';
import 'package:flutter_blog_app/core/usecase/usecase.dart';
import 'package:flutter_blog_app/foundation/repositories/auth_repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserSignOut implements UseCase<String, NoParams> {
  final AuthRepository authRepository;

  UserSignOut(this.authRepository);
  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await authRepository.signOut();
  }
}
