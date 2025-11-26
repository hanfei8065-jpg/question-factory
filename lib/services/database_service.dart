import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/question.dart';
import '../models/user_progress.dart';
import 'dart:convert';

class DatabaseService {
  static Database? _database;
  static const String dbName = 'learnest.db';

  // 获取数据库实例
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 初始化数据库
  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 创建用户进度表
        await db.execute('''
          CREATE TABLE user_progress (
            userId TEXT PRIMARY KEY,
            currentLevelId TEXT,
            goldCoin INTEGER,
            exp INTEGER,
            streakDays INTEGER,
            wrongQuestionIds TEXT,
            levelStars TEXT,
            completedLevels TEXT,
            unlockedWorlds TEXT,
            achievements TEXT,
            lastPlayDate TEXT
          )
        ''');

        // 创建题目表
        await db.execute('''
          CREATE TABLE questions (
            id TEXT PRIMARY KEY,
            content TEXT,
            options TEXT,
            answer TEXT,
            explanation TEXT,
            subject TEXT,
            grade INTEGER,
            type TEXT,
            difficulty INTEGER,
            tags TEXT
          )
        ''');
      },
    );
  }

  // 保存用户进度
  static Future<void> saveUserProgress(UserProgress progress) async {
    final db = await database;
    await db.insert('user_progress', {
      'userId': progress.userId,
      'currentLevelId': progress.currentLevelId,
      'goldCoin': progress.goldCoin,
      'exp': progress.exp,
      'streakDays': progress.streakDays,
      'wrongQuestionIds': jsonEncode(progress.wrongQuestionIds),
      'levelStars': jsonEncode(progress.levelStars),
      'completedLevels': jsonEncode(progress.completedLevels),
      'unlockedWorlds': jsonEncode(progress.unlockedWorlds),
      'achievements': jsonEncode(progress.achievements),
      'lastPlayDate': progress.lastPlayDate.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 获取用户进度
  static Future<UserProgress?> getUserProgress(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_progress',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;

    return UserProgress(
      userId: maps[0]['userId'],
      currentLevelId: maps[0]['currentLevelId'],
      goldCoin: maps[0]['goldCoin'],
      exp: maps[0]['exp'],
      streakDays: maps[0]['streakDays'],
      wrongQuestionIds: List<String>.from(
        jsonDecode(maps[0]['wrongQuestionIds']),
      ),
      levelStars: Map<String, int>.from(jsonDecode(maps[0]['levelStars'])),
      completedLevels: List<String>.from(
        jsonDecode(maps[0]['completedLevels']),
      ),
      unlockedWorlds: List<String>.from(jsonDecode(maps[0]['unlockedWorlds'])),
      achievements: jsonDecode(maps[0]['achievements']),
      lastPlayDate: DateTime.parse(maps[0]['lastPlayDate']),
    );
  }

  // 保存题目
  static Future<void> saveQuestions(List<Question> questions) async {
    final db = await database;
    final batch = db.batch();

    for (final question in questions) {
      batch.insert('questions', {
        'id': question.id,
        'content': question.content,
        'options': jsonEncode(question.options),
        'answer': question.answer,
        'explanation': question.explanation,
        'subject': question.subject.toString().split('.').last,
        'grade': question.grade,
        'type': question.type.toString().split('.').last,
        'difficulty': question.difficulty,
        'tags': jsonEncode(question.tags),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
  }

  // 获取题目
  static Future<List<Question>> getQuestions({
    String? subject,
    int? grade,
    QuestionType? type,
    List<String>? ids,
  }) async {
    final db = await database;

    String whereClause = '1 = 1';
    List<dynamic> whereArgs = [];

    if (subject != null) {
      whereClause += ' AND subject = ?';
      whereArgs.add(subject);
    }
    if (grade != null) {
      whereClause += ' AND grade = ?';
      whereArgs.add(grade);
    }
    if (type != null) {
      whereClause += ' AND type = ?';
      whereArgs.add(type.toString().split('.').last);
    }
    if (ids != null && ids.isNotEmpty) {
      whereClause += ' AND id IN (${List.filled(ids.length, '?').join(',')})';
      whereArgs.addAll(ids);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return List.generate(maps.length, (i) {
      return Question(
        id: maps[i]['id'],
        content: maps[i]['content'],
        options: List<String>.from(jsonDecode(maps[i]['options'])),
        answer: maps[i]['answer'],
        explanation: maps[i]['explanation'],
        subject: Subject.values.firstWhere(
          (e) => e.toString().split('.').last == maps[i]['subject'],
        ),
        grade: maps[i]['grade'],
        type: QuestionType.values.firstWhere(
          (e) => e.toString().split('.').last == maps[i]['type'],
        ),
        difficulty: maps[i]['difficulty'],
        tags: List<String>.from(jsonDecode(maps[i]['tags'])),
      );
    });
  }

  // 获取错题本
  static Future<List<Question>> getWrongQuestions(String userId) async {
    final progress = await getUserProgress(userId);
    if (progress == null || progress.wrongQuestionIds.isEmpty) {
      return [];
    }
    return getQuestions(ids: progress.wrongQuestionIds);
  }

  // 添加错题
  static Future<void> addWrongQuestion(String userId, String questionId) async {
    final progress = await getUserProgress(userId);
    if (progress == null) return;

    if (!progress.wrongQuestionIds.contains(questionId)) {
      final updatedProgress = progress.copyWith(
        wrongQuestionIds: [...progress.wrongQuestionIds, questionId],
      );
      await saveUserProgress(updatedProgress);
    }
  }

  // 从错题本移除
  static Future<void> removeWrongQuestion(
    String userId,
    String questionId,
  ) async {
    final progress = await getUserProgress(userId);
    if (progress == null) return;

    final updatedProgress = progress.copyWith(
      wrongQuestionIds: progress.wrongQuestionIds
          .where((id) => id != questionId)
          .toList(),
    );
    await saveUserProgress(updatedProgress);
  }
}
