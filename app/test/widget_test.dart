import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/data/habit/dock_badge_source.dart';
import 'package:app/data/habit/habit_local_source.dart';
import 'package:app/data/habit/habit_repository_impl.dart';
import 'package:app/domain/habit/add_habit.dart';
import 'package:app/domain/habit/get_at_risk_count.dart';
import 'package:app/domain/habit/get_habits.dart';
import 'package:app/domain/habit/get_streak_status.dart';
import 'package:app/domain/habit/habit.dart';
import 'package:app/domain/habit/habit_date.dart';
import 'package:app/domain/habit/remove_habit.dart';
import 'package:app/domain/habit/streak_status.dart';
import 'package:app/domain/habit/toggle_completion.dart';
import 'package:app/domain/habit/toggle_completion_for_date.dart';
import 'package:app/domain/habit/update_habit.dart';
import 'package:app/presentation/widgets/domain/habit/habit_notifier.dart';
import 'package:app/presentation/pages/home_screen.dart';

HabitNotifier _buildNotifier(SharedPreferences prefs) {
  final localSource = HabitLocalSource(prefs);
  final badgeSource = DockBadgeSource();
  final getStreakStatus = GetStreakStatus();
  final repo = HabitRepositoryImpl(
    localSource: localSource,
    badgeSource: badgeSource,
    getStreakStatus: getStreakStatus,
  );
  return HabitNotifier(
    addHabit: AddHabit(repo),
    removeHabit: RemoveHabit(repo),
    updateHabit: UpdateHabit(repo),
    toggleCompletion: ToggleCompletion(repo),
    toggleCompletionForDate: ToggleCompletionForDate(repo),
    getHabits: GetHabits(repo),
    getStreakStatus: getStreakStatus,
    getAtRiskCount: GetAtRiskCount(getStreakStatus),
  );
}

void main() {
  testWidgets('空の状態でホーム画面が表示される', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final notifier = _buildNotifier(prefs);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: notifier,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Never Miss Twice'), findsOneWidget);
    expect(find.byType(FilledButton), findsWidgets);
  });

  testWidgets('習慣を追加できる', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final notifier = _buildNotifier(prefs);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: notifier,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.tap(find.byIcon(Icons.add_rounded).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '毎日運動');
    await tester.tap(find.text('追加する'));
    await tester.pumpAndSettle();

    expect(find.text('毎日運動'), findsOneWidget);
  });

  test('ストリーク計算: 今日完了でonTrack', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final notifier = _buildNotifier(prefs);

    await notifier.addHabit('テスト習慣');
    final habit = notifier.habits.first;
    await notifier.toggleCompletion(habit.id);

    expect(notifier.streakStatus(notifier.habits.first), StreakStatus.onTrack);
    expect(notifier.currentStreak(notifier.habits.first), 1);
  });

  group('Never Miss Twice ルール', () {
    final getStreakStatus = GetStreakStatus();

    String daysAgo(int n) => HabitDate.fromDateTime(
        DateTime.now().subtract(Duration(days: n)));

    Habit makeHabit(Set<String> dates, {int createdDaysAgo = 10}) => Habit(
          id: 'test',
          name: 'test',
          createdAt: DateTime.now().subtract(Duration(days: createdDaysAgo)),
          completedDates: dates,
        );

    test('今日完了 → onTrack', () {
      final habit = makeHabit({daysAgo(0)});
      expect(getStreakStatus(habit), StreakStatus.onTrack);
    });

    test('昨日完了・今日未完了 → onTrack（1日ミスなだけで安全）', () {
      final habit = makeHabit({daysAgo(1)});
      expect(getStreakStatus(habit), StreakStatus.onTrack);
    });

    test('一昨日完了・昨日今日未完了 → warning（1日ミスのみ）', () {
      final habit = makeHabit({daysAgo(2)});
      expect(getStreakStatus(habit), StreakStatus.warning);
    });

    test('3日前完了・一昨日昨日未完了 → broken（2日連続ミス）', () {
      final habit = makeHabit({daysAgo(3)});
      expect(getStreakStatus(habit), StreakStatus.broken);
    });

    test('1日空きでストリーク継続: 今日・一昨日完了', () {
      final habit = makeHabit({daysAgo(0), daysAgo(2)});
      final status = getStreakStatus(habit);
      expect(status, StreakStatus.onTrack);
      expect(habit.currentStreak(status), 2);
    });

    test('1日空きでストリーク継続: 今日・一昨日・4日前完了', () {
      final habit = makeHabit({daysAgo(0), daysAgo(2), daysAgo(4)});
      final status = getStreakStatus(habit);
      expect(status, StreakStatus.onTrack);
      expect(habit.currentStreak(status), 3);
    });

    test('連続完了日もカウント: 今日・昨日・一昨日完了', () {
      final habit = makeHabit({daysAgo(0), daysAgo(1), daysAgo(2)});
      final status = getStreakStatus(habit);
      expect(status, StreakStatus.onTrack);
      expect(habit.currentStreak(status), 3);
    });

    test('2日連続ミスでストリーク途切れ: 今日完了・3日前完了（昨日一昨日ミス）', () {
      final habit = makeHabit({daysAgo(0), daysAgo(3)});
      final status = getStreakStatus(habit);
      expect(status, StreakStatus.onTrack);
      expect(habit.currentStreak(status), 1);
    });

    test('broken時はストリーク0', () {
      final habit = makeHabit({daysAgo(5)});
      final status = getStreakStatus(habit);
      expect(status, StreakStatus.broken);
      expect(habit.currentStreak(status), 0);
    });

    test('作成日が今日 → onTrack', () {
      final habit = makeHabit({}, createdDaysAgo: 0);
      expect(getStreakStatus(habit), StreakStatus.onTrack);
    });

    test('作成日が昨日・未完了 → onTrack（まだ1日目で連続ミスなし）', () {
      final habit = makeHabit({}, createdDaysAgo: 1);
      expect(getStreakStatus(habit), StreakStatus.onTrack);
    });
  });
}
