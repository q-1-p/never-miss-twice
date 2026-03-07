import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/domain/habit/habit_add_dialog.dart';
import '../widgets/domain/habit/habit_list_item.dart';
import '../widgets/domain/habit/habit_notifier.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<HabitNotifier>();
    final habits = notifier.habits;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── ヘッダー ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 12, 8),
            child: Row(
              children: [
                const Text(
                  'Never Miss Twice',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: '習慣を追加',
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => const HabitAddDialog(),
                  ),
                ),
              ],
            ),
          ),
          // ── 習慣リスト ───────────────────────────────────────────────
          Expanded(
            child: habits.isEmpty
                ? const Center(
                    child: Text(
                      '右上の + ボタンで習慣を追加してください',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: habits.length,
                    itemBuilder: (_, i) => HabitListItem(habit: habits[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
