-- ========================================================
-- 表名: aim_agent_employee
-- 功能: F-006/F-007/F-008/F-009 智能员工主表
-- 服务: mall-agent-employee-service
-- 删除策略: 时间戳软删除（deleted_at）
-- 生成时间: 2026-03-16
-- ========================================================

-- --------------------------------------------------------
-- 建表语句
-- --------------------------------------------------------
DROP TABLE IF EXISTS `aim_agent_employee`;
CREATE TABLE IF NOT EXISTS `aim_agent_employee` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `employee_no` VARCHAR(32) NOT NULL COMMENT '员工编号，格式：AIM{yyyyMM}{序列号}',
    `name` VARCHAR(64) DEFAULT NULL COMMENT '员工名称（系统自动生成）',
    `job_type_id` BIGINT NOT NULL COMMENT '岗位类型ID，关联 aim_agent_job_type.id',
    `spu_code` VARCHAR(64) DEFAULT NULL COMMENT '代理商品SPU编码（商品销售岗必填，客服岗为null）',
    `style_config_id` BIGINT DEFAULT NULL COMMENT '人设风格配置ID，关联 aim_agent_style_config.id',
    `audit_status` TINYINT NOT NULL DEFAULT 0 COMMENT '审核状态：0-待审核 1-已驳回 2-已通过',
    `employee_status` TINYINT DEFAULT NULL COMMENT '员工状态（仅audit_status=2时有效）：0-待激活 1-待上线 2-营业中 3-强制离线 4-已封禁 5-已注销，NULL=未审核通过',
    `commission_rate` DECIMAL(5,2) DEFAULT NULL COMMENT '佣金比例（0.00~100.00）',
    `reject_reason` VARCHAR(255) DEFAULT NULL COMMENT '驳回原因（最近一次驳回时必填）',
    `prompt` TEXT DEFAULT NULL COMMENT 'Prompt内容（F-009生成）',
    `invite_code` VARCHAR(16) DEFAULT NULL COMMENT '邀请码（Base62 encoded employeeId，首次/share时懒生成，NULL=未生成）',
    `creator_id` BIGINT DEFAULT NULL COMMENT '创建人ID（申请用户ID）',
    `updater_id` BIGINT DEFAULT NULL COMMENT '更新人ID',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted_at` DATETIME DEFAULT NULL COMMENT '注销时间（软删除，NULL=未注销）',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_employee_no` (`employee_no`),
    UNIQUE KEY `uk_invite_code` (`invite_code`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_job_type_id` (`job_type_id`),
    KEY `idx_employee_status` (`employee_status`),
    KEY `idx_audit_status` (`audit_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='智能员工主表';

-- --------------------------------------------------------
-- 测试数据
-- --------------------------------------------------------
INSERT INTO `aim_agent_employee` (`id`, `user_id`, `employee_no`, `name`, `job_type_id`, `spu_code`, `style_config_id`, `audit_status`, `employee_status`, `commission_rate`, `reject_reason`, `prompt`, `invite_code`, `creator_id`, `updater_id`, `create_time`, `update_time`, `deleted_at`) VALUES
(1, 10001, 'AIM2026030001', '智能导购小助手', 1, 'SPU2024000001', 1, 2, 2, 10.00, NULL, '您是AI智能导购平台的客服助手，专业严谨。请用专业友好的语气帮助用户解决问题。', 'aB3x9K', 10001, 10001, '2026-03-15 10:00:00', '2026-03-15 10:00:00', NULL),
(2, 10001, 'AIM2026030002', '商品推广专员', 2, 'SPU2024000002', 2, 2, 1, 15.00, NULL, NULL, NULL, 10001, 10001, '2026-03-15 10:05:00', '2026-03-15 10:05:00', NULL),
(3, 10002, 'AIM2026030003', '待审核员工', 1, 'SPU2024000003', 1, 0, NULL, NULL, NULL, NULL, NULL, 10002, 10002, '2026-03-15 10:10:00', '2026-03-15 10:10:00', NULL),
(4, 10003, 'AIM2026030004', '售后客服专员', 3, 'SPU2024000005', 3, 2, 3, 8.00, NULL, '您是AI智能导购平台的售后专员，亲切友好。', 'mN7pQr', 10003, 10003, '2026-03-15 10:15:00', '2026-03-15 10:15:00', NULL),
(5, 10004, 'AIM2026030005', '被驳回员工', 2, 'SPU2024000001', 2, 1, NULL, NULL, '资料不完整，请补充相关证明', NULL, NULL, 10004, 10004, '2026-03-15 10:20:00', '2026-03-15 10:20:00', NULL);
