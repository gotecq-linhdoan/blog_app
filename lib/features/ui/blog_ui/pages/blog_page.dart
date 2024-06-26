import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blog_app/core/common/widget/loader.dart';
import 'package:flutter_blog_app/core/theme/app_pallete.dart';
import 'package:flutter_blog_app/core/util/show_snackbar.dart';
import 'package:flutter_blog_app/features/presentation/auth_bloc/auth_bloc.dart';
import 'package:flutter_blog_app/features/presentation/blog_bloc/blog_bloc.dart';
import 'package:flutter_blog_app/features/ui/blog_ui/widgets/blog_card.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  @override
  void initState() {
    context.read<BlogBloc>().add(BlogGetAll());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.read<AuthBloc>().add(AuthSignOut());
            context.pushReplacement('/');
          },
          icon: Icon(MdiIcons.logout),
        ),
        title: const Text('Blog App'),
        actions: [
          IconButton(
            onPressed: () => context.go('/addblog'),
            icon: const Icon(CupertinoIcons.add_circled),
          ),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Loader();
          }
          if (state is BlogDisplaySuccess) {
            return ListView.builder(
              itemCount: state.blogList.length,
              itemBuilder: (context, index) {
                final blog = state.blogList[index];
                return BlogCard(
                    blog: blog,
                    color: index % 3 == 0
                        ? AppPallete.gradient1
                        : index % 3 == 1
                            ? AppPallete.gradient2
                            : AppPallete.gradient3);
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
