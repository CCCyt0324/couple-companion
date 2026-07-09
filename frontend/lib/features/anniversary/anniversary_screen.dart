import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';
import '../../models/wish.dart';

class AnniversaryScreen extends StatefulWidget {
  const AnniversaryScreen({super.key});

  @override
  State<AnniversaryScreen> createState() => _AnniversaryScreenState();
}

class _AnniversaryScreenState extends State<AnniversaryScreen> {
  late List<Anniversary> _items;

  @override
  void initState() {
    super.initState();
    _items = [...MockData.anniversaries];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        backgroundColor: AppTheme.primaryPink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            const AppGradientHeader(
              title: '纪念日',
              subtitle: '支持 recurring / once、即将到来和在一起天数展示。',
              icon: '🎉',
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                color: AppTheme.peach,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('在一起'),
                    SizedBox(height: 8),
                    Text(
                      '51 天',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppSectionTitle(title: '即将到来'),
            ),
            const SizedBox(height: 8),
            ...MockData.upcomingAnniversaries.map(
              (item) {
                final ann = item['ann'] as Anniversary;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: AppCard(
                    color: AppTheme.sky,
                    child: Row(
                      children: [
                        const Text('⏰', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ann.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(ann.date),
                            ],
                          ),
                        ),
                        AppInfoChip(
                          label: '还有 ${item['daysLeft']} 天',
                          background: Colors.white,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppSectionTitle(title: '全部纪念日'),
            ),
            const SizedBox(height: 8),
            ..._items.map(
              (item) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Text('💌', style: TextStyle(fontSize: 24)),
                    title: Text(item.title),
                    subtitle: Text(item.date),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item.isRecurring ? '每年' : '一次'),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _items.remove(item);
                            });
                          },
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
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

  Future<void> _addItem() async {
    final titleController = TextEditingController();
    final dateController = TextEditingController();
    bool recurring = true;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('新增纪念日'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: '名称'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(hintText: 'YYYY-MM-DD'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: recurring,
                onChanged: (value) => setState(() => recurring = value),
                title: const Text('每年重复'),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                this.setState(() {
                  _items.insert(
                    0,
                    Anniversary(
                      id: _items.length + 10,
                      title: titleController.text.trim(),
                      date: dateController.text.trim(),
                      type: recurring ? 'recurring' : 'once',
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }
}
