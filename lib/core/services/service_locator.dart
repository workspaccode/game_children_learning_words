import 'package:get_it/get_it.dart';

import '../../services/auth_service.dart';
import '../../services/firebase_database_service.dart';
import '../../services/storage_service.dart';
import '../../services/translation_service.dart';
import '../../services/tts_service.dart';
import '../repositories/auth_repository.dart';
import '../use_cases/auth_use_cases.dart';

class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  static GetIt get instance => _getIt;

  static T get<T extends Object>() => _getIt.get<T>();

  static Future<void> initialize() async {
    // Register services as singletons
    _getIt.registerLazySingleton<FirebaseDatabaseService>(
      () => FirebaseDatabaseService.instance,
    );
    _getIt.registerLazySingleton<StorageService>(StorageService.new);
    _getIt.registerLazySingleton<AuthService>(AuthService.new);
    _getIt.registerLazySingleton<TTSService>(TTSService.new);
    _getIt.registerLazySingleton<TranslationService>(TranslationService.new);

    // Repositories
    _getIt.registerLazySingleton<IAuthRepository>(
      () => AuthRepository(get<AuthService>()),
    );

    // Use Cases
    _getIt.registerLazySingleton<SignUpUseCase>(
      () => SignUpUseCase(get<IAuthRepository>(), get<AuthService>()),
    );
    
    _getIt.registerLazySingleton<SignInUseCase>(
      () => SignInUseCase(get<IAuthRepository>()),
    );
    
    _getIt.registerLazySingleton<CheckParentUseCase>(
      () => CheckParentUseCase(get<IAuthRepository>()),
    );
    
    _getIt.registerLazySingleton<CompleteChildRegistrationUseCase>(
      () => CompleteChildRegistrationUseCase(get<IAuthRepository>()),
    );

    // Initialize services that need async initialization
    await _initializeAsyncServices();
  }

  static Future<void> _initializeAsyncServices() async {
    // Initialize Firebase database with sample data
    final database = get<FirebaseDatabaseService>();
    await database.initializeSampleData();

    // Initialize storage
    final storage = get<StorageService>();
    await storage.init();

    // Initialize TTS
    final tts = get<TTSService>();
    await tts.initialize();

    // Initialize translation service
    //  final translation = get<TranslationService>();
    // await translation
  }

  static Future<void> reset() async {
    await _getIt.reset();
    await initialize();
  }

  static void registerFactory<T extends Object>(T Function() factory) {
    _getIt.registerFactory<T>(factory);
  }

  static void registerSingleton<T extends Object>(T instance) {
    _getIt.registerSingleton<T>(instance);
  }

  static void registerLazySingleton<T extends Object>(T Function() factory) {
    _getIt.registerLazySingleton<T>(factory);
  }

  static bool isRegistered<T extends Object>() {
    return _getIt.isRegistered<T>();
  }

  static Future<void> unregister<T extends Object>() async {
    if (isRegistered<T>()) {
      await _getIt.unregister<T>();
    }
  }

  // Specific service getters for convenience
  static FirebaseDatabaseService get database => get<FirebaseDatabaseService>();
  static StorageService get storage => get<StorageService>();
  static AuthService get auth => get<AuthService>();
  static TTSService get tts => get<TTSService>();
  static TranslationService get translation => get<TranslationService>();
}