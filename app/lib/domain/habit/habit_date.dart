class HabitDate {
  const HabitDate._();

  static String _format(DateTime date) =>
      '${date.year}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String today() => _format(DateTime.now());

  static String yesterday() =>
      _format(DateTime.now().subtract(const Duration(days: 1)));

  static String fromDateTime(DateTime date) => _format(date);
}
