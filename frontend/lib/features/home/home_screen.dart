import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';
import '../../core/constants/api_constants.dart';
import '../../services/api/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../core/mock/mock_data.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Map<String, dynamic> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final [anniversaryRes, weatherRes, periodRes, greetingRes] = await Future.wait([
        apiService.get(ApiConstants.anniversaries),
        apiService.get(ApiConstants.weather, params: {'city': 'beijing'}),
        apiService.get(ApiConstants.periodCountdown),
        apiService.get(ApiConstants.greetingToday),
      ]);
      setState(() {
        final annList = (apiService.unwrap(anniversaryRes.data) as List?) ?? [];
        final weatherData = (apiService.unwrap(weatherRes.data) as Map?) ?? {};
        final countdown = apiService.unwrap(periodRes.data);
        final greeting = apiService.unwrap(greetingRes.data);

        _data = {
          'anniversaries': annList,
          'weather': (weatherData['weather'] as Map?) ?? {},
          'reminder': weatherData['reminder'] ?? '',
          'periodCountdown': countdown?.toString() ?? '--',
          'greeting': greeting,
          'loveDays': _calcLoveDays(annList),
        };
        _loading = false;
      });
    } catch (_) {
        ref.read(habitProvider.notifier).load();
      setState(() => _loading = false);
    }
  }

  int _calcLoveDays(List annList) {
    if (annList.isEmpty) return 0;
    final first = annList.first as Map;
    final date = first['date']?.toString() ?? '';
    if (date.length < 10) return 0;
    return DateTime.now().difference(DateTime.parse(date)).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final habit = ref.watch(habitProvider);
    final stats = habit.stats ?? MockData.habitStats;
    final weather = (_data['weather'] as Map?) ?? {};
    final dailyList = (weather['daily'] as List?) ?? [];

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPink))
          : ListView(padding: const EdgeInsets.only(bottom: 28), children: [
              AppGradientHeader(
                title: auth.user?.nickname ?? '情侣小宇宙',
                subtitle: '${_data['loveDays'] ?? 0} 天',
                icon: '💝',
              ),
              const SizedBox(height: 14),

              // 房间码
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(color: AppTheme.peach, child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.home_rounded, color: AppTheme.primaryPink),
                  title: const Text('房间码', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('共享数据给TA'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/room'),
                )),
              ),
              const SizedBox(height: 12),

              // 习惯打卡
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  AppSectionTitle(title: '今日习惯', actionLabel: '打卡', onAction: () => context.push('/habits')),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(value: stats.progress, minHeight: 10, borderRadius: BorderRadius.circular(99), backgroundColor: AppTheme.lightPink, color: AppTheme.primaryPink),
                  const SizedBox(height: 8),
                  Text('已完成 ${stats.completed}/${stats.total}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ])),
              ),
              const SizedBox(height: 12),

              // 天气
              if (dailyList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppCard(color: AppTheme.sky, child: Column(children: [
                    Row(children: [
                      Text('${weather['now']?['temp'] ?? '--'}°', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      Text(weather['now']?['text'] ?? '--', style: const TextStyle(fontSize: 16, color: AppTheme.textGray)),
                      const Spacer(),
                      const Text('更多 →', style: TextStyle(fontSize: 13, color: AppTheme.primaryPink)),
                    ]),
                    if (_data['reminder'] != null && _data['reminder'].toString().isNotEmpty)
                      Padding(padding: const EdgeInsets.only(top: 6), child: Text('💡 ${_data['reminder']}', style: const TextStyle(fontSize: 13))),
                  ])),
                ),
              const SizedBox(height: 12),

              // 经期倒计时
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(color: AppTheme.lightPink, child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Text('🩷', style: TextStyle(fontSize: 22)),
                  title: const Text('经期倒计时'),
                  subtitle: Text(_data['periodCountdown']?.toString() ?? '--'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/period'),
                )),
              ),
              const SizedBox(height: 12),

              // 快捷入口
              Row(
                children: [
                  Expanded(child: _quickCard('💝 心情记录', '记录今天的心情', '/mood', AppTheme.peach, context)),
                  Expanded(child: _quickCard('📅 纪念日', '${_data['loveDays'] ?? 0} 天在一起', '/anniversary', AppTheme.sky, context)),
                ].expand((w) => [w, const SizedBox(width: 12)]).take(3).toList(),
              ),
            ]),
      ),
    );
  }

  Widget _quickCard(String title, String subtitle, String route, Color color, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: title.contains('心情') ? 20 : 0, right: title.contains('纪念日') ? 20 : 0),
      child: SizedBox(width: 160, child: AppCard(color: color, onTap: () => context.push(route), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textGray)),
      ]))),
    );
  }
}
