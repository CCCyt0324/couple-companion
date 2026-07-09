import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';

class GameHubScreen extends StatelessWidget {
  const GameHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const AppGradientHeader(
              title: '情侣小游戏',
              subtitle: '更多趣味游戏即将上线',
              icon: '🎮',
            ),
            const Spacer(),
            Center(
              child: Column(
                children: [
                  const Text('🚧', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text('功能尚在开发中', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textGray)),
                  const SizedBox(height: 8),
                  const Text('心动问答、甜蜜二选一、爱的任务、默契大考验\n正在紧锣密鼓地开发中，敬请期待～', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppTheme.textGray)),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
