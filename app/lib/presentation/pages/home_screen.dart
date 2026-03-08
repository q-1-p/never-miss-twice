import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/habit/habit_date.dart';
import '../widgets/domain/habit/habit_add_dialog.dart';
import '../widgets/domain/habit/habit_list_item.dart';
import '../widgets/domain/habit/habit_notifier.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<HabitNotifier>();
    final habits = notifier.habits;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── ヘッダー ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Never Miss Twice',
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const HabitAddDialog(),
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(52, 52),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Icon(Icons.add_rounded, size: 24),
                  ),
                ],
              ),
            ),
            // ── 統計チップ ──
            if (habits.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: _StatsRow(notifier: notifier),
              ),
            if (habits.isEmpty) const SizedBox(height: 8),
            // ── 習慣リスト / 空状態 ──
            Expanded(
              child: habits.isEmpty
                  ? _EmptyState(
                      onAdd: () => showDialog<void>(
                        context: context,
                        builder: (_) => const HabitAddDialog(),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 32),
                      itemCount: habits.length,
                      itemBuilder: (_, i) => HabitListItem(habit: habits[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

}

class _StatsRow extends StatelessWidget {
  final HabitNotifier notifier;

  const _StatsRow({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final habits = notifier.habits;
    final todayStr = HabitDate.today();
    final completedCount = habits
        .where((h) => h.completedDates.contains(todayStr))
        .length;
    final atRisk = notifier.atRiskCount;

    // 最長ストリーク（全習慣中の最大値）
    var maxStreak = 0;
    for (final h in habits) {
      final s = notifier.currentStreak(h);
      if (s > maxStreak) maxStreak = s;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatChip(
          icon: Icons.check_circle_outline_rounded,
          label: '$completedCount/${habits.length} 完了',
        ),
        if (maxStreak > 0)
          _StatChip(
            icon: Icons.local_fire_department_rounded,
            label: '最長 $maxStreak日連続',
            color: Theme.of(context).colorScheme.primary,
          ),
        if (atRisk > 0)
          _StatChip(
            icon: Icons.warning_amber_rounded,
            label: '$atRisk 要注意',
            color: const Color(0xFFF59F00),
          ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _StatChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = color ?? theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 40,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '習慣を始めよう',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '右上の + ボタンで\n最初の習慣を追加してください',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('習慣を追加'),
          ),
        ],
      ),
    );
  }
}
