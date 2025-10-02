import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/game_progress_model.dart';
import '../models/sentence_model.dart';
import '../models/user_model.dart';
import '../models/word_model.dart';

class DatabaseService {
  DatabaseService._init();
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('learning_words.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        user_type TEXT NOT NULL,
        age INTEGER,
        profile_image_url TEXT,
        parent_id TEXT,
        is_google_user INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Words table
    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_ar TEXT NOT NULL,
        word_en TEXT NOT NULL,
        meaning_ar TEXT,
        meaning_en TEXT,
        pronunciation_ar TEXT,
        pronunciation_en TEXT,
        image_url TEXT,
        audio_url_ar TEXT,
        audio_url_en TEXT,
        difficulty_level INTEGER NOT NULL DEFAULT 1,
        category TEXT,
        created_by TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // Sentences table
    await db.execute('''
      CREATE TABLE sentences (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sentence_ar TEXT NOT NULL,
        sentence_en TEXT NOT NULL,
        audio_url_ar TEXT,
        audio_url_en TEXT,
        difficulty_level INTEGER NOT NULL DEFAULT 1,
        category TEXT,
        created_by TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // Game Progress table
    await db.execute('''
      CREATE TABLE game_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        game_type TEXT NOT NULL,
        level INTEGER NOT NULL,
        score INTEGER NOT NULL,
        max_score INTEGER NOT NULL,
        time_spent INTEGER NOT NULL,
        completed_at TEXT NOT NULL,
        language TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // User Achievements table
    await db.execute('''
      CREATE TABLE user_achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        achievement_type TEXT NOT NULL,
        achievement_data TEXT,
        earned_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Learning Sessions table
    await db.execute('''
      CREATE TABLE learning_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        session_type TEXT NOT NULL,
        duration INTEGER NOT NULL,
        words_learned INTEGER DEFAULT 0,
        accuracy_rate REAL DEFAULT 0.0,
        started_at TEXT NOT NULL,
        ended_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Insert sample data
    await _insertSampleData(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add meaning columns to words table
      await db.execute('ALTER TABLE words ADD COLUMN meaning_ar TEXT');
      await db.execute('ALTER TABLE words ADD COLUMN meaning_en TEXT');
    }
  }

  Future<void> _insertSampleData(Database db) async {
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
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'word_ar': 'قلم',
        'word_en': 'pen',
        'pronunciation_ar': 'قَلَم',
        'pronunciation_en': 'pen',
        'difficulty_level': 1,
        'category': 'objects',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'word_ar': 'بيت',
        'word_en': 'house',
        'pronunciation_ar': 'بَيْت',
        'pronunciation_en': 'house',
        'difficulty_level': 1,
        'category': 'places',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'word_ar': 'شمس',
        'word_en': 'sun',
        'pronunciation_ar': 'شَمْس',
        'pronunciation_en': 'sun',
        'difficulty_level': 1,
        'category': 'nature',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'word_ar': 'قمر',
        'word_en': 'moon',
        'pronunciation_ar': 'قَمَر',
        'pronunciation_en': 'moon',
        'difficulty_level': 1,
        'category': 'nature',
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final word in sampleWords) {
      await db.insert('words', word);
    }

    // Sample sentences
    final sampleSentences = [
      {
        'sentence_ar': 'هذا كتاب جميل',
        'sentence_en': 'This is a beautiful book',
        'difficulty_level': 1,
        'category': 'basic',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'sentence_ar': 'القلم على الطاولة',
        'sentence_en': 'The pen is on the table',
        'difficulty_level': 1,
        'category': 'basic',
        'created_at': DateTime.now().toIso8601String(),
      },
      {
        'sentence_ar': 'البيت كبير ونظيف',
        'sentence_en': 'The house is big and clean',
        'difficulty_level': 2,
        'category': 'descriptions',
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final sentence in sampleSentences) {
      await db.insert('sentences', sentence);
    }
  }

  // User operations
  Future<void> createUser(UserModel user) async {
    try {
      print('🔄 Creating user: ${user.id} - ${user.email}');
      final db = await instance.database;

      // Check if user already exists
      final existingUser = await getUserById(user.id);
      if (existingUser != null) {
        print('⚠️ User already exists, updating instead...');
        await updateUser(user);
        return;
      }

      await db.insert('users', user.toMap());
      print('✅ User created successfully: ${user.id}');
    } catch (e) {
      print('💥 Database Error creating user: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<UserModel>> getChildrenByParentId(String parentId) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'parent_id = ? AND user_type = ?',
      whereArgs: [parentId, 'child'],
    );

    return maps.map(UserModel.fromMap).toList();
  }

  Future<void> updateUser(UserModel user) async {
    final db = await instance.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(String id) async {
    final db = await instance.database;
    await db.update(
      'users',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Word operations
  Future<List<WordModel>> getWordsByLevel(int level, {String? language}) async {
    final db = await instance.database;
    final maps = await db.query(
      'words',
      where: 'difficulty_level = ? AND is_active = 1',
      whereArgs: [level],
      orderBy: 'created_at DESC',
    );

    return maps.map(WordModel.fromMap).toList();
  }

  Future<List<WordModel>> getWordsByCategory(String category) async {
    final db = await instance.database;
    final maps = await db.query(
      'words',
      where: 'category = ? AND is_active = 1',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );

    return maps.map(WordModel.fromMap).toList();
  }

  Future<void> createWord(WordModel word) async {
    final db = await instance.database;
    await db.insert('words', word.toMap());
  }

  // Sentence operations
  Future<List<SentenceModel>> getSentencesByLevel(int level) async {
    final db = await instance.database;
    final maps = await db.query(
      'sentences',
      where: 'difficulty_level = ? AND is_active = 1',
      whereArgs: [level],
      orderBy: 'created_at DESC',
    );

    return maps.map(SentenceModel.fromMap).toList();
  }

  Future<List<SentenceModel>> getRandomSentences(
    int count, {
    int? level,
  }) async {
    final db = await instance.database;
    String whereClause = 'is_active = 1';
    List<dynamic> whereArgs = [];

    if (level != null) {
      whereClause += ' AND difficulty_level = ?';
      whereArgs.add(level);
    }

    final maps = await db.query(
      'sentences',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'RANDOM()',
      limit: count,
    );

    return maps.map(SentenceModel.fromMap).toList();
  }

  Future<void> createSentence(SentenceModel sentence) async {
    final db = await instance.database;
    await db.insert('sentences', sentence.toMap());
  }

  // Game Progress operations
  Future<void> saveGameProgress(GameProgressModel progress) async {
    final db = await instance.database;
    await db.insert('game_progress', progress.toMap());
  }

  Future<List<GameProgressModel>> getUserGameProgress(String userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'game_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'completed_at DESC',
    );

    return maps.map(GameProgressModel.fromMap).toList();
  }

  Future<GameProgressModel?> getBestScore(
    String userId,
    String gameType,
    int level,
  ) async {
    final db = await instance.database;
    final maps = await db.query(
      'game_progress',
      where: 'user_id = ? AND game_type = ? AND level = ?',
      whereArgs: [userId, gameType, level],
      orderBy: 'score DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return GameProgressModel.fromMap(maps.first);
    }
    return null;
  }

  // Statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    final db = await instance.database;

    // Total games played
    final totalGamesResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM game_progress WHERE user_id = ?',
      [userId],
    );
    final totalGames = totalGamesResult.first['count']! as int;

    // Average score
    final avgScoreResult = await db.rawQuery(
      'SELECT AVG(score) as avg_score FROM game_progress WHERE user_id = ?',
      [userId],
    );
    final avgScore = (avgScoreResult.first['avg_score'] as double?) ?? 0.0;

    // Total time spent (in minutes)
    final totalTimeResult = await db.rawQuery(
      'SELECT SUM(time_spent) as total_time FROM game_progress WHERE user_id = ?',
      [userId],
    );
    final totalTime = (totalTimeResult.first['total_time'] as int?) ?? 0;

    // Games by type
    final gamesByTypeResult = await db.rawQuery(
      'SELECT game_type, COUNT(*) as count FROM game_progress WHERE user_id = ? GROUP BY game_type',
      [userId],
    );

    final gamesByType = <String, int>{};
    for (final row in gamesByTypeResult) {
      gamesByType[row['game_type']! as String] = row['count']! as int;
    }

    return {
      'totalGames': totalGames,
      'averageScore': avgScore,
      'totalTimeMinutes': (totalTime / 60).round(),
      'gamesByType': gamesByType,
    };
  }

  // Learning Sessions
  Future<void> startLearningSession(String userId, String sessionType) async {
    final db = await instance.database;
    await db.insert('learning_sessions', {
      'user_id': userId,
      'session_type': sessionType,
      'duration': 0,
      'started_at': DateTime.now().toIso8601String(),
      'ended_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> endLearningSession(
    int sessionId,
    int duration,
    int wordsLearned,
    double accuracyRate,
  ) async {
    final db = await instance.database;
    await db.update(
      'learning_sessions',
      {
        'duration': duration,
        'words_learned': wordsLearned,
        'accuracy_rate': accuracyRate,
        'ended_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // Game Progress operations
  Future<List<GameProgressModel>> getAllGameProgress(String userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'game_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'completed_at DESC',
    );

    return maps.map(GameProgressModel.fromMap).toList();
  }

  Future<void> insertGameProgress(GameProgressModel progress) async {
    final db = await instance.database;
    await db.insert('game_progress', progress.toMap());
  }

  Future<void> updateGameProgress(GameProgressModel progress) async {
    final db = await instance.database;
    await db.update(
      'game_progress',
      progress.toMap(),
      where: 'id = ?',
      whereArgs: [progress.id],
    );
  }

  // Words operations
  Future<List<WordModel>> getAllWords() async {
    final db = await instance.database;
    final maps = await db.query('words', orderBy: 'word_ar ASC');
    return maps.map(WordModel.fromMap).toList();
  }

  Future<List<WordModel>> getRecentWords({int limit = 10}) async {
    final db = await instance.database;
    final maps = await db.query(
      'words',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map(WordModel.fromMap).toList();
  }

  Future<List<WordModel>> getFavoriteWords(String userId) async {
    final db = await instance.database;
    // This would require a favorites table, for now return empty list
    return <WordModel>[];
  }

  Future<List<WordModel>> searchWords(String query) async {
    final db = await instance.database;
    final maps = await db.query(
      'words',
      where:
          'word_ar LIKE ? OR word_en LIKE ? OR meaning_ar LIKE ? OR meaning_en LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'word_ar ASC',
    );
    return maps.map(WordModel.fromMap).toList();
  }

  Future<WordModel?> getWordById(int id) async {
    final db = await instance.database;
    final maps = await db.query('words', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return WordModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<String>> getCategories() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT category FROM words WHERE category IS NOT NULL ORDER BY category',
    );
    return result.map((row) => row['category']! as String).toList();
  }

  Future<List<int>> getLevels() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT difficulty_level FROM words ORDER BY difficulty_level',
    );
    return result.map((row) => row['difficulty_level']! as int).toList();
  }

  // Word actions
  Future<void> addWordToFavorites(String userId, int wordId) async {
    // This would require a favorites table, for now do nothing
  }

  Future<void> removeWordFromFavorites(String userId, int wordId) async {
    // This would require a favorites table, for now do nothing
  }

  Future<void> markWordAsLearned(String userId, int wordId) async {
    // This would require a learned_words table, for now do nothing
  }

  Future<void> addWordToRecent(String userId, int wordId) async {
    // This would require a recent_words table, for now do nothing
  }

  Future<int> insertWord(WordModel word) async {
    final db = await instance.database;
    return db.insert('words', word.toMap());
  }

  Future<void> updateWord(WordModel word) async {
    final db = await instance.database;
    await db.update(
      'words',
      word.toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  Future<void> deleteWord(int wordId) async {
    final db = await instance.database;
    await db.delete('words', where: 'id = ?', whereArgs: [wordId]);
  }

  Future<List<WordModel>> getRandomWords(
    int count, {
    String? category,
    int? level,
  }) async {
    final db = await instance.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (category != null) {
      whereClause = 'category = ?';
      whereArgs.add(category);
    }

    if (level != null) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += 'difficulty_level = ?';
      whereArgs.add(level);
    }

    final maps = await db.query(
      'words',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'RANDOM()',
      limit: count,
    );

    return maps.map(WordModel.fromMap).toList();
  }

  // Database management
  Future<void> initDatabase() async {
    await database;
  }

  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'learning_words.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
