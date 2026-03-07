import 'habit_date.dart';
import 'streak_status.dart';

class Habit {
  final String id;
  final String name;
  final DateTime createdAt;
  final Set<String> completedDates;

  const Habit({
    required this.id,
    required this.name,
    required this.createdAt,
    this.completedDates = const {},
  });

  int currentStreak(StreakStatus status) {
    if (status == StreakStatus.broken) return 0;

    var cursor = completedDates.contains(HabitDate.today())
        ? DateTime.now()
        : DateTime.now().subtract(const Duration(days: 1));

    var streak = 0;
    while (completedDates.contains(HabitDate.fromDateTime(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Habit copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    Set<String>? completedDates,
  }) =>
      Habit(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        completedDates: completedDates ?? this.completedDates,
      );
}
