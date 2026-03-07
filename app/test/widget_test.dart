import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/providers/habit_provider.dart';
import 'package:app/services/dock_badge_service.dart';
import 'package:app/services/storage_service.dart';
import 'package:app/ui/screens/home_screen.dart';

void main() {
  testWidgets('空の状態でホーム画面が表示される', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final provider = HabitProvider(storage, DockBadgeService());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.text('Never Miss Twice'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('習慣を追加できる', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final provider = HabitProvider(storage, DockBadgeService());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
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
    final storage = await StorageService.create();
    final provider = HabitProvider(storage, DockBadgeService());

    provider.addHabit('テスト習慣');
    final habit = provider.habits.first;
    provider.toggleCompletion(habit.id);

    expect(
      provider.streakStatus(provider.habits.first),
      StreakStatus.onTrack,
    );
    expect(provider.currentStreak(provider.habits.first), 1);
  });
}
