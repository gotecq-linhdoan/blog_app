import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blog_app/core/common/widget/loader.dart';
import 'package:flutter_blog_app/core/theme/app_pallete.dart';
import 'package:flutter_blog_app/core/util/calculate_reading_time.dart';
import 'package:flutter_blog_app/core/util/format_date.dart';
import 'package:flutter_blog_app/core/util/show_snackbar.dart';
import 'package:flutter_blog_app/features/presentation/blog_bloc/blog_bloc.dart';
import 'package:flutter_blog_app/foundation/entities/blog_entity/blog.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BlogViewerPage extends StatefulWidget {
  final Blog blog;
  const BlogViewerPage({super.key, required this.blog});

  @override
  State<BlogViewerPage> createState() => _BlogViewerPageState();
}

class _BlogViewerPageState extends State<BlogViewerPage> {
  final QuillController _controller = QuillController.basic();
  @override
  void initState() {
    super.initState();
    _controller.document = Document.fromHtml(widget.blog.content);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              context.read<BlogBloc>().add(BlogDelete(blogId: widget.blog.id));
            },
            icon: Icon(MdiIcons.delete),
          ),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.error);
          } else if (state is BlogDeleteSuccess) {
            context.pushReplacement('/');
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Loader();
          }
          return Scrollbar(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.blog.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'By ${widget.blog.posterName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${formatDateBydMMMYYYY(widget.blog.updatedAt)} - ${calculateReadingTime(widget.blog.content)} min',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppPallete.greyColor,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        height: 200,
                        imageUrl: widget.blog.imageUrl,
                        imageBuilder: (context, imageProvider) {
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                                colorFilter: const ColorFilter.mode(
                                    Colors.red, BlendMode.colorBurn),
                              ),
                            ),
                          );
                        },
                        placeholder: (context, url) => const Loader(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    HtmlWidget(
                      widget.blog.content,
                      textStyle: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
