import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_constants.dart';
import '../core/mock/mock_data.dart';
import '../models/mood.dart';
import '../services/api/api_service.dart';

class MoodState {
  const MoodState({
    this.today,
    this.partnerMood,
    this.history = const [],
    this.isLoading = false,
  });

  final MoodRecord? today;
  final MoodRecord? partnerMood;
  final List<MoodRecord> history;
  final bool isLoading;

  MoodState copyWith({
    MoodRecord? today,
    MoodRecord? partnerMood,
    List<MoodRecord>? history,
    bool? isLoading,
  }) {
    return MoodState(
      today: today ?? this.today,
      partnerMood: partnerMood ?? this.partnerMood,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MoodNotifier extends StateNotifier<MoodState> {
  MoodNotifier() : super(const MoodState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final results = await Future.wait([
        apiService.get(ApiConstants.moodToday),
        apiService.get(ApiConstants.moodCompare),
      ]);
      final todayData = apiService.unwrap(results[0].data);
      final compareData = apiService.unwrap(results[1].data);
      state = state.copyWith(
        today: todayData is Map<String, dynamic>
            ? MoodRecord.fromJson(todayData)
            : null,
        partnerMood: compareData is Map<String, dynamic> &&
                compareData['partnerMood'] is Map<String, dynamic>
            ? MoodRecord.fromJson(
                compareData['partnerMood'] as Map<String, dynamic>,
              )
            : null,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        today: MockData.moodToday,
        partnerMood: MockData.partnerMood,
        history: MockData.moodHistory,
        isLoading: false,
      );
    }
  }

  Future<void> set(int value, {String? note}) async {
    try {
      await apiService.post(
        ApiConstants.moodRecord,
        data: {'moodValue': value, 'note': note},
      );
      await load();
    } catch (_) {
      state = state.copyWith(
        today: MoodRecord(
          id: state.today?.id ?? 1,
          userId: state.today?.userId ?? 1,
          date: DateTime.now().toIso8601String().substring(0, 10),
          moodValue: value,
          note: note,
        ),
      );
    }
  }

  Future<void> loadHistory(int year, int month) async {
    try {
      final res = await apiService.get(
        ApiConstants.moodHistory,
        params: {'year': year, 'month': month},
      );
      final payload = apiService.unwrap(res.data) as List<dynamic>;
      state = state.copyWith(
        history: payload
            .map((item) => MoodRecord.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (_) {
      state = state.copyWith(history: MockData.moodHistory);
    }
  }
}

final moodProvider =
    StateNotifierProvider<MoodNotifier, MoodState>((ref) => MoodNotifier());
