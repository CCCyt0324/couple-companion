import 'package:flutter/material.dart';
import '../../services/api/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';
import '../../models/wish.dart' as m;

class WishScreen extends StatefulWidget {
  const WishScreen({super.key});
  @override
  State<WishScreen> createState() => _WishScreenState();
}

class _WishScreenState extends State<WishScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<m.WishNote> _whispers = [], _wishes = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 2, vsync: this); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final [wRes, sRes] = await Future.wait([
        apiService.get(ApiConstants.wishes, params: {'type': 'whisper'}),
        apiService.get(ApiConstants.wishes, params: {'type': 'wish'}),
      ]);
      if (mounted) setState(() {
        _whispers = ((apiService.unwrap(wRes.data) as List?) ?? []).map((j) => m.WishNote.fromJson(j)).toList();
        _wishes = ((apiService.unwrap(sRes.data) as List?) ?? []).map((j) => m.WishNote.fromJson(j)).toList();
        _loading = false;
      });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _send(String type) async {
    final ctrl = TextEditingController();
    final content = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: Text(type == 'whisper' ? '💌 发送悄悄话' : '💝 添加心愿'),
      content: TextField(controller: ctrl, maxLines: 3, decoration: InputDecoration(hintText: type == 'whisper' ? '写一句悄悄话...' : '写下你的小心愿...')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')), ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('发送'))],
    ));
    if (content != null && content.isNotEmpty) { await apiService.post(ApiConstants.wishes, data: {'content': content, 'type': type}); _load(); }
  }

  Future<void> _read(int id) async { await apiService.put('${ApiConstants.wishes}/$id/read'); _load(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgColor,
    appBar: AppBar(title: const Text('✉️ 心愿小纸条'), bottom: TabBar(controller: _tabCtrl, indicatorColor: AppTheme.primaryPink, labelColor: AppTheme.primaryPink, tabs: const [Tab(text: '💌 悄悄话'), Tab(text: '💝 心愿清单')])),
    floatingActionButton: FloatingActionButton(backgroundColor: AppTheme.primaryPink, onPressed: () => _send(_tabCtrl.index == 0 ? 'whisper' : 'wish'), child: const Icon(Icons.add, color: Colors.white)),
    body: _loading ? const Center(child: CircularProgressIndicator()) : TabBarView(controller: _tabCtrl, children: [_buildList(_whispers), _buildList(_wishes)]),
  );

  Widget _buildList(List<m.WishNote> notes) {
    if (notes.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('💝', style: TextStyle(fontSize: 48)), const SizedBox(height: 12), const Text('还没有内容，点击右下角添加', style: TextStyle(color: AppTheme.textGray))]));
    return ListView.builder(padding: const EdgeInsets.all(16), itemCount: notes.length, itemBuilder: (_, i) {
      final n = notes[i];
      return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: n.isRead ? Colors.white : const Color(0xFFFFF0F5), borderRadius: BorderRadius.circular(16), border: n.isRead ? null : Border.all(color: AppTheme.lightPink)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(n.isWhisper ? '💌' : '💝', style: const TextStyle(fontSize: 22)), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n.content, style: TextStyle(color: n.isRead ? AppTheme.textGray : AppTheme.textDark)), const SizedBox(height: 4), Text(n.createdAt.toString().substring(0, 16), style: const TextStyle(fontSize: 11, color: AppTheme.textGray))])),
        if (!n.isRead) GestureDetector(onTap: () => _read(n.id), child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppTheme.primaryPink, borderRadius: BorderRadius.circular(10)), child: const Text('已读', style: TextStyle(color: Colors.white, fontSize: 11)))),
      ]));
    });
  }
}
