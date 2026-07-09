import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';

class RoomCodeScreen extends StatefulWidget {
  const RoomCodeScreen({super.key});
  @override
  State<RoomCodeScreen> createState() => _RoomCodeScreenState();
}

class _RoomCodeScreenState extends State<RoomCodeScreen> {
  final _codeCtrl = TextEditingController();
  String? _myRoomCode;
  int? _memberCount;
  bool _loading = false;
  bool _initializing = true;

  @override
  void initState() { super.initState(); _loadMyRoom(); }
  @override
  void dispose() { _codeCtrl.dispose(); super.dispose(); }

  Future<void> _loadMyRoom() async {
    try {
      final res = await apiService.get(ApiConstants.myRoom);
      final data = apiService.unwrap(res.data);
      if (data is Map && data['room'] != null) {
        setState(() {
          _myRoomCode = data['room']['code'] as String?;
          _memberCount = data['memberCount'] as int?;
          _initializing = false;
        });
        return;
      }
    } catch (_) {}
    setState(() => _initializing = false);
  }

  Future<void> _join() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.length != 6) { _show('房间码为 6 位'); return; }
    setState(() => _loading = true);
    try {
      final res = await apiService.post(ApiConstants.joinRoom, data: {'roomCode': code});
      final data = apiService.unwrap(res.data) as Map<String, dynamic>;
      setState(() {
        _myRoomCode = data['room']['code'] as String?;
        _memberCount = data['memberCount'] as int?;
        _loading = false;
      });
      _show('加入成功！');
    } catch (_) {
      _show('加入失败，请检查房间码');
      setState(() => _loading = false);
    }
  }

  Future<void> _leave() async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('退出房间'),
      content: const Text('退出后将创建新房间，不再与对方共享数据。确认退出？'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确认退出')),
      ],
    ));
    if (confirm != true) return;
    setState(() => _loading = true);
    try {
      final res = await apiService.post(ApiConstants.leaveRoom);
      final data = apiService.unwrap(res.data) as Map<String, dynamic>;
      setState(() {
        _myRoomCode = data['roomCode'] as String?;
        _memberCount = 1;
        _loading = false;
      });
      _show('已退出，新房间码已生成');
    } catch (_) {
      _show('退出失败');
      setState(() => _loading = false);
    }
  }

  void _show(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgColor,
    body: SafeArea(child: _initializing
      ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPink))
      : ListView(padding: const EdgeInsets.only(bottom: 28), children: [
        const AppGradientHeader(title: '房间码', subtitle: '输入相同房间码共享数据', icon: '🏠'),
        const SizedBox(height: 18),

        if (_myRoomCode != null) ...[
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: AppCard(color: AppTheme.peach, child: Column(children: [
            const Text('你的房间码', style: TextStyle(color: AppTheme.textGray)), const SizedBox(height: 8),
            Text(_myRoomCode!, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: 6)),
            if (_memberCount != null) Text('${_memberCount} 人在房间', style: const TextStyle(color: AppTheme.textGray)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () { Clipboard.setData(ClipboardData(text: _myRoomCode!)); _show('已复制'); },
                icon: const Icon(Icons.copy), label: const Text('复制'),
              )),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _leave,
                icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                label: const Text('退出', style: TextStyle(color: Colors.redAccent)),
              ),
            ]),
          ]))),
          const SizedBox(height: 16),
        ],

        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('📥 加入 TA 的房间', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 14),
          TextField(controller: _codeCtrl, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(hintText: '6 位房间码', prefixIcon: Icon(Icons.home_outlined))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _loading ? null : _join,
            child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('加入房间'),
          )),
        ]))),
      ]),
    ),
  );
}
