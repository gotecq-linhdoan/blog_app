import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blog_app/foundation/entities/blog_entity/blog.dart';
import 'package:flutter_blog_app/foundation/usecase/blog_usecase/delete_blog.dart';
import 'package:flutter_blog_app/foundation/usecase/blog_usecase/get_all_blog.dart';
import 'package:flutter_blog_app/foundation/usecase/blog_usecase/update_blog.dart';
import 'package:flutter_blog_app/foundation/usecase/blog_usecase/upload_blog.dart';

part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlog _uploadBlog;
  final GetAllBlogs _getAllBlogs;
  final DeleteBlog _deleteBlog;
  final UpdateBlog _updateBlog;
  BlogBloc({
    required UploadBlog uploadBlog,
    required GetAllBlogs getAllBlogs,
    required DeleteBlog deleteBlog,
    required UpdateBlog updateBlog,
  })  : _uploadBlog = uploadBlog,
        _getAllBlogs = getAllBlogs,
        _deleteBlog = deleteBlog,
        _updateBlog = updateBlog,
        super(BlogInitial()) {
    on<BlogEvent>((event, emit) {
      emit(BlogLoading());
    });
    on<BlogUpload>((event, emit) async {
      final res = await _uploadBlog(UploadBlogParams(
        posterId: event.posterId,
        title: event.title,
        contentDelta: event.contentDelta,
        content: event.content,
        image: event.image,
        topics: event.topics,
      ));
      res.fold(
        (l) => emit(BlogFailure(l.failMessage)),
        (r) => emit(BlogUploadSuccess()),
      );
    });
    on<BlogUpdate>((event, emit) async {
      final res = await _updateBlog(
        UpdateBlogParams(
          id: event.id,
          imageUrl: event.imageUrl,
          posterId: event.posterId,
          contentDelta: event.contentDelta,
          title: event.title,
          content: event.content,
          image: event.image,
          topics: event.topics,
        ),
      );
      res.fold(
        (l) => emit(BlogFailure(l.failMessage)),
        (r) => emit(BlogUpdateSuccess()),
      );
    });
    on<BlogGetAll>((event, emit) async {
      final res = await _getAllBlogs(GetAllBlogsParams());
      res.fold((l) => emit(BlogFailure(l.failMessage)),
          (r) => emit(BlogDisplaySuccess(r)));
    });
    on<BlogDelete>((event, emit) async {
      final res = await _deleteBlog(DeleteBlogParams(blogId: event.blogId));
      res.fold((l) => emit(BlogFailure(l.failMessage)),
          (r) => emit(BlogDeleteSuccess()));
    });
  }
}
