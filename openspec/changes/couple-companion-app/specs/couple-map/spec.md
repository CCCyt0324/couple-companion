## ADDED Requirements

### Requirement: 双方实时位置共享
系统 SHALL 在地图上展示情侣双方的实时位置。

#### Scenario: 查看双方位置
- **WHEN** 用户打开两人地图页面
- **THEN** 地图上以两个不同标记展示双方当前位置，使用各自头像

#### Scenario: 对方未授权位置
- **WHEN** 伴侣未开启位置共享权限
- **THEN** 对方标记显示为灰色，提示「对方未开启位置共享」

### Requirement: 距离显示
系统 SHALL 计算并显示两人之间的直线距离。

#### Scenario: 查看两人距离
- **WHEN** 双方均在线且位置可见
- **THEN** 页面底部展示「你们相距 X 公里」

### Requirement: 位置隐私控制
系统 SHALL 允许用户随时开启或关闭位置共享。

#### Scenario: 暂时关闭位置共享
- **WHEN** 用户在设置中关闭位置共享
- **THEN** 对方地图页我的位置标记变为灰色，不再实时更新
