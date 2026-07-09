# 情侣陪伴APP — API 接口文档

## 基础信息

| 项目 | 值 |
|------|------|
| Base URL | `http://localhost:3000/api` |
| 鉴权方式 | `Authorization: Bearer <token>` |
| 响应格式 | `{ code: 200, data: <>, message: "ok" }` |
| 错误格式 | `{ code: <status>, message: "<error>", timestamp: "..." }` |

## 1. 认证模块 `/auth`

### 1.1 发送短信验证码

```
POST /auth/sms/send
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | ✅ | 11 位手机号 |

### 1.2 手机号注册

```
POST /auth/register/phone
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | ✅ | 11 位手机号 |
| smsCode | string | ✅ | 6 位验证码（开发环境可用 000000） |
| nickname | string | ✅ | 昵称 2-20 字 |
| password | string | ✅ | 密码 6-32 位 |

响应:
```json
{
  "token": "eyJ...",
  "loveCode": "AB3FG7",
  "user": { "id": 1, "nickname": "小明", "phone": "138...", "avatarUrl": null }
}
```

### 1.3 邮箱注册

```
POST /auth/register/email
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| email | string | ✅ | 邮箱地址 |
| nickname | string | ✅ | 昵称 2-20 字 |
| password | string | ✅ | 密码 6-32 位 |

### 1.4 微信注册/登录

```
POST /auth/register/wechat
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| openid | string | ✅ | 微信 openid |
| nickname | string | ✅ | 微信昵称 |

### 1.5 手机号登录

```
POST /auth/login/phone
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | ✅ | 11 位手机号 |
| password | string | ✅ | 密码 |

### 1.6 邮箱登录

```
POST /auth/login/email
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| email | string | ✅ | 邮箱地址 |
| password | string | ✅ | 密码 |

### 1.7 发起情侣绑定请求

```
POST /auth/couple/request     🔐 需登录
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| loveCode | string | ✅ | 对方的 6-7 位恋爱码 |

### 1.8 确认情侣绑定

```
POST /auth/couple/confirm     🔐 需登录
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| loveCode | string | ✅ | 双方恋爱码 |
| startDate | string | ❌ | 恋爱起始日期，如 "2026-05-20"，默认今天 |

### 1.9 获取我的恋爱码

```
GET /auth/love-code     🔐 需登录
```

响应: `{ "loveCode": "AB3FG7" }`

### 1.10 刷新恋爱码

```
POST /auth/love-code/refresh     🔐 需登录
```

响应: `"AB3FG8"`（每月限 3 次）

---

## 2. 用户模块 `/user` 🔐 需登录

### 2.1 获取个人信息

```
GET /user/profile
```

响应:
```json
{ "id": 1, "nickname": "小明", "avatarUrl": "...", "loveCode": "AB3FG7", ... }
```

### 2.2 修改个人资料

```
PUT /user/profile
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| nickname | string | ❌ | 新昵称 |
| avatarUrl | string | ❌ | 头像 URL |

---

## 3. 情侣模块 `/couple` 🔐 需登录

### 3.1 获取伴侣信息

```
GET /couple/partner
```

响应:
```json
{
  "couple": { "id": 1, "startDate": "2026-05-20", "status": "active" },
  "partner": { "id": 2, "nickname": "小红", "avatarUrl": "..." }
}
```
（未配对时 couple 和 partner 为 null）

---

## 4. 首页 Dashboard

### 4.1 每日情话 `/greeting` 🔐

#### 获取今日情话

```
GET /greeting/today
```

响应:
```json
{ "id": 1, "date": "2026-07-09", "contentA": "...", "contentB": "...", "bgImageUrl": null }
```

#### 编辑今日情话

```
PUT /greeting/content
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| content | string | ✅ | 情话内容 |
| isUserA | boolean | ✅ | 当前用户是否是 A 方 |

#### 设置情话背景图

```
PUT /greeting/bg-image
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| bgImageUrl | string | ✅ | OSS 图片 URL |

#### WebSocket — 情话实时同步

```
连接: ws://localhost:3000/greeting (namespace: /greeting)
发送: "greeting:join" { coupleId }
接收: "greeting:updated" { contentA, contentB, ... }
```

---

### 4.2 习惯打卡 `/habit` 🔐

#### 获取习惯列表

```
GET /habit
```

响应:
```json
[
  { "id": 1, "name": "喝水", "icon": "💧", "sortOrder": 0 },
  { "id": 2, "name": "吃水果", "icon": "🍎", "sortOrder": 1 }
]
```

#### 添加习惯

```
POST /habit
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | string | ✅ | 习惯名称 |
| icon | string | ✅ | emoji 图标 |

