import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class StorageService {
  static const _configKey = 'timer_config';
  static const _historyKey = 'session_history';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // --- Config ---

  TimerConfig loadConfig() {
    final json = _prefs.getString(_configKey);
    if (json == null) return const TimerConfig();
    return TimerConfig.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> saveConfig(TimerConfig config) async {
    await _prefs.setString(_configKey, jsonEncode(config.toJson()));
  }

  // --- Session History ---

  List<SessionRecord> loadHistory() {
    final json = _prefs.getString(_historyKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => SessionRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveHistory(List<SessionRecord> history) async {
    await _prefs.setString(
        _historyKey, jsonEncode(history.map((e) => e.toJson()).toList()));
  }

  Future<void> recordWorkSession(int focusMinutes) async {
    final today = _todayString();
    final history = loadHistory();
    final idx = history.indexWhere((r) => r.date == today);
    if (idx >= 0) {
      history[idx].sessionsCompleted++;
      history[idx].totalFocusMinutes += focusMinutes;
    } else {
      history.add(SessionRecord(
        date: today,
        sessionsCompleted: 1,
        totalFocusMinutes: focusMinutes,
      ));
    }
    await _saveHistory(history);
  }

  // --- Computed Stats ---

  int todaySessions() {
    final today = _todayString();
    final history = loadHistory();
    final record = history.where((r) => r.date == today);
    return record.isEmpty ? 0 : record.first.sessionsCompleted;
  }

  int totalSessions() {
    final history = loadHistory();
    final completions = history.fold(0, (int sum, r) => sum + r.sessionsCompleted);
    final focusMinutes = history.fold(0, (int sum, r) => sum + r.totalFocusMinutes);
    final fromFocus = focusMinutes ~/ 25;
    return max(completions, fromFocus);
  }

  int totalFocusMinutes() {
    return loadHistory().fold(0, (sum, r) => sum + r.totalFocusMinutes);
  }

  int currentStreak() {
    final history = loadHistory();
    if (history.isEmpty) return 0;

    // Sort descending by date
    history.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    var checkDate = DateTime.now();

    for (final record in history) {
      final checkString =
          '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';

      if (record.date == checkString && record.sessionsCompleted > 0) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (record.date.compareTo(checkString) < 0) {
        // We've passed the expected date without a match — streak broken
        break;
      }
    }
    return streak;
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
