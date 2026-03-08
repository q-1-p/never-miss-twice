import '../../core/use_case.dart';
import 'habit_repository.dart';

class UpdateHabitParams {
  final String id;
  final String name;
  const UpdateHabitParams({required this.id, required this.name});
}

class UpdateHabit implements AsyncUseCase<void, UpdateHabitParams> {
  const UpdateHabit(this._repository);
  final HabitRepository _repository;

  @override
  Future<void> call(UpdateHabitParams params) =>
      _repository.updateHabit(params.id, params.name);
}
