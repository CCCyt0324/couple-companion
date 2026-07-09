import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';

class GameRoomScreen extends StatelessWidget {
  const GameRoomScreen({super.key, required this.roomId});
  final int roomId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            AppGradientHeader(title: '房间 #$roomId', subtitle: '游戏房间', icon: '🎮'),
            const Spacer(),
            const Center(
              child: Column(
                children: [
                  Text('🚧', style: TextStyle(fontSize: 64)),
                  SizedBox(height: 16),
                  Text('功能尚在开发中', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textGray)),
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
