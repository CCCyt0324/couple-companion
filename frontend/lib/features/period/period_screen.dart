import 'package:flutter/material.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';
import '../../services/api/api_service.dart';

class PeriodScreen extends StatefulWidget {
  const PeriodScreen({super.key});
  @override
  State<PeriodScreen> createState() => _PeriodScreenState();
}

class _PeriodScreenState extends State<PeriodScreen> {
  DateTime _selectedDate = _dateOnly(DateTime.now());
  String _flowLevel = '中';
  final Set<String> _symptoms = <String>{};
  final Set<String> _emotions = <String>{};
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _cycleController = TextEditingController(text: '28');
  final TextEditingController _periodController = TextEditingController(text: '7');
  bool _loading = false;
  String? _predictedDate;
  String? _countdown;
  String? _confidence;

  static const List<String> _flowOptions = ['无', '少', '中', '多'];
  static const List<String> _symptomOptions = ['腹痛', '腰酸', '乏力', '头晕', '乳房胀痛', '长痘', '水肿', '头痛'];
  static const List<String> _emotionOptions = ['烦躁', '低落', '焦虑', '敏感', '平静', '开心'];

  @override
  void initState() { super.initState(); _loadData(); }

  @override
  void dispose() {
    _noteController.dispose(); _cycleController.dispose(); _periodController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await _loadTodayRecord();
      final settingRes = await apiService.get(ApiConstants.periodSetting);
      final setting = apiService.unwrap(settingRes.data) as Map<String, dynamic>?;
      if (setting != null && mounted) {
        setState(() {
          _cycleController.text = (setting['cycleDays'] ?? 28).toString();
          _periodController.text = (setting['periodDays'] ?? 7).toString();
        });
      }
      await _loadPrediction();
    } catch (_) {}
  }

  Future<bool> _loadTodayRecord() async {
    final todayRes = await apiService.get(ApiConstants.periodToday);
    final todayData = apiService.unwrap(todayRes.data) as Map<String, dynamic>?;
    if (todayData == null || !mounted) return false;
    setState(() {
      _selectedDate = todayData['date'] != null ? _dateOnly(DateTime.parse(todayData['date'].toString())) : _dateOnly(DateTime.now());
      _applyRecord(todayData);
    });
    return true;
  }

  Future<void> _loadPrediction() async {
    try {
      final [predictRes, countdownRes] = await Future.wait([apiService.get(ApiConstants.periodPredict), apiService.get(ApiConstants.periodCountdown)]);
      final pred = apiService.unwrap(predictRes.data) as Map<String, dynamic>?;
      final cd = apiService.unwrap(countdownRes.data);
      if (!mounted) return;
      setState(() {
        if (pred != null) {
          final p = pred['predictedDate']?.toString();
          _predictedDate = p != null && p.length >= 10 ? p.substring(5, 10) : p;
          _confidence = '${((pred['confidence'] as num? ?? 0) * 100).toInt()}%';
        }
        _countdown = cd is String ? cd : cd?.toString();
      });
    } catch (_) {}
  }

  void _applyRecord(Map<String, dynamic> r) {
    _flowLevel = r['flowLevel'] as String? ?? '中';
    _symptoms..clear()..addAll(r['symptoms'] is List ? List<String>.from(r['symptoms']) : const []);
    _emotions..clear()..addAll(r['emotions'] is List ? List<String>.from(r['emotions']) : const []);
    _noteController.text = r['note'] as String? ?? '';
  }

  void _resetDraft() => setState(() { _flowLevel = '中'; _symptoms.clear(); _emotions.clear(); _noteController.clear(); });

  Future<void> _changeSelectedDate(DateTime date) async {
    final d = _dateOnly(date);
    setState(() => _selectedDate = d);
    if (_isSameDay(d, DateTime.now())) {
      try { final ok = await _loadTodayRecord(); if (!ok) _resetDraft(); } catch (_) { _resetDraft(); }
    } else {
      _resetDraft();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now(),
      helpText: '选择记录日期', cancelText: '取消', confirmText: '确定',
    );
    if (picked != null) await _changeSelectedDate(picked);
  }

  Future<void> _saveRecord() async {
    setState(() => _loading = true);
    try {
      await apiService.post(ApiConstants.periodRecord, data: {
        'date': _formatDate(_selectedDate), 'flowLevel': _flowLevel,
        'symptoms': _symptoms.toList(), 'emotions': _emotions.toList(),
        'note': _noteController.text.trim(),
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已保存 ${_formatDate(_selectedDate)} 的记录')));
      await _loadPrediction();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存失败')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveSetting() async {
    setState(() => _loading = true);
    try {
      await apiService.put(ApiConstants.periodSetting, data: {
        'cycleDays': int.tryParse(_cycleController.text) ?? 28,
        'periodDays': int.tryParse(_periodController.text) ?? 7,
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('设置已更新')));
      await _loadPrediction();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存失败')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _isSameDay(_selectedDate, DateTime.now());

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.only(bottom: 56), children: [
          const AppGradientHeader(title: '经期管理', subtitle: '记录每日数据，补录历史，持续跟踪预测', icon: '🩷'),
          const SizedBox(height: 18),

          // 日期选择
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const AppSectionTitle(title: '记录日期'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.peach, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.stroke)),
                child: Row(children: [
                  Container(
                    width: 46, height: 46,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryPink),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                      Text(_formatDate(_selectedDate), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      if (isToday) const AppInfoChip(label: '今天', icon: '📅', background: AppTheme.lightPink, foreground: AppTheme.primaryPink),
                    ]),
                    const SizedBox(height: 4),
                    Text(isToday ? '正在记录今天的数据' : '补录模式 - 当前选择的日期', style: const TextStyle(fontSize: 12, color: AppTheme.textGray)),
                  ])),
                  OutlinedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.edit_calendar_rounded), label: const Text('选择')),
                ]),
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                OutlinedButton(onPressed: () => _changeSelectedDate(DateTime.now()), child: const Text('今天')),
                OutlinedButton(onPressed: () => _changeSelectedDate(DateTime.now().subtract(const Duration(days: 1))), child: const Text('昨天')),
                TextButton.icon(onPressed: _pickDate, icon: const Icon(Icons.calendar_today_rounded), label: const Text('打开日历')),
              ]),
            ])),
          ),
          const SizedBox(height: 14),

          // 记录表单
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AppSectionTitle(title: isToday ? '今日记录' : '补录记录'),
              const SizedBox(height: 6),
              Text('日期: ${_formatDate(_selectedDate)}', style: const TextStyle(color: AppTheme.textGray)),
              const SizedBox(height: 16),
              const AppSectionTitle(title: '经量'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: _flowOptions.map((item) => ChoiceChip(
                label: Text(item), selected: _flowLevel == item,
                onSelected: (_) => setState(() => _flowLevel = item),
              )).toList()),
              const SizedBox(height: 16),
              const AppSectionTitle(title: '症状'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: _symptomOptions.map((item) => FilterChip(
                label: Text(item), selected: _symptoms.contains(item),
                onSelected: (s) => setState(() => s ? _symptoms.add(item) : _symptoms.remove(item)),
              )).toList()),
              const SizedBox(height: 16),
              const AppSectionTitle(title: '情绪'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: _emotionOptions.map((item) => FilterChip(
                label: Text(item), selected: _emotions.contains(item),
                onSelected: (s) => setState(() => s ? _emotions.add(item) : _emotions.remove(item)),
              )).toList()),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController, maxLines: 3,
                decoration: const InputDecoration(hintText: '备注（可选）', helperText: '切换上方日期可补录历史经期记录'),
              ),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: _loading ? null : _saveRecord,
                child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('保存记录'),
              )),
            ])),
          ),
          const SizedBox(height: 16),

          // 预测 + 倒计时
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: AppCard(color: AppTheme.peach, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('预测日期', style: TextStyle(fontSize: 13, color: AppTheme.textGray)),
                const SizedBox(height: 6),
                Text(_predictedDate ?? '--', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                if (_confidence != null) Text('置信度 $_confidence', style: const TextStyle(fontSize: 11, color: AppTheme.textGray)),
              ]))),
              const SizedBox(width: 12),
              Expanded(child: AppCard(color: AppTheme.lightPink, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('倒计时', style: TextStyle(fontSize: 13, color: AppTheme.textGray)),
                const SizedBox(height: 6),
                Text(_countdown ?? '--', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('提前做好准备', style: TextStyle(fontSize: 11, color: AppTheme.textGray)),
              ]))),
            ]),
          ),
          const SizedBox(height: 16),

          // 周期设置
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const AppSectionTitle(title: '周期设置'),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: TextField(controller: _cycleController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '平均周期天数'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _periodController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '经期天数'))),
              ]),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: OutlinedButton(
                onPressed: _loading ? null : _saveSetting,
                child: const Text('保存设置'),
              )),
            ])),
          ),
          const SizedBox(height: 16),

          // 护理指南
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppCard(color: AppTheme.mint, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              AppSectionTitle(title: '护理指南'),
              SizedBox(height: 10),
              Text('1. 保暖、补水、避免空腹喝咖啡。'),
              SizedBox(height: 6),
              Text('2. 轻度拉伸或散步，比完全不动更舒服。'),
              SizedBox(height: 6),
              Text('3. 如果连续多次明显不适，建议及时就医。'),
            ])),
          ),
        ]),
      ),
    );
  }
}

DateTime _dateOnly(DateTime v) => DateTime(v.year, v.month, v.day);
bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
String _formatDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
