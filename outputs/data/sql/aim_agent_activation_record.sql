-- ========================================================
-- 表名: aim_agent_activation_record
-- 功能: F-007 智能员工解锁与激活 - 激活记录流水表
-- 服务: mall-agent-employee-service
-- 删除策略: 软删除（is_deleted）
-- 生成时间: 2026-03-16
-- ========================================================

-- --------------------------------------------------------
-- 建表语句
-- --------------------------------------------------------
DROP TABLE IF EXISTS `aim_agent_activation_record`;
CREATE TABLE IF NOT EXISTS `aim_agent_activation_record` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `employee_id` BIGINT NOT NULL COMMENT '智能员工ID',
    `employee_no` VARCHAR(32) NOT NULL COMMENT '员工编号',
    `employee_name` VARCHAR(64) NOT NULL COMMENT '员工名称',
    `inviter_user_id` BIGINT NOT NULL COMMENT '邀请人用户ID',
    `helper_user_id` BIGINT NOT NULL COMMENT '助力人用户ID',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除（0-否，1-是）',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_employee_helper` (`employee_id`, `helper_user_id`),
    KEY `idx_employee_id` (`employee_id`),
    KEY `idx_inviter_user_id` (`inviter_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='智能员工激活记录流水表';

-- --------------------------------------------------------
-- 测试数据
-- --------------------------------------------------------
INSERT INTO `aim_agent_activation_record` (`id`, `employee_id`, `employee_no`, `employee_name`, `inviter_user_id`, `helper_user_id`, `is_deleted`, `create_time`) VALUES
(1, 2, 'E2026000002', '销售顾问-小明', 10001, 20001, 0, '2026-03-15 10:00:00'),
(2, 2, 'E2026000002', '销售顾问-小明', 10001, 20002, 0, '2026-03-15 10:05:00'),
(3, 2, 'E2026000002', '销售顾问-小明', 10001, 20003, 0, '2026-03-15 10:10:00'),
(4, 4, 'E2026000004', '售后专员-小红', 10003, 20004, 0, '2026-03-15 10:15:00'),
(5, 4, 'E2026000004', '售后专员-小红', 10003, 20005, 0, '2026-03-15 10:20:00');
