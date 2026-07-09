class User {
  User({required this.id, this.phone, this.email, required this.nickname, this.avatarUrl, required this.createdAt});

  final int id;
  final String? phone;
  final String? email;
  final String nickname;
  final String? avatarUrl;
  final DateTime createdAt;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int? ?? 0,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    nickname: json['nickname'] as String? ?? '',
    avatarUrl: json['avatarUrl'] as String?,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class Couple {
  Couple({required this.id, required this.userAId, required this.userBId, required this.startDate, required this.status});
  final int id, userAId, userBId;
  final String startDate, status;

  factory Couple.fromJson(Map<String, dynamic> json) => Couple(
    id: json['id'] as int? ?? 0,
    userAId: json['userAId'] as int? ?? 0,
    userBId: json['userBId'] as int? ?? 0,
    startDate: json['startDate'] as String? ?? '',
    status: json['status'] as String? ?? 'active',
  );
}

class PartnerInfo {
  PartnerInfo({this.couple, this.partner});
  final Couple? couple;
  final User? partner;

  factory PartnerInfo.fromJson(Map<String, dynamic> json) => PartnerInfo(
    couple: json['couple'] is Map<String, dynamic> ? Couple.fromJson(json['couple'] as Map<String, dynamic>) : null,
    partner: json['partner'] is Map<String, dynamic> ? User.fromJson(json['partner'] as Map<String, dynamic>) : null,
  );
  bool get isBound => couple != null && partner != null;
}
