import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';

class StorageService {
  static const _habitsKey = 'habits_v1';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  List<Habit> loadHabits() {
    final jsonString = _prefs.getString(_habitsKey);
    if (jsonString == null) return [];
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list.map((e) => Habit.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final jsonString = jsonEncode(habits.map((h) => h.toJson()).toList());
    await _prefs.setString(_habitsKey, jsonString);
  }
}
