import 'package:flutter/foundation.dart';

import '../../core/use_case.dart';
import '../../domain/habit/add_habit.dart';
import '../../domain/habit/get_at_risk_count.dart';
import '../../domain/habit/get_habits.dart';
import '../../domain/habit/get_streak_status.dart';
import '../../domain/habit/habit.dart';
import '../../domain/habit/remove_habit.dart';
import '../../domain/habit/streak_status.dart';
import '../../domain/habit/toggle_completion.dart';

class HabitNotifier extends ChangeNotifier {
  final AddHabit _addHabit;
  final RemoveHabit _removeHabit;
  final ToggleCompletion _toggleCompletion;
  final GetHabits _getHabits;
  final GetStreakStatus _getStreakStatus;
  final GetAtRiskCount _getAtRiskCount;

  List<Habit> _habits = [];
  List<Habit> get habits => _habits;

  HabitNotifier({
    required AddHabit addHabit,
    required RemoveHabit removeHabit,
    required ToggleCompletion toggleCompletion,
    required GetHabits getHabits,
    required GetStreakStatus getStreakStatus,
    required GetAtRiskCount getAtRiskCount,
  })  : _addHabit = addHabit,
        _removeHabit = removeHabit,
        _toggleCompletion = toggleCompletion,
        _getHabits = getHabits,
        _getStreakStatus = getStreakStatus,
        _getAtRiskCount = getAtRiskCount {
    _habits = _getHabits(const NoParams());
  }

  StreakStatus streakStatus(Habit habit) => _getStreakStatus(habit);

  int currentStreak(Habit habit) => habit.currentStreak(_getStreakStatus(habit));

  int get atRiskCount => _getAtRiskCount(_habits);

  Future<void> addHabit(String name) async {
    await _addHabit(name);
    _refresh();
  }

  Future<void> removeHabit(String id) async {
    await _removeHabit(id);
    _refresh();
  }

  Future<void> toggleCompletion(String id) async {
    await _toggleCompletion(id);
    _refresh();
  }

  void _refresh() {
    _habits = _getHabits(const NoParams());
    notifyListeners();
  }
}
