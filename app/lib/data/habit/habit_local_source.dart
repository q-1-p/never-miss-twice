import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'habit_model.dart';

class HabitLocalSource {
  static const _habitsKey = 'habits_v1';

  final SharedPreferences _prefs;

  HabitLocalSource(this._prefs);

  List<HabitModel> loadHabits() {
    final jsonString = _prefs.getString(_habitsKey);
    if (jsonString == null) return [];
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((e) => HabitModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveHabits(List<HabitModel> habits) async {
    final jsonString = jsonEncode(habits.map((h) => h.toJson()).toList());
    await _prefs.setString(_habitsKey, jsonString);
  }
}
