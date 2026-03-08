import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/habit/habit.dart';
import 'habit_notifier.dart';

class HabitAddDialog extends StatefulWidget {
  final Habit? habit;

  const HabitAddDialog({super.key, this.habit});

  @override
  State<HabitAddDialog> createState() => _HabitAddDialogState();
}

class _HabitAddDialogState extends State<HabitAddDialog> {
  final _controller = TextEditingController();

  bool get _isEditing => widget.habit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _controller.text = widget.habit!.name;
    }
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
    final notifier = context.read<HabitNotifier>();
    if (_isEditing) {
      notifier.updateHabit(widget.habit!.id, name);
    } else {
      notifier.addHabit(name);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = _controller.text.trim().isNotEmpty;

    return AlertDialog(
      icon: Icon(
        _isEditing ? Icons.edit_rounded : Icons.add_task_rounded,
        color: theme.colorScheme.primary,
        size: 32,
      ),
      title: Text(_isEditing ? '習慣を編集' : '新しい習慣'),
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
            _isEditing ? '習慣の名前を変更できます' : '毎日続けられる小さな習慣から始めましょう',
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
          icon: Icon(
            _isEditing ? Icons.check_rounded : Icons.add_rounded,
            size: 18,
          ),
          label: Text(_isEditing ? '更新する' : '追加する'),
        ),
      ],
    );
  }
}
