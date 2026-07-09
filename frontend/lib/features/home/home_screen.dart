import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final habits = ref.watch(habitProvider);
    final partnerInfo = MockData.demoPartnerInfo;
    final startDate = DateTime.tryParse(partnerInfo.couple?.startDate ?? '');
    final loveDays =
        startDate == null ? 0 : DateTime.now().difference(startDate).inDays + 1;
    final userName = authState.user?.nickname ?? MockData.demoUser.nickname;
    final todoList = MockData.todos;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(habitProvider.notifier).load();
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              AppGradientHeader(
                title: '第 $loveDays 天',
                subtitle: '你好，$userName。今天也继续把陪伴做得认真一点。',
                icon: '💞',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '手机号',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authState.user?.phone ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppSectionTitle(title: '今日情话'),
                      const SizedBox(height: 14),
                      _BubbleLine(
                        label: 'TA',
                        text: MockData.greeting['contentB'] as String,
                        tint: AppTheme.lightPink,
                      ),
                      const SizedBox(height: 10),
                      _BubbleLine(
                        label: '我',
                        text: MockData.greeting['contentA'] as String,
                        tint: AppTheme.peach,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickEntryCard(
                        title: '记录心情',
                        subtitle: '把今天的状态告诉 TA',
                        icon: '🌡',
                        color: AppTheme.peach,
                        onTap: () => context.push('/mood'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickEntryCard(
                        title: '房间码',
                        subtitle: '输入相同码同步数据',
                        icon: '🏠',
                        color: AppTheme.sky,
                        onTap: () => context.push('/room'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppSectionTitle(title: '打卡进度'),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: habits.stats?.progress ?? 0.75,
                              minHeight: 14,
                              borderRadius: BorderRadius.circular(99),
                              backgroundColor: AppTheme.lightPink,
                              color: AppTheme.primaryPink,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${habits.stats?.completed ?? 3}/${habits.stats?.total ?? 4}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (habits.habits.isEmpty
                                ? MockData.habits
                                : habits.habits)
                            .take(4)
                            .map(
                              (habit) => AppInfoChip(
                                label: habit.name,
                                icon: habit.icon,
                                background: AppTheme.peach,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppSectionTitle(title: '待办摘要'),
                      const SizedBox(height: 14),
                      ...todoList.map(
                        (todo) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            (todo['completed'] as bool)
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: (todo['completed'] as bool)
                                ? AppTheme.primaryPink
                                : AppTheme.textGray,
                          ),
                          title: Text(
                            todo['content'] as String,
                            style: TextStyle(
                              decoration: (todo['completed'] as bool)
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: (todo['completed'] as bool)
                                  ? AppTheme.textGray
                                  : AppTheme.textDark,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push('/todos'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        color: AppTheme.sky,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('天气'),
                            const SizedBox(height: 8),
                            Text(
                              '${MockData.homeWeather['temperature']}°',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(MockData.homeWeather['description'] as String),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppCard(
                        color: AppTheme.peach,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('经期卡片'),
                            SizedBox(height: 8),
                            Text(
                              '还有 6 天',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text('预测日期 07-15'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BubbleLine extends StatelessWidget {
  const _BubbleLine({
    required this.label,
    required this.text,
    required this.tint,
  });

  final String label;
  final String text;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textGray,
            ),
          ),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(color: AppTheme.textDark, height: 1.5)),
        ],
      ),
    );
  }
}

class _QuickEntryCard extends StatelessWidget {
  const _QuickEntryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: color,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: AppTheme.textGray)),
        ],
      ),
    );
  }
}
