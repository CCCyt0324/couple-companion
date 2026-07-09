import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';

class GameRoomScreen extends StatefulWidget {
  const GameRoomScreen({super.key, required this.roomId});

  final int roomId;

  @override
  State<GameRoomScreen> createState() => _GameRoomScreenState();
}

class _GameRoomScreenState extends State<GameRoomScreen> {
  String? _selected;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final question = MockData.gameQuestion['question'] as String;
    final options = (MockData.gameQuestion['options'] as List<dynamic>).cast<String>();

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            AppGradientHeader(
              title: '房间 #${widget.roomId}',
              subtitle: _submitted ? '已提交答案，等待结算结果。' : '先选一个最像你们的答案。',
              icon: '🧠',
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionTitle(title: '题目'),
                    const SizedBox(height: 12),
                    Text(
                      question,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...options.map(
                      (option) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ChoiceChip(
                          label: SizedBox(
                            width: double.infinity,
                            child: Text(option),
                          ),
                          selected: _selected == option,
                          onSelected: _submitted
                              ? null
                              : (_) => setState(() => _selected = option),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selected == null || _submitted
                            ? null
                            : () => setState(() => _submitted = true),
                        child: Text(_submitted ? '已提交' : '提交答案'),
                      ),
                    ),
                    if (_submitted) ...[
                      const SizedBox(height: 16),
                      AppCard(
                        color: AppTheme.sky,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '默契结果',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 8),
                            Text('心有灵犀 85 分'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => context.go('/games'),
                        child: const Text('返回游戏大厅'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
