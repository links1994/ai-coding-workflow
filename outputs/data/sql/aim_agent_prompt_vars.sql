-- ========================================================
-- 表名: aim_agent_prompt_vars
-- 功能: F-009 Prompt管理与生成 - Prompt变量配置表
-- 服务: mall-agent-employee-service
-- 删除策略: 软删除（is_deleted）
-- 生成时间: 2026-03-16
-- ========================================================

-- --------------------------------------------------------
-- 建表语句
-- --------------------------------------------------------
DROP TABLE IF EXISTS `aim_agent_prompt_vars`;
CREATE TABLE IF NOT EXISTS `aim_agent_prompt_vars` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `var_key` VARCHAR(100) NOT NULL COMMENT '变量键',
    `var_value` VARCHAR(500) NOT NULL COMMENT '变量值',
    `description` VARCHAR(200) DEFAULT NULL COMMENT '变量描述',
    `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序序号',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：0-禁用 1-启用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记：0-未删除 1-已删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_var_key` (`var_key`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Prompt变量配置表';

-- --------------------------------------------------------
-- 测试数据
-- --------------------------------------------------------
INSERT INTO `aim_agent_prompt_vars` (`id`, `var_key`, `var_value`, `description`, `sort_order`, `status`, `create_time`, `update_time`, `is_deleted`) VALUES
(1, 'PLATFORM_NAME', 'AI智能导购平台', '平台名称', 1, 1, '2026-03-15 10:00:00', '2026-03-15 10:00:00', 0),
(2, 'DEFAULT_GREETING', '您好，我是您的专属导购助手', '默认问候语', 2, 1, '2026-03-15 10:05:00', '2026-03-15 10:05:00', 0),
(3, 'COMPANY_NAME', '智购科技有限公司', '公司名称', 3, 1, '2026-03-15 10:10:00', '2026-03-15 10:10:00', 0),
(4, 'SERVICE_TIME', '9:00-22:00', '服务时间', 4, 1, '2026-03-15 10:15:00', '2026-03-15 10:15:00', 0),
(5, 'CONTACT_PHONE', '400-888-8888', '客服电话', 5, 1, '2026-03-15 10:20:00', '2026-03-15 10:20:00', 0);
