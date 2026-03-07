import '../../core/use_case.dart';
import 'habit_repository.dart';

class AddHabit extends AsyncUseCase<void, String> {
  final HabitRepository _repository;

  AddHabit(this._repository);

  @override
  Future<void> call(String name) => _repository.addHabit(name);
}
