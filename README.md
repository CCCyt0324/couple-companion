# 情侣小宇宙 — 双人陪伴互动 PWA

> 一款面向情侣的私密陪伴型 Web App，支持添加到手机主屏，iOS/Android 通用。

## 技术栈

| 层级 | 选型 |
|------|------|
| 前端框架 | **Flutter 3.44** (Web + PWA) |
| 状态管理 | **Riverpod 2.x** |
| 路由 | **GoRouter** |
| 后端框架 | **NestJS 10** (Node.js) |
| 数据库 | **MySQL 8.0** |
| 缓存 | **Redis 7.x** |
| 实时通信 | **Socket.io** |
| AI 服务 | **通义千问 qwen-plus** (DashScope) |
| 天气服务 | **高德天气 API** + **Open-Meteo** |
| 部署 | 阿里云 ECS + Nginx 反向代理 + pm2 |

## 功能模块 (12 个)

| 模块 | 说明 |
|------|------|
| 🏠 房间码 | 6 位房间码共享数据，免注册登录 |
| 📊 首页仪表盘 | 恋爱天数、习惯进度、天气、经期倒计时 |
| ✅ 任务中心 | 习惯打卡 + 共享待办清单 |
| 🌡 心情温度计 | 0-100 滑动条 + 情侣对比 |
| 📅 纪念日 | 添加/删除/倒计时/提醒 |
| 📸 共享相册 | 文件上传 + 粘贴上传 + 点赞 + 评论 |
| ✉️ 心愿纸条 | 悄悄话 + 心愿管理 |
| 💬 情侣状态 | 预设/自定义状态 + 互动通知 |
| 🤖 AI 管家 | 通义千问自由对话 |
| 🌤 天气 | 高德实时数据 + 三日预报 |
| 📆 经期管理 | 记录/周期设置/智能预测 |
| 🎮 情侣游戏 | 功能开发中 |

## 项目结构

```
├── backend/                    # NestJS 后端
│   └── src/
│       ├── main.ts             # 入口 (CORS + 静态托管 + SPA回退)
│       ├── app.module.ts       # 根模块 (13 个业务模块)
│       ├── common/             # 通用层 (守卫/过滤器/拦截器)
│       ├── config/             # 配置 (环境变量/命名策略)
│       ├── database/
│       │   ├── entities/       # 12 个 TypeORM 实体 (20+ 张表)
│       │   ├── migrations/     # 建库 SQL
│       │   └── seeds/          # 题库种子数据
│       ├── modules/            # 13 个业务模块
│       │   ├── auth/           #   认证 (手机/邮箱/微信)
│       │   ├── room/           #   房间码系统 (基础设施)
│       │   ├── habit/          #   习惯打卡
│       │   ├── todo/           #   待办事项
│       │   ├── mood/           #   心情温度计
│       │   ├── anniversary/    #   纪念日
│       │   ├── album/          #   共享相册 (multer 文件上传)
│       │   ├── wish/           #   心愿纸条
│       │   ├── status/         #   情侣状态
│       │   ├── butler/         #   AI 管家
│       │   ├── weather/        #   天气
│       │   ├── period/         #   经期管理
│       │   ├── greeting/       #   每日情话
│       │   └── games/          #   小游戏 (WebSocket)
│       └── providers/          # AI/OSS/推送 服务提供商
│
├── frontend/                   # Flutter Web 前端
│   ├── web/
│   │   ├── index.html          # PWA 入口 (启动动画+viewport)
│   │   └── manifest.json       # PWA 配置
│   └── lib/
│       ├── main.dart           # 启动入口 (userId 持久化)
│       ├── core/               # 核心层 (配置/路由/主题/组件)
│       ├── models/             # 数据模型
│       ├── services/           # API + WebSocket 服务
│       ├── providers/          # Riverpod 状态管理
│       └── features/           # 15 个功能页面
│
└── openspec/                   # 需求规格文档
```

## 核心设计

### 房间码共享机制

```
用户A 打开页面 → 自动创建匿名用户 → 生成6位房间码
用户B 打开页面 → 输入A的房间码 → 加入成功
之后所有数据 (习惯/心情/纪念日/相册/纸条) 通过 roomId 隔离共享
```

### 鉴权策略 (三层降级)

```
OptionalAuthGuard
├─ JWT Token   (Authorization: Bearer xxx)
├─ x-user-id   (自用模式, localStorage 持久化)
└─ 匿名         (sub=0)
```

### 数据隔离

所有业务表通过 `roomId` 字段隔离，同房间码的用户看到相同数据。

## 快速开始

### 环境要求

- Node.js >= 22
- MySQL 8.0
- Redis 7.x
- Flutter SDK >= 3.24

### 本地开发

```bash
# 后端
cd backend
cp .env.example .env    # 编辑数据库密码
npm install
npm run dev              # http://localhost:3000

# 前端
cd frontend
flutter pub get
flutter run -d chrome    # http://localhost:58888
```

### 生产部署

```bash
# 构建前端 (替换为真实 API 地址)
cd frontend
flutter build web --dart-define=API_URL=http://你的IP/api

# 复制到后端静态目录
cp -r build/web ../backend/www

# 部署到服务器
scp -r backend/* root@服务器IP:/opt/couple-app/
ssh root@服务器IP "pm2 restart couple-api"
```

## 环境变量

```env
# 数据库
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=your_password
DB_DATABASE=couple_companion

# AI 服务 (通义千问)
AI_API_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
AI_API_KEY=your_dashscope_key
AI_MODEL=qwen-plus

# 天气 (高德)
WEATHER_API_KEY=your_amap_key

# JWT
JWT_SECRET=your_secret
JWT_EXPIRES_IN=7d
```

## License

MIT
