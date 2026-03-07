import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habit.dart';
import '../../providers/habit_provider.dart';

class HabitListItem extends StatelessWidget {
  final Habit habit;

  const HabitListItem({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final status = provider.streakStatus(habit);
    final streak = provider.currentStreak(habit);
    final completedToday = habit.completedDates.contains(
      HabitProvider.todayKey,
    );

    final bgColor = switch (status) {
      StreakStatus.onTrack => Colors.white,
      StreakStatus.warning => const Color(0xFFFFF3CD),
      StreakStatus.broken => const Color(0xFFFEE2E2),
    };

    final subtitleText = switch (status) {
      StreakStatus.onTrack => streak == 0 ? '初日' : '$streak日連続',
      StreakStatus.warning => '$streak日連続 — 今日やれば継続できます',
      StreakStatus.broken => 'ストリーク途切れ',
    };

    final subtitleIcon = switch (status) {
      StreakStatus.warning => const Text('⚠️ '),
      _ => const SizedBox.shrink(),
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: bgColor,
      elevation: 1,
      child: ListTile(
        leading: Checkbox(
          value: completedToday,
          onChanged: (_) => provider.toggleCompletion(habit.id),
        ),
        title: Text(
          habit.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Row(
          children: [
            subtitleIcon,
            Expanded(child: Text(subtitleText)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: '削除',
          onPressed: () => _confirmDelete(context, provider),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    HabitProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('習慣を削除'),
        content: Text('「${habit.name}」を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      provider.removeHabit(habit.id);
    }
  }
}
