-- ========================================================
-- 表名: aim_agent_employee_stats
-- 功能: F-008 智能员工运营管理 - 员工统计汇总表
-- 服务: mall-agent-employee-service
-- 删除策略: 物理删除
-- 生成时间: 2026-03-16
-- ========================================================

-- --------------------------------------------------------
-- 建表语句
-- --------------------------------------------------------
DROP TABLE IF EXISTS `aim_agent_employee_stats`;
CREATE TABLE IF NOT EXISTS `aim_agent_employee_stats` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `employee_id` BIGINT NOT NULL COMMENT '员工ID',
    `consult_count` BIGINT NOT NULL DEFAULT 0 COMMENT '咨询次数',
    `total_revenue` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '总营收',
    `total_commission` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '总佣金',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_employee_id` (`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工统计汇总表';

-- --------------------------------------------------------
-- 测试数据
-- --------------------------------------------------------
INSERT INTO `aim_agent_employee_stats` (`id`, `employee_id`, `consult_count`, `total_revenue`, `total_commission`, `create_time`, `update_time`) VALUES
(1, 1, 1523, 125800.50, 12580.05, '2026-03-15 10:00:00', '2026-03-15 10:00:00'),
(2, 2, 0, 0.00, 0.00, '2026-03-15 10:05:00', '2026-03-15 10:05:00'),
(3, 4, 856, 68900.00, 5512.00, '2026-03-15 10:15:00', '2026-03-15 10:15:00');
