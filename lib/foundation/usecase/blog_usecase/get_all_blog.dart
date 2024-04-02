import 'package:flutter_blog_app/core/error/failure.dart';
import 'package:flutter_blog_app/core/usecase/usecase.dart';
import 'package:flutter_blog_app/foundation/entities/blog_entity/blog.dart';
import 'package:flutter_blog_app/foundation/repositories/blog_repository/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllBlogs implements UseCase<List<Blog>, GetAllBlogsParams> {
  final BlogRepository blogRepository;
  GetAllBlogs(this.blogRepository);

  @override
  Future<Either<Failure, List<Blog>>> call(GetAllBlogsParams params) async {
    return await blogRepository.getAllBlogs();
  }
}

class GetAllBlogsParams {}
