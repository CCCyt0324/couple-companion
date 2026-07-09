import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';

class GameHubScreen extends StatelessWidget {
  const GameHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            const AppGradientHeader(
              title: '情侣小游戏',
              subtitle: '房间创建、开始游戏、答题和结果页都已经补出可走通的 UI。',
              icon: '🎮',
            ),
            const SizedBox(height: 18),
            ...MockData.gameCatalog.map(
              (game) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: AppCard(
                  color: AppTheme.peach,
                  child: Row(
                    children: [
                      Text(game['icon']!, style: const TextStyle(fontSize: 30)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              game['name']!,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(game['desc']!),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => context.push('/games/room/1'),
                        child: const Text('开始'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppSectionTitle(title: '最近游戏'),
            ),
            const SizedBox(height: 8),
            ...MockData.gameHistory.map(
              (room) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Text(room.gameIcon),
                    title: Text(room.gameName),
                    subtitle: Text(room.createdAt.toString().substring(0, 16)),
                    trailing: AppInfoChip(
                      label: room.status,
                      background: AppTheme.sky,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
