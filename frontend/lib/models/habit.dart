class Habit {
  Habit({
    required this.id,
    required this.coupleId,
    required this.name,
    required this.icon,
    required this.sortOrder,
  });

  final int id;
  final int coupleId;
  final String name;
  final String icon;
  final int sortOrder;

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as int? ?? 0,
        coupleId: json['coupleId'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        icon: json['icon'] as String? ?? '✨',
        sortOrder: json['sortOrder'] as int? ?? 0,
      );
}

class HabitStats {
  HabitStats({required this.total, required this.completed});

  final int total;
  final int completed;

  factory HabitStats.fromJson(Map<String, dynamic> json) => HabitStats(
        total: json['total'] as int? ?? 0,
        completed: json['completed'] as int? ?? 0,
      );

  double get progress => total == 0 ? 0 : completed / total;
}
