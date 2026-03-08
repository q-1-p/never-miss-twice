import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/habit/habit.dart';
import '../../../../domain/habit/habit_date.dart';
import '../../../../domain/habit/streak_status.dart';
import 'habit_calendar_sheet.dart';
import 'habit_notifier.dart';

class HabitListItem extends StatefulWidget {
  final Habit habit;

  const HabitListItem({super.key, required this.habit});

  @override
  State<HabitListItem> createState() => _HabitListItemState();
}

class _HabitListItemState extends State<HabitListItem> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<HabitNotifier>();
    final habit = widget.habit;
    final status = notifier.streakStatus(habit);
    final streak = notifier.currentStreak(habit);
    final completedToday = habit.completedDates.contains(HabitDate.today());
    final theme = Theme.of(context);

    final statusColor = _statusColor(status);
    final surfaceColor = _surfaceColor(status, theme.brightness);

    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.05),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Card(
          color: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: statusColor.withValues(alpha: 0.15)),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(color: statusColor, width: 3),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // ── チェックボタン ──
                GestureDetector(
                  onTap: () => notifier.toggleCompletion(habit.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          completedToday ? statusColor : Colors.transparent,
                      border: Border.all(
                        color: completedToday
                            ? statusColor
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: completedToday
                          ? Icon(Icons.check_rounded,
                              color: theme.colorScheme.onPrimary,
                              size: 20,
                              key: const ValueKey('checked'))
                          : const SizedBox.shrink(
                              key: ValueKey('unchecked')),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // ── 習慣名 + ステータスラベル ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: completedToday
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                          color: completedToday
                              ? theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5)
                              : theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _StatusLabel(status: status, streak: streak),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                // ── ストリークカウンター（大きく強調） ──
                _StreakCounter(
                  status: status,
                  streak: streak,
                  statusColor: statusColor,
                ),
                const SizedBox(width: 4),
                // ── アクションボタン ──
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_month_outlined,
                          size: 20),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'カレンダー',
                      onPressed: () => _openCalendar(context, notifier),
                      style: IconButton.styleFrom(
                        foregroundColor:
                            theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 20),
                      visualDensity: VisualDensity.compact,
                      tooltip: '削除',
                      onPressed: () =>
                          _confirmDelete(context, notifier),
                      style: IconButton.styleFrom(
                        foregroundColor:
                            theme.colorScheme.error.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _statusColor(StreakStatus status) => switch (status) {
        StreakStatus.onTrack => const Color(0xFF3949AB),
        StreakStatus.warning => const Color(0xFFF59F00),
        StreakStatus.broken => const Color(0xFFE03131),
      };

  static Color _surfaceColor(StreakStatus status, Brightness brightness) {
    if (brightness == Brightness.dark) {
      return switch (status) {
        StreakStatus.onTrack => const Color(0xFF1A1A2E),
        StreakStatus.warning => const Color(0xFF2A2415),
        StreakStatus.broken => const Color(0xFF2A1515),
      };
    }
    return switch (status) {
      StreakStatus.onTrack => Colors.white,
      StreakStatus.warning => const Color(0xFFFFFBF0),
      StreakStatus.broken => const Color(0xFFFFF5F5),
    };
  }

  void _openEdit(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => HabitAddDialog(habit: widget.habit),
    );
  }

  void _openCalendar(BuildContext context, HabitNotifier notifier) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: notifier,
        child: HabitCalendarSheet(habit: widget.habit),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    HabitNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('習慣を削除'),
        content: Text('「${widget.habit.name}」を削除しますか？'),
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
      await notifier.removeHabit(widget.habit.id);
    }
  }
}

/// ストリーク数を大きく表示するカウンター
class _StreakCounter extends StatelessWidget {
  final StreakStatus status;
  final int streak;
  final Color statusColor;

  const _StreakCounter({
    required this.status,
    required this.streak,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // broken の場合は小さく表示
    if (status == StreakStatus.broken) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: statusColor.withValues(alpha: 0.08),
        ),
        child: Center(
          child: Icon(
            Icons.refresh_rounded,
            size: 22,
            color: statusColor.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    // onTrack の初日
    if (status == StreakStatus.onTrack && streak == 0) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        ),
        child: Center(
          child: Icon(
            Icons.auto_awesome_rounded,
            size: 22,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    // ストリーク数表示（メイン）
    final isLong = streak >= 7;
    final isMilestone = streak >= 30;

    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: isMilestone
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  statusColor,
                  statusColor.withValues(alpha: 0.7),
                ],
              )
            : null,
        color: isMilestone
            ? null
            : statusColor.withValues(alpha: isLong ? 0.12 : 0.08),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 炎アイコン（7日以上で表示）
          if (isLong)
            Icon(
              Icons.local_fire_department_rounded,
              size: isMilestone ? 16 : 14,
              color: isMilestone
                  ? theme.colorScheme.onPrimary
                  : statusColor,
            ),
          // 数字
          Text(
            '$streak',
            style: TextStyle(
              fontSize: streak >= 100 ? 18 : 22,
              fontWeight: FontWeight.w800,
              color: isMilestone
                  ? theme.colorScheme.onPrimary
                  : statusColor,
              height: 1.1,
            ),
          ),
          // ラベル
          Text(
            '日連続',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isMilestone
                  ? theme.colorScheme.onPrimary.withValues(alpha: 0.9)
                  : statusColor.withValues(alpha: 0.7),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// ステータスに応じた補助ラベル（小さめ表示）
class _StatusLabel extends StatelessWidget {
  final StreakStatus status;
  final int streak;

  const _StatusLabel({required this.status, required this.streak});

  @override
  Widget build(BuildContext context) {
    final (icon, text, color) = _data(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontSize: 11,
              ),
        ),
      ],
    );
  }

  (IconData, String, Color) _data(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (status) {
      StreakStatus.onTrack when streak > 0 => (
          Icons.trending_up_rounded,
          '継続中',
          scheme.primary,
        ),
      StreakStatus.onTrack => (
          Icons.auto_awesome_rounded,
          '初日',
          scheme.onSurfaceVariant,
        ),
      StreakStatus.warning => (
          Icons.notifications_active_rounded,
          '今日やれば継続できます',
          const Color(0xFFF59F00),
        ),
      StreakStatus.broken => (
          Icons.refresh_rounded,
          'ストリーク途切れ',
          const Color(0xFFE03131),
        ),
    };
  }
}
