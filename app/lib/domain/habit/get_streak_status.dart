import '../../core/use_case.dart';
import 'habit.dart';
import 'habit_date.dart';
import 'streak_status.dart';

class GetStreakStatus extends UseCase<StreakStatus, Habit> {
  @override
  StreakStatus call(Habit habit) {
    final today = HabitDate.today();
    final yesterday = HabitDate.yesterday();

    if (habit.completedDates.contains(today)) return StreakStatus.onTrack;
    if (habit.completedDates.contains(yesterday)) return StreakStatus.warning;

    // 作成日が今日なら初日なのでbrokenではない
    if (HabitDate.fromDateTime(habit.createdAt) == today) {
      return StreakStatus.onTrack;
    }

    return StreakStatus.broken;
  }
}
