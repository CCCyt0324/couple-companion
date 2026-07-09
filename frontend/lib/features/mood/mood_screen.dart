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
  final _noteCtrl = TextEditingController();
  double _value = 75;
  bool _seeded = false;

  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(moodProvider);
    final today = state.today ?? MockData.moodToday;
    final partner = state.partnerMood ?? MockData.partnerMood;
    final history = state.history.isEmpty ? MockData.moodHistory : state.history;

    if (!_seeded) { _value = today.moodValue.toDouble(); _noteCtrl.text = today.note ?? ''; _seeded = true; }
    final color = MoodRecord.getColor(_value.toInt());

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(child: ListView(padding: const EdgeInsets.only(bottom: 96), children: [
        const AppGradientHeader(title: '心情温度计', subtitle: '记录心情，同步给对方', icon: '🌡'),
        const SizedBox(height: 18),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const AppSectionTitle(title: '今天的心情'), const SizedBox(height: 18),
          Row(children: [
            Expanded(child: Container(height: 180, decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.stroke)), child: Center(child: _Thermometer(value: _value, color: color)))),
            const SizedBox(width: 16),
            Column(children: [
              Text('${_value.toInt()}', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(height: 8),
              Text(_labelFor(_value.toInt()), style: const TextStyle(color: AppTheme.textGray)),
            ]),
          ]),
          const SizedBox(height: 18),
          Slider(min: 0, max: 100, value: _value, activeColor: color, inactiveColor: AppTheme.lightPink, onChanged: (v) => setState(() => _value = v)),
          TextField(controller: _noteCtrl, maxLines: 3, decoration: const InputDecoration(labelText: '备注', hintText: '今天发生了什么')),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () async {
              await ref.read(moodProvider.notifier).set(_value.toInt(), note: _noteCtrl.text.trim());
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('心情已更新')));
            },
            child: const Text('保存心情'),
          )),
        ]))),
        const SizedBox(height: 16),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: AppCard(color: AppTheme.sky, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const AppSectionTitle(title: '情侣对比'), const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _CompareBar(label: '我', value: _value.toInt())), const SizedBox(width: 12),
            Expanded(child: _CompareBar(label: 'TA', value: partner.moodValue)),
          ]),
        ]))),
        const SizedBox(height: 16),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const AppSectionTitle(title: '本月记录'), const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: history.map((r) => Container(width: 46, height: 46, decoration: BoxDecoration(color: MoodRecord.getColor(r.moodValue), borderRadius: BorderRadius.circular(16)), alignment: Alignment.center, child: Text(r.date.substring(r.date.length - 2), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))).toList()),
        ]))),
      ])),
    );
  }

  String _labelFor(int v) { if (v <= 20) return '非常低落'; if (v <= 40) return '有点低落'; if (v <= 60) return '平静一般'; if (v <= 80) return '心情不错'; return '非常开心'; }
}

class _Thermometer extends StatelessWidget {
  final double value; final Color color;
  const _Thermometer({required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    SizedBox(width: 40, child: Stack(alignment: Alignment.bottomCenter, children: [
      Container(width: 16, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8))),
      AnimatedContainer(duration: const Duration(milliseconds: 300), width: 16, height: 140 * value / 100, decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withAlpha(150), color], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(8))),
    ])),
    const SizedBox(width: 10),
    Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [for (int i = 100; i >= 0; i -= 20) Text('$i', style: const TextStyle(fontSize: 9, color: AppTheme.textGray))]),
    const SizedBox(width: 8),
    Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
  ]);
}

class _CompareBar extends StatelessWidget {
  final String label; final int value;
  const _CompareBar({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 6),
    Container(height: 80, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), alignment: Alignment.bottomCenter,
      child: AnimatedContainer(duration: const Duration(milliseconds: 500), height: 80 * value / 100, decoration: BoxDecoration(color: MoodRecord.getColor(value).withAlpha(100), borderRadius: BorderRadius.circular(8))),
    ), const SizedBox(height: 6), Text('$value', style: TextStyle(fontWeight: FontWeight.bold, color: MoodRecord.getColor(value))),
  ]);
}
