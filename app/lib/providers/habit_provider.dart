import 'package:flutter/foundation.dart';

import '../models/habit.dart';
import '../services/dock_badge_service.dart';
import '../services/storage_service.dart';

enum StreakStatus { onTrack, warning, broken }

class HabitProvider extends ChangeNotifier {
  final StorageService _storage;
  final DockBadgeService _dockBadge;

  List<Habit> _habits = [];

  List<Habit> get habits => List.unmodifiable(_habits);

  HabitProvider(this._storage, this._dockBadge) {
    _habits = _storage.loadHabits();
    _updateDockBadge();
  }

  // ── date helpers ──────────────────────────────────────────────────────────

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String get todayKey => _dateKey(DateTime.now());

  static String get _yesterdayKey =>
      _dateKey(DateTime.now().subtract(const Duration(days: 1)));

  // ── streak logic ──────────────────────────────────────────────────────────

  StreakStatus streakStatus(Habit habit) {
    final today = todayKey;
    final yesterday = _yesterdayKey;

    if (habit.completedDates.contains(today)) return StreakStatus.onTrack;
    if (habit.completedDates.contains(yesterday)) return StreakStatus.warning;

    // 作成日が今日なら初日なのでbrokenではない
    if (_dateKey(habit.createdAt) == today) return StreakStatus.onTrack;

    return StreakStatus.broken;
  }

  int currentStreak(Habit habit) {
    final status = streakStatus(habit);
    if (status == StreakStatus.broken) return 0;

    // 今日完了済みなら今日から、そうでなければ昨日から遡る
    var cursor = habit.completedDates.contains(todayKey)
        ? DateTime.now()
        : DateTime.now().subtract(const Duration(days: 1));

    var streak = 0;
    while (habit.completedDates.contains(_dateKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get atRiskCount =>
      _habits.where((h) => streakStatus(h) == StreakStatus.warning).length;

  // ── mutations ─────────────────────────────────────────────────────────────

  void addHabit(String name) {
    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      createdAt: DateTime.now(),
      completedDates: {},
    );
    _habits = [..._habits, habit];
    _persist();
    notifyListeners();
  }

  void removeHabit(String id) {
    _habits = _habits.where((h) => h.id != id).toList();
    _persist();
    notifyListeners();
    _updateDockBadge();
  }

  void toggleCompletion(String id) {
    final today = todayKey;
    _habits = _habits.map((h) {
      if (h.id != id) return h;
      final dates = Set<String>.from(h.completedDates);
      if (dates.contains(today)) {
        dates.remove(today);
      } else {
        dates.add(today);
      }
      return h.copyWith(completedDates: dates);
    }).toList();
    _persist();
    notifyListeners();
    _updateDockBadge();
  }

  // ── private ───────────────────────────────────────────────────────────────

  void _persist() => _storage.saveHabits(_habits);

  void _updateDockBadge() {
    final count = atRiskCount;
    _dockBadge.setBadge(count > 0 ? count.toString() : null);
  }
}
