import 'package:flutter/material.dart';

import '../../models/game.dart';
import '../../models/habit.dart';
import '../../models/mood.dart';
import '../../models/user.dart';
import '../../models/wish.dart';
import '../theme/app_theme.dart';

class MockData {
  static Map<String, dynamic> demoUserToJson({
    String? nickname,
    String? phone,
  }) {
    return <String, dynamic>{
      'id': 1,
      'phone': phone ?? '13800000000',
      'nickname': nickname ?? '小满',
      'avatarUrl': null,
      'createdAt': '2026-01-12T08:00:00.000Z',
    };
  }

  static final demoUser = User.fromJson(demoUserToJson());

  static final demoPartner = User.fromJson(<String, dynamic>{
    'id': 2,
    'phone': '13900000000',
    'nickname': '阿曜',
    'avatarUrl': null,
    'createdAt': '2026-01-12T08:00:00.000Z',
  });

  static final demoPartnerInfo = PartnerInfo(
    couple: Couple(
      id: 1,
      userAId: 1,
      userBId: 2,
      startDate: '2026-05-20',
      status: 'active',
    ),
    partner: demoPartner,
  );

  static final habits = <Habit>[
    Habit(id: 1, coupleId: 1, name: '一起喝水', icon: '💧', sortOrder: 0),
    Habit(id: 2, coupleId: 1, name: '晚安打卡', icon: '🌙', sortOrder: 1),
    Habit(id: 3, coupleId: 1, name: '夸夸对方', icon: '🌷', sortOrder: 2),
    Habit(id: 4, coupleId: 1, name: '同步日程', icon: '🗓', sortOrder: 3),
  ];

  static final habitStats = HabitStats(total: 4, completed: 3);

  static final todos = <Map<String, dynamic>>[
    {'id': 1, 'content': '周五晚餐订位', 'completed': false},
    {'id': 2, 'content': '给 TA 准备早安便签', 'completed': true},
    {'id': 3, 'content': '共享相册补上上周照片', 'completed': false},
  ];

  static final moodToday = MoodRecord(
    id: 1,
    userId: 1,
    date: '2026-07-09',
    moodValue: 78,
    note: '工作收尾很顺，晚上想和 TA 散步。',
  );

  static final partnerMood = MoodRecord(
    id: 2,
    userId: 2,
    date: '2026-07-09',
    moodValue: 62,
    note: '今天有点累，但看到消息会开心。',
  );

  static final moodHistory = <MoodRecord>[
    MoodRecord(id: 3, userId: 1, date: '2026-07-01', moodValue: 58),
    MoodRecord(id: 4, userId: 1, date: '2026-07-02', moodValue: 74),
    MoodRecord(id: 5, userId: 1, date: '2026-07-03', moodValue: 68),
    MoodRecord(id: 6, userId: 1, date: '2026-07-04', moodValue: 82),
    MoodRecord(id: 7, userId: 1, date: '2026-07-05', moodValue: 65),
    MoodRecord(id: 8, userId: 1, date: '2026-07-06', moodValue: 88),
    MoodRecord(id: 9, userId: 1, date: '2026-07-07', moodValue: 72),
    MoodRecord(id: 10, userId: 1, date: '2026-07-08', moodValue: 79),
  ];

