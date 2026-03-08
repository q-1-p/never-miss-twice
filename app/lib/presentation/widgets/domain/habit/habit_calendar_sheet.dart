import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/habit/habit.dart';
import '../../../../domain/habit/habit_date.dart';
import '../../../../domain/habit/streak_status.dart';
import 'habit_notifier.dart';

class HabitCalendarSheet extends StatefulWidget {
  final Habit habit;

  const HabitCalendarSheet({super.key, required this.habit});

  @override
  State<HabitCalendarSheet> createState() => _HabitCalendarSheetState();
}

class _HabitCalendarSheetState extends State<HabitCalendarSheet> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  Future<void> _onTapDate(String dateStr) async {
    await context.read<HabitNotifier>().toggleCompletionForDate(
          widget.habit.id,
          dateStr,
        );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayStr = HabitDate.fromDateTime(now);

    final currentMonth = DateTime(now.year, now.month);
    final canGoNext = _displayedMonth.isBefore(currentMonth);

    final notifier = context.watch<HabitNotifier>();
    final habit = notifier.habits.firstWhere(
      (h) => h.id == widget.habit.id,
      orElse: () => widget.habit,
    );
    final completedDates = habit.completedDates;

    final monthLabel =
        '${_displayedMonth.year}年${_displayedMonth.month}月';

    final firstOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final startOffset = firstOfMonth.weekday % 7;
    final daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;

    // 当月の達成数
    final completedThisMonth = completedDates.where((d) {
      final parts = d.split('-');
      if (parts.length != 3) return false;
      return int.tryParse(parts[0]) == _displayedMonth.year &&
          int.tryParse(parts[1]) == _displayedMonth.month;
    }).length;

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final streak = notifier.currentStreak(habit);
    final streakStatus = notifier.streakStatus(habit);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 習慣名 ──
            Text(
              habit.name,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // ── ストリークハイライト ──
            _StreakHighlight(
              streak: streak,
              status: streakStatus,
              primaryColor: primaryColor,
              completedThisMonth: completedThisMonth,
            ),
            const SizedBox(height: 16),
            // ── 月ナビ ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _prevMonth,
                ),
                Text(
                  monthLabel,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: canGoNext ? _nextMonth : null,
                ),
              ],
            ),
            const SizedBox(height: 4),
            // ── 曜日ヘッダー ──
            Row(
              children: [
                _DayHeader('日', color: Colors.red[400]),
                const _DayHeader('月'),
                const _DayHeader('火'),
                const _DayHeader('水'),
                const _DayHeader('木'),
                const _DayHeader('金'),
                _DayHeader('土', color: Colors.blue[400]),
              ],
            ),
            const Divider(height: 12, thickness: 0.5),
            // ── カレンダーグリッド ──
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var i = 0; i < startOffset; i++) const SizedBox.shrink(),
                for (var day = 1; day <= daysInMonth; day++)
                  Builder(builder: (context) {
                    final cellDate = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month,
                      day,
                    );
                    final dateStr = HabitDate.fromDateTime(cellDate);
                    final isCompleted = completedDates.contains(dateStr);
                    final isToday = dateStr == todayStr;
                    final isFuture = cellDate.isAfter(today);

                    return _DayCell(
                      day: day,
                      isCompleted: isCompleted,
                      isToday: isToday,
                      isDisabled: isFuture,
                      primaryColor: primaryColor,
                      onTap: isFuture ? null : () => _onTapDate(dateStr),
                    );
                  }),
              ],
            ),
            // ── 達成率バー ──
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('達成率',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          )),
                      Text(
                        '${daysInMonth > 0 ? (completedThisMonth / daysInMonth * 100).round() : 0}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: daysInMonth > 0
                          ? completedThisMonth / daysInMonth
                          : 0,
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.surfaceContainer,
                      valueColor:
                          AlwaysStoppedAnimation(primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakHighlight extends StatelessWidget {
  final int streak;
  final StreakStatus status;
  final Color primaryColor;
  final int completedThisMonth;

  const _StreakHighlight({
    required this.streak,
    required this.status,
    required this.primaryColor,
    required this.completedThisMonth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 現在のストリーク
          _StreakStat(
            value: '$streak',
            label: '日連続',
            icon: streak > 0
                ? Icons.local_fire_department_rounded
                : Icons.remove_rounded,
            color: status == StreakStatus.broken
                ? theme.colorScheme.onSurfaceVariant
                : primaryColor,
            isActive: streak > 0,
          ),
          Container(
            width: 1,
            height: 36,
            color: theme.colorScheme.outlineVariant,
          ),
          // 今月の達成日数
          _StreakStat(
            value: '$completedThisMonth',
            label: '日達成',
            icon: Icons.check_circle_outline_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            isActive: completedThisMonth > 0,
          ),
        ],
      ),
    );
  }
}

class _StreakStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isActive;

  const _StreakStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1.1,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.7),
                height: 1.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String label;
  final Color? color;

  const _DayHeader(this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color ??
                Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isCompleted;
  final bool isToday;
  final bool isDisabled;
  final Color primaryColor;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.isCompleted,
    required this.isToday,
    required this.isDisabled,
    required this.primaryColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? bgColor;
    Color textColor;
    Border? border;
    List<BoxShadow>? shadows;
    Gradient? gradient;

    if (isDisabled) {
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.2);
    } else if (isCompleted) {
      gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor,
          Color.fromARGB(
            (primaryColor.a * 255).round(),
            (primaryColor.r * 255).round(),
            (primaryColor.g * 255).round(),
            min((primaryColor.b * 255).round() + 40, 255),
          ),
        ],
      );
      textColor = theme.colorScheme.onPrimary;
      shadows = [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.3),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
    } else {
      textColor = theme.colorScheme.onSurface;
    }

    if (isToday) {
      border = Border.all(
        color: isCompleted ? primaryColor.withValues(alpha: 0.5) : primaryColor,
        width: 2.5,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            gradient: gradient,
            border: border,
            boxShadow: shadows,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                color: textColor,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
