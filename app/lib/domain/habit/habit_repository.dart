import 'habit.dart';

abstract class HabitRepository {
  List<Habit> getAll();
  Future<void> addHabit(String name);
  Future<void> removeHabit(String id);
  Future<void> toggleCompletion(String id);
}
