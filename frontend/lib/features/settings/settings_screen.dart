import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user ?? MockData.demoUser;

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.only(bottom: 28), children: [
          const AppGradientHeader(title: '设置', subtitle: '自用模式 · 无需登录', icon: '⚙️'),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(radius: 28, backgroundColor: AppTheme.lightPink,
                  child: Text(user.nickname.isNotEmpty ? user.nickname[0] : 'U',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textDark))),
                title: Text(user.nickname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                subtitle: const Text('自用模式'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...const ['关于我们', '隐私设置', '推送通知', '意见反馈', '用户协议', '隐私政策'].map((t) =>
            Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), child: AppCard(child: ListTile(contentPadding: EdgeInsets.zero, title: Text(t), trailing: const Icon(Icons.chevron_right_rounded))))),
        ]),
      ),
    );
  }
}
