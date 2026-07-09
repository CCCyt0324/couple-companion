import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../core/mock/mock_data.dart';
import '../models/habit.dart';
import '../services/api/api_service.dart';

class HabitState {
  const HabitState({
    this.habits = const [],
    this.stats,
    this.isLoading = false,
  });

  final List<Habit> habits;
  final HabitStats? stats;
  final bool isLoading;

  HabitState copyWith({
    List<Habit>? habits,
    HabitStats? stats,
    bool? isLoading,
  }) {
    return HabitState(
      habits: habits ?? this.habits,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HabitNotifier extends StateNotifier<HabitState> {
  HabitNotifier() : super(const HabitState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final responses = await Future.wait([
        apiService.get(ApiConstants.habits),
        apiService.get(ApiConstants.habitStats),
      ]);
      final habitData = apiService.unwrap(responses[0].data) as List<dynamic>;
      final statsData = apiService.unwrap(responses[1].data) as Map<String, dynamic>;
      state = state.copyWith(
        habits: habitData
            .map((item) => Habit.fromJson(item as Map<String, dynamic>))
            .toList(),
        stats: HabitStats.fromJson(statsData),
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        habits: MockData.habits,
        stats: MockData.habitStats,
        isLoading: false,
      );
    }
  }

  Future<void> toggle(int habitId) async {
    try {
      await apiService.put('${ApiConstants.habitToggle}/$habitId/toggle');
      await load();
    } catch (_) {
      final stats = state.stats ?? MockData.habitStats;
      state = state.copyWith(
        stats: HabitStats(
          total: stats.total,
          completed: stats.completed < stats.total
              ? stats.completed + 1
              : stats.completed,
        ),
      );
    }
  }

  Future<void> add(String name, String icon) async {
    try {
      await apiService.post(
        ApiConstants.habits,
        data: {'name': name, 'icon': icon},
      );
      await load();
    } catch (_) {
      final next = [
        ...state.habits,
        Habit(
          id: state.habits.length + 100,
          coupleId: 1,
          name: name,
          icon: icon,
          sortOrder: state.habits.length,
        ),
      ];
      state = state.copyWith(
        habits: next,
        stats: HabitStats(
          total: next.length,
          completed: state.stats?.completed ?? 0,
        ),
      );
    }
  }

  Future<void> remove(int id) async {
    try {
      await apiService.delete('${ApiConstants.habitToggle}/$id');
      await load();
    } catch (_) {
      final next = state.habits.where((habit) => habit.id != id).toList();
      state = state.copyWith(
        habits: next,
        stats: HabitStats(
          total: next.length,
          completed:
              ((state.stats?.completed ?? 0).clamp(0, next.length) as num)
                  .toInt(),
        ),
      );
    }
  }
}

final habitProvider =
    StateNotifierProvider<HabitNotifier, HabitState>((ref) => HabitNotifier());
