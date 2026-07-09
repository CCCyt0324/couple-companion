## ADDED Requirements

### Requirement: 每日情话编辑
系统 SHALL 支持情侣双方各自编辑当日的专属情话文案，实时同步给对方。

#### Scenario: 编辑今日情话
- **WHEN** 用户在首页情话卡片点击编辑
- **THEN** 弹出编辑框，输入文案后保存，对方通过 WebSocket 实时收到更新

#### Scenario: 新的一天自动初始化
- **WHEN** 每日 0 点
- **THEN** 情话记录自动创建新条目，默认为空白可编辑状态

### Requirement: 自定义背景图
系统 SHALL 支持为每日情话设置自定义背景图。

#### Scenario: 设置情话背景图
- **WHEN** 用户点击更换背景图并从相册选择图片
- **THEN** 背景图上传至 OSS，情话卡片展示新背景

### Requirement: WebSocket 实时同步
系统 SHALL 通过 WebSocket 同步情话内容变更，避免轮询。

#### Scenario: 对方编辑后实时展示
- **WHEN** 伴侣编辑并保存情话
- **THEN** 本方首页情话卡片立即更新显示对方编辑的新内容
