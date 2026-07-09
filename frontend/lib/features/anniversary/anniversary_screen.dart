import 'package:flutter/material.dart';
import '../../services/api/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';
import '../../models/wish.dart' as m;

class AnniversaryScreen extends StatefulWidget {
  const AnniversaryScreen({super.key});
  @override
  State<AnniversaryScreen> createState() => _AnniversaryScreenState();
}

class _AnniversaryScreenState extends State<AnniversaryScreen> {
  List<m.Anniversary> _anniversaries = [];
  List<dynamic> _upcoming = [];
  int _totalDays = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final [listRes, upcomingRes] = await Future.wait([
        apiService.get(ApiConstants.anniversaries),
        apiService.get(ApiConstants.anniversaryUpcoming),
      ]);
      final anns = (apiService.unwrap(listRes.data) as List?) ?? [];
      final coming = (apiService.unwrap(upcomingRes.data) as List?) ?? [];
      setState(() {
        _anniversaries = anns.map((j) => m.Anniversary.fromJson(j)).toList();
        _upcoming = coming;
        if (_anniversaries.isNotEmpty) {
          final first = _anniversaries.first;
          _totalDays = DateTime.now().difference(DateTime.parse(first.date)).inDays;
        }
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _add() async {
    final titleCtrl = TextEditingController(); final dateCtrl = TextEditingController(); bool recurring = true;
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDlg) => AlertDialog(
      title: const Text('添加纪念日'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: '名称')),
        TextField(controller: dateCtrl, decoration: const InputDecoration(hintText: '日期 YYYY-MM-DD')),
        Row(children: [const Text('每年重复'), Switch(value: recurring, onChanged: (v) => setDlg(() => recurring = v))]),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('添加'))],
    )));
    if (ok == true) {
      await apiService.post(ApiConstants.anniversaries, data: {'title': titleCtrl.text, 'date': dateCtrl.text, 'type': recurring ? 'recurring' : 'once', 'remindConfig': {'onDay': true, 'threeDaysBefore': true, 'sevenDaysBefore': false}});
      _load();
    }
  }

  Future<void> _delete(int id) async { await apiService.delete('${ApiConstants.anniversaries}/$id'); _load(); }

  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: AppTheme.bgColor, appBar: AppBar(title: const Text('📅 纪念日')), body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(16), children: [
    Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.lightPink, AppTheme.primaryPink]), borderRadius: BorderRadius.circular(20)), child: Column(children: [const Text('🎀', style: TextStyle(fontSize: 30)), const Text('在一起', style: TextStyle(color: Colors.white70, fontSize: 14)), Text('$_totalDays 天', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold))])),
    const SizedBox(height: 16),
    if (_upcoming.isNotEmpty) ...[
      const Text('📌 即将到来', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 8),
      ..._upcoming.take(3).map((u) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.lightPink)), child: Row(children: [
        const Text('💝', style: TextStyle(fontSize: 22)), const SizedBox(width: 12),
        Expanded(child: Text(u['ann']['title'], style: const TextStyle(fontWeight: FontWeight.w600))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: AppTheme.lightPink, borderRadius: BorderRadius.circular(12)), child: Text('还有 ${u['daysLeft']} 天', style: const TextStyle(color: AppTheme.primaryPink, fontSize: 13))),
      ]))),
      const SizedBox(height: 16),
    ],
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('📋 全部纪念日', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), IconButton(onPressed: _add, icon: const Icon(Icons.add_circle, color: AppTheme.primaryPink))]),
    ..._anniversaries.map((a) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(children: [
      const Text('💝', style: TextStyle(fontSize: 20)), const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600)), Text(a.date, style: const TextStyle(color: AppTheme.textGray, fontSize: 12))])),
      Text(a.isRecurring ? '每年' : '一次', style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 8),
      GestureDetector(onTap: () => _delete(a.id), child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20)),
    ]))),
  ]));
}