#### 删除习惯

```
DELETE /habit/:id
```

#### 打卡/取消打卡

```
PUT /habit/:id/toggle
```

响应: `{ "habitId": 1, "userId": 1, "date": "2026-07-09", "completed": true }`

#### 今日打卡统计

```
GET /habit/today-stats
```

响应: `{ "total": 5, "completed": 3 }`

---

### 4.3 待办事项 `/todo` 🔐

#### 获取待办列表

```
GET /todo
```

#### 创建待办

```
POST /todo
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| content | string | ✅ | 待办内容 |
| deadline | string | ❌ | 截止日期 ISO 格式 |

#### 切换完成状态

```
PUT /todo/:id/toggle
```

#### 删除待办

```
DELETE /todo/:id
```

---

## 5. 心情温度计 `/mood` 🔐

### 5.1 获取今日心情

```
GET /mood/today
```

响应: `{ "id": 1, "moodValue": 75, "date": "2026-07-09", "note": "今天很开心" }` 或 `null`

### 5.2 记录/修改心情

```
POST /mood
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| moodValue | number | ✅ | 心情值 0-100 |
| note | string | ❌ | 备注文字 |

### 5.3 心情历史

```
GET /mood/history?year=2026&month=7
```

响应: `[{ "date": "2026-07-01", "moodValue": 65 }, ...]`

### 5.4 情侣心情对比

```
GET /mood/compare
```

响应:
```json
{
  "myMood": { "moodValue": 75, "note": "..." },
  "partnerMood": { "moodValue": 40, "note": "..." }
}
```

---

## 6. 经期管理 `/period` 🔐

### 6.1 获取今日记录

```
GET /period/today
```

### 6.2 保存记录

```
POST /period/record
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| flowLevel | string | ✅ | 少/中/多/无 |
| symptoms | string[] | ❌ | 腹痛/腰酸/乏力/头晕/乳房胀痛/长痘/水肿/头痛 |
| emotions | string[] | ❌ | 烦躁/低落/焦虑/敏感/平静/开心 |
| note | string | ❌ | 备注 |

### 6.3 获取周期设置

```
GET /period/setting
```

响应: `{ "cycleDays": 28, "periodDays": 7 }`

### 6.4 修改周期设置

```
PUT /period/setting
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| cycleDays | number | ✅ | 平均周期天数 |
| periodDays | number | ✅ | 经期天数 |

### 6.5 预测下次经期

```
GET /period/predict
```

响应: `{ "predictedDate": "2026-08-06", "confidence": 0.83 }`

### 6.6 经期倒计时

```
GET /period/countdown
```

响应: `"28 天"` 或 `"今天"` 或 `null`

---

## 7. 天气 `/weather` 🔐

### 7.1 获取天气 + 提醒

```
GET /weather?city=beijing
```

响应:
```json
{
  "weather": { "daily": [...] },
  "reminder": "记得带伞，穿厚一点的外套"
}
```

### 7.2 仅获取贴心提醒

```
GET /weather/reminder?city=beijing
```

---

## 8. 纪念日 `/anniversary` 🔐

### 8.1 获取列表

```
GET /anniversary
```

响应:
```json
[
  {
    "id": 1, "title": "在一起", "date": "2026-05-20", "type": "recurring",
    "remindConfig": { "onDay": true, "threeDaysBefore": true, "sevenDaysBefore": false },
    "bgImageUrl": null
  }
]
```

### 8.2 创建纪念日

```
POST /anniversary
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| title | string | ✅ | 名称 |
| date | string | ✅ | 日期 "YYYY-MM-DD" |
| type | string | ❌ | "recurring" 每年重复 / "once" 一次性 |
| remindConfig | object | ❌ | `{ onDay, threeDaysBefore, sevenDaysBefore }` |
| bgImageUrl | string | ❌ | 背景图 |

### 8.3 修改纪念日

```
PUT /anniversary/:id
```

### 8.4 删除纪念日

```
DELETE /anniversary/:id
```

### 8.5 即将到来的纪念日

```
GET /anniversary/upcoming
```

响应: `[{ "ann": {...}, "daysLeft": 15 }, ...]`

---

## 9. 共享相册 `/album` 🔐

### 9.1 获取相册列表

```
GET /album
```

### 9.2 创建相册

```
POST /album
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | string | ✅ | 相册名称 |

