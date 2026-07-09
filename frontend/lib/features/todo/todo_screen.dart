import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';
import '../../core/constants/api_constants.dart';
import '../../core/mock/mock_data.dart';
import '../../services/api/api_service.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});
  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  late List<Map<String, dynamic>> _todos;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await apiService.get(ApiConstants.todos);
      final data = (apiService.unwrap(res.data) as List?) ?? [];
      setState(() { _todos = data.map((j) => Map<String, dynamic>.from(j)).toList(); _loading = false; });
    } catch (_) {
      setState(() { _todos = MockData.todos.map((item) => Map<String, dynamic>.from(item)).toList(); _loading = false; });
    }
  }

  Future<void> _toggle(int id, int i) async {
    await apiService.put('${ApiConstants.todos}/$id/toggle');
    setState(() => _todos[i]['status'] = _todos[i]['status'] == 'done' ? 'pending' : 'done');
  }

  Future<void> _delete(int id) async {
    await apiService.delete('${ApiConstants.todos}/$id');
    setState(() => _todos.removeWhere((e) => e['id'] == id));
  }

  Future<void> _add() async {
    final ctrl = TextEditingController();
    final content = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('新增待办'), content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: '输入待办内容')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')), ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('添加'))],
    ));
    if (content != null && content.isNotEmpty) {
      final res = await apiService.post(ApiConstants.todos, data: {'content': content});
      final item = apiService.unwrap(res.data) as Map<String, dynamic>;
      setState(() => _todos.insert(0, Map<String, dynamic>.from(item)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgColor,
    floatingActionButton: FloatingActionButton(onPressed: _add, backgroundColor: AppTheme.primaryPink, child: const Icon(Icons.add, color: Colors.white)),
    body: SafeArea(child: _loading ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPink)) : ListView(padding: const EdgeInsets.only(bottom: 96), children: [
      const AppGradientHeader(title: '待办清单', subtitle: '共享待办，共同完成', icon: '🗂'),
      const SizedBox(height: 18),
      if (_todos.isEmpty) const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('还没有待办事项，点击右下角添加')))
      else ..._todos.asMap().entries.map((entry) {
        final i = entry.key; final t = entry.value; final done = t['status'] == 'done';
        return Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), child: AppCard(child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: IconButton(onPressed: () => _toggle(t['id'], i), icon: Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: done ? AppTheme.primaryPink : AppTheme.textGray)),
          title: Text(t['content'] ?? '', style: TextStyle(decoration: done ? TextDecoration.lineThrough : null)),
          trailing: IconButton(onPressed: () => _delete(t['id']), icon: const Icon(Icons.delete_outline_rounded)),
        )));
      }),
    ])),
  );
}
