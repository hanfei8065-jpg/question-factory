import 'package:shared_preferences/shared_preferences.dart';

class UserProgressService {
  static final UserProgressService _instance = UserProgressService._internal();
  factory UserProgressService() => _instance;
  UserProgressService._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // Get total questions answered
  int getTotalQuestions() => _prefs.getInt('total_questions') ?? 0;

  // Get accuracy percentage
  double getAccuracy() => _prefs.getDouble('accuracy') ?? 0.0;

  // Get total study time in minutes
  int getStudyTime() => _prefs.getInt('study_time') ?? 0;

  // Increment question count
  Future<void> incrementQuestions() async {
    int current = getTotalQuestions();
    await _prefs.setInt('total_questions', current + 1);
  }

  // Update accuracy
  Future<void> updateAccuracy(double accuracy) async {
    await _prefs.setDouble('accuracy', accuracy);
  }

  // Add study time
  Future<void> addStudyTime(int minutes) async {
    int current = getStudyTime();
    await _prefs.setInt('study_time', current + minutes);
  }

  // Add XP (experience points) - returns true if user ranked up
  Future<bool> addXP(int xp) async {
    int currentXP = _prefs.getInt('user_xp') ?? 0;
    int currentLevel = _prefs.getInt('user_level') ?? 1;
    int newXP = currentXP + xp;

    // Simple level up logic: 100 XP per level
    int xpForNextLevel = currentLevel * 100;
    bool rankedUp = false;

    if (newXP >= xpForNextLevel) {
      currentLevel++;
      newXP -= xpForNextLevel;
      rankedUp = true;
      await _prefs.setInt('user_level', currentLevel);
    }

    await _prefs.setInt('user_xp', newXP);
    return rankedUp;
  }

  // Increment solved questions count
  Future<void> incrementSolved() async {
    int current = _prefs.getInt('solved_count') ?? 0;
    await _prefs.setInt('solved_count', current + 1);
  }

  // Update daily streak
  Future<void> updateStreak() async {
    String? lastSolvedDate = _prefs.getString('last_solved_date');
    String today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD

    if (lastSolvedDate == null) {
      // First time solving
      await _prefs.setInt('current_streak', 1);
    } else if (lastSolvedDate != today) {
      // New day
      DateTime lastDate = DateTime.parse(lastSolvedDate);
      DateTime nowDate = DateTime.now();
      int dayDiff = nowDate.difference(lastDate).inDays;

      if (dayDiff == 1) {
        // Consecutive day - increment streak
        int streak = _prefs.getInt('current_streak') ?? 0;
        await _prefs.setInt('current_streak', streak + 1);
      } else if (dayDiff > 1) {
        // Streak broken - reset to 1
        await _prefs.setInt('current_streak', 1);
      }
    }

    await _prefs.setString('last_solved_date', today);
  }
}