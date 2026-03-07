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
    return AlertDialog(
      title: const Text('習慣を追加'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: '例: 毎日30分読書',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        onSubmitted: (_) => _submit(),
        textInputAction: TextInputAction.done,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(onPressed: _submit, child: const Text('追加')),
      ],
    );
  }
}
