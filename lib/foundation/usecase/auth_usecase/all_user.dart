import 'package:flutter_blog_app/core/error/failure.dart';
import 'package:flutter_blog_app/core/usecase/usecase.dart';
import 'package:flutter_blog_app/foundation/entities/user_entity/user.dart';
import 'package:flutter_blog_app/foundation/repositories/auth_repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AllUser implements UseCase<List<User>, NoParams> {
  final AuthRepository authRepository;
  const AllUser(this.authRepository);
  @override
  Future<Either<Failure, List<User>>> call(NoParams params) async {
    return await authRepository.getUserList();
  }
}
