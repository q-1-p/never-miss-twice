import '../../domain/habit/habit.dart';

class HabitModel {
  final String id;
  final String name;
  final String createdAt;
  final List<String> completedDates;

  const HabitModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.completedDates,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) => HabitModel(
        id: json['id'] as String,
        name: json['name'] as String,
        createdAt: json['createdAt'] as String,
        completedDates: List<String>.from(json['completedDates'] as List),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt,
        'completedDates': completedDates,
      };

  Habit toDomain() => Habit(
        id: id,
        name: name,
        createdAt: DateTime.parse(createdAt),
        completedDates: Set<String>.from(completedDates),
      );

  factory HabitModel.fromDomain(Habit habit) => HabitModel(
        id: habit.id,
        name: habit.name,
        createdAt: habit.createdAt.toIso8601String(),
        completedDates: habit.completedDates.toList(),
      );
}
