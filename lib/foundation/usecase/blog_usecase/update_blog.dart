import 'dart:io';

import 'package:flutter_blog_app/core/error/failure.dart';
import 'package:flutter_blog_app/core/usecase/usecase.dart';
import 'package:flutter_blog_app/foundation/repositories/blog_repository/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateBlog implements UseCase<String, UpdateBlogParams> {
  final BlogRepository blogRepository;

  UpdateBlog(this.blogRepository);
  @override
  Future<Either<Failure, String>> call(UpdateBlogParams params) async {
    return await blogRepository.updateBlog(
      id: params.id,
      image: params.image,
      imageUrl: params.imageUrl,
      title: params.title,
      content: params.content,
      posterId: params.posterId,
      topics: params.topics,
    );
  }
}

class UpdateBlogParams {
  final String id;
  final String imageUrl;
  final String posterId;
  final String title;
  final String content;
  final File? image;
  final List<String> topics;

  UpdateBlogParams({
    required this.id,
    required this.imageUrl,
    required this.posterId,
    required this.title,
    required this.content,
    required this.image,
    required this.topics,
  });
}