### 9.3 删除相册

```
DELETE /album/:id
```

### 9.4 获取相册内照片

```
GET /album/:id/photos
```

### 9.5 上传照片

```
POST /album/:id/photos       Content-Type: multipart/form-data
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | File | ✅ | 图片文件（JPG/PNG/HEIC/GIF，≤10MB） |

### 9.6 点赞照片

```
POST /album/photos/:photoId/like
```

### 9.7 取消点赞

```
DELETE /album/photos/:photoId/like
```

### 9.8 发表评论

```
POST /album/photos/:photoId/comments
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| content | string | ✅ | 评论内容 |
| parentId | number | ❌ | 父评论 ID（楼中楼回复） |

### 9.9 获取评论列表

```
GET /album/photos/:photoId/comments
```

---

## 10. 心愿小纸条 `/wish` 🔐

### 10.1 发送纸条

```
POST /wish
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| content | string | ✅ | 内容 |
| type | string | ✅ | "whisper" 悄悄话 / "wish" 心愿 |

### 10.2 获取纸条列表

```
GET /wish?type=whisper    (可选过滤类型)
```

### 10.3 标记已读

```
PUT /wish/:id/read
```

### 10.4 删除纸条

```
DELETE /wish/:id
```

---

## 11. 情侣状态 `/status` 🔐

### 11.1 获取我的状态

```
GET /status/mine
```

响应: `{ "id": 1, "type": "mood", "content": "开心", "emoji": "😊", "bgColor": "#FFE6F0", "expiresAt": "..." }` 或 `null`

### 11.2 设置状态

```
POST /status
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| type | string | ✅ | mood/activity/weather/special/custom |
| content | string | ✅ | 状态文字（自定义时 ≤8 字） |
| emoji | string | ❌ | emoji 表情 |
| bgColor | string | ❌ | 背景色 |

预设状态枚举：
- **心情类**: 开心/难过/疲惫/生气/想你
- **活动类**: 工作中/学习中/吃饭中/运动中/睡觉中
- **天气类**: 下雨/晴天/下雪
- **特殊类**: emo中/想静静/求抱抱/等你找我

### 11.3 互动（戳一戳/抱抱/留言/同款）

```
POST /status/:id/interact
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| type | string | ✅ | poke/hug/comment/copy |
| content | string | ❌ | 留言内容（type=comment 时） |

---

## 12. 共同桌宠 `/pet` 🔐

### 12.1 获取桌宠状态

```
GET /pet
```

响应:
```json
{
  "id": 1, "name": "暹暹", "level": 3, "exp": 250,
  "hunger": 78, "happy": 82, "clean": 65, "energy": 90
}
```

### 12.2 互动

```
POST /pet/interact
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| type | string | ✅ | feed/play/clean/sleep |

响应:
```json
{ "pet": { ... }, "msg": "暹暹吃得好开心！" }
```

（10 分钟内重复同类型互动会返回提示）

### 12.3 互动日志

```
GET /pet/logs
```

---

## 13. 情侣小游戏 `/games` 🔐

### 13.1 创建游戏房间

```
POST /games/room
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| gameType | string | ✅ | heart_qa / two_choice / love_task / match_test |

### 13.2 查询房间

```
GET /games/room/:id
```

### 13.3 开始游戏

```
POST /games/room/:id/start
```

### 13.4 获取题目

```
GET /games/question/:gameType
```

### 13.5 提交答案

```
POST /games/answer
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| roomId | number | ✅ | 房间 ID |
| questionId | number | ✅ | 题目 ID |
| answer | string | ✅ | 答案内容 |

### 13.6 获取默契结果

```
GET /games/match/:roomId
```

响应:
```json
{ "score": 85, "grade": "心有灵犀" }
```

| 评级 | 分数范围 |
|------|----------|
| 灵魂伴侣 | 90+ |
| 心有灵犀 | 70-89 |
| 渐入佳境 | 50-69 |
| 还需磨合 | <50 |

### 13.7 游戏历史

```
GET /games/history?type=heart_qa
```

### WebSocket — 游戏实时通信

