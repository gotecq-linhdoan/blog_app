import 'package:flutter_blog_app/core/common/cubit/app_user/app_user_cubit.dart';
import 'package:flutter_blog_app/core/network/check_network_connection.dart';
import 'package:flutter_blog_app/core/secret/app_secret.dart';
import 'package:flutter_blog_app/foundation/api/auth_data_source/auth_remote_data_source.dart';
import 'package:flutter_blog_app/foundation/domain/auth_repository_impl/auth_repository_impl.dart';
import 'package:flutter_blog_app/foundation/repositories/auth_repository/auth_repository.dart';
import 'package:flutter_blog_app/foundation/usecase/auth_usecase/current_user.dart';
import 'package:flutter_blog_app/foundation/usecase/auth_usecase/sign_out.dart';
import 'package:flutter_blog_app/foundation/usecase/auth_usecase/user_sign_in.dart';
import 'package:flutter_blog_app/foundation/usecase/auth_usecase/user_sign_up.dart';
import 'package:flutter_blog_app/features/presentation/auth_bloc/auth_bloc.dart';
import 'package:flutter_blog_app/foundation/api/blog_data_source/blog_local_data_source.dart';
import 'package:flutter_blog_app/foundation/api/blog_data_source/blog_remote_data_source.dart';
import 'package:flutter_blog_app/foundation/domain/blog_repository_impl/blog_repository_impl.dart';
import 'package:flutter_blog_app/foundation/repositories/blog_repository/blog_repository.dart';
import 'package:flutter_blog_app/foundation/usecase/blog_usecase/delete_blog.dart';
import 'package:flutter_blog_app/foundation/usecase/blog_usecase/get_all_blog.dart';
import 'package:flutter_blog_app/foundation/usecase/blog_usecase/update_blog.dart';
import 'package:flutter_blog_app/foundation/usecase/blog_usecase/upload_blog.dart';
import 'package:flutter_blog_app/features/presentation/blog_bloc/blog_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initBlog();
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnnonKey,
  );

  Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;

  serviceLocator.registerLazySingleton(() => supabase.client);
  serviceLocator.registerLazySingleton(() => AppUserCubit());
  serviceLocator.registerFactory(() => InternetConnection());
  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(
      serviceLocator(),
    ),
  );
  serviceLocator.registerLazySingleton(
    () => Hive.box(name: 'blogs'),
  );
}

void _initBlog() {
  serviceLocator
    ..registerFactory<BlogRemoteDataResource>(
      () => BlogRemoteDataResourceImlp(
        serviceLocator(),
      ),
    )
    ..registerFactory<BlogLocalDataSource>(
      () => BlogLocalDataSourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<BlogRepository>(
      () => BlogRepositoryImpl(
        serviceLocator<BlogRemoteDataResource>(),
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UploadBlog(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetAllBlogs(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => DeleteBlog(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UpdateBlog(
        serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => BlogBloc(
        uploadBlog: serviceLocator(),
        getAllBlogs: serviceLocator(),
        deleteBlog: serviceLocator(),
        updateBlog: serviceLocator(),
      ),
    );
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceIpm(
        serviceLocator(),
      ),
    )
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserSignUp(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserSignIn(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => CurrentUser(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserSignOut(
        serviceLocator(),
      ),
    )
    ..registerFactory(() => User)
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userSignIn: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
        userSignOut: serviceLocator(),
      ),
    );
}
