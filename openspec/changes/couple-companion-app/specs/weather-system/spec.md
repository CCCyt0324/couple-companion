## ADDED Requirements

### Requirement: 定位天气获取
系统 SHALL 基于用户 GPS 定位获取当前位置的实时天气数据。

#### Scenario: 打开天气 Tab 自动获取天气
- **WHEN** 用户打开天气 Tab 并授权定位权限
- **THEN** 展示当前位置的实时温度、天气图标和天气描述

### Requirement: 实时天气展示
天气页 SHALL 展示当前温度、天气图标、天气描述和气象详情。

#### Scenario: 查看完整天气信息
- **WHEN** 用户打开天气页面
- **THEN** 展示当前温度（大号数字）、体感温度、湿度、风力风向

### Requirement: 三日预报
系统 SHALL 展示未来三日的天气预报。

#### Scenario: 查看三日预报
- **WHEN** 用户打开天气页面
- **THEN** 以横向卡片展示未来三天的日期、天气图标和温度范围

### Requirement: 今日贴心提醒
系统 SHALL 根据天气状况 AI 生成穿衣建议、带伞提醒、护肤建议等。

#### Scenario: 雨天显示带伞提醒
- **WHEN** 今日天气为雨天
- **THEN** 提醒卡片展示「今天有雨，记得带伞哦～」及相关建议
