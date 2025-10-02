import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:readingquest_bilingual_learning/core/network/network_info.dart';
import 'package:readingquest_bilingual_learning/core/repositories/auth_repository.dart';
import 'package:readingquest_bilingual_learning/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:readingquest_bilingual_learning/features/admin/domain/repositories/admin_repository.dart';
import 'package:readingquest_bilingual_learning/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:readingquest_bilingual_learning/features/auth/data/datasources/local_storage.dart';
// BLoCs
import 'package:readingquest_bilingual_learning/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:readingquest_bilingual_learning/features/child/data/repositories/child_repository_impl.dart';
// Repositories
import 'package:readingquest_bilingual_learning/features/child/domain/repositories/child_repository.dart';
import 'package:readingquest_bilingual_learning/features/child/presentation/bloc/child_bloc.dart';
import 'package:readingquest_bilingual_learning/features/parent/data/repositories/parent_repository_impl.dart';
import 'package:readingquest_bilingual_learning/features/parent/domain/repositories/parent_repository.dart';
import 'package:readingquest_bilingual_learning/features/parent/presentation/bloc/parent_bloc.dart';
import 'package:readingquest_bilingual_learning/features/teacher/data/datasources/teacher_local_datasource.dart';
import 'package:readingquest_bilingual_learning/features/teacher/data/repositories/teacher_repository_impl.dart';
import 'package:readingquest_bilingual_learning/features/teacher/domain/repositories/teacher_repository.dart';
import 'package:readingquest_bilingual_learning/features/teacher/presentation/bloc/teacher_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';



final GetIt locator = GetIt.instance;

Future<void> initializeDependencies() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  locator.registerLazySingleton(() => prefs);

  locator.registerLazySingleton(() => FirebaseAuth.instance);
  locator.registerLazySingleton(() => FirebaseFirestore.instance);
  locator.registerLazySingleton(GoogleSignIn.new);
  locator.registerLazySingleton(Connectivity.new);

  // Network Info
  locator.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: locator()),
  );

  // Data sources
  locator.registerLazySingleton(() => LocalStorage(locator()));
  locator.registerLazySingleton<TeacherLocalDataSource>(
    () => TeacherLocalDataSourceImpl(sharedPreferences: locator()),
  );

  // Repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: locator(),
      firestore: locator(),
      googleSignIn: locator(),
      localStorage: locator(),
    ),
  );

  locator.registerLazySingleton<ChildRepository>(
    () => ChildRepositoryImpl(locator()),
  );

  locator.registerLazySingleton<ParentRepository>(
    () => ParentRepositoryImpl(locator()),
  );

  locator.registerLazySingleton<TeacherRepository>(
    () => TeacherRepositoryImpl(
      firestore: locator(),
      localDataSource: locator(),
      networkInfo: locator(),
    ),
  );

  locator.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(locator()),
  );

  // BLoCs
  locator.registerFactory(
    () => AuthBloc(authRepository: locator(), connectivity: locator()),
  );

  locator.registerFactory(() => ChildBloc(childRepository: locator()));

  locator.registerFactory(() => ParentBloc(parentRepository: locator()));

  locator.registerFactory(() => TeacherBloc(
    teacherRepository: locator(),
    networkInfo: locator(),
  ));

  locator.registerFactory(() => AdminBloc(adminRepository: locator()));
}
