## ADDED Requirements

### Requirement: 照片上传
系统 SHALL 支持批量上传 JPG/PNG/HEIC/GIF 格式照片，单张最大 10MB。

#### Scenario: 上传照片到共享相册
- **WHEN** 用户选择本地照片并确认上传
- **THEN** 照片上传至 OSS（前端压缩+服务端生成缩略图），展示在瀑布流中，对方可见

#### Scenario: 上传超大文件被拒
- **WHEN** 用户选择超过 10MB 的照片
- **THEN** 系统提示「照片不能超过 10MB，请压缩后重试」

### Requirement: 瀑布流展示
系统 SHALL 以瀑布流布局展示相册照片。

#### Scenario: 浏览照片墙
- **WHEN** 用户打开相册页面
- **THEN** 照片以瀑布流形式排列，支持上下滚动，照片按时间倒序

### Requirement: 多相册分类管理
系统 SHALL 支持创建多个相册房间，自定义名称，每个房间独立管理照片。

#### Scenario: 创建新相册房间
- **WHEN** 用户创建相册「我们的旅行」
- **THEN** 新相册房间出现在列表，可进入房间上传照片

### Requirement: 点赞功能
系统 SHALL 支持对照片点赞，同用户对同照片不可重复点赞。

#### Scenario: 点赞照片
- **WHEN** 用户双击照片点赞
- **THEN** 点赞计数 +1，若已点过则提示「已经赞过啦」，通过唯一索引（photo_id + user_id）防重复

### Requirement: 评论功能
系统 SHALL 支持对照片发表评论和楼中楼回复。

#### Scenario: 发表评论
- **WHEN** 用户在照片下输入评论内容并发送
- **THEN** 评论发布成功，其他用户可见

#### Scenario: 楼中楼回复
- **WHEN** 用户点击某条评论进行回复
- **THEN** 回复挂载到父评论下，展示缩进层级

### Requirement: 实时同步推送
系统 SHALL 在对方上传照片/点赞/评论时推送通知。

#### Scenario: 对方上传了新照片
- **WHEN** 伴侣上传新照片到共享相册
- **THEN** 用户收到推送通知，打开相册时新照片带「NEW」标记
