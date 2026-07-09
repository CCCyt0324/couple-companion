class Habit {
  Habit({required this.id, required this.roomId, required this.name, required this.icon, required this.sortOrder, this.todayDone = false, this.todayDoneBy});
  final int id, roomId, sortOrder;
  final String name, icon;
  final bool todayDone;
  final int? todayDoneBy;

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    id: json['id'] as int? ?? 0, roomId: json['roomId'] as int? ?? 0,
    name: json['name'] as String? ?? '', icon: json['icon'] as String? ?? '✨', sortOrder: json['sortOrder'] as int? ?? 0,
    todayDone: json['todayDone'] as bool? ?? false, todayDoneBy: json['todayDoneBy'] as int?,
  );
}

class HabitStats {
  HabitStats({required this.total, required this.completed});
  final int total, completed;
  factory HabitStats.fromJson(Map<String, dynamic> json) => HabitStats(total: json['total'] as int? ?? 0, completed: json['completed'] as int? ?? 0);
  double get progress => total == 0 ? 0 : completed / total;
}
