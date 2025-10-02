import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'features/admin/data/datasources/admin_local_datasource.dart';
import 'features/admin/data/repositories/admin_repository_impl.dart';
import 'features/admin/domain/repositories/admin_repository.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/child/data/datasources/child_local_datasource.dart';
import 'features/child/data/repositories/child_repository_impl.dart';
import 'features/child/domain/repositories/child_repository.dart';
import 'features/child/presentation/bloc/child_bloc.dart';
import 'features/game/data/repositories/game_repository_impl.dart';
import 'features/game/domain/repositories/game_repository.dart';
import 'features/game/presentation/bloc/game_bloc.dart';
import 'features/parent/data/datasources/parent_local_datasource.dart';
import 'features/parent/data/repositories/parent_repository_impl.dart';
import 'features/parent/domain/repositories/parent_repository.dart';
import 'features/parent/presentation/bloc/parent_bloc.dart';
import 'features/teacher/data/datasources/teacher_local_datasource.dart';
import 'features/teacher/data/repositories/teacher_repository_impl.dart';
import 'features/teacher/domain/repositories/teacher_repository.dart';
import 'features/teacher/presentation/bloc/teacher_bloc.dart';
import 'services/firebase_database_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl()),
  );

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  // Firebase Services
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(GoogleSignIn.new);
  sl.registerLazySingleton(Connectivity.new);

  // Features - Game
  sl.registerLazySingleton(() => FirebaseDatabaseService.instance);
  sl.registerLazySingleton<GameRepository>(() => GameRepositoryImpl(sl()));
  sl.registerFactory(() => GameBloc(sl()));

  // Features - Auth
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
      localStorage: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => AuthBloc(authRepository: sl(), connectivity: sl()),
  );

  // Features - Child
  sl.registerLazySingleton<ChildLocalDataSource>(
    () => ChildLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<ChildRepository>(() => ChildRepositoryImpl(sl()));
  sl.registerLazySingleton(() => ChildBloc(childRepository: sl()));

  // Features - Parent
  sl.registerLazySingleton<ParentLocalDataSource>(
    () => ParentLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<ParentRepository>(() => ParentRepositoryImpl(sl()));
  sl.registerLazySingleton(() => ParentBloc(parentRepository: sl()));

  // Features - Teacher
  sl.registerLazySingleton<TeacherLocalDataSource>(
    () => TeacherLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<TeacherRepository>(
    () => TeacherRepositoryImpl(
      firestore: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => TeacherBloc(teacherRepository: sl(), networkInfo: sl()),
  );

  // Features - Admin
  sl.registerLazySingleton<AdminLocalDataSource>(
    () => AdminLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl(sl()));
  sl.registerLazySingleton(() => AdminBloc(adminRepository: sl()));
}
