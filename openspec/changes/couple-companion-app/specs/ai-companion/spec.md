## ADDED Requirements

### Requirement: AI 输入数据采集
系统 SHALL 在每次生成管家建议时采集 5 项输入数据：对方今日心情值、经期阶段、今日天气、今日打卡情况、最近纪念日倒计时。

#### Scenario: 输入数据完备时生成建议
- **WHEN** 对方已记录心情 + 经期 + 天气可获取 + 打卡有数据
- **THEN** 系统将 5 项数据传入 AI 提示词，生成个性化建议

#### Scenario: 输入数据部分缺失
- **WHEN** 对方未记录今日心情
- **THEN** 该输入项标记为空，AI 在生成内容时跳过相关维度

### Requirement: 今日建议生成
系统 SHALL 基于输入数据 AI 生成 3 条今日行动建议。

#### Scenario: 对方处于经期时建议
- **WHEN** 伴侣当前处于经期
- **THEN** AI 生成包含「多喝热水」「准备暖宝宝」等体贴建议

### Requirement: 避坑提醒
系统 SHALL 生成 1 条基于对方状态的避坑提醒。

#### Scenario: 显示避坑建议
- **WHEN** 管家 Tab 加载
- **THEN** 展示「今天尽量避免」雷区提示（如「她今天看起来有点累，避免争吵」）

### Requirement: 话术模板
系统 SHALL 生成 2 条高情商话术参考模板。

#### Scenario: 获取话术建议
- **WHEN** 用户查看话术模板
- **THEN** 展示「可以这样说」配文示例，支持一键复制

### Requirement: 缓存优化
系统 SHALL 每日仅调用 AI 一次，结果通过 Redis 缓存 24 小时，过期后重新生成。

#### Scenario: 当日首次访问管家
- **WHEN** 用户今日首次打开管家 Tab
- **THEN** 调用 AI API 生成内容，结果写入 Redis（TTL=24h）

#### Scenario: 当日重复访问管家
- **WHEN** 用户今日再次打开管家 Tab
- **THEN** 直接从 Redis 读取缓存结果，不调用 AI API
