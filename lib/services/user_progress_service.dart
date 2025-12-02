import 'package:shared_preferences/shared_preferences.dart';

/// User Progress Model - represents all gamification stats
class UserStats {
  final int totalXP;
  final int questionsSolved;
  final int currentStreak;
  final String lastStudyDate;
  final String rankTitle;

  UserStats({
    required this.totalXP,
    required this.questionsSolved,
    required this.currentStreak,
    required this.lastStudyDate,
    required this.rankTitle,
  });

  UserStats copyWith({
    int? totalXP,
    int? questionsSolved,
    int? currentStreak,
    String? lastStudyDate,
    String? rankTitle,
  }) {
    return UserStats(
      totalXP: totalXP ?? this.totalXP,
      questionsSolved: questionsSolved ?? this.questionsSolved,
      currentStreak: currentStreak ?? this.currentStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      rankTitle: rankTitle ?? this.rankTitle,
    );
  }
}

/// Singleton Service for User Progress Persistence
class UserProgressService {
  static final UserProgressService _instance = UserProgressService._internal();
  factory UserProgressService() => _instance;
  UserProgressService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // Storage Keys
  static const String _keyTotalXP = 'user_total_xp';
  static const String _keyQuestionsSolved = 'user_questions_solved';
  static const String _keyCurrentStreak = 'user_current_streak';
  static const String _keyLastStudyDate = 'user_last_study_date';

  // Rank Thresholds (XP-based progression)
  static const Map<String, int> _rankThresholds = {
    'Newbie Scholar': 0,
    'Bronze Learner': 500,
    'Silver Scholar': 1000,
    'Gold Achiever': 2500,
    'Platinum Master': 5000,
    'Diamond Legend': 10000,
    'Ultimate Sage': 20000,
  };

  /// Initialize service - MUST be called before first use
  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (!_isInitialized || _prefs == null) {
      throw StateError(
        'UserProgressService not initialized. Call init() first.',
      );
    }
  }

  /// Get current total XP
  int getTotalXP() {
    _ensureInitialized();
    return _prefs!.getInt(_keyTotalXP) ?? 0;
  }

  /// Get total questions solved
  int getQuestionsSolved() {
    _ensureInitialized();
    return _prefs!.getInt(_keyQuestionsSolved) ?? 0;
  }

  /// Get current streak
  int getCurrentStreak() {
    _ensureInitialized();
    return _prefs!.getInt(_keyCurrentStreak) ?? 0;
  }

  /// Get last study date (ISO 8601 format)
  String getLastStudyDate() {
    _ensureInitialized();
    return _prefs!.getString(_keyLastStudyDate) ?? '';
  }

  /// Calculate rank title based on current XP
  String getRankTitle() {
    final xp = getTotalXP();
    String currentRank = 'Newbie Scholar';

    for (final entry in _rankThresholds.entries) {
      if (xp >= entry.value) {
        currentRank = entry.key;
      } else {
        break;
      }
    }

    return currentRank;
  }

  /// Add XP and check for rank up
  /// Returns true if user ranked up
  Future<bool> addXP(int amount) async {
    _ensureInitialized();

    final oldXP = getTotalXP();
    final newXP = oldXP + amount;
    final oldRank = getRankTitle();

    await _prefs!.setInt(_keyTotalXP, newXP);

    // Check if ranked up
    final newRank = getRankTitle();
    return newRank != oldRank;
  }

  /// Increment questions solved counter
  Future<void> incrementSolved() async {
    _ensureInitialized();
    final current = getQuestionsSolved();
    await _prefs!.setInt(_keyQuestionsSolved, current + 1);
  }

  /// Update streak based on study date logic
  /// Call this whenever user completes a question
  Future<void> updateStreak() async {
    _ensureInitialized();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStudyStr = getLastStudyDate();

    if (lastStudyStr.isEmpty) {
      // First time studying
      await _prefs!.setInt(_keyCurrentStreak, 1);
      await _prefs!.setString(_keyLastStudyDate, today.toIso8601String());
      return;
    }

    final lastStudy = DateTime.parse(lastStudyStr);
    final lastStudyDay = DateTime(
      lastStudy.year,
      lastStudy.month,
      lastStudy.day,
    );
    final difference = today.difference(lastStudyDay).inDays;

    if (difference == 0) {
      // Same day - no change to streak
      return;
    } else if (difference == 1) {
      // Consecutive day - increment streak
      final currentStreak = getCurrentStreak();
      await _prefs!.setInt(_keyCurrentStreak, currentStreak + 1);
      await _prefs!.setString(_keyLastStudyDate, today.toIso8601String());
    } else {
      // Streak broken - reset to 1
      await _prefs!.setInt(_keyCurrentStreak, 1);
      await _prefs!.setString(_keyLastStudyDate, today.toIso8601String());
    }
  }

  /// Get all stats as a model
  UserStats getStats() {
    _ensureInitialized();

    return UserStats(
      totalXP: getTotalXP(),
      questionsSolved: getQuestionsSolved(),
      currentStreak: getCurrentStreak(),
      lastStudyDate: getLastStudyDate(),
      rankTitle: getRankTitle(),
    );
  }

  /// Reset all progress (for testing or user request)
  Future<void> resetProgress() async {
    _ensureInitialized();
    await _prefs!.setInt(_keyTotalXP, 0);
    await _prefs!.setInt(_keyQuestionsSolved, 0);
    await _prefs!.setInt(_keyCurrentStreak, 0);
    await _prefs!.setString(_keyLastStudyDate, '');
  }

  /// Get XP needed for next rank
  int getXPForNextRank() {
    final currentXP = getTotalXP();
    final rankList = _rankThresholds.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    for (final entry in rankList) {
      if (currentXP < entry.value) {
        return entry.value - currentXP;
      }
    }

    // Already at max rank
    return 0;
  }

  /// Get next rank title
  String getNextRankTitle() {
    final currentXP = getTotalXP();
    final rankList = _rankThresholds.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    for (final entry in rankList) {
      if (currentXP < entry.value) {
        return entry.key;
      }
    }

    // Already at max rank
    return 'Ultimate Sage';
  }
}
