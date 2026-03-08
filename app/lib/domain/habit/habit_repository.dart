import 'habit.dart';

abstract class HabitRepository {
  List<Habit> getAll();
  Future<void> addHabit(String name);
  Future<void> removeHabit(String id);
  Future<void> toggleCompletion(String id);
  Future<void> toggleCompletionForDate(String id, String date); // YYYY-MM-DD
  Future<void> updateHabit(String id, String name);
}
