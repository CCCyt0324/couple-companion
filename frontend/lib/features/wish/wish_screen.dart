import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';
import '../../models/wish.dart';

class WishScreen extends StatefulWidget {
  const WishScreen({super.key});

  @override
  State<WishScreen> createState() => _WishScreenState();
}

class _WishScreenState extends State<WishScreen> with TickerProviderStateMixin {
  late final TabController _controller;
  late List<WishNote> _whispers;
  late List<WishNote> _wishes;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
    _whispers = [...MockData.whispers];
    _wishes = [...MockData.wishes];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _addWish,
        backgroundColor: AppTheme.primaryPink,
        child: const Icon(Icons.edit_outlined, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const AppGradientHeader(
              title: '心愿小纸条',
              subtitle: 'whisper / wish 双列表已经分开，便于继续接已读和删除动作。',
              icon: '📝',
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _controller,
              labelColor: AppTheme.primaryPink,
              indicatorColor: AppTheme.primaryPink,
              tabs: const [
                Tab(text: '悄悄话'),
                Tab(text: '心愿'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _controller,
                children: [
                  _WishList(
                    items: _whispers,
                    onDelete: (note) =>
                        setState(() => _whispers.removeWhere((e) => e.id == note.id)),
                  ),
                  _WishList(
                    items: _wishes,
                    onDelete: (note) =>
                        setState(() => _wishes.removeWhere((e) => e.id == note.id)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addWish() async {
    final controller = TextEditingController();
    final isWhisper = _controller.index == 0;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isWhisper ? '写一张悄悄话' : '写一个心愿'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: '输入内容'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final note = WishNote(
                id: DateTime.now().millisecondsSinceEpoch,
                coupleId: 1,
                fromUserId: 1,
                content: controller.text.trim(),
                type: isWhisper ? 'whisper' : 'wish',
                isRead: false,
                status: 'active',
                createdAt: DateTime.now(),
              );
              setState(() {
                if (isWhisper) {
                  _whispers.insert(0, note);
                } else {
                  _wishes.insert(0, note);
                }
              });
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

class _WishList extends StatelessWidget {
  const _WishList({
    required this.items,
    required this.onDelete,
  });

  final List<WishNote> items;
  final ValueChanged<WishNote> onDelete;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyState(
        icon: '📮',
        title: '还没有内容',
        message: '写下第一张纸条，让对方在普通日子里也能收到惊喜。',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final note = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            color: note.isRead ? AppTheme.white : AppTheme.peach,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(note.isWhisper ? '🤫' : '✨'),
              title: Text(note.content),
              subtitle: Text(note.createdAt.toString().substring(0, 16)),
              trailing: IconButton(
                onPressed: () => onDelete(note),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ),
          ),
        );
      },
    );
  }
}
