import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blog_app/core/common/cubit/app_user/app_user_cubit.dart';
import 'package:flutter_blog_app/core/theme/theme.dart';
import 'package:flutter_blog_app/features/presentation/auth_bloc/auth_bloc.dart';
import 'package:flutter_blog_app/features/ui/auth_ui/pages/signin_page.dart';
import 'package:flutter_blog_app/features/ui/auth_ui/pages/signup_page.dart';
import 'package:flutter_blog_app/foundation/entities/blog_entity/blog.dart';
import 'package:flutter_blog_app/features/presentation/blog_bloc/blog_bloc.dart';
import 'package:flutter_blog_app/features/ui/blog_ui/pages/add_new_blog.dart';
import 'package:flutter_blog_app/features/ui/blog_ui/pages/blog_page.dart';
import 'package:flutter_blog_app/features/ui/blog_ui/pages/blog_viewer_page.dart';
import 'package:flutter_blog_app/init_dependencies.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => serviceLocator<AppUserCubit>(),
      ),
      BlocProvider(
        create: (_) => serviceLocator<AuthBloc>(),
      ),
      BlocProvider(
        create: (_) => serviceLocator<BlogBloc>(),
      ),
    ],
    child: const MyApp(),
  ));
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return BlocSelector<AppUserCubit, AppUserState, bool>(
          selector: (state) {
            return state is AppUserLoggedIn;
          },
          builder: (context, isLoggedIn) {
            if (isLoggedIn) {
              return const BlogPage();
            }
            return const SigninPage();
          },
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'singup',
          builder: (BuildContext context, GoRouterState state) {
            return const SignupPage();
          },
        ),
        GoRoute(
          path: 'addblog',
          builder: (BuildContext context, GoRouterState state) {
            return const NewBlogPage();
          },
        ),
        GoRoute(
          path: 'blogdetail',
          builder: (BuildContext context, GoRouterState state) {
            final Blog blog = state.extra as Blog;
            return BlogViewerPage(blog: blog);
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Blog App',
      theme: AppTheme.darkThemeMode,
      routerConfig: _router,
    );
  }
}
