part of 'blog_bloc.dart';

@immutable
sealed class BlogEvent {}

final class BlogUpload extends BlogEvent {
  final String posterId;
  final String title;
  final String content;
  final String contentDelta;
  final File image;
  final List<String> topics;

  BlogUpload({
    required this.posterId,
    required this.title,
    required this.content,
    required this.contentDelta,
    required this.image,
    required this.topics,
  });
}

final class BlogUpdate extends BlogEvent {
  final String id;
  final String imageUrl;
  final String posterId;
  final String title;
  final String content;
  final String contentDelta;
  final File? image;
  final List<String> topics;

  BlogUpdate({
    required this.id,
    required this.imageUrl,
    required this.posterId,
    required this.title,
    required this.content,
    required this.contentDelta,
    required this.image,
    required this.topics,
  });
}

final class BlogGetAll extends BlogEvent {}

final class BlogDelete extends BlogEvent {
  final String blogId;

  BlogDelete({required this.blogId});
}
