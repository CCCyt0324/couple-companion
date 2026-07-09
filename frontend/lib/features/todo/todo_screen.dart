import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  late List<Map<String, dynamic>> _todos;

  @override
  void initState() {
    super.initState();
    _todos = MockData.todos.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        backgroundColor: AppTheme.primaryPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            const AppGradientHeader(
              title: '待办清单',
              subtitle: '对应 /todo 的创建、切换和删除动作，先把交互壳子补齐。',
              icon: '🗂',
            ),
            const SizedBox(height: 18),
            if (_todos.isEmpty)
              const EmptyState(
                icon: '🫧',
                title: '今天没有待办',
                message: '现在很适合去多陪陪对方。',
              )
            else
              ..._todos.map(
                (todo) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: IconButton(
                        onPressed: () {
                          setState(() {
                            todo['completed'] = !(todo['completed'] as bool);
                          });
                        },
                        icon: Icon(
                          (todo['completed'] as bool)
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: (todo['completed'] as bool)
                              ? AppTheme.primaryPink
                              : AppTheme.textGray,
                        ),
                      ),
                      title: Text(
                        todo['content'] as String,
                        style: TextStyle(
                          decoration: (todo['completed'] as bool)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            _todos.removeWhere(
                              (element) => element['id'] == todo['id'],
                            );
                          });
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addTodo() async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增待办'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '输入待办内容'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _todos.insert(0, {
                  'id': _todos.length + 10,
                  'content': controller.text.trim(),
                  'completed': false,
                });
              });
              Navigator.pop(context);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}
