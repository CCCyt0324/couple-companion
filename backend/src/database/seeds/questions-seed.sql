-- 游戏题库初始化数据
INSERT INTO `game_question` (`game_type`, `content`, `options`) VALUES
-- 心动问答
('heart_qa', '你最喜欢TA的哪个特点？', NULL),
('heart_qa', '第一次见面时，你对TA的第一印象是什么？', NULL),
('heart_qa', '如果可以和TA一起去任何地方，你最想去哪？', NULL),
('heart_qa', 'TA做过的哪件事让你最感动？', NULL),
('heart_qa', '你觉得TA最像哪种小动物？', NULL),
('heart_qa', '你们之间最难忘的一次约会是什么时候？', NULL),
('heart_qa', '如果有一天你想对TA说一句话，会是什么？', NULL),
('heart_qa', 'TA的哪个小习惯你最喜欢？', NULL),
('heart_qa', '你觉得十年后的你们会在做什么？', NULL),
('heart_qa', '你最喜欢和TA一起做的日常小事是什么？', NULL),

-- 甜蜜二选一
('two_choice', 'A. 宅家看电影 vs B. 出门逛街', '["宅家看电影","出门逛街"]'),
('two_choice', 'A. 海边度假 vs B. 山间露营', '["海边度假","山间露营"]'),
('two_choice', 'A. 早起约会 vs B. 熬夜聊天', '["早起约会","熬夜聊天"]'),
('two_choice', 'A. 惊喜礼物 vs B. 陪伴时光', '["惊喜礼物","陪伴时光"]'),
('two_choice', 'A. 火锅 vs B. 日料', '["火锅","日料"]'),
('two_choice', 'A. 猫派 vs B. 狗派', '["猫派","狗派"]'),
('two_choice', 'A. 甜食党 vs B. 咸食党', '["甜食党","咸食党"]'),
('two_choice', 'A. 计划型 vs B. 随性型', '["计划型","随性型"]'),
('two_choice', 'A. 文字聊天 vs B. 电话/语音', '["文字聊天","电话/语音"]'),
('two_choice', 'A. 浪漫仪式感 vs B. 平淡小确幸', '["浪漫仪式感","平淡小确幸"]'),

-- 爱的任务
('love_task', '为TA做一顿爱心早餐', NULL),
('love_task', '写一封手写情书', NULL),
('love_task', '给TA一个至少30秒的拥抱', NULL),
('love_task', '今天对TA说三次"我爱你"', NULL),
('love_task', '为TA按摩肩颈10分钟', NULL),
('love_task', '给TA唱一首完整的歌', NULL),
('love_task', '帮TA完成一件TA今天要做的事', NULL),
('love_task', '给TA准备一个小惊喜', NULL),
('love_task', '今天忍住不对TA发脾气', NULL),
('love_task', '为TA拍一张好看的照片', NULL),

-- 默契大考验
('match_test', 'TA最喜欢的颜色是什么？', NULL),
('match_test', 'TA开心时最先做什么？', NULL),
('match_test', 'TA最讨厌的食物是什么？', NULL),
('match_test', 'TA睡前做的最后一件事是什么？', NULL),
('match_test', 'TA最想去旅行的国家是哪里？', NULL),
('match_test', 'TA最喜欢的季节是哪个？', NULL),
('match_test', 'TA的手机屏幕壁纸是什么？', NULL),
('match_test', 'TA觉得自己像什么动物？', NULL),
('match_test', 'TA生气时通常会怎么做？', NULL),
('match_test', '你们第一次牵手是什么时候？', NULL);
