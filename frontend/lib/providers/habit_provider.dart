import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../core/mock/mock_data.dart';
import '../models/habit.dart';
import '../services/api/api_service.dart';

class HabitState {
  const HabitState({this.habits = const [], this.stats, this.completedIds = const {}, this.isLoading = false});
  final List<Habit> habits;
  final HabitStats? stats;
  final Set<int> completedIds;
  final bool isLoading;

  HabitState copyWith({List<Habit>? habits, HabitStats? stats, Set<int>? completedIds, bool? isLoading}) =>
    HabitState(habits: habits ?? this.habits, stats: stats ?? this.stats, completedIds: completedIds ?? this.completedIds, isLoading: isLoading ?? this.isLoading);
}

class HabitNotifier extends StateNotifier<HabitState> {
  HabitNotifier() : super(const HabitState()) { load(); }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final [habitRes, statsRes] = await Future.wait([
        apiService.get(ApiConstants.habits),
        apiService.get(ApiConstants.habitStats),
      ]);
      final raw = apiService.unwrap(habitRes.data) as List<dynamic>;
      final statsRaw = apiService.unwrap(statsRes.data) as Map<String, dynamic>;

      final habits = raw.map((j) => Habit.fromJson(j as Map<String, dynamic>)).toList();
      final doneIds = habits.where((h) => h.todayDone).map((h) => h.id).toSet();

      state = state.copyWith(
        habits: habits,
        stats: HabitStats.fromJson(statsRaw),
        completedIds: doneIds,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(habits: MockData.habits, stats: MockData.habitStats, isLoading: false);
    }
  }

  Future<void> toggle(int habitId) async {
    final newSet = Set<int>.from(state.completedIds);
    final cur = state.stats?.completed ?? 0;
    final tot = state.stats?.total ?? 5;
    if (newSet.contains(habitId)) { newSet.remove(habitId); state = state.copyWith(completedIds: newSet, stats: HabitStats(total: tot, completed: cur - 1)); }
    else { newSet.add(habitId); state = state.copyWith(completedIds: newSet, stats: HabitStats(total: tot, completed: cur + 1)); }
    try { await apiService.put('${ApiConstants.habitToggle}/$habitId/toggle'); await load(); } catch (_) { await load(); }
  }

  Future<void> add(String n, String i) async {
    try { await apiService.post(ApiConstants.habits, data: {'name': n, 'icon': i}); await load(); }
    catch (_) { final next = [...state.habits, Habit(id: state.habits.length + 100, roomId: 1, name: n, icon: i, sortOrder: state.habits.length)]; state = state.copyWith(habits: next, stats: HabitStats(total: next.length, completed: state.stats?.completed ?? 0)); }
  }

  Future<void> remove(int id) async {
    try { await apiService.delete('${ApiConstants.habitToggle}/$id'); await load(); }
    catch (_) { final next = state.habits.where((h) => h.id != id).toList(); state = state.copyWith(habits: next, stats: HabitStats(total: next.length, completed: (state.stats?.completed ?? 0).clamp(0, next.length))); }
  }
}

final habitProvider = StateNotifierProvider<HabitNotifier, HabitState>((ref) => HabitNotifier());
