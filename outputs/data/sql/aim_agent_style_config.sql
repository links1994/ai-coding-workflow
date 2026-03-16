-- ========================================================
-- 表名: aim_agent_style_config
-- 功能: F-002 人设风格管理
-- 服务: mall-agent-employee-service
-- 删除策略: 软删除（is_deleted）
-- 生成时间: 2026-03-16
-- ========================================================

-- --------------------------------------------------------
-- 建表语句
-- --------------------------------------------------------
DROP TABLE IF EXISTS `aim_agent_style_config`;
CREATE TABLE IF NOT EXISTS `aim_agent_style_config` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `name` VARCHAR(64) NOT NULL COMMENT '风格名称',
    `icon` VARCHAR(255) DEFAULT NULL COMMENT '风格图标URL',
    `description` VARCHAR(255) DEFAULT NULL COMMENT '风格描述',
    `prompt_preview` VARCHAR(500) DEFAULT NULL COMMENT 'Prompt预览文本',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：0-禁用 1-启用',
    `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序号',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '删除标记：0-未删除 1-已删除',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `creator_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
    `updater_id` BIGINT DEFAULT NULL COMMENT '更新人ID',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_name` (`name`),
    KEY `idx_status` (`status`),
    KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='智能员工人设风格配置表';

-- --------------------------------------------------------
-- 测试数据
-- --------------------------------------------------------
INSERT INTO `aim_agent_style_config` (`id`, `name`, `icon`, `description`, `prompt_preview`, `status`, `sort_order`, `is_deleted`, `create_time`, `update_time`, `creator_id`, `updater_id`) VALUES
(1, '专业严谨', 'https://cdn.example.com/icons/professional.png', '专业、严谨、高效的沟通风格', '您是一位专业的客服代表，以严谨、高效的方式回答用户问题，注重准确性和专业性。', 1, 1, 0, '2026-03-15 10:00:00', '2026-03-15 10:00:00', 10001, 10001),
(2, '亲切友好', 'https://cdn.example.com/icons/friendly.png', '亲切、友好、耐心的沟通风格', '您是一位亲切的客服代表，以友好、耐心的态度与用户交流，让用户感受到温暖和关怀。', 1, 2, 0, '2026-03-15 10:05:00', '2026-03-15 10:05:00', 10001, 10001),
(3, '幽默风趣', 'https://cdn.example.com/icons/humorous.png', '幽默、风趣、轻松的沟通风格', '您是一位幽默的客服代表，以风趣、轻松的方式与用户互动，让服务过程充满欢乐。', 1, 3, 0, '2026-03-15 10:10:00', '2026-03-15 10:10:00', 10001, 10001),
(4, '正式商务', NULL, '正式、商务的沟通风格', '您是一位正式的商务代表，以专业、得体的商务礼仪与用户交流。', 0, 4, 0, '2026-03-15 10:15:00', '2026-03-15 10:15:00', 10001, 10001),
(5, '已删除风格', NULL, '这是一条已删除的测试数据', '已删除', 1, 5, 1, '2026-03-15 10:20:00', '2026-03-15 10:20:00', 10001, 10001);
