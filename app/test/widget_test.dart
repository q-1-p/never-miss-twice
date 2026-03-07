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
import 'package:app/domain/habit/remove_habit.dart';
import 'package:app/domain/habit/streak_status.dart';
import 'package:app/domain/habit/toggle_completion.dart';
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
    toggleCompletion: ToggleCompletion(repo),
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
    expect(find.byIcon(Icons.add), findsOneWidget);
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

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '毎日運動');
    await tester.tap(find.text('追加'));
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
}
