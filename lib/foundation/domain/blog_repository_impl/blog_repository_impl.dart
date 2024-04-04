import 'dart:io';

import 'package:flutter_blog_app/core/error/exception.dart';
import 'package:flutter_blog_app/core/error/failure.dart';
import 'package:flutter_blog_app/core/network/check_network_connection.dart';
import 'package:flutter_blog_app/foundation/api/blog_data_source/blog_local_data_source.dart';
import 'package:flutter_blog_app/foundation/api/blog_data_source/blog_remote_data_source.dart';
import 'package:flutter_blog_app/foundation/model/blog_model/blog_model.dart';
import 'package:flutter_blog_app/foundation/entities/blog_entity/blog.dart';
import 'package:flutter_blog_app/foundation/repositories/blog_repository/blog_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class BlogRepositoryImpl implements BlogRepository {
  final BlogRemoteDataResource blogRemoteDataResource;
  final BlogLocalDataSource blogLocalDataSource;
  final ConnectionChecker connectionChecker;

  BlogRepositoryImpl(
    this.blogRemoteDataResource,
    this.blogLocalDataSource,
    this.connectionChecker,
  );
  @override
  Future<Either<Failure, Blog>> uploadBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure('No internet connection!'));
      }
      BlogModel blogModel = BlogModel(
        id: const Uuid().v1(),
        posterId: posterId,
        title: title,
        content: content,
        imageUrl: '',
        topics: topics,
        updatedAt: DateTime.now(),
      );
      final imageUrl = await blogRemoteDataResource.uploadBlogImage(
        image: image,
        blog: blogModel,
      );
      blogModel = blogModel.copyWith(imageUrl: imageUrl);
      final uploadedBlog = await blogRemoteDataResource.uploadBlog(blogModel);
      return right(uploadedBlog);
    } on ServerExceptions catch (e) {
      return left(Failure(e.excMessage));
    }
  }

  @override
  Future<Either<Failure, List<Blog>>> getAllBlogs() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final blogList = blogLocalDataSource.loadBlogs();
        return right(blogList);
      }
      final blogList = await blogRemoteDataResource.getAllBlogs();
      blogLocalDataSource.uploadLocalBlogs(blogs: blogList);
      return right(blogList);
    } on ServerExceptions catch (e) {
      return left(Failure(e.excMessage));
    }
  }

  @override
  Future<Either<Failure, String>> deleteBlog({required String blogId}) async {
    try {
      final deleteMessage = await blogRemoteDataResource.deleteBlog(blogId);
      return right(deleteMessage);
    } on ServerExceptions catch (e) {
      return left(Failure(e.excMessage));
    }
  }

  @override
  Future<Either<Failure, String>> updateBlog({
    required String id,
    required String imageUrl,
    required File? image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  }) async {
    try {
      BlogModel blogModel = BlogModel(
        id: id,
        posterId: posterId,
        title: title,
        content: content,
        imageUrl: imageUrl,
        topics: topics,
        updatedAt: DateTime.now(),
      );
      if (image != null) {
        final imageUrl = await blogRemoteDataResource.uploadBlogImage(
          image: image,
          blog: blogModel,
        );
        blogModel = blogModel.copyWith(imageUrl: imageUrl);
      }
      final updateMessage = await blogRemoteDataResource.updateBlog(blogModel);
      return right(updateMessage);
    } on ServerExceptions catch (e) {
      return left(Failure(e.excMessage));
    }
  }
}
