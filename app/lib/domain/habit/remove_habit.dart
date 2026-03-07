import '../../core/use_case.dart';
import 'habit_repository.dart';

class RemoveHabit extends AsyncUseCase<void, String> {
  final HabitRepository _repository;

  RemoveHabit(this._repository);

  @override
  Future<void> call(String id) => _repository.removeHabit(id);
}
