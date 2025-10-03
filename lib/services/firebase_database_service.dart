import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/classroom_model.dart';
import '../models/daily_activity_model.dart';
import '../models/game_progress_model.dart';
import '../models/payment_model.dart';
import '../models/sentence_model.dart';
import '../models/subscription_model.dart';
import '../models/user_model.dart';
import '../models/word_model.dart';

class FirebaseDatabaseService {
  FirebaseDatabaseService._init();
  static final FirebaseDatabaseService instance =
      FirebaseDatabaseService._init();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _usersCollection = 'users';
  static const String _wordsCollection = 'words';
  static const String _sentencesCollection = 'sentences';
  static const String _gameProgressCollection = 'game_progress';
  static const String _subscriptionsCollection = 'subscriptions';
  static const String _dailyActivitiesCollection = 'daily_activities';
  static const String _classroomsCollection = 'classrooms';
  static const String _refundsCollection = 'refunds';

  // User operations
  Future<void> createUser(UserModel user) async {
    try {
      print('🔄 Creating user in Firestore: ${user.id} - ${user.email}');

      // Check if user already exists
      final existingUser = await getUserById(user.id);
      if (existingUser != null) {
        print('⚠️ User already exists, updating instead...');
        await updateUser(user);
        return;
      }

      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(user.toMap());
      print('✅ User created successfully in Firestore: ${user.id}');
    } catch (e) {
      print('💥 Firestore Error creating user: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserById(String id) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(id).get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('💥 Firestore Error getting user: $e');
      return null;
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final query = await _firestore
          .collection(_usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromMap(query.docs.first.data());
      }
      return null;
    } catch (e) {
      print('💥 Firestore Error getting user by email: $e');
      return null;
    }
  }

  /// البحث عن مستخدم بالبريد الإلكتروني ونوع المستخدم
  Future<UserModel?> getUserByEmailAndType(
    String email,
    dynamic userType,
  ) async {
    try {
      // تحويل UserType إلى string إذا لزم الأمر
      String userTypeString;
      if (userType.toString().contains('.')) {
        userTypeString = userType.toString().split('.').last;
      } else {
        userTypeString = userType.toString();
      }

      final query = await _firestore
          .collection(_usersCollection)
          .where('email', isEqualTo: email)
          .where('user_type', isEqualTo: userTypeString)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromMap(query.docs.first.data());
      }
      return null;
    } catch (e) {
      print('💥 Firestore Error getting user by email and type: $e');
      return null;
    }
  }

  Future<List<UserModel>> getChildrenByParentId(String parentId) async {
    try {
      final query = await _firestore
          .collection(_usersCollection)
          .where('parent_id', isEqualTo: parentId)
          .where('user_type', isEqualTo: 'child')
          .where('is_active', isEqualTo: true)
          .get();

      return query.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      print('💥 Firestore Error getting children: $e');
      return [];
    }
  }

  Future<bool> canParentAddMoreChildren(String parentId) async {
    try {
      final children = await getChildrenByParentId(parentId);
      return children.length < 4; // Max 4 children per parent
    } catch (e) {
      print('💥 Firestore Error checking parent children limit: $e');
      return false;
    }
  }

