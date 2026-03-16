-- ========================================================
-- 表名: aim_agent_employee_apply
-- 功能: F-006 智能员工申请扩展表
-- 服务: mall-agent-employee-service
-- 删除策略: 软删除（is_deleted）
-- 生成时间: 2026-03-16
-- ========================================================

-- --------------------------------------------------------
-- 建表语句
-- --------------------------------------------------------
DROP TABLE IF EXISTS `aim_agent_employee_apply`;
CREATE TABLE IF NOT EXISTS `aim_agent_employee_apply` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `employee_id` BIGINT NOT NULL COMMENT '员工ID',
    `social_links` TEXT DEFAULT NULL COMMENT '社交链接（JSON格式）',
    `screenshots` TEXT DEFAULT NULL COMMENT '截图凭证（JSON数组）',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记：0-未删除 1-已删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_employee_id` (`employee_id`),
    KEY `idx_employee_id_deleted` (`employee_id`, `is_deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='智能员工申请扩展表';

-- --------------------------------------------------------
-- 测试数据
-- --------------------------------------------------------
INSERT INTO `aim_agent_employee_apply` (`id`, `employee_id`, `social_links`, `screenshots`, `create_time`, `update_time`, `is_deleted`) VALUES
(1, 3, '["https://weibo.com/user123", "https://douyin.com/user123"]', '["https://cdn.example.com/screenshot1.jpg", "https://cdn.example.com/screenshot2.jpg"]', '2026-03-15 10:10:00', '2026-03-15 10:10:00', 0),
(2, 5, '["https://weibo.com/user456"]', '["https://cdn.example.com/screenshot3.jpg"]', '2026-03-15 10:20:00', '2026-03-15 10:20:00', 0);
