import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';
import '../../models/habit.dart';
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
        onPressed: () => _addHabit(context, ref), backgroundColor: AppTheme.primaryPink, child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(child: ListView(padding: const EdgeInsets.only(bottom: 96), children: [
        const AppGradientHeader(title: '任务中心', subtitle: '习惯打卡 + 待办事项', icon: '✅'),
        const SizedBox(height: 18),

        // 今日进度卡片——点击弹出明细
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: GestureDetector(
          onTap: () => _showProgressDetail(context, ref),
          child: AppCard(color: AppTheme.peach, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const AppSectionTitle(title: '今日进度'),
              const Spacer(),
              const Text('查看明细 ›', style: TextStyle(fontSize: 13, color: AppTheme.primaryPink)),
            ]),
            const SizedBox(height: 14),
            LinearProgressIndicator(value: stats.progress, minHeight: 14, borderRadius: BorderRadius.circular(99), backgroundColor: AppTheme.lightPink, color: AppTheme.primaryPink),
            const SizedBox(height: 12),
            Text('已完成 ${stats.completed}/${stats.total} 项', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ])),
        )),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppSectionTitle(title: '习惯打卡', actionLabel: '待办清单', onAction: () => context.push('/todos')),
        ),
        const SizedBox(height: 8),
        ...habits.map((h) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: AppCard(child: Row(children: [
            Text(h.icon, style: const TextStyle(fontSize: 28)), const SizedBox(width: 12),
            Expanded(child: Text(h.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            OutlinedButton(onPressed: () => ref.read(habitProvider.notifier).toggle(h.id), child: const Text('打卡')),
          ])),
        )),
      ])),
    );
  }

  void _showProgressDetail(BuildContext context, WidgetRef ref) {
    final state = ref.read(habitProvider);
    final habits = state.habits.isEmpty ? MockData.habits : state.habits;
    final done = state.completedIds;

    final completed = habits.where((h) => done.contains(h.id) || h.todayDone).toList();
    final uncompleted = habits.where((h) => !done.contains(h.id) && !h.todayDone).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('📋 今日打卡明细', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('每日 00:00 自动重置，第二天重新开始', style: TextStyle(fontSize: 12, color: AppTheme.textGray)),
            const SizedBox(height: 16),

            if (completed.isNotEmpty) ...[
              Text('✅ 已完成 (${completed.length})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryPink)),
              const SizedBox(height: 8),
              ...completed.map((h) => _habitRow(h, true)),
              const SizedBox(height: 16),
            ],
            if (uncompleted.isNotEmpty) ...[
              Text('⏳ 未完成 (${uncompleted.length})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textGray)),
              const SizedBox(height: 8),
              ...uncompleted.map((h) => _habitRow(h, false)),
            ],
            if (habits.isEmpty) const Text('还没有添加习惯'),
            const SizedBox(height: 12),
          ]),
        );
      },
    );
  }

  Widget _habitRow(Habit h, bool done) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Text(h.icon, style: const TextStyle(fontSize: 24)), const SizedBox(width: 10),
      Expanded(child: Text(h.name, style: TextStyle(fontSize: 16, color: done ? AppTheme.textGray : AppTheme.textDark))),
      Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? AppTheme.primaryPink : AppTheme.textGray),
    ]),
  );

  Future<void> _addHabit(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    const icons = ['💧', '🍎', '😴', '🧴', '🏠', '🏃', '📖', '💊', '🎵'];
    String selected = '💧';
    await showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDlg) => AlertDialog(
      title: const Text('添加习惯'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: ctrl, decoration: const InputDecoration(hintText: '习惯名称')),
        const SizedBox(height: 12),
        Wrap(spacing: 6, children: icons.map((i) => GestureDetector(
          onTap: () => setDlg(() => selected = i),
          child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(border: Border.all(color: selected == i ? AppTheme.primaryPink : Colors.transparent, width: 2), borderRadius: BorderRadius.circular(8)), child: Text(i, style: const TextStyle(fontSize: 28))),
        )).toList()),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        ElevatedButton(onPressed: () { ref.read(habitProvider.notifier).add(ctrl.text.trim(), selected); Navigator.pop(ctx); }, child: const Text('添加')),
      ],
    )));
  }
}
