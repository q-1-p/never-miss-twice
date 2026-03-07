import '../../core/use_case.dart';
import 'habit.dart';
import 'habit_repository.dart';

class GetHabits extends UseCase<List<Habit>, NoParams> {
  final HabitRepository _repository;

  GetHabits(this._repository);

  @override
  List<Habit> call(NoParams params) => _repository.getAll();
}
