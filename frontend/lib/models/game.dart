class GameRoom {
  GameRoom({
    required this.id,
    required this.gameType,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String gameType;
  final String status;
  final DateTime createdAt;

  factory GameRoom.fromJson(Map<String, dynamic> json) => GameRoom(
        id: json['id'] as int? ?? 0,
        gameType: json['gameType'] as String? ?? '',
        status: json['status'] as String? ?? 'waiting',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  String get gameName {
    switch (gameType) {
      case 'heart_qa':
        return '心动问答';
      case 'two_choice':
        return '甜蜜二选一';
      case 'love_task':
        return '爱的任务';
      case 'match_test':
        return '默契大考验';
      default:
        return gameType;
    }
  }

  String get gameIcon {
    switch (gameType) {
      case 'heart_qa':
        return '💞';
      case 'two_choice':
        return '✨';
      case 'love_task':
        return '🎯';
      case 'match_test':
        return '🧠';
      default:
        return '🎮';
    }
  }
}

class MatchResult {
  MatchResult({required this.score, required this.grade});

  final int score;
  final String grade;

  factory MatchResult.fromJson(Map<String, dynamic> json) => MatchResult(
        score: json['score'] as int? ?? 0,
        grade: json['grade'] as String? ?? '',
      );
}
