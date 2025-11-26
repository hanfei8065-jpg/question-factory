import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';
import '../services/database_service.dart';

class UserProgressProvider with ChangeNotifier {
  UserProgress? _progress;
  String _userId = 'default_user'; // 简化处理，使用固定用户ID

  UserProgress? get progress => _progress;

  // 获取用户总星星数
  int get totalStars {
    if (_progress == null) return 0;
    return _progress!.levelStars.values.fold(0, (sum, stars) => sum + stars);
  }

  // 初始化用户进度
  Future<void> initialize() async {
    _progress = await DatabaseService.getUserProgress(_userId);
    if (_progress == null) {
      // 创建新用户进度
      _progress = UserProgress(
        userId: _userId,
        currentLevelId: 'level_math_1_1',
        goldCoin: 0,
        exp: 0,
        streakDays: 0,
        wrongQuestionIds: [],
        levelStars: {},
        completedLevels: [],
        unlockedWorlds: ['world_math_1'],
        achievements: {},
        lastPlayDate: DateTime.now(),
      );
      await DatabaseService.saveUserProgress(_progress!);
    }
    notifyListeners();
  }

  // 更新关卡进度
  Future<void> updateLevelProgress(String levelId, int stars) async {
    if (_progress == null) return;

    final updatedProgress = _progress!.copyWith(
      levelStars: {..._progress!.levelStars, levelId: stars},
      completedLevels: [
        ..._progress!.completedLevels,
        if (!_progress!.completedLevels.contains(levelId)) levelId,
      ],
    );

    await DatabaseService.saveUserProgress(updatedProgress);
    _progress = updatedProgress;
    notifyListeners();
  }

  // 添加金币和经验
  Future<void> addRewards(int coins, int exp) async {
    if (_progress == null) return;

    final updatedProgress = _progress!.copyWith(
      goldCoin: _progress!.goldCoin + coins,
      exp: _progress!.exp + exp,
    );

    await DatabaseService.saveUserProgress(updatedProgress);
    _progress = updatedProgress;
    notifyListeners();
  }

  // 解锁新世界
  Future<void> unlockWorld(String worldId) async {
    if (_progress == null) return;

    if (!_progress!.unlockedWorlds.contains(worldId)) {
      final updatedProgress = _progress!.copyWith(
        unlockedWorlds: [..._progress!.unlockedWorlds, worldId],
      );

      await DatabaseService.saveUserProgress(updatedProgress);
      _progress = updatedProgress;
      notifyListeners();
    }
  }

  // 更新连续天数
  Future<void> updateStreakDays() async {
    if (_progress == null) return;

    final now = DateTime.now();
    final lastPlay = _progress!.lastPlayDate;
    final difference = now.difference(lastPlay).inDays;

    int newStreakDays = _progress!.streakDays;
    if (difference == 1) {
      // 连续打卡
      newStreakDays++;
    } else if (difference > 1) {
      // 中断连续打卡
      newStreakDays = 1;
    }

    final updatedProgress = _progress!.copyWith(
      streakDays: newStreakDays,
      lastPlayDate: now,
    );

    await DatabaseService.saveUserProgress(updatedProgress);
    _progress = updatedProgress;
    notifyListeners();
  }

  // 添加错题
  Future<void> addWrongQuestion(String questionId) async {
    if (_progress == null) return;

    await DatabaseService.addWrongQuestion(_userId, questionId);
    _progress = await DatabaseService.getUserProgress(_userId);
    notifyListeners();
  }

  // 移除错题
  Future<void> removeWrongQuestion(String questionId) async {
    if (_progress == null) return;

    await DatabaseService.removeWrongQuestion(_userId, questionId);
    _progress = await DatabaseService.getUserProgress(_userId);
    notifyListeners();
  }

  // 获取关卡星级
  int getLevelStars(String levelId) {
    if (_progress == null) return 0;
    return _progress!.levelStars[levelId] ?? 0;
  }

  // 检查关卡是否完成
  bool isLevelCompleted(String levelId) {
    if (_progress == null) return false;
    return _progress!.completedLevels.contains(levelId);
  }

  // 检查世界是否解锁
  bool isWorldUnlocked(String worldId) {
    if (_progress == null) return false;
    return _progress!.unlockedWorlds.contains(worldId);
  }
}
