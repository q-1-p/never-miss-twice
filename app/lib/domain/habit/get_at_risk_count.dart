import '../../core/use_case.dart';
import 'get_streak_status.dart';
import 'habit.dart';
import 'streak_status.dart';

class GetAtRiskCount extends UseCase<int, List<Habit>> {
  final GetStreakStatus _getStreakStatus;

  GetAtRiskCount(this._getStreakStatus);

  @override
  int call(List<Habit> habits) =>
      habits.where((h) => _getStreakStatus(h) == StreakStatus.warning).length;
}
