import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blog_app/features/blog/domain/entity/blog.dart';
import 'package:flutter_blog_app/features/blog/domain/usecase/get_all_blog.dart';
import 'package:flutter_blog_app/features/blog/domain/usecase/upload_blog.dart';

part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlog _uploadBlog;
  final GetAllBlogs _getAllBlogs;
  BlogBloc({
    required UploadBlog uploadBlog,
    required GetAllBlogs getAllBlogs,
  })  : _uploadBlog = uploadBlog,
        _getAllBlogs = getAllBlogs,
        super(BlogInitial()) {
    on<BlogEvent>((event, emit) {
      emit(BlogLoading());
    });
    on<BlogUpload>((event, emit) async {
      final res = await _uploadBlog(UploadBlogParams(
        posterId: event.posterId,
        title: event.title,
        content: event.content,
        image: event.image,
        topics: event.topics,
      ));
      res.fold(
        (l) => emit(BlogFailure(l.failMessage)),
        (r) => emit(BlogUploadSuccess()),
      );
    });
    on<BlogGetAll>((event, emit) async {
      final res = await _getAllBlogs(GetAllBlogsParams());
      res.fold((l) => emit(BlogFailure(l.failMessage)),
          (r) => emit(BlogDisplaySuccess(r)));
    });
  }
}
