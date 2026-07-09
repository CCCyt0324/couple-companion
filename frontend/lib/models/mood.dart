import 'package:flutter/material.dart';

class MoodRecord {
  MoodRecord({
    required this.id,
    required this.userId,
    required this.date,
    required this.moodValue,
    this.note,
  });

  final int id;
  final int userId;
  final String date;
  final int moodValue;
  final String? note;

  factory MoodRecord.fromJson(Map<String, dynamic> json) => MoodRecord(
        id: json['id'] as int? ?? 0,
        userId: json['userId'] as int? ?? 0,
        date: json['date'] as String? ?? '',
        moodValue: json['moodValue'] as int? ?? 50,
        note: json['note'] as String?,
      );

  static Color getColor(int value) {
    if (value <= 20) return const Color(0xFF4A90D9);
    if (value <= 40) return const Color(0xFF7BB3E0);
    if (value <= 60) return const Color(0xFF6BCB77);
    if (value <= 80) return const Color(0xFFFF9F45);
    return const Color(0xFFFF6B6B);
  }
}
