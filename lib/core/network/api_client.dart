import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';

import '../../models/game_progress_model.dart';
import '../../models/sentence_model.dart';
import '../../models/user_model.dart';
import '../../models/word_model.dart';

// part 'api_client.g.dart';

// @RestApi()
abstract class ApiClient {
  // factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // Auth endpoints
  @POST('/auth/login')
  Future<ApiResponse<UserModel>> login(LoginRequest request);

  @POST('/auth/register')
  Future<ApiResponse<UserModel>> register(RegisterRequest request);

  @POST('/auth/google')
  Future<ApiResponse<UserModel>> googleSignIn(GoogleSignInRequest request);

  @POST('/auth/refresh')
  Future<ApiResponse<String>> refreshToken(RefreshTokenRequest request);

  @POST('/auth/logout')
  Future<ApiResponse<void>> logout();

  // Words endpoints
  @GET('/words')
  Future<ApiResponse<List<WordModel>>> getWords({
    int? level,
    String? category,
    String? language,
    int? limit,
    int? offset,
  });

  @GET('/words/{id}')
  Future<ApiResponse<WordModel>> getWord(@Path('id') int id);

  @POST('/words')
  Future<ApiResponse<WordModel>> createWord(@Body() WordModel word);

  @PUT('/words/{id}')
  Future<ApiResponse<WordModel>> updateWord(
    @Path('id') int id,
    @Body() WordModel word,
  );

  @DELETE('/words/{id}')
  Future<ApiResponse<void>> deleteWord(@Path('id') int id);

  // Sentences endpoints
  @GET('/sentences')
  Future<ApiResponse<List<SentenceModel>>> getSentences({
    @Query('level') int? level,
    @Query('category') String? category,
    @Query('language') String? language,
    @Query('limit') int? limit,
    int? offset,
  });

  @GET('/sentences/{id}')
  Future<ApiResponse<SentenceModel>> getSentence(@Path('id') int id);

  @POST('/sentences')
  Future<ApiResponse<SentenceModel>> createSentence(
    @Body() SentenceModel sentence,
  );

  // Progress endpoints
  @POST('/progress')
  Future<ApiResponse<GameProgressModel>> saveProgress(
    @Body() GameProgressModel progress,
  );

  @GET('/progress/user/{userId}')
  Future<ApiResponse<List<GameProgressModel>>> getUserProgress(
    @Path('userId') String userId,
  );

  @GET('/progress/stats/{userId}')
  Future<ApiResponse<UserStatsResponse>> getUserStats(
    @Path('userId') String userId,
  );

  // Leaderboard endpoints
  @GET('/leaderboard')
  Future<ApiResponse<List<LeaderboardEntry>>> getLeaderboard({
    @Query('gameType') String? gameType,
    @Query('level') int? level,
    @Query('limit') int? limit,
  });

  // Content endpoints
  @GET('/content/categories')
  Future<ApiResponse<List<String>>> getCategories();

  @GET('/content/levels')
  Future<ApiResponse<List<int>>> getLevels();

  // File upload
  @POST('/upload/audio')
  @MultiPart()
  Future<ApiResponse<String>> uploadAudio(dynamic file);

  @POST('/upload/image')
  @MultiPart()
  Future<ApiResponse<String>> uploadImage(dynamic file);
}

// Request/Response models
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse(
      success: (json['success'] as bool?) ?? false,
      message: (json['message'] as String?) ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) {
    return {
      'success': success,
      'message': message,
      'data': data != null ? toJsonT(data as T) : null,
      'errors': errors,
    };
  }
}

@JsonSerializable()
class LoginRequest {
  LoginRequest({required this.email, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: (json['email'] as String?) ?? '',
      password: (json['password'] as String?) ?? '',
    );
  }
  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

@JsonSerializable()
class RegisterRequest {
  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
    this.age,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      password: (json['password'] as String?) ?? '',
      userType: (json['userType'] as String?) ?? 'student',
      age: json['age'] as int?,
    );
  }
  final String name;
  final String email;
  final String password;
  final String userType;
  final int? age;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'userType': userType,
      'age': age,
    };
  }
}

@JsonSerializable()
class GoogleSignInRequest {
  GoogleSignInRequest({required this.idToken, required this.accessToken});

  factory GoogleSignInRequest.fromJson(Map<String, dynamic> json) {
    return GoogleSignInRequest(
      idToken: (json['idToken'] as String?) ?? '',
      accessToken: (json['accessToken'] as String?) ?? '',
    );
  }
  final String idToken;
  final String accessToken;

  Map<String, dynamic> toJson() {
    return {'idToken': idToken, 'accessToken': accessToken};
  }
}

@JsonSerializable()
class RefreshTokenRequest {
  RefreshTokenRequest({required this.refreshToken});

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) {
    return RefreshTokenRequest(
      refreshToken: (json['refreshToken'] as String?) ?? '',
    );
  }
  final String refreshToken;

  Map<String, dynamic> toJson() {
    return {'refreshToken': refreshToken};
  }
}

@JsonSerializable()
class UserStatsResponse {
  UserStatsResponse({
    required this.totalGames,
    required this.averageScore,
    required this.totalTimeMinutes,
    required this.gamesByType,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalWordsLearned,
    required this.achievements,
  });

  factory UserStatsResponse.fromJson(Map<String, dynamic> json) {
    return UserStatsResponse(
      totalGames: (json['totalGames'] as int?) ?? 0,
      averageScore: ((json['averageScore'] as num?) ?? 0.0).toDouble(),
      totalTimeMinutes: (json['totalTimeMinutes'] as int?) ?? 0,
      gamesByType: Map<String, int>.from(json['gamesByType'] as Map),
      currentStreak: (json['currentStreak'] as int?) ?? 0,
      bestStreak: (json['bestStreak'] as int?) ?? 0,
      totalWordsLearned: (json['totalWordsLearned'] as int?) ?? 0,
      achievements: List<String>.from(json['achievements'] as List? ?? []),
    );
  }
  final int totalGames;
  final double averageScore;
  final int totalTimeMinutes;
  final Map<String, int> gamesByType;
  final int currentStreak;
  final int bestStreak;
  final int totalWordsLearned;
  final List<String> achievements;

  Map<String, dynamic> toJson() {
    return {
      'totalGames': totalGames,
      'averageScore': averageScore,
      'totalTimeMinutes': totalTimeMinutes,
      'gamesByType': gamesByType,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalWordsLearned': totalWordsLearned,
      'achievements': achievements,
    };
  }
}

@JsonSerializable()
class LeaderboardEntry {
  LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.score,
    required this.rank,
    required this.gameType,
    required this.level,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: (json['userId'] as String?) ?? '',
      userName: (json['userName'] as String?) ?? '',
      userAvatar: json['userAvatar'] as String?,
      score: (json['score'] as int?) ?? 0,
      rank: (json['rank'] as int?) ?? 0,
      gameType: (json['gameType'] as String?) ?? '',
      level: (json['level'] as int?) ?? 1,
    );
  }
  final String userId;
  final String userName;
  final String? userAvatar;
  final int score;
  final int rank;
  final String gameType;
  final int level;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'score': score,
      'rank': rank,
      'gameType': gameType,
      'level': level,
    };
  }
}
