import '../../core/use_case.dart';
import 'habit_repository.dart';

class ToggleCompletion extends AsyncUseCase<void, String> {
  final HabitRepository _repository;

  ToggleCompletion(this._repository);

  @override
  Future<void> call(String id) => _repository.toggleCompletion(id);
}
