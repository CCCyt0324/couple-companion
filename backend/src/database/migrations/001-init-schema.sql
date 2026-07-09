-- =====================================================
-- 情侣陪伴APP 数据库初始化脚本 (MySQL 8.0)
-- =====================================================

CREATE DATABASE IF NOT EXISTS couple_companion
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE couple_companion;

-- =====================================================
-- 用户与关系层
-- =====================================================

CREATE TABLE `user` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `phone` VARCHAR(20) NULL UNIQUE,
  `email` VARCHAR(100) NULL UNIQUE,
  `wechat_openid` VARCHAR(64) NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `nickname` VARCHAR(50) NOT NULL,
  `avatar_url` VARCHAR(500) NULL,
  `love_code` VARCHAR(7) NOT NULL UNIQUE COMMENT '恋爱码（6-7位大写字母+数字）',
  `love_code_refresh_count` INT NOT NULL DEFAULT 0 COMMENT '当月刷新次数',
  `love_code_refresh_month` VARCHAR(7) NOT NULL COMMENT '刷新记录月份 YYYY-MM',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_love_code` (`love_code`),
  INDEX `idx_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `couple` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_a_id` INT UNSIGNED NOT NULL,
  `user_b_id` INT UNSIGNED NOT NULL,
  `start_date` DATE NOT NULL COMMENT '恋爱起始日期',
  `status` VARCHAR(20) NOT NULL DEFAULT 'active' COMMENT 'active/disbanded',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_user_a` (`user_a_id`),
  INDEX `idx_user_b` (`user_b_id`),
  UNIQUE KEY `uk_couple_users` (`user_a_id`, `user_b_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 日常记录层
-- =====================================================

CREATE TABLE `daily_greeting` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `couple_id` INT UNSIGNED NOT NULL,
  `date` DATE NOT NULL,
  `content_a` TEXT NULL COMMENT '用户A的情话',
  `content_b` TEXT NULL COMMENT '用户B的情话',
  `bg_image_url` VARCHAR(500) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_couple_date` (`couple_id`, `date`),
  INDEX `idx_date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `habit` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `couple_id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `icon` VARCHAR(10) NOT NULL DEFAULT 'ok',
  `sort_order` INT NOT NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_couple_id` (`couple_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `habit_log` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `habit_id` INT UNSIGNED NOT NULL,
  `user_id` INT UNSIGNED NOT NULL,
  `date` DATE NOT NULL,
  `completed` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_habit_user_date` (`habit_id`, `user_id`, `date`),
  INDEX `idx_date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `todo` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `couple_id` INT UNSIGNED NOT NULL,
  `content` VARCHAR(500) NOT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT 'pending/done',
  `created_by` INT UNSIGNED NOT NULL,
  `deadline` DATETIME NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_couple_status` (`couple_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `mood_record` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL,
  `date` DATE NOT NULL,
  `mood_value` TINYINT UNSIGNED NOT NULL COMMENT '心情值 0-100',
  `note` TEXT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date` (`user_id`, `date`),
  INDEX `idx_date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `period_record` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL,
  `date` DATE NOT NULL,
  `flow_level` VARCHAR(10) NOT NULL COMMENT '少/中/多/无',
  `symptoms` JSON NULL COMMENT '症状数组',
  `emotions` JSON NULL COMMENT '情绪数组',
  `note` TEXT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date` (`user_id`, `date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `period_setting` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL UNIQUE,
  `cycle_days` INT NOT NULL DEFAULT 28 COMMENT '平均周期天数',
  `period_days` INT NOT NULL DEFAULT 7 COMMENT '经期天数',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 互动功能层
-- =====================================================

CREATE TABLE `anniversary` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `couple_id` INT UNSIGNED NOT NULL,
  `title` VARCHAR(100) NOT NULL,
  `date` DATE NOT NULL COMMENT '日期（不含年份的月日用固定年份存储）',
  `type` VARCHAR(20) NOT NULL DEFAULT 'recurring' COMMENT 'recurring/once',
  `remind_config` JSON NULL COMMENT '{onDay, threeDaysBefore, sevenDaysBefore}',
  `bg_image_url` VARCHAR(500) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_couple_date` (`couple_id`, `date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `album` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `couple_id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `cover_url` VARCHAR(500) NULL,
  `sort_order` INT NOT NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_couple` (`couple_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `photo` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `album_id` INT UNSIGNED NOT NULL,
  `upload_user_id` INT UNSIGNED NOT NULL,
  `url` VARCHAR(500) NOT NULL,
  `thumbnail_url` VARCHAR(500) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_album` (`album_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `photo_like` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `photo_id` INT UNSIGNED NOT NULL,
  `user_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_photo_user` (`photo_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `photo_comment` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `photo_id` INT UNSIGNED NOT NULL,
  `user_id` INT UNSIGNED NOT NULL,
  `content` TEXT NOT NULL,
  `parent_id` INT UNSIGNED NULL COMMENT '父评论ID（楼中楼）',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_photo` (`photo_id`),
  INDEX `idx_parent` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `wish_note` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `couple_id` INT UNSIGNED NOT NULL,
  `from_user_id` INT UNSIGNED NOT NULL,
  `content` TEXT NOT NULL,
  `type` VARCHAR(20) NOT NULL COMMENT 'whisper/wish',
  `is_read` TINYINT(1) NOT NULL DEFAULT 0,
  `status` VARCHAR(20) NOT NULL DEFAULT 'active',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_couple_type` (`couple_id`, `type`),
  INDEX `idx_read` (`from_user_id`, `is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `user_status` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT UNSIGNED NOT NULL,
  `type` VARCHAR(20) NOT NULL COMMENT 'mood/activity/weather/special/custom',
  `content` VARCHAR(50) NOT NULL,
  `emoji` VARCHAR(10) NULL,
  `bg_color` VARCHAR(20) NULL,
  `expires_at` DATETIME NOT NULL COMMENT '24小时后过期',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `status_interaction` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `status_id` INT UNSIGNED NOT NULL,
  `from_user_id` INT UNSIGNED NOT NULL,
  `type` VARCHAR(20) NOT NULL COMMENT 'poke/hug/comment/copy',
  `content` VARCHAR(200) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_status` (`status_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 桌宠系统
-- =====================================================

CREATE TABLE `pet` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `couple_id` INT UNSIGNED NOT NULL UNIQUE,
  `name` VARCHAR(50) NOT NULL DEFAULT '暹暹',
  `hunger` INT NOT NULL DEFAULT 80 COMMENT '饱饱值 0-100',
  `happy` INT NOT NULL DEFAULT 80 COMMENT '开心值 0-100',
  `clean` INT NOT NULL DEFAULT 80 COMMENT '干净值 0-100',
  `energy` INT NOT NULL DEFAULT 80 COMMENT '精力值 0-100',
  `level` INT NOT NULL DEFAULT 1 COMMENT '等级',
  `exp` INT NOT NULL DEFAULT 0 COMMENT '经验值',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pet_interaction` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `pet_id` INT UNSIGNED NOT NULL,
  `user_id` INT UNSIGNED NOT NULL,
  `type` VARCHAR(20) NOT NULL COMMENT 'feed/play/clean/sleep',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_pet_date` (`pet_id`, `created_at` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 小游戏
-- =====================================================

CREATE TABLE `game_room` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `game_type` VARCHAR(30) NOT NULL,
  `couple_id` INT UNSIGNED NOT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'waiting' COMMENT 'waiting/playing/finished',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_couple_game` (`couple_id`, `game_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `game_question` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `game_type` VARCHAR(30) NOT NULL,
  `content` TEXT NOT NULL,
  `options` JSON NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_game_type` (`game_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `game_answer` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `room_id` INT UNSIGNED NOT NULL,
  `user_id` INT UNSIGNED NOT NULL,
  `question_id` INT UNSIGNED NOT NULL,
  `answer` TEXT NOT NULL,
  `score` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  INDEX `idx_room_user` (`room_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 天气缓存
-- =====================================================

CREATE TABLE `weather_cache` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `couple_id` INT UNSIGNED NOT NULL,
  `city` VARCHAR(50) NOT NULL,
  `data` JSON NOT NULL,
  `cached_at` DATETIME NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_couple_city` (`couple_id`, `city`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
