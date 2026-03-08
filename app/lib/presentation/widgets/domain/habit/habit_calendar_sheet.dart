import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/habit/habit.dart';
import '../../../../domain/habit/habit_date.dart';
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

    final createdAt = widget.habit.createdAt;
    final createdDay =
        DateTime(createdAt.year, createdAt.month, createdAt.day);
    final createdMonth = DateTime(createdAt.year, createdAt.month);
    final currentMonth = DateTime(now.year, now.month);

    final canGoPrev = _displayedMonth.isAfter(createdMonth);
    final canGoNext = _displayedMonth.isBefore(currentMonth);

    // Get up-to-date completedDates from notifier
    final notifier = context.watch<HabitNotifier>();
    final habit = notifier.habits.firstWhere(
      (h) => h.id == widget.habit.id,
      orElse: () => widget.habit,
    );
    final completedDates = habit.completedDates;

    // Month header label
    final monthLabel =
        '${_displayedMonth.year}年${_displayedMonth.month}月';

    // Build calendar cells
    final firstOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    // Dart weekday: Mon=1..Sun=7. Convert to Sunday-first: Sun=0..Sat=6
    final startOffset = firstOfMonth.weekday % 7;
    final daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Habit name
            Text(
              habit.name,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: canGoPrev ? _prevMonth : null,
                ),
                Text(
                  monthLabel,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: canGoNext ? _nextMonth : null,
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Day-of-week header (Sunday first)
            const Row(
              children: [
                _DayHeader('日', color: Colors.red),
                _DayHeader('月'),
                _DayHeader('火'),
                _DayHeader('水'),
                _DayHeader('木'),
                _DayHeader('金'),
                _DayHeader('土', color: Colors.blue),
              ],
            ),
            const SizedBox(height: 4),
            // Calendar grid
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Leading blank cells
                for (var i = 0; i < startOffset; i++) const SizedBox.shrink(),
                // Day cells
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
                    final isBeforeCreation = cellDate.isBefore(createdDay);
                    final isDisabled = isFuture || isBeforeCreation;

                    return _DayCell(
                      day: day,
                      isCompleted: isCompleted,
                      isToday: isToday,
                      isDisabled: isDisabled,
                      primaryColor: primaryColor,
                      onTap: isDisabled ? null : () => _onTapDate(dateStr),
                    );
                  }),
              ],
            ),
          ],
        ),
      ),
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
            color: color ?? Colors.grey[600],
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
    Color? bgColor;
    Color textColor;
    Border? border;

    if (isDisabled) {
      bgColor = null;
      textColor = Colors.grey[300]!;
    } else if (isCompleted) {
      bgColor = primaryColor;
      textColor = Colors.white;
    } else {
      bgColor = null;
      textColor = Colors.black87;
    }

    if (isToday) {
      border = Border.all(
        color: isCompleted ? primaryColor.withAlpha(180) : primaryColor,
        width: 2,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            border: border,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 13,
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
