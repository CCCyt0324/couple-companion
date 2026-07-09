import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';
import '../../providers/habit_provider.dart';

class HabitScreen extends ConsumerWidget {
  const HabitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(habitProvider);
    final habits = state.habits.isEmpty ? MockData.habits : state.habits;
    final stats = state.stats ?? MockData.habitStats;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(context, ref),
        backgroundColor: AppTheme.primaryPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            const AppGradientHeader(
              title: '任务中心',
              subtitle: '把习惯打卡和待办事项合并成一个节奏感更强的操作区。',
              icon: '✅',
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                color: AppTheme.peach,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionTitle(title: '今日进度'),
                    const SizedBox(height: 14),
                    LinearProgressIndicator(
                      value: stats.progress,
                      minHeight: 14,
                      borderRadius: BorderRadius.circular(99),
                      backgroundColor: AppTheme.lightPink,
                      color: AppTheme.primaryPink,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '已完成 ${stats.completed} / ${stats.total} 项',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppSectionTitle(
                title: '习惯打卡',
                actionLabel: '待办清单',
                onAction: () => context.push('/todos'),
              ),
            ),
            const SizedBox(height: 8),
            ...habits.map(
              (habit) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: AppCard(
                  child: Row(
                    children: [
                      Text(habit.icon, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          habit.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            ref.read(habitProvider.notifier).toggle(habit.id),
                        child: const Text('打卡'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddHabitDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    const icons = ['💧', '🌙', '🌷', '🗓', '🍎', '🏃'];
    var selectedIcon = icons.first;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('添加习惯'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: '习惯名称'),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: icons
                        .map(
                          (icon) => ChoiceChip(
                            label: Text(icon),
                            selected: selectedIcon == icon,
                            onSelected: (_) => setState(() => selectedIcon = icon),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(habitProvider.notifier)
                        .add(controller.text.trim(), selectedIcon);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('添加'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
