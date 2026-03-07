import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/habit/dock_badge_source.dart';
import 'data/habit/habit_local_source.dart';
import 'data/habit/habit_repository_impl.dart';
import 'domain/habit/add_habit.dart';
import 'domain/habit/get_at_risk_count.dart';
import 'domain/habit/get_habits.dart';
import 'domain/habit/get_streak_status.dart';
import 'domain/habit/remove_habit.dart';
import 'domain/habit/toggle_completion.dart';
import 'presentation/widgets/domain/habit/habit_notifier.dart';
import 'presentation/pages/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final localSource = HabitLocalSource(prefs);
  final badgeSource = DockBadgeSource();
  final getStreakStatus = GetStreakStatus();
  final habitRepository = HabitRepositoryImpl(
    localSource: localSource,
    badgeSource: badgeSource,
    getStreakStatus: getStreakStatus,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => HabitNotifier(
        addHabit: AddHabit(habitRepository),
        removeHabit: RemoveHabit(habitRepository),
        toggleCompletion: ToggleCompletion(habitRepository),
        getHabits: GetHabits(habitRepository),
        getStreakStatus: getStreakStatus,
        getAtRiskCount: GetAtRiskCount(getStreakStatus),
      ),
      child: const NeverMissTwiceApp(),
    ),
  );
}

class NeverMissTwiceApp extends StatelessWidget {
  const NeverMissTwiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Never Miss Twice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