  // get getAllWords
  Future<List<WordModel>> getAllWords() async {
    try {
      final snapshot = await _firestore
          .collection(_wordsCollection)
          .where('is_active', isEqualTo: true)
          .get();
      final words = snapshot.docs
          .map((doc) => WordModel.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
      return words;
    } catch (e) {
      print('💥 Firestore Error getting words: $e');
      rethrow;
    }
  }

  // Update parent's children_count
  Future<void> linkChildToParent(String childId, String parentId) async {
    try {
      // Check if parent can add more children
      final canAdd = await canParentAddMoreChildren(parentId);
      if (!canAdd) {
        throw Exception('تجاوز الحد الأقصى لعدد الأطفال (4 أطفال كحد أقصى)');
      }

      // Update child's parent_id
      await _firestore.collection(_usersCollection).doc(childId).update({
        'parent_id': parentId,
        'updated_at': DateTime.now().toIso8601String(),
      });

      print('✅ Child linked to parent successfully: $childId -> $parentId');
    } catch (e) {
      print('💥 Firestore Error linking child to parent: $e');
      rethrow;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      final updateData = user.copyWith(updatedAt: DateTime.now()).toMap();
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .update(updateData);
      print('✅ User updated successfully in Firestore: ${user.id}');
    } catch (e) {
      print('💥 Firestore Error updating user: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection(_usersCollection).doc(id).update({
        'is_active': false,
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('✅ User soft deleted in Firestore: $id');
    } catch (e) {
      print('💥 Firestore Error deleting user: $e');
      rethrow;
    }
  }

  // Get parent by email
  Future<UserModel?> checkParentExists(String parentEmail) async {
    try {
      print('🔄 Checking if parent exists with email: $parentEmail');

      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('email', isEqualTo: parentEmail)
          .where('user_type', isEqualTo: 'parent')
          .where('is_active', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('❌ No parent found with email: $parentEmail');
        return null;
      }

      final parentData = querySnapshot.docs.first.data();
      print('✅ Parent found: ${parentData['name']}');

      return UserModel.fromMap(parentData);
    } catch (e) {
      print('❌ Error checking parent existence: $e');
      throw Exception('Failed to check parent existence');
    }
  }

  // Update child with parent information
  Future<void> updateChildWithParentInfo({
    required String childId,
    required String parentId,
    required String parentEmail,
    required String username,
    required int age,
  }) async {
    try {
      print('🔄 Updating child with parent info: $childId');

      await _firestore.collection(_usersCollection).doc(childId).update({
        'parentId': parentId,
        'parentEmail': parentEmail,
        'username': username,
        'age': age,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Child updated successfully');
    } catch (e) {
      print('❌ Error updating child with parent info: $e');
      throw Exception('Failed to update child with parent information');
    }
  }

  // Word operations
  Future<List<WordModel>> getWordsByLevel(int level, {String? language}) async {
    try {
      var query = _firestore
          .collection(_wordsCollection)
          .where('difficulty_level', isEqualTo: level)
          .where('is_active', isEqualTo: true)
          .orderBy('created_at', descending: true);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => WordModel.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      print('💥 Firestore Error getting words by level: $e');
      return [];
    }
  }

  Future<List<WordModel>> getWordsByCategory(String category) async {
    try {
      final query = await _firestore
          .collection(_wordsCollection)
          .where('category', isEqualTo: category)
          .where('is_active', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .get();

      return query.docs
          .map((doc) => WordModel.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      print('💥 Firestore Error getting words by category: $e');
      return [];
    }
  }

  Future<void> createWord(WordModel word) async {
    try {
      await _firestore.collection(_wordsCollection).add(word.toMap());
      print('✅ Word created successfully in Firestore');
    } catch (e) {
      print('💥 Firestore Error creating word: $e');
      rethrow;
    }
  }

  // Insert word and return the ID
  Future<int> insertWord(WordModel word) async {
    try {
      final docRef = await _firestore
          .collection(_wordsCollection)
          .add(word.toMap());
      print('✅ Word inserted successfully in Firestore: ${docRef.id}');
      // Return a hash of the document ID as an integer
      return docRef.id.hashCode.abs();
    } catch (e) {
      print('💥 Firestore Error inserting word: $e');
      return -1;
    }
  }

  // Update word
  Future<void> updateWord(WordModel word) async {
    try {
      if (word.id == null) {
        throw Exception('Word ID is required for update');
      }

      // Find the document by searching for the word
      final query = await _firestore
          .collection(_wordsCollection)
          .where('id', isEqualTo: word.id)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update(word.toMap());
        print('✅ Word updated successfully in Firestore: ${word.id}');
      } else {
        throw Exception('Word not found for update: ${word.id}');
      }
    } catch (e) {
      print('💥 Firestore Error updating word: $e');
      rethrow;
    }
  }

  // Delete word
  Future<void> deleteWord(int wordId) async {
    try {
      final query = await _firestore
          .collection(_wordsCollection)
          .where('id', isEqualTo: wordId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({
          'is_active': false,
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('✅ Word soft deleted in Firestore: $wordId');
      } else {
        throw Exception('Word not found for deletion: $wordId');
      }
    } catch (e) {
      print('💥 Firestore Error deleting word: $e');
      rethrow;
    }
  }

  // Get word by ID
  Future<WordModel?> getWordById(String wordId) async {
    try {
      // Try to get by document ID first
      final doc = await _firestore
          .collection(_wordsCollection)
          .doc(wordId)
          .get();
      if (doc.exists && doc.data() != null) {
        return WordModel.fromMap({'id': doc.id, ...doc.data()!});
      }

      // If not found, try to search by word ID field
      final query = await _firestore
          .collection(_wordsCollection)
          .where('id', isEqualTo: int.tryParse(wordId))
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return WordModel.fromMap({
          'id': query.docs.first.id,
          ...query.docs.first.data(),
        });
      }

      return null;
    } catch (e) {
      print('💥 Firestore Error getting word by ID: $e');
      return null;
    }
  }

  // Get recent words
  Future<List<WordModel>> getRecentWords({int limit = 20}) async {
    try {
      final query = await _firestore
          .collection(_wordsCollection)
          .where('is_active', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .orderBy(FieldPath.documentId, descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => WordModel.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      print('💥 Firestore Error getting recent words: $e');
      return [];
    }
  }

  // Search words
  Future<List<WordModel>> searchWords(String query) async {
    try {
      if (query.isEmpty) return [];

      final searchQuery = query.toLowerCase();

      // Search in Arabic words
      final arQuery = await _firestore
          .collection(_wordsCollection)
          .where('is_active', isEqualTo: true)
          .get();

      final results = <WordModel>[];

      for (final doc in arQuery.docs) {
        final data = doc.data();
        final wordAr = (data['word_ar'] ?? '').toString().toLowerCase();
        final wordEn = (data['word_en'] ?? '').toString().toLowerCase();
        final meaningAr = (data['meaning_ar'] ?? '').toString().toLowerCase();
        final meaningEn = (data['meaning_en'] ?? '').toString().toLowerCase();

        if (wordAr.contains(searchQuery) ||
            wordEn.contains(searchQuery) ||
            meaningAr.contains(searchQuery) ||
            meaningEn.contains(searchQuery)) {
          results.add(WordModel.fromMap({'id': doc.id, ...data}));
        }
      }

      return results;
    } catch (e) {
      print('💥 Firestore Error searching words: $e');
      return [];
    }
  }

  // Get categories
  Future<List<String>> getCategories() async {
    try {
      final query = await _firestore
          .collection(_wordsCollection)
          .where('is_active', isEqualTo: true)
          .get();

      final categories = <String>{};
      for (final doc in query.docs) {
        final category = doc.data()['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categories.add(category);
        }
      }

      return categories.toList()..sort();
    } catch (e) {
      print('💥 Firestore Error getting categories: $e');
      return [];
    }
  }

  // Get levels
  Future<List<int>> getLevels() async {
    try {
      final query = await _firestore
          .collection(_wordsCollection)
          .where('is_active', isEqualTo: true)
          .get();

      final levels = <int>{};
      for (final doc in query.docs) {
        final level = doc.data()['difficulty_level'] as int?;
        if (level != null) {
          levels.add(level);
        }
      }

      return levels.toList()..sort();
    } catch (e) {
      print('💥 Firestore Error getting levels: $e');
      return [];
    }
  }

  // Get random words
  Future<List<WordModel>> getRandomWords(
    int count, {
    String? category,
    int? level,
  }) async {
    try {
      var query = _firestore
          .collection(_wordsCollection)
          .where('is_active', isEqualTo: true);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (level != null) {
        query = query.where('difficulty_level', isEqualTo: level);
      }

      // Get more documents than needed and shuffle
      final snapshot = await query.limit(count * 3).get();
      final words = snapshot.docs
          .map((doc) => WordModel.fromMap({'id': doc.id, ...doc.data()}))
          .toList();

      words.shuffle();
      return words.take(count).toList();
    } catch (e) {
      print('💥 Firestore Error getting random words: $e');
      return [];
    }
  }

  // Favorite words operations
  Future<List<WordModel>> getFavoriteWords(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();
      if (!userDoc.exists) return [];

      final userData = userDoc.data();
      final dynamic rawFavoriteWords = userData!['favorite_words'];
      final List<dynamic> favoriteWordsList = rawFavoriteWords is List
          ? rawFavoriteWords
          : [];
      final favoriteIds = List<int>.from(favoriteWordsList.whereType<int>());

      if (favoriteIds.isEmpty) return [];

      final words = <WordModel>[];
      for (final wordId in favoriteIds) {
        final word = await getWordById(wordId.toString());
        if (word != null) {
          words.add(word);
        }
      }

      return words;
    } catch (e) {
      print('💥 Firestore Error getting favorite words: $e');
      return [];
    }
  }

  // Get favorite words by ID (alias for getFavoriteWords)
  Future<List<WordModel>> getFavoriteWordsById(String userId) async {
    return getFavoriteWords(userId);
  }

  // Add word to favorites
  Future<void> addWordToFavorites(String userId, int wordId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'favorite_words': FieldValue.arrayUnion([wordId]),
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('✅ Word added to favorites: $wordId for user $userId');
    } catch (e) {
      print('💥 Firestore Error adding word to favorites: $e');
      rethrow;
    }
  }

  // Remove word from favorites
  Future<void> removeWordFromFavorites(String userId, int wordId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'favorite_words': FieldValue.arrayRemove([wordId]),
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('✅ Word removed from favorites: $wordId for user $userId');
    } catch (e) {
      print('💥 Firestore Error removing word from favorites: $e');
      rethrow;
    }
  }

  // Mark word as learned
  Future<void> markWordAsLearned(String userId, int wordId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'learned_words': FieldValue.arrayUnion([wordId]),
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('✅ Word marked as learned: $wordId for user $userId');
    } catch (e) {
      print('💥 Firestore Error marking word as learned: $e');
      rethrow;
    }
  }

  // Add word to recent
  Future<void> addWordToRecent(String userId, int wordId) async {
    try {
      // Get current recent words
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();
      List<int> recentWords = [];

      if (userDoc.exists) {
        final dynamic rawRecentWords = userDoc.data()?['recent_words'];
        recentWords = rawRecentWords is List
            ? List<int>.from(rawRecentWords.whereType<int>())
            : [];
      }

      // Remove if already exists and add to front
      recentWords.remove(wordId);
      recentWords.insert(0, wordId);

      // Keep only last 50 recent words
      if (recentWords.length > 50) {
        recentWords = recentWords.take(50).toList();
      }

      await _firestore.collection(_usersCollection).doc(userId).update({
        'recent_words': recentWords,
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('✅ Word added to recent: $wordId for user $userId');
    } catch (e) {
      print('💥 Firestore Error adding word to recent: $e');
      rethrow;
    }
  }

  // Sentence operations
  Future<List<SentenceModel>> getSentencesByLevel(int level) async {
    try {
      final query = await _firestore
          .collection(_sentencesCollection)
          .where('difficulty_level', isEqualTo: level)
          .where('is_active', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .get();

      return query.docs
          .map((doc) => SentenceModel.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      print('💥 Firestore Error getting sentences by level: $e');
      return [];
    }
  }

  Future<List<SentenceModel>> getRandomSentences(
    int count, {
    int? level,
  }) async {
    try {
      var query = _firestore
          .collection(_sentencesCollection)
          .where('is_active', isEqualTo: true);

      if (level != null) {
        query = query.where('difficulty_level', isEqualTo: level);
      }

      // Firestore doesn't support RANDOM(), so we'll get more docs and shuffle
      final snapshot = await query.limit(count * 2).get();
      final sentences = snapshot.docs
          .map((doc) => SentenceModel.fromMap({'id': doc.id, ...doc.data()}))
          .toList();

      sentences.shuffle();
      return sentences.take(count).toList();
    } catch (e) {
      print('💥 Firestore Error getting random sentences: $e');
      return [];
    }
  }

  Future<void> createSentence(SentenceModel sentence) async {
    try {
      await _firestore.collection(_sentencesCollection).add(sentence.toMap());
      print('✅ Sentence created successfully in Firestore');
    } catch (e) {
      print('💥 Firestore Error creating sentence: $e');
      rethrow;
    }
  }

  // Game Progress operations
  Future<void> saveGameProgress(GameProgressModel progress) async {
    try {
      await _firestore
          .collection(_gameProgressCollection)
          .add(progress.toMap());
      print('✅ Game progress saved successfully in Firestore');
    } catch (e) {
      print('💥 Firestore Error saving game progress: $e');
      rethrow;
    }
  }

  Future<List<GameProgressModel>> getUserGameProgress(String userId) async {
    try {
      final query = await _firestore
          .collection(_gameProgressCollection)
          .where('user_id', isEqualTo: userId)
          .orderBy('completed_at', descending: true)
          .get();

      return query.docs
          .map(
            (doc) => GameProgressModel.fromMap({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      print('💥 Firestore Error getting user game progress: $e');
      return [];
    }
  }

  Future<GameProgressModel?> getBestScore(
    String userId,
    String gameType,
    int level,
  ) async {
    try {
      final query = await _firestore
          .collection(_gameProgressCollection)
          .where('user_id', isEqualTo: userId)
          .where('game_type', isEqualTo: gameType)
          .where('level', isEqualTo: level)
          .orderBy('score', descending: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return GameProgressModel.fromMap({
          'id': query.docs.first.id,
          ...query.docs.first.data(),
        });
      }
      return null;
    } catch (e) {
      print('💥 Firestore Error getting best score: $e');
      return null;
    }
  }

  // Statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      // Get all game progress for user
      final gameProgress = await getUserGameProgress(userId);

      if (gameProgress.isEmpty) {
        return {
          'total_games': 0,
          'total_score': 0,
          'average_score': 0.0,
          'best_score': 0,
          'total_time': 0,
          'games_by_type': <String, int>{},
        };
      }

      final totalGames = gameProgress.length;
      final totalScore = gameProgress.fold<int>(
        0,
        (acc, progress) => acc + progress.score,
      );
      final averageScore = totalScore / totalGames;
      final bestScore = gameProgress
          .map((p) => p.score)
          .reduce((a, b) => a > b ? a : b);
      final totalTime = gameProgress.fold<int>(
        0,
        (acc, progress) => acc + progress.timeSpent,
      );

      final gamesByType = <String, int>{};
      for (final progress in gameProgress) {
        gamesByType[progress.gameType] =
            (gamesByType[progress.gameType] ?? 0) + 1;
      }

      return {
        'total_games': totalGames,
        'total_score': totalScore,
        'average_score': averageScore,
        'best_score': bestScore,
        'total_time': totalTime,
        'games_by_type': gamesByType,
      };
    } catch (e) {
      print('💥 Firestore Error getting user statistics: $e');
      return {
        'total_games': 0,
        'total_score': 0,
        'average_score': 0.0,
        'best_score': 0,
        'total_time': 0,
        'games_by_type': <String, int>{},
      };
    }
  }

  // Initialize sample data (for first time setup)
  Future<void> initializeSampleData() async {
    try {
      print('🔄 Initializing sample data in Firestore...');

      // Check if data already exists
      final wordsSnapshot = await _firestore
          .collection(_wordsCollection)
          .limit(1)
          .get();
      if (wordsSnapshot.docs.isNotEmpty) {
        print('⚠️ Sample data already exists, skipping...');
        return;
      }

      // Sample Arabic words
      final sampleWords = [
        {
          'word_ar': 'كتاب',
          'word_en': 'book',
          'meaning_ar': 'مجموعة من الأوراق المطبوعة والمجلدة',
          'meaning_en': 'A set of printed pages bound together',
          'pronunciation_ar': 'كِتَاب',
          'pronunciation_en': 'book',
          'difficulty_level': 1,
          'category': 'objects',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word_ar': 'قلم',
          'word_en': 'pen',
          'pronunciation_ar': 'قَلَم',
          'pronunciation_en': 'pen',
          'difficulty_level': 1,
          'category': 'objects',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word_ar': 'بيت',
          'word_en': 'house',
          'pronunciation_ar': 'بَيْت',
          'pronunciation_en': 'house',
          'difficulty_level': 1,
          'category': 'places',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word_ar': 'شمس',
          'word_en': 'sun',
          'pronunciation_ar': 'شَمْس',
          'pronunciation_en': 'sun',
          'difficulty_level': 1,
          'category': 'nature',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'word_ar': 'قمر',
          'word_en': 'moon',
          'pronunciation_ar': 'قَمَر',
          'pronunciation_en': 'moon',
          'difficulty_level': 1,
          'category': 'nature',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      // Add words to Firestore
      final batch = _firestore.batch();
      for (final word in sampleWords) {
        final docRef = _firestore.collection(_wordsCollection).doc();
        batch.set(docRef, word);
      }

      // Sample sentences
      final sampleSentences = [
        {
          'sentence_ar': 'هذا كتاب جميل',
          'sentence_en': 'This is a beautiful book',
          'difficulty_level': 1,
          'category': 'basic',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'sentence_ar': 'القلم على الطاولة',
          'sentence_en': 'The pen is on the table',
          'difficulty_level': 1,
          'category': 'basic',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'sentence_ar': 'البيت كبير ونظيف',
          'sentence_en': 'The house is big and clean',
          'difficulty_level': 2,
          'category': 'descriptions',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      // Add sentences to batch
      for (final sentence in sampleSentences) {
        final docRef = _firestore.collection(_sentencesCollection).doc();
        batch.set(docRef, sentence);
      }

      // Commit batch
      await batch.commit();
      print('✅ Sample data initialized successfully in Firestore');
    } catch (e) {
      print('💥 Firestore Error initializing sample data: $e');
    }
  }

  // Subscription operations
  Future<void> createSubscription(SubscriptionModel subscription) async {
    try {
      await _firestore
          .collection(_subscriptionsCollection)
          .doc(subscription.id)
          .set(subscription.toMap());
      print(
        '✅ Subscription created successfully in Firestore: ${subscription.id}',
      );
    } catch (e) {
      print('💥 Firestore Error creating subscription: $e');
      rethrow;
    }
  }

  Future<List<SubscriptionModel>> getParentSubscriptions(
    String parentId,
  ) async {
    try {
      final query = await _firestore
          .collection(_subscriptionsCollection)
          .where('parent_id', isEqualTo: parentId)
          .orderBy('created_at', descending: true)
          .get();

      return query.docs
          .map((doc) => SubscriptionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('💥 Firestore Error getting parent subscriptions: $e');
      return [];
    }
  }

  Future<List<SubscriptionModel>> getTeacherSubscriptions(
    String teacherId,
  ) async {
    try {
      final query = await _firestore
          .collection(_subscriptionsCollection)
          .where('teacher_id', isEqualTo: teacherId)
          .where('status', isEqualTo: 'active')
          .get();

      return query.docs
          .map((doc) => SubscriptionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('💥 Firestore Error getting teacher subscriptions: $e');
      return [];
    }
  }

  Future<SubscriptionModel?> getSubscriptionById(String subscriptionId) async {
    try {
      final doc = await _firestore
          .collection(_subscriptionsCollection)
          .doc(subscriptionId)
          .get();

      if (doc.exists && doc.data() != null) {
        return SubscriptionModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('💥 Firestore Error getting subscription by ID: $e');
      return null;
    }
  }

  Future<void> updateSubscription(SubscriptionModel subscription) async {
    try {
      await _firestore
          .collection(_subscriptionsCollection)
          .doc(subscription.id)
          .update(subscription.toMap());
      print('✅ Subscription updated successfully: ${subscription.id}');
    } catch (e) {
      print('💥 Firestore Error updating subscription: $e');
      rethrow;
    }
  }

  // Payment operations
  Future<List<PaymentModel>> getUserPayments(String userId) async {
    try {
      final query = await _firestore
          .collection('payments')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      return query.docs
          .map((doc) => PaymentModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      print('💥 Firestore Error getting user payments: $e');
      return [];
    }
  }

  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      final doc = await _firestore.collection('payments').doc(paymentId).get();

      if (doc.exists && doc.data() != null) {
        return PaymentModel.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      print('💥 Firestore Error getting payment by ID: $e');
      return null;
    }
  }

  Future<void> createPayment(PaymentModel payment) async {
    try {
      await _firestore
          .collection('payments')
          .doc(payment.id)
          .set(payment.toJson());
      print('✅ Payment created successfully: ${payment.id}');
    } catch (e) {
      print('💥 Firestore Error creating payment: $e');
      rethrow;
    }
  }

  Future<void> updatePayment(PaymentModel payment) async {
    try {
      await _firestore
          .collection('payments')
          .doc(payment.id)
          .update(payment.toJson());
      print('✅ Payment updated successfully: ${payment.id}');
    } catch (e) {
      print('💥 Firestore Error updating payment: $e');
      rethrow;
    }
  }

  // Daily Activities operations
  Future<void> createDailyActivity(DailyActivityModel activity) async {
    try {
      await _firestore
          .collection(_dailyActivitiesCollection)
          .doc(activity.id)
          .set(activity.toMap());
      print('✅ Daily activity created successfully: ${activity.id}');
    } catch (e) {
      print('💥 Firestore Error creating daily activity: $e');
      rethrow;
    }
  }

  Future<List<DailyActivityModel>> getChildDailyActivities(
    String childId, {
    DateTime? date,
  }) async {
    try {
      var query = _firestore
          .collection(_dailyActivitiesCollection)
          .where('child_id', isEqualTo: childId);

      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
        query = query
            .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
            .where('date', isLessThanOrEqualTo: endOfDay.toIso8601String());
      }

      final snapshot = await query.orderBy('date', descending: true).get();
      return snapshot.docs
          .map((doc) => DailyActivityModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('💥 Firestore Error getting child daily activities: $e');
      return [];
    }
  }

  Future<void> completeActivityItem(
    String activityId,
    String itemId, {
    int? score,
    Duration? timeSpent,
  }) async {
    try {
      // This would require reading the document, updating the specific item, and writing back
      // For simplicity, we'll create a separate collection for activity completions
      final completion = {
        'activity_id': activityId,
        'item_id': itemId,
        'completed_at': DateTime.now().toIso8601String(),
        'score': score,
        'time_spent': timeSpent?.inSeconds,
      };

      await _firestore.collection('activity_completions').add(completion);
      print('✅ Activity item completed: $itemId');
    } catch (e) {
      print('💥 Firestore Error completing activity item: $e');
      rethrow;
    }
  }

  // Classroom operations
  Future<void> createClassroom(ClassroomModel classroom) async {
    try {
      await _firestore
          .collection(_classroomsCollection)
          .doc(classroom.id)
          .set(classroom.toMap());
      print('✅ Classroom created successfully: ${classroom.id}');
    } catch (e) {
      print('💥 Firestore Error creating classroom: $e');
      rethrow;
    }
  }

  Future<List<ClassroomModel>> getTeacherClassrooms(String teacherId) async {
    try {
      final query = await _firestore
          .collection(_classroomsCollection)
          .where('teacher_id', isEqualTo: teacherId)
          .where('is_active', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .get();

      return query.docs
          .map((doc) => ClassroomModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('💥 Firestore Error getting teacher classrooms: $e');
      return [];
    }
  }

  Future<List<ClassroomModel>> getStudentClassrooms(String studentId) async {
    try {
      final query = await _firestore
          .collection(_classroomsCollection)
          .where('student_ids', arrayContains: studentId)
          .where('is_active', isEqualTo: true)
          .get();

      return query.docs
          .map((doc) => ClassroomModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('💥 Firestore Error getting student classrooms: $e');
      return [];
    }
  }

  Future<void> addStudentToClassroom(
    String classroomId,
    String studentId,
    String parentId,
  ) async {
    try {
      await _firestore
          .collection(_classroomsCollection)
          .doc(classroomId)
          .update({
            'student_ids': FieldValue.arrayUnion([studentId]),
            'parent_ids': FieldValue.arrayUnion([parentId]),
            'updated_at': DateTime.now().toIso8601String(),
          });
      print('✅ Student added to classroom: $studentId -> $classroomId');
    } catch (e) {
      print('💥 Firestore Error adding student to classroom: $e');
      rethrow;
    }
  }

  Future<void> removeStudentFromClassroom(
    String classroomId,
    String studentId,
    String parentId,
  ) async {
    try {
      await _firestore
          .collection(_classroomsCollection)
          .doc(classroomId)
          .update({
            'student_ids': FieldValue.arrayRemove([studentId]),
            'parent_ids': FieldValue.arrayRemove([parentId]),
            'updated_at': DateTime.now().toIso8601String(),
          });
      print('✅ Student removed from classroom: $studentId');
    } catch (e) {
      print('💥 Firestore Error removing student from classroom: $e');
      rethrow;
    }
  }

  // Teacher Dashboard Statistics
  Future<Map<String, dynamic>> getTeacherDashboardStats(
    String teacherId,
  ) async {
    try {
      // Get teacher's classrooms
      final classrooms = await getTeacherClassrooms(teacherId);
      final subscriptions = await getTeacherSubscriptions(teacherId);

      final totalStudents = classrooms.fold<int>(
        0,
        (acc, classroom) => acc + classroom.studentCount,
      );
      final activeSubscriptions = subscriptions.length;
      final totalRevenue = subscriptions.fold<double>(
        0,
        (acc, sub) => acc + sub.amount,
      );

      return {
        'total_classrooms': classrooms.length,
        'total_students': totalStudents,
        'active_subscriptions': activeSubscriptions,
        'total_revenue': totalRevenue,
        'avg_students_per_classroom': classrooms.isEmpty
            ? 0.0
            : totalStudents / classrooms.length,
      };
    } catch (e) {
      print('💥 Firestore Error getting teacher dashboard stats: $e');
      return {
        'total_classrooms': 0,
        'total_students': 0,
        'active_subscriptions': 0,
        'total_revenue': 0.0,
        'avg_students_per_classroom': 0.0,
      };
    }
  }

  // Parent Dashboard Statistics
  Future<Map<String, dynamic>> getParentDashboardStats(String parentId) async {
    try {
      final children = await getChildrenByParentId(parentId);
      final subscriptions = await getParentSubscriptions(parentId);

      final activeSubscriptions = subscriptions.length;
      final totalSpent = subscriptions.fold<double>(
        0,
        (acc, sub) => acc + sub.amount,
      );

      // Get today's activities for all children
      int totalTodayActivities = 0;
      int completedTodayActivities = 0;

      for (final child in children) {
        final activities = await getChildDailyActivities(
          child.id,
          date: DateTime.now(),
        );
        for (final activity in activities) {
          totalTodayActivities += activity.activities.length;
          completedTodayActivities += 0;
        }
      }

      return {
        'total_children': children.length,
        'active_subscriptions': activeSubscriptions,
        'total_spent': totalSpent,
        'today_activities': totalTodayActivities,
        'completed_activities': completedTodayActivities,
        'completion_rate': totalTodayActivities > 0
            ? completedTodayActivities / totalTodayActivities
            : 0.0,
      };
    } catch (e) {
      print('💥 Firestore Error getting parent dashboard stats: $e');
      return {
        'total_children': 0,
        'active_subscriptions': 0,
        'total_spent': 0.0,
        'today_activities': 0,
        'completed_activities': 0,
        'completion_rate': 0.0,
      };
    }
  }

  // ==================== PAYMENT OPERATIONS ====================

  // Get payments by subscription
  Future<List<PaymentModel>> getSubscriptionPayments(
    String subscriptionId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('payments')
          .where('subscriptionId', isEqualTo: subscriptionId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PaymentModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('💥 Firestore Error getting subscription payments: $e');
      return [];
    }
  }

  // Refund operations
  Future<void> createRefundRequest(RefundRequest refund) async {
    try {
      await _firestore
          .collection(_refundsCollection)
          .doc(refund.id)
          .set(refund.toMap());
      print('✅ Refund request created successfully: ${refund.id}');
    } catch (e) {
      print('💥 Firestore Error creating refund request: $e');
      rethrow;
    }
  }
}