  static final whispers = <WishNote>[
    WishNote(
      id: 1,
      coupleId: 1,
      fromUserId: 2,
      content: '下次见面想抱你久一点。',
      type: 'whisper',
      isRead: false,
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    WishNote(
      id: 2,
      coupleId: 1,
      fromUserId: 1,
      content: '其实我今天一直在想你。',
      type: 'whisper',
      isRead: true,
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static final wishes = <WishNote>[
    WishNote(
      id: 3,
      coupleId: 1,
      fromUserId: 1,
      content: '秋天一起去看海。',
      type: 'wish',
      isRead: false,
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    WishNote(
      id: 4,
      coupleId: 1,
      fromUserId: 2,
      content: '把我们每个月的合照都洗出来。',
      type: 'wish',
      isRead: true,
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  static final status = UserStatus(
    id: 1,
    userId: 1,
    type: 'mood',
    content: '想你了',
    emoji: '🥹',
    bgColor: '#FFE6F0',
    expiresAt: DateTime.now().add(const Duration(hours: 8)),
  );

  static final anniversaries = <Anniversary>[
    Anniversary(
      id: 1,
      title: '在一起',
      date: '2026-05-20',
      type: 'recurring',
      remindConfig: const {
        'onDay': true,
        'threeDaysBefore': true,
        'sevenDaysBefore': false,
      },
    ),
    Anniversary(
      id: 2,
      title: '第一次旅行',
      date: '2026-08-18',
      type: 'once',
    ),
    Anniversary(
      id: 3,
      title: '第一次牵手',
      date: '2026-07-14',
      type: 'recurring',
    ),
  ];

  static final upcomingAnniversaries = <Map<String, dynamic>>[
    {'ann': anniversaries[2], 'daysLeft': 5},
    {'ann': anniversaries[1], 'daysLeft': 40},
  ];

  static const greeting = <String, dynamic>{
    'date': '2026-07-09',
    'contentA': '今天也想把最柔软的那一面留给你。',
    'contentB': '你出现之后，我连普通的傍晚都觉得值得收藏。',
  };

  static const homeWeather = <String, dynamic>{
    'city': '上海',
    'temperature': 30,
    'description': '多云转晴',
    'reminder': '傍晚适合散步，记得带一把小伞。',
  };

  static const weatherForecast = <Map<String, dynamic>>[
    {'day': '今天', 'icon': '⛅', 'high': 31, 'low': 26},
    {'day': '明天', 'icon': '🌦', 'high': 29, 'low': 25},
    {'day': '周六', 'icon': '☀️', 'high': 33, 'low': 27},
  ];

  static const butlerAdvice = <String, dynamic>{
    'warning': '今天对方精力一般，交流时更适合给回应而不是追问。',
    'cached': true,
    'suggestions': [
      '把“你忙完了吗”换成“我等你回来聊”。',
      '发一张今天路上看到的小事，降低开启聊天的门槛。',
      '睡前问一句“你今天最辛苦的时刻是什么”。',
    ],
    'templates': [
      '我不急着打扰你，就是想让你知道我在想你。',
      '今天辛苦了，晚一点记得回来让我抱一下。',
      '你不用一直很厉害，在我这里可以先放松。',
    ],
  };

  static final gameHistory = <GameRoom>[
    GameRoom(
      id: 11,
      gameType: 'match_test',
      status: 'finished',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    GameRoom(
      id: 12,
      gameType: 'heart_qa',
      status: 'finished',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static const gameCatalog = <Map<String, String>>[
    {
      'type': 'heart_qa',
      'name': '心动问答',
      'icon': '💞',
      'desc': '轮流回答问题，把想法说深一点。',
    },
    {
      'type': 'two_choice',
      'name': '甜蜜二选一',
      'icon': '✨',
      'desc': '快速作答，看看默契反应。',
    },
    {
      'type': 'love_task',
      'name': '爱的任务',
      'icon': '🎯',
      'desc': '抽一张轻任务，今天就去做。',
    },
    {
      'type': 'match_test',
      'name': '默契大考验',
      'icon': '🧠',
      'desc': '分开作答，最后统一看分数。',
    },
  ];

  static const gameQuestion = <String, dynamic>{
    'question': '如果我们突然有一整天空闲，你最想一起做什么？',
    'options': ['窝在家看电影', '去城市边缘散步', '找一家新店吃饭', '短途出逃半天'],
  };

  static const albums = <Map<String, dynamic>>[
    {'id': 1, 'name': '春天散步'},
    {'id': 2, 'name': '夜宵地图'},
    {'id': 3, 'name': '碎片日常'},
  ];

  static const albumPhotos = <Map<String, dynamic>>[
    {'id': 1, 'title': '地铁玻璃倒影', 'likes': 14, 'comments': 3, 'color': 0xFFFFE3E3},
    {'id': 2, 'title': '晚霞和冰淇淋', 'likes': 22, 'comments': 5, 'color': 0xFFFFF2D8},
    {'id': 3, 'title': '雨后的人行道', 'likes': 9, 'comments': 1, 'color': 0xFFE5F1FF},
    {'id': 4, 'title': '出门前的镜子', 'likes': 18, 'comments': 4, 'color': 0xFFF0E8FF},
  ];

  static const mapSnapshot = <String, dynamic>{
    'distance': '5.2 公里',
    'partnerSharing': true,
    'myLocation': {'lat': 31.2304, 'lng': 121.4737, 'updatedAt': 1720483200},
    'partnerLocation': {'lat': 31.2212, 'lng': 121.4581, 'updatedAt': 1720483500},
  };

  static Color parseHexColor(String? hex, {Color fallback = AppTheme.lightPink}) {
    if (hex == null || hex.isEmpty) {
      return fallback;
    }
    final normalized = hex.replaceFirst('#', '');
    return Color(int.parse('FF$normalized', radix: 16));
  }
}
