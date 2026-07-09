import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_chrome.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const List<_MoreItem> _items = <_MoreItem>[
    _MoreItem('任务中心', '习惯 + 待办', '✓', '/habits'),
    _MoreItem('心情记录', '滑动记录和情绪对比', 'M', '/mood'),
    _MoreItem('纪念日', '倒计时与提醒', 'A', '/anniversary'),
    _MoreItem('情侣状态', '设置状态与互动', 'S', '/status'),
    _MoreItem('心愿纸条', '悄悄话与愿望', 'W', '/wish'),
    _MoreItem('共享相册', '相册与评论', 'P', '/album'),
    _MoreItem('情侣游戏', '创建房间与答题', 'G', '/games'),
    _MoreItem('两人地图', '位置共享', 'L', '/map'),
    _MoreItem('设置', '资料与偏好设置', 'C', '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: <Widget>[
            const AppGradientHeader(
              title: '更多功能',
              subtitle: '这里整理了全部扩展功能入口，当前版本已移除登录注册流程。',
              icon: 'M',
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                itemCount: _items.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final _MoreItem item = _items[index];
                  return AppCard(
                    color: index.isEven ? AppTheme.peach : AppTheme.sky,
                    onTap: () => context.push(item.route),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(item.icon, style: const TextStyle(fontSize: 30)),
                        const Spacer(),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(item.subtitle),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                color: AppTheme.mint,
                child: Text(
                  '当前为直达体验模式，打开应用即可使用，不再需要登录或注册。',
                  style: TextStyle(color: AppTheme.textDark, height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreItem {
  const _MoreItem(this.title, this.subtitle, this.icon, this.route);

  final String title;
  final String subtitle;
  final String icon;
  final String route;
}
