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
import 'domain/habit/toggle_completion_for_date.dart';
import 'domain/habit/update_habit.dart';
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
        updateHabit: UpdateHabit(habitRepository),
        toggleCompletion: ToggleCompletion(habitRepository),
        toggleCompletionForDate: ToggleCompletionForDate(habitRepository),
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

  static const _seedColor = Color(0xFF3949AB);

  static const _textTheme = TextTheme(
    headlineMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
  );

  static ThemeData _buildTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
    ).copyWith(
      surface: const Color(0xFFF5F5F7),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainer: const Color(0xFFEEEEF4),
    );

    return _buildThemeData(colorScheme);
  }

  static ThemeData _buildDarkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );

    return _buildThemeData(colorScheme);
  }

  static ThemeData _buildThemeData(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: _textTheme,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
        dragHandleColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        dragHandleSize: const Size(40, 4),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Never Miss Twice',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      darkTheme: _buildDarkTheme(),
      home: const HomeScreen(),
    );
  }
}
