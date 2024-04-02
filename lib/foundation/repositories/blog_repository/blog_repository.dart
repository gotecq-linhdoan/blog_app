import 'dart:io';

import 'package:flutter_blog_app/core/error/failure.dart';
import 'package:flutter_blog_app/foundation/entities/blog_entity/blog.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class BlogRepository {
  Future<Either<Failure, Blog>> uploadBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  });
  Future<Either<Failure, List<Blog>>> getAllBlogs();
  Future<Either<Failure, String>> deleteBlog({
    required String blogId,
  });
}
