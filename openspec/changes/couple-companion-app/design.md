## Context

本项目是从零开始构建一款 Hello Kitty 粉色主题的双人情侣陪伴互动 APP。目标用户为年轻情侣群体，产品形态为移动端原生 APP。当前无现有代码，属于全新项目。团队配置建议 4 人（2 前端 + 1 后端 + 1 UI 设计师），开发周期约 15 周。

## Goals / Non-Goals

**Goals:**
- 交付 iOS + Android 双端可用 APP，UI 高度还原 Hello Kitty 粉色设计
- 所有功能围绕「两人共同使用」设计，确保双人数据实时同步
- 桌宠系统作为情感纽带，全局陪伴
- 小游戏房间制实时联机体验
- AI 管家模块提供情绪价值

**Non-Goals:**
- 不做朋友圈/动态/社区等社交传播功能（主打私密双人空间）
- 不做多语言国际化（首期仅简体中文）
- 不做多对关系（如多角恋/开放关系管理）
- 不做付费会员体系（首期免费）

## Decisions

### 前端：Flutter 3.x + Riverpod 2.x + GoRouter
- **选择理由**: 一套代码双端（iOS + Android），UI 还原度高，自绘引擎适合 Hello Kitty 定制主题。Riverpod 是 Provider 的升级版，支持编译时安全、无上下文依赖的响应式状态管理。GoRouter 支持声明式命名路由
- **备选**: React Native（若团队 JS 经验更丰富），但 Flutter 对复杂动画（桌宠）支持更好

### 后端：Node.js + NestJS + TypeScript
- **选择理由**: NestJS 提供模块化架构和依赖注入，适合 13+ 业务模块的组织管理。TypeScript 全栈统一类型定义，WebSocket(Socket.io) 集成成熟，AI 模块调用大模型 SDK 方便
- **备选**: Express + TypeScript（更轻量但缺少模块化结构）；Go + Gin（性能更优但 AI 集成不如 JS 生态方便）

### 数据库：MySQL 8.0 + Redis 7.x
- **选择理由**: MySQL 适合关系型情侣数据模型，支持事务（情侣绑定需事务一致性）。Redis 用于会话管理、在线状态、AI 管家结果缓存（24h）、小游戏房间临时状态

### 实时通信：WebSocket (Socket.io)
- **选择理由**: 小游戏联机、每日情话同步、情侣状态变更、心愿纸条即时推送都需要低延迟实时通信。Socket.io 支持自动重连、心跳检测和房间管理

### 文件存储：阿里云 OSS
- **选择理由**: 国内访问速度快，SDK 成熟，支持图片处理（缩放/水印/格式转换）。需配置生命周期策略（冷数据归档）

### 推送：极光推送 + 厂商通道
- **选择理由**: 国内推送到达率高，支持 iOS + Android 统一接入。Android 需补充华为/小米/OPPO/VIVO 厂商通道提高到达率

### 天气 API：和风天气
- **选择理由**: 国内天气数据准确，免费额度充足，支持 GPS 坐标查询

### 地图 SDK：高德地图
- **选择理由**: 国内定位精度高，覆盖广，SDK 自带距离计算

### AI 大模型：接入通用 LLM API
- **选择理由**: 管家建议、天气提醒等场景需要文本生成能力。采用每日限调用 1 次 + Redis 24h 缓存的策略控制成本

## Risks / Trade-offs

- [实时同步复杂度] 双人数据实时同步依赖 WebSocket 长连接稳定性 → 实现消息确认 + 离线队列 + 重连自动同步 + 心跳检测 + 状态补偿
- [桌宠性能] Flutter 全局悬浮组件 + 帧动画可能影响列表滚动性能 → 使用 Overlay + 节流动画帧率，低端机降级动画，后台暂停动画
- [定位隐私] 两人地图涉及实时位置敏感数据 → 默认关闭位置共享，每次开启需确认，数据端到端加密
- [经期数据合规] 经期数据属于个人健康敏感信息 → 加密传输存储，不出现在日志和统计中
- [国内推送到达率] Android 厂商推送限制可能影响及时性 → 多通道（厂商通道 + 极光通道），重要提醒短信兜底
- [小游戏同步延迟] 实时联机受网络质量影响 → 游戏设计为非竞技型（回合制/异步对比），容忍 2-3 秒延迟
- [图片存储成本] 照片上传量增长导致成本上升 → 前端压缩 + 服务端缩略图 + 冷数据归档 + OSS 生命周期策略
- [大模型调用成本] AI 管家频繁调用成本高 → 每日限调用 1 次 + Redis 缓存结果，使用轻量模型
- [恋爱码冲突] 6 位码在高并发下可能冲突 → 生成时重试 10 次 + 冲突自动扩展至 7 位

## Data Model

```
用户与关系层:
User:
  id, phone, email, wechat_openid, nickname, avatar_url, love_code, created_at

Couple:
  id, user_a_id, user_b_id, start_date, status, created_at

日常记录层:
DailyGreeting:
  id, couple_id, date, content_a, content_b, bg_image_url

Habit:
  id, couple_id, name, icon, sort_order

HabitLog:
  id, habit_id, user_id, date, completed

Todo:
  id, couple_id, content, status, created_by, deadline

MoodRecord:
  id, user_id, date, mood_value(0-100), note, created_at

PeriodRecord:
  id, user_id, date, flow_level, symptoms[], emotions[], note

PeriodSetting:
  id, user_id, cycle_days, period_days

互动功能层:
Anniversary:
  id, couple_id, title, date, type(recurring/once), remind_config, bg_image_url

Album:
  id, couple_id, name, cover_url, sort_order

Photo:
  id, album_id, upload_user_id, url, thumbnail_url, created_at

PhotoLike:
  id, photo_id, user_id (唯一索引 photo_id+user_id 防重复)

PhotoComment:
  id, photo_id, user_id, content, parent_id(楼中楼), created_at

WishNote:
  id, couple_id, from_user_id, content, type(whisper/wish), is_read, status

UserStatus:
  id, user_id, type, content, emoji, bg_color, expires_at

StatusInteraction:
  id, status_id, from_user_id, type(poke/hug/comment/copy), content

Pet:
  id, couple_id, name, hunger, happy, clean, energy, level, exp, updated_at

PetInteraction:
  id, pet_id, user_id, type(feed/play/clean/sleep), created_at

游戏层:
GameRoom:
  id, game_type, couple_id, status(waiting/playing/finished), created_at

GameQuestion:
  id, game_type, content, options(JSON)

GameAnswer:
  id, room_id, user_id, question_id, answer, score

天气缓存层:
WeatherCache:
  id, couple_id, city, data(JSON), cached_at
```

ER 关系核心：
- 所有业务表都关联 coupleId（情侣维度隔离）
- 用户操作表都记录 userId
- 情侣关系为 1 对多：一对情侣对应多条记录

## Team Config

| 角色 | 人数 | 职责 |
|------|------|------|
| 前端开发 | 2 人 | Flutter 双端开发，1 人偏 UI 组件，1 人偏业务逻辑+状态管理 |
| 后端开发 | 1 人 | API 开发、数据库设计、WebSocket、第三方服务接入 |
| UI 设计师 | 1 人 | 视觉设计、图标绘制、桌宠帧动画、主题风格把控 |

可选用补充：测试工程师（第 5 阶段介入）、产品经理（兼职）

## Open Questions

- Hello Kitty IP 授权是否已获取？如未获取，需评估是否使用原创粉色猫咪 IP 替代
- AI 大模型具体选型（国内合规要求可能需要使用国产大模型 API）
- 是否需要后台管理系统做内容和问题库管理？
