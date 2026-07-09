import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  static const presets = <String, List<Map<String, String>>>{
    '心情类': [
      {'emoji': '😊', 'text': '开心'},
      {'emoji': '😞', 'text': '难过'},
      {'emoji': '😴', 'text': '疲惫'},
      {'emoji': '🥹', 'text': '想你'},
    ],
    '活动类': [
      {'emoji': '💼', 'text': '工作中'},
      {'emoji': '📚', 'text': '学习中'},
      {'emoji': '🍜', 'text': '吃饭中'},
      {'emoji': '🏃', 'text': '运动中'},
    ],
    '特殊类': [
      {'emoji': '🫂', 'text': '求抱抱'},
      {'emoji': '🌧', 'text': 'emo中'},
      {'emoji': '🔕', 'text': '想静静'},
      {'emoji': '📞', 'text': '等你找我'},
    ],
  };

  String _content = MockData.status.content;
  String _emoji = MockData.status.emoji ?? '🥹';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            const AppGradientHeader(
              title: '情侣状态',
              subtitle: '状态设置、复制同款、互动按钮都已经具备展示位。',
              icon: '💬',
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                color: MockData.parseHexColor(MockData.status.bgColor),
                child: Row(
                  children: [
                    Text(_emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _content,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...presets.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSectionTitle(title: entry.key),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: entry.value
                            .map(
                              (item) => ChoiceChip(
                                label: Text('${item['emoji']} ${item['text']}'),
                                selected: _content == item['text'],
                                onSelected: (_) {
                                  setState(() {
                                    _content = item['text']!;
                                    _emoji = item['emoji']!;
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('戳一戳'))),
                  const SizedBox(width: 10),
                  Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('抱抱'))),
                  const SizedBox(width: 10),
                  Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('同款'))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
