import 'dart:io';
import 'package:flutter_blog_app/core/error/exception.dart';
import 'package:flutter_blog_app/foundation/model/blog_model/blog_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

abstract interface class BlogRemoteDataResource {
  Future<BlogModel> uploadBlog(BlogModel blog);
  Future<String> uploadBlogImage({
    required File image,
    required BlogModel blog,
  });
  Future<List<BlogModel>> getAllBlogs();
  Future<String> deleteBlog(String blogId);
  Future<String> updateBlog(BlogModel blog);
}

class BlogRemoteDataResourceImlp implements BlogRemoteDataResource {
  final SupabaseClient supabaseClient;

  BlogRemoteDataResourceImlp(this.supabaseClient);

  @override
  Future<BlogModel> uploadBlog(BlogModel blog) async {
    try {
      final blogData = await supabaseClient
          .from('blogs')
          .insert(
            blog.toJson(),
          )
          .select();
      return BlogModel.fromJson(blogData.first);
    } on PostgrestException catch (e) {
      throw ServerExceptions(e.message);
    } catch (e) {
      throw ServerExceptions(e.toString());
    }
  }

  @override
  Future<String> uploadBlogImage({
    required File image,
    required BlogModel blog,
  }) async {
    try {
      final String blogImageName = '${blog.title}_${Uuid().v1()}';
      await supabaseClient.storage
          .from('blog_images')
          .upload(blogImageName, image);
      return supabaseClient.storage
          .from('blog_images')
          .getPublicUrl(blogImageName);
    } on StorageException catch (e) {
      throw ServerExceptions(e.message);
    } catch (e) {
      throw ServerExceptions(e.toString());
    }
  }

  @override
  Future<List<BlogModel>> getAllBlogs() async {
    try {
      final blogList = await supabaseClient
          .from('blogs')
          .select('*, profiles (name)')
          .order('updated_at', ascending: false);
      return blogList
          .map((blog) => BlogModel.fromJson(blog).copyWith(
                posterName: blog['profiles']['name'],
              ))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerExceptions(e.message);
    } catch (e) {
      throw ServerExceptions(e.toString());
    }
  }

  @override
  Future<String> deleteBlog(String blogId) async {
    try {
      await supabaseClient.from('blogs').delete().eq('id', blogId);
      return 'Delete blog success!';
    } on PostgrestException catch (e) {
      throw ServerExceptions(e.message);
    } catch (e) {
      throw ServerExceptions(e.toString());
    }
  }

  @override
  Future<String> updateBlog(BlogModel blog) async {
    try {
      await supabaseClient
          .from('blogs')
          .update(blog.toJsonUpdate())
          .eq('id', blog.id);
      return 'Updated Success!!';
    } on PostgrestException catch (e) {
      throw ServerExceptions(e.message);
    } on ServerExceptions catch (e) {
      throw ServerExceptions(e.toString());
    }
  }
}