```
连接: ws://localhost:3000/games (namespace: /games)
发送: "game:join" { roomId, coupleId }
发送: "game:leave" {}
接收: "game:answer_submitted" { userId }
接收: "game:match_result" { score, grade }
```

---

## 14. AI 恋爱管家 `/butler` 🔐

### 14.1 获取今日建议

```
GET /butler/advice
```

响应:
```json
{
  "suggestions": ["今天多关心对方", "给TA发一句早安", "询问TA今天过得怎么样"],
  "warning": "今天尽量避免说让对方不开心的话",
  "templates": ["宝贝今天想我了吗？", "辛苦啦，记得好好休息~"],
  "cached": true
}
```

（当日重复调用返回缓存，cached=true）

---

## 15. 两人地图 `/map` 🔐

### 15.1 上传位置

```
POST /map/location
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| lat | number | ✅ | 纬度 |
| lng | number | ✅ | 经度 |

### 15.2 获取双方位置

```
GET /map/locations
```

响应:
```json
{
  "myLocation": { "lat": 39.9, "lng": 116.4, "updatedAt": 1700000000 },
  "partnerLocation": { "lat": 39.95, "lng": 116.35, "updatedAt": 1700000000 },
  "distance": "5.2 公里",
  "partnerSharing": true
}
```

（partnerLocation 在对方关闭共享时为 null）

### 15.3 设置共享开关

```
POST /map/share-status
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| sharing | boolean | ✅ | 是否共享位置 |

### WebSocket — 位置实时更新

```
连接: ws://localhost:3000/map (namespace: /map)
发送: "map:join" { coupleId }
接收: "map:location_changed" { userId, lat, lng }
```

---

## 附录 A：前端需要实现的 UI 页面

| Tab | 页面 | 核心数据来源 | Codex 开发者注意 |
|-----|------|-------------|-----------------|
| 首页 | 恋爱天数 + 情话 + 快捷入口 + 打卡进度 + 待办 + 天气卡片 + 经期卡片 | `/greeting/today` `/habit/today-stats` `/todo` `/weather` `/period/countdown` | 多 API 聚合页面，建议并发请求 |
| 天气 | 天气详情 + 三日预报 + 提醒 | `/weather?city=...` | 需要 GPS 定位权限 |
| 例假 | 经期记录 + 周期设置 + 预测 + 指南 | `/period/*` | 敏感数据，注意隐私 |
| 管家 | AI 建议 + 话术 + 避坑 | `/butler/advice` | 支持一键复制话术 |
| 更多 | 8 个功能入口 → 对应子页面 | 见下方 | - |

**更多页子页面：**

| 页面 | API |
|------|-----|
| 任务中心 | `/habit` + `/todo` |
| 心情温度计 | `/mood/*` （滑动条 + 温度计可视化 + 情侣对比） |
| 纪念日 | `/anniversary/*` |
| 情侣状态 | `/status/*` |
| 心愿小纸条 | `/wish/*` |
| 共享相册 | `/album/*` |
| 共同桌宠 | `/pet/*` |
| 情侣小游戏 | `/games/*` + WebSocket |
| 两人地图 | `/map/*` + WebSocket |
| 情侣配对 | `/couple/partner` + `/auth/couple/*` |

## 附录 B：桌宠全局悬浮组件

桌宠「暹暹」需在所有主要页面右下角悬浮。API 数据来自 `/pet`。

属性面板展示：

| 属性 | 颜色建议 | 范围 |
|------|----------|------|
| 饱饱值 🍖 | 橙色 | 0-100 |
| 开心值 😊 | 黄色 | 0-100 |
| 干净值 ✨ | 蓝色 | 0-100 |
| 精力值 ⚡ | 绿色 | 0-100 |

互动按钮：喂食 / 玩耍 / 清洁 / 睡觉

## 附录 C：心情温度计颜色映射

| 分值 | 颜色 | Hex | 情绪 |
|------|------|-----|------|
| 0-20 | 深蓝 | `#4A90D9` | 非常低落 |
| 20-40 | 浅蓝 | `#7BB3E0` | 有点低落 |
| 40-60 | 绿色 | `#6BCB77` | 平静一般 |
| 60-80 | 橙色 | `#FF9F45` | 心情不错 |
| 80-100 | 红色 | `#FF6B6B` | 非常开心 |

五段之间使用线性插值渐变。
