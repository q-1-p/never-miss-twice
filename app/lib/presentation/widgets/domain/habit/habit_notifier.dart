import 'package:flutter/foundation.dart';

import '../../../../core/use_case.dart';
import '../../../../domain/habit/add_habit.dart';
import '../../../../domain/habit/get_at_risk_count.dart';
import '../../../../domain/habit/get_habits.dart';
import '../../../../domain/habit/get_streak_status.dart';
import '../../../../domain/habit/habit.dart';
import '../../../../domain/habit/remove_habit.dart';
import '../../../../domain/habit/streak_status.dart';
import '../../../../domain/habit/toggle_completion.dart';
import '../../../../domain/habit/toggle_completion_for_date.dart';
import '../../../../domain/habit/update_habit.dart';

class HabitNotifier extends ChangeNotifier {
  final AddHabit _addHabit;
  final RemoveHabit _removeHabit;
  final UpdateHabit _updateHabit;
  final ToggleCompletion _toggleCompletion;
  final ToggleCompletionForDate _toggleCompletionForDate;
  final GetHabits _getHabits;
  final GetStreakStatus _getStreakStatus;
  final GetAtRiskCount _getAtRiskCount;

  List<Habit> _habits = [];
  List<Habit> get habits => _habits;

  HabitNotifier({
    required AddHabit addHabit,
    required RemoveHabit removeHabit,
    required UpdateHabit updateHabit,
    required ToggleCompletion toggleCompletion,
    required ToggleCompletionForDate toggleCompletionForDate,
    required GetHabits getHabits,
    required GetStreakStatus getStreakStatus,
    required GetAtRiskCount getAtRiskCount,
  }) : _addHabit = addHabit,
       _removeHabit = removeHabit,
       _updateHabit = updateHabit,
       _toggleCompletion = toggleCompletion,
       _toggleCompletionForDate = toggleCompletionForDate,
       _getHabits = getHabits,
       _getStreakStatus = getStreakStatus,
       _getAtRiskCount = getAtRiskCount {
    _habits = _getHabits(const NoParams());
  }

  StreakStatus streakStatus(Habit habit) => _getStreakStatus(habit);

  int currentStreak(Habit habit) =>
      habit.currentStreak(_getStreakStatus(habit));

  int get atRiskCount => _getAtRiskCount(_habits);

  Future<void> addHabit(String name) async {
    await _addHabit(name);
    _refresh();
  }

  Future<void> updateHabit(String id, String name) async {
    await _updateHabit(UpdateHabitParams(id: id, name: name));
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

  Future<void> toggleCompletionForDate(String id, String date) async {
    await _toggleCompletionForDate(
      ToggleCompletionForDateParams(id: id, date: date),
    );
    _refresh();
  }

  void _refresh() {
    _habits = _getHabits(const NoParams());
    notifyListeners();
  }
}
