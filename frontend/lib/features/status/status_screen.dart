import 'package:flutter/material.dart';
import '../../services/api/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';
import '../../models/wish.dart' as m;

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});
  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  m.UserStatus? _myStatus;
  m.UserStatus? _partnerStatus;
  List<dynamic> _notifications = [];
  String? _showPartnerStatusId;
  bool _loading = true;

  static const _presets = {
    'mood': ['😊 开心', '😢 难过', '😫 疲惫', '😠 生气', '🥰 想你'],
    'activity': ['💼 工作中', '📚 学习中', '🍽️ 吃饭中', '🏃 运动中', '😴 睡觉中'],
    'weather': ['🌧️ 下雨', '☀️ 晴天', '❄️ 下雪'],
    'special': ['😔 emo中', '🤫 想静静', '🤗 求抱抱', '📞 等你找我'],
  };

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final [mine, partner, interactions] = await Future.wait([
        apiService.get(ApiConstants.statusMine),
        apiService.get(ApiConstants.statusPartner),
        apiService.get(ApiConstants.statusInteractions),
      ]);
      final myData = apiService.unwrap(mine.data);
      final ptData = apiService.unwrap(partner.data);
      final notiData = (apiService.unwrap(interactions.data) as List?) ?? [];

      if (mounted) setState(() {
        _myStatus = myData is Map ? m.UserStatus.fromJson(Map<String, dynamic>.from(myData)) : null;
        _partnerStatus = ptData is Map ? m.UserStatus.fromJson(Map<String, dynamic>.from(ptData)) : null;
        _notifications = notiData;
        _loading = false;
      });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _setStatus(String type, String content, String emoji, String bgColor) async {
    await apiService.post(ApiConstants.status, data: {'type': type, 'content': content, 'emoji': emoji, 'bgColor': bgColor});
    _load();
  }

  Future<void> _interact(int statusId, String type) async {
    await apiService.post('${ApiConstants.status}/$statusId/interact', data: {'type': type});
    _show('互动已发送');
    _load();
  }

  Future<void> _customStatus() async {
    final ctrl = TextEditingController();
    final text = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('自定义状态'), content: TextField(controller: ctrl, maxLength: 8, decoration: const InputDecoration(hintText: '不超过8个字')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')), ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('设置'))],
    ));
    if (text != null && text.isNotEmpty) await _setStatus('custom', text, '✨', '#FFE6F0');
  }

  void _show(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgColor,
    appBar: AppBar(title: const Text('💬 情侣状态'), actions: [IconButton(onPressed: _customStatus, icon: const Icon(Icons.edit, color: AppTheme.primaryPink))]),
    body: _loading ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPink)) : ListView(padding: const EdgeInsets.all(16), children: [
      // TA 的状态
      if (_partnerStatus != null)
        _statusCard(_partnerStatus!, isMe: false),
      if (_partnerStatus != null) const SizedBox(height: 12),

      // 我的状态
      if (_myStatus != null)
        _statusCard(_myStatus!, isMe: true),
      const SizedBox(height: 12),

      // 互动通知
      if (_notifications.isNotEmpty) ...[
        const Text('🔔 互动通知', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.primaryPink)),
        const SizedBox(height: 8),
        ..._notifications.map((raw) {
          final n = Map<String, dynamic>.from(raw as Map);
          final inter = Map<String, dynamic>.from(n['interaction'] as Map? ?? {});
          final fromStatus = Map<String, dynamic>.from(n['status'] as Map? ?? {});
          return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Text(fromStatus['emoji']?.toString() ?? '💬', style: const TextStyle(fontSize: 22)), const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_actionLabel(inter['type']?.toString()), style: const TextStyle(fontWeight: FontWeight.w600)),
                if (inter['content'] != null) Text(inter['content'].toString(), style: const TextStyle(color: AppTheme.textGray, fontSize: 13)),
              ])),
            ]));
        }),
        const SizedBox(height: 16),
      ],

      // 如果对方有状态——互动按钮
      if (_partnerStatus != null) ...[
        const Text('🎯 给TA的互动', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.primaryPink)),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _interactBtn('👉 戳一戳', 'poke', _partnerStatus!.id),
          _interactBtn('🤗 抱抱', 'hug', _partnerStatus!.id),
          _interactBtn('💬 留言', 'comment', _partnerStatus!.id),
          _interactBtn('🔄 同款', 'copy', _partnerStatus!.id),
        ]),
        const SizedBox(height: 20),
      ],

      // 预设状态选择
      ..._presets.entries.map((cat) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_catLabel(cat.key), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.primaryPink)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: cat.value.map((s) {
          final parts = s.split(' ');
          return GestureDetector(
            onTap: () => _setStatus(cat.key, parts[1], parts[0], '#FFE6F0'),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.lightPink)), child: Text(s, style: const TextStyle(fontSize: 14))),
          );
        }).toList()),
        const SizedBox(height: 16),
      ])),
    ]),
  );

  Widget _statusCard(m.UserStatus s, {required bool isMe}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: _parseColor(s.bgColor) ?? (isMe ? Colors.white : AppTheme.lightPink), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.stroke)),
    child: Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(isMe ? '我的状态' : 'TA 的状态', style: const TextStyle(fontSize: 12, color: AppTheme.textGray)),
        const SizedBox(height: 4),
        Text(s.content, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ]),
      const Spacer(),
      Text(s.emoji ?? '', style: const TextStyle(fontSize: 30)),
    ]),
  );

  Widget _interactBtn(String label, String type, int statusId) => GestureDetector(
    onTap: () => _interact(statusId, type),
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)), child: Text(label.split(' ')[1], style: const TextStyle(fontSize: 14))),
  );

  String _catLabel(String key) {
    switch (key) { case 'mood': return '💭 心情类'; case 'activity': return '🏃 活动类'; case 'weather': return '🌤️ 天气类'; case 'special': return '✨ 特殊类'; default: return key; }
  }

  String _actionLabel(String? type) {
    switch (type) { case 'poke': return '👉 戳了戳你'; case 'hug': return '🤗 给了你一个拥抱'; case 'comment': return '💬 留言了'; case 'copy': return '🔄 设置了同款状态'; default: return '互动了你'; }
  }

  Color? _parseColor(String? hex) {
    if (hex == null) return null;
    try { return Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16)); } catch (_) { return null; }
  }
}
