## ADDED Requirements

### Requirement: 悄悄话发送
系统 SHALL 支持用户写一句话的小纸条发送给对方，即时推送通知。

#### Scenario: 发送悄悄话
- **WHEN** 用户输入「今天特别想你」并点击发送
- **THEN** 对方收到推送通知，打开 APP 后可查看悄悄话内容

### Requirement: 心愿清单管理
系统 SHALL 支持创建个人心愿清单，可选择性发送给对方。

#### Scenario: 添加心愿项
- **WHEN** 用户添加心愿「想吃榴莲千层」
- **THEN** 心愿加入个人清单，可选择仅自己可见或分享给对方

#### Scenario: 发送心愿给对方
- **WHEN** 用户点击心愿旁边的「发送给 TA」按钮
- **THEN** 对方收到推送通知，看到心愿内容

### Requirement: 心愿管理
系统 SHALL 支持心愿项的添加和删除。

#### Scenario: 心愿实现后删除
- **WHEN** 用户删除已实现的心愿项
- **THEN** 该项从清单中移除
