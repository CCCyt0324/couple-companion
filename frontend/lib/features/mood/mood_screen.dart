import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';
import '../../models/mood.dart';
import '../../providers/mood_provider.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  late final TextEditingController _noteController;
  double _value = 75;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(moodProvider);
    final today = state.today ?? MockData.moodToday;
    final partner = state.partnerMood ?? MockData.partnerMood;
    final history = state.history.isEmpty ? MockData.moodHistory : state.history;

    if (!_seeded) {
      _value = today.moodValue.toDouble();
      _noteController.text = today.note ?? '';
      _seeded = true;
    }

    final currentColor = MoodRecord.getColor(_value.toInt());

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            const AppGradientHeader(
              title: '心情温度计',
              subtitle: '颜色映射已经按 API 文档附录 C 的五段区间落成。',
              icon: '🌡',
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionTitle(title: '今天的心情'),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppTheme.stroke),
                            ),
                            child: Center(
                              child: _Thermometer(value: _value, color: currentColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            Text(
                              '${_value.toInt()}',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: currentColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _labelFor(_value.toInt()),
                              style: const TextStyle(color: AppTheme.textGray),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Slider(
                      min: 0,
                      max: 100,
                      value: _value,
                      activeColor: currentColor,
                      inactiveColor: AppTheme.lightPink,
                      onChanged: (value) => setState(() => _value = value),
                    ),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: '备注',
                        hintText: '今天发生了什么，想让对方知道吗？',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await ref.read(moodProvider.notifier).set(
                                _value.toInt(),
                                note: _noteController.text.trim(),
                              );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('心情已更新')),
                            );
                          }
                        },
                        child: const Text('保存心情'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                color: AppTheme.sky,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionTitle(title: '情侣对比'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _CompareBar(label: '我', value: _value.toInt())),
                        const SizedBox(width: 12),
                        Expanded(child: _CompareBar(label: 'TA', value: partner.moodValue)),
                      ],
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
                    const AppSectionTitle(title: '本月记录'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: history
                          .map(
                            (record) => Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: MoodRecord.getColor(record.moodValue),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                record.date.substring(record.date.length - 2),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelFor(int value) {
    if (value <= 20) return '非常低落';
    if (value <= 40) return '有点低落';
    if (value <= 60) return '平静一般';
    if (value <= 80) return '心情不错';
    return '非常开心';
  }
}

class _Thermometer extends StatelessWidget {
  const _Thermometer({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 132,
          decoration: BoxDecoration(
            color: AppTheme.lightPink,
            borderRadius: BorderRadius.circular(99),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 26,
            height: value * 1.32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('100'),
            Text('80'),
            Text('60'),
            Text('40'),
            Text('20'),
            Text('0'),
          ],
        ),
      ],
    );
  }
}

class _CompareBar extends StatelessWidget {
  const _CompareBar({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Container(
          height: 96,
          width: 54,
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 54,
            height: value * 0.96,
            decoration: BoxDecoration(
              color: MoodRecord.getColor(value),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text('$value'),
      ],
    );
  }
}
