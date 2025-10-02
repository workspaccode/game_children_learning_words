import 'package:dio/dio.dart';

import '../../models/game_progress_model.dart';
import '../../models/sentence_model.dart';
import '../../models/user_model.dart';
import '../../models/word_model.dart';
import 'api_client.dart';

class ApiClientImpl implements ApiClient {
  ApiClientImpl(this._dio);
  final Dio _dio;

  @override
  Future<ApiResponse<UserModel>> login(LoginRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: request.toJson(),
      );
      return ApiResponse<UserModel>.fromJson(
        response.data!,
        (json) => UserModel.fromMap(json! as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<ApiResponse<UserModel>> register(RegisterRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: request.toJson(),
      );
      return ApiResponse<UserModel>.fromJson(
        response.data!,
        (json) => UserModel.fromMap(json! as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<ApiResponse<UserModel>> googleSignIn(
    GoogleSignInRequest request,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/google',
        data: request.toJson(),
      );
      return ApiResponse<UserModel>.fromJson(
        response.data!,
        (json) => UserModel.fromMap(json! as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  @override
  Future<ApiResponse<String>> refreshToken(RefreshTokenRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: request.toJson(),
      );
      return ApiResponse<String>.fromJson(
        response.data!,
        (json) => json! as String,
      );
    } catch (e) {
      throw Exception('Token refresh failed: $e');
    }
  }

  @override
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('/auth/logout');
      return ApiResponse<void>.fromJson(response.data!, (json) {});
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<ApiResponse<List<WordModel>>> getWords({
    int? level,
    String? category,
    String? language,
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/words',
        queryParameters: {
          if (level != null) 'level': level,
          if (category != null) 'category': category,
          if (language != null) 'language': language,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );
      return ApiResponse<List<WordModel>>.fromJson(
        response.data!,
        (json) => (json! as List)
            .map((item) => WordModel.fromMap(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      throw Exception('Failed to get words: $e');
    }
  }

  @override
  Future<ApiResponse<WordModel>> getWord(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/words/$id');
      return ApiResponse<WordModel>.fromJson(
        response.data!,
        (json) => WordModel.fromMap(json! as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to get word: $e');
    }
  }

  @override
  Future<ApiResponse<List<SentenceModel>>> getSentences({
    int? level,
    String? category,
    String? language,
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/sentences',
        queryParameters: {
          if (level != null) 'level': level,
          if (category != null) 'category': category,
          if (language != null) 'language': language,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );
      return ApiResponse<List<SentenceModel>>.fromJson(
        response.data!,
        (json) => (json! as List)
            .map((item) => SentenceModel.fromMap(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      throw Exception('Failed to get sentences: $e');
    }
  }

  @override
  Future<ApiResponse<SentenceModel>> getSentence(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/sentences/$id');
      return ApiResponse<SentenceModel>.fromJson(
        response.data!,
        (json) => SentenceModel.fromMap(json! as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to get sentence: $e');
    }
  }

  Future<ApiResponse<GameProgressModel>> saveGameProgress(
    GameProgressModel progress,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/game/progress',
        data: progress.toMap(),
      );
      return ApiResponse<GameProgressModel>.fromJson(
        response.data!,
        (json) => GameProgressModel.fromMap(json! as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to save game progress: $e');
    }
  }

  @override
  Future<ApiResponse<UserStatsResponse>> getUserStats(String userId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/users/$userId/stats',
      );
      return ApiResponse<UserStatsResponse>.fromJson(
        response.data!,
        (json) => UserStatsResponse.fromJson(json! as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to get user stats: $e');
    }
  }

  @override
  Future<ApiResponse<List<LeaderboardEntry>>> getLeaderboard({
    String? gameType,
    int? level,
    int? limit,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/leaderboard',
        queryParameters: {
          if (gameType != null) 'gameType': gameType,
          if (level != null) 'level': level,
          if (limit != null) 'limit': limit,
        },
      );
      return ApiResponse<List<LeaderboardEntry>>.fromJson(
        response.data!,
        (json) => (json! as List)
            .map(
              (item) => LeaderboardEntry.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
      );
    } catch (e) {
      throw Exception('Failed to get leaderboard: $e');
    }
  }

  @override
  Future<ApiResponse<String>> uploadAudio(dynamic audioFile) async {
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(audioFile.path as String),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        '/upload/audio',
        data: formData,
      );
      return ApiResponse<String>.fromJson(
        response.data!,
        (json) => json! as String,
      );
    } catch (e) {
      throw Exception('Failed to upload audio: $e');
    }
  }

  @override
  Future<ApiResponse<String>> uploadImage(dynamic imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path as String),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        '/upload/image',
        data: formData,
      );
      return ApiResponse<String>.fromJson(
        response.data!,
        (json) => json! as String,
      );
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  @override
  Future<ApiResponse<WordModel>> createWord(WordModel word) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/words',
        data: word.toMap(),
      );
      return ApiResponse<WordModel>.fromJson(
        response.data!,
        (json) => WordModel.fromMap(json! as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to create word: $e');
    }
  }

  @override
  Future<ApiResponse<WordModel>> updateWord(int id, WordModel word) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/words/$id',
        data: word.toMap(),
      );
      return ApiResponse<WordModel>.fromJson(
        response.data!,
        (json) => WordModel.fromMap(json! as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to update word: $e');
    }
  }

  @override
  Future<ApiResponse<void>> deleteWord(int id) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>('/words/$id');
      return ApiResponse<void>.fromJson(response.data!, (json) {});
    } catch (e) {
      throw Exception('Failed to delete word: $e');
    }
  }

  @override
  Future<ApiResponse<SentenceModel>> createSentence(
    SentenceModel sentence,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/sentences',
        data: sentence.toMap(),
      );
      return ApiResponse<SentenceModel>.fromJson(
        response.data!,
        (json) => SentenceModel.fromMap(json! as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to create sentence: $e');
    }
  }

  @override
  Future<ApiResponse<GameProgressModel>> saveProgress(
    GameProgressModel progress,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/progress',
        data: progress.toMap(),
      );
      return ApiResponse<GameProgressModel>.fromJson(
        response.data!,
        (json) => GameProgressModel.fromMap(json! as Map<String, dynamic>),
      );
    } catch (e) {
      throw Exception('Failed to save progress: $e');
    }
  }

  @override
  Future<ApiResponse<List<GameProgressModel>>> getUserProgress(
    String userId,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/progress/user/$userId',
      );
      return ApiResponse<List<GameProgressModel>>.fromJson(
        response.data!,
        (json) => (json! as List)
            .map(
              (item) => GameProgressModel.fromMap(item as Map<String, dynamic>),
            )
            .toList(),
      );
    } catch (e) {
      throw Exception('Failed to get user progress: $e');
    }
  }

  @override
  Future<ApiResponse<List<String>>> getCategories() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/content/categories',
      );
      return ApiResponse<List<String>>.fromJson(
        response.data!,
        (json) => List<String>.from(json! as List),
      );
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  @override
  Future<ApiResponse<List<int>>> getLevels() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/content/levels');
      return ApiResponse<List<int>>.fromJson(
        response.data!,
        (json) => List<int>.from(json! as List),
      );
    } catch (e) {
      throw Exception('Failed to get levels: $e');
    }
  }
}
