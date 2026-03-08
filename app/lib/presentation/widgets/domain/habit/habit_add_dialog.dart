import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'habit_notifier.dart';

class HabitAddDialog extends StatefulWidget {
  const HabitAddDialog({super.key});

  @override
  State<HabitAddDialog> createState() => _HabitAddDialogState();
}

class _HabitAddDialogState extends State<HabitAddDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    context.read<HabitNotifier>().addHabit(name);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = _controller.text.trim().isNotEmpty;

    return AlertDialog(
      icon: Icon(
        Icons.add_task_rounded,
        color: theme.colorScheme.primary,
        size: 32,
      ),
      title: const Text('新しい習慣'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: '例: 毎日30分読書',
            ),
            maxLength: 50,
            autofocus: true,
            onSubmitted: (_) => _submit(),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 8),
          Text(
            '毎日続けられる小さな習慣から始めましょう',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: isValid ? _submit : null,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('追加する'),
        ),
      ],
    );
  }
}
