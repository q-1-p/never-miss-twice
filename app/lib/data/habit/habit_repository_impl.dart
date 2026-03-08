import '../../domain/habit/get_streak_status.dart';
import '../../domain/habit/habit.dart';
import '../../domain/habit/habit_date.dart';
import '../../domain/habit/habit_repository.dart';
import '../../domain/habit/streak_status.dart';
import 'dock_badge_source.dart';
import 'habit_local_source.dart';
import 'habit_model.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalSource _localSource;
  final DockBadgeSource _badgeSource;
  final GetStreakStatus _getStreakStatus;

  late List<Habit> _cache;

  HabitRepositoryImpl({
    required HabitLocalSource localSource,
    required DockBadgeSource badgeSource,
    required GetStreakStatus getStreakStatus,
  })  : _localSource = localSource,
        _badgeSource = badgeSource,
        _getStreakStatus = getStreakStatus {
    _cache = _localSource.loadHabits().map((m) => m.toDomain()).toList();
    _refreshBadge();
  }

  @override
  List<Habit> getAll() => List.unmodifiable(_cache);

  @override
  Future<void> addHabit(String name) async {
    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      createdAt: DateTime.now(),
      completedDates: {},
    );
    _cache = [..._cache, habit];
    await _persist();
  }

  @override
  Future<void> removeHabit(String id) async {
    _cache = _cache.where((h) => h.id != id).toList();
    await _persist();
    _refreshBadge();
  }

  @override
  Future<void> toggleCompletion(String id) async {
    final today = HabitDate.today();
    _cache = _cache.map((h) {
      if (h.id != id) return h;
      final dates = Set<String>.from(h.completedDates);
      dates.contains(today) ? dates.remove(today) : dates.add(today);
      return h.copyWith(completedDates: dates);
    }).toList();
    await _persist();
    _refreshBadge();
  }

  @override
  Future<void> toggleCompletionForDate(String id, String date) async {
    _cache = _cache.map((h) {
      if (h.id != id) return h;
      final dates = Set<String>.from(h.completedDates);
      dates.contains(date) ? dates.remove(date) : dates.add(date);
      return h.copyWith(completedDates: dates);
    }).toList();
    await _persist();
    _refreshBadge();
  }

  Future<void> _persist() async {
    await _localSource.saveHabits(_cache.map(HabitModel.fromDomain).toList());
  }

  void _refreshBadge() {
    final count = _cache
        .where((h) => _getStreakStatus(h) == StreakStatus.warning)
        .length;
    _badgeSource.setBadge(count > 0 ? count.toString() : null);
  }
}
