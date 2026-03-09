import '../../core/use_case.dart';
import 'habit.dart';
import 'habit_date.dart';
import 'streak_status.dart';

class GetStreakStatus extends UseCase<StreakStatus, Habit> {
  @override
  StreakStatus call(Habit habit) {
    final today = HabitDate.today();

    if (habit.completedDates.contains(today)) return StreakStatus.onTrack;

    // 作成日が今日なら初日なのでbrokenではない
    if (HabitDate.fromDateTime(habit.createdAt) == today) {
      return StreakStatus.onTrack;
    }

    final yesterday = HabitDate.yesterday();

    // 昨日完了 → 今日サボっても1日ミスなだけ。まだ安全
    if (habit.completedDates.contains(yesterday)) return StreakStatus.onTrack;

    // 作成日が昨日 → まだ1日目。連続ミスの心配なし
    if (HabitDate.fromDateTime(habit.createdAt) == yesterday) {
      return StreakStatus.onTrack;
    }

    // 一昨日完了なら確定ミスは昨日の1日だけ。今日やればまだ間に合う
    final twoDaysAgo = HabitDate.fromDateTime(
        DateTime.now().subtract(const Duration(days: 2)));
    if (habit.completedDates.contains(twoDaysAgo)) return StreakStatus.warning;

    // 昨日も一昨日も未完了 → 2日連続ミス確定
    return StreakStatus.broken;
  }
}
