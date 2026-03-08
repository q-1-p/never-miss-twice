import '../../core/use_case.dart';
import 'habit_repository.dart';

class ToggleCompletionForDateParams {
  final String id;
  final String date; // YYYY-MM-DD
  const ToggleCompletionForDateParams({required this.id, required this.date});
}

class ToggleCompletionForDate
    implements AsyncUseCase<void, ToggleCompletionForDateParams> {
  const ToggleCompletionForDate(this._repository);
  final HabitRepository _repository;

  @override
  Future<void> call(ToggleCompletionForDateParams params) =>
      _repository.toggleCompletionForDate(params.id, params.date);
}
