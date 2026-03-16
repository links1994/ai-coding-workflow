-- ========================================================
-- 表名: aim_agent_user_quota
-- 功能: F-003 名额配置管理 - 用户名额汇总表
-- 服务: mall-agent-employee-service
-- 删除策略: 软删除（is_deleted）
-- 生成时间: 2026-03-16
-- ========================================================

-- --------------------------------------------------------
-- 建表语句
-- --------------------------------------------------------
DROP TABLE IF EXISTS `aim_agent_user_quota`;
CREATE TABLE IF NOT EXISTS `aim_agent_user_quota` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `total_quota` INT NOT NULL DEFAULT 0 COMMENT '总名额',
    `used_quota` INT NOT NULL DEFAULT 0 COMMENT '已用名额',
    `unlocked_thresholds` TEXT COMMENT '已解锁销售额阈值列表（JSON数组）',
    `version` INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '软删除标记',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_id` (`user_id`),
    KEY `idx_user_id_deleted` (`user_id`, `is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户名额汇总表';

-- --------------------------------------------------------
-- 测试数据
-- --------------------------------------------------------
INSERT INTO `aim_agent_user_quota` (`id`, `user_id`, `total_quota`, `used_quota`, `unlocked_thresholds`, `version`, `create_time`, `update_time`, `is_deleted`) VALUES
(1, 10001, 5, 2, '[10000]', 1, '2026-03-15 10:00:00', '2026-03-15 10:00:00', 0),
(2, 10002, 3, 0, '[]', 0, '2026-03-15 10:05:00', '2026-03-15 10:05:00', 0),
(3, 10003, 10, 5, '[10000, 50000]', 2, '2026-03-15 10:10:00', '2026-03-15 10:10:00', 0),
(4, 10004, 0, 0, '[]', 0, '2026-03-15 10:15:00', '2026-03-15 10:15:00', 0),
(5, 10005, 20, 10, '[10000, 50000, 100000]', 3, '2026-03-15 10:20:00', '2026-03-15 10:20:00', 0);
