class WishNote {
  WishNote({
    required this.id,
    required this.coupleId,
    required this.fromUserId,
    required this.content,
    required this.type,
    required this.isRead,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final int coupleId;
  final int fromUserId;
  final String content;
  final String type;
  final bool isRead;
  final String status;
  final DateTime createdAt;

  factory WishNote.fromJson(Map<String, dynamic> json) => WishNote(
        id: json['id'] as int? ?? 0,
        coupleId: json['coupleId'] as int? ?? 0,
        fromUserId: json['fromUserId'] as int? ?? 0,
        content: json['content'] as String? ?? '',
        type: json['type'] as String? ?? '',
        isRead: json['isRead'] as bool? ?? false,
        status: json['status'] as String? ?? 'active',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  bool get isWhisper => type == 'whisper';
  bool get isWish => type == 'wish';
}

class UserStatus {
  UserStatus({
    required this.id,
    required this.userId,
    required this.type,
    required this.content,
    this.emoji,
    this.bgColor,
    required this.expiresAt,
  });

  final int id;
  final int userId;
  final String type;
  final String content;
  final String? emoji;
  final String? bgColor;
  final DateTime expiresAt;

  factory UserStatus.fromJson(Map<String, dynamic> json) => UserStatus(
        id: json['id'] as int? ?? 0,
        userId: json['userId'] as int? ?? 0,
        type: json['type'] as String? ?? '',
        content: json['content'] as String? ?? '',
        emoji: json['emoji'] as String?,
        bgColor: json['bgColor'] as String?,
        expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class Anniversary {
  Anniversary({
    required this.id,
    required this.title,
    required this.date,
    this.type = 'recurring',
    this.remindConfig,
    this.bgImageUrl,
  });

  final int id;
  final String title;
  final String date;
  final String type;
  final Map<String, bool>? remindConfig;
  final String? bgImageUrl;

  factory Anniversary.fromJson(Map<String, dynamic> json) => Anniversary(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        date: json['date'] as String? ?? '',
        type: json['type'] as String? ?? 'recurring',
        remindConfig: json['remindConfig'] is Map<String, dynamic>
            ? Map<String, bool>.from(json['remindConfig'] as Map<String, dynamic>)
            : null,
        bgImageUrl: json['bgImageUrl'] as String?,
      );

  bool get isRecurring => type == 'recurring';
}
