class Habit {
  final String id;
  final String name;
  final DateTime createdAt;
  final Set<String> completedDates;

  const Habit({
    required this.id,
    required this.name,
    required this.createdAt,
    this.completedDates = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'completedDates': completedDates.toList(),
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        completedDates: Set<String>.from(json['completedDates'] as List),
      );

  Habit copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    Set<String>? completedDates,
  }) =>
      Habit(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        completedDates: completedDates ?? this.completedDates,
      );
}
