-- ========================================================
-- 表名: aim_agent_configs
-- 功能: F-003 名额配置管理 - 通用配置表
-- 服务: mall-agent-employee-service
-- 删除策略: 物理删除
-- 生成时间: 2026-03-16
-- ========================================================

-- --------------------------------------------------------
-- 建表语句
-- --------------------------------------------------------
DROP TABLE IF EXISTS `aim_agent_configs`;
CREATE TABLE IF NOT EXISTS `aim_agent_configs` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `biz_type` VARCHAR(32) NOT NULL COMMENT '业务类型（QUOTA）',
    `config_key` VARCHAR(64) NOT NULL COMMENT '配置键',
    `config_value` TEXT COMMENT '配置值（JSON）',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_biz_type_key` (`biz_type`, `config_key`),
    KEY `idx_biz_type` (`biz_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='通用配置表';

-- --------------------------------------------------------
-- 测试数据
-- --------------------------------------------------------
INSERT INTO `aim_agent_configs` (`biz_type`, `config_key`, `config_value`, `create_time`, `update_time`) VALUES
('QUOTA', 'LEVEL_1_INIT', '{"quota": 3}', '2026-03-15 10:00:00', '2026-03-15 10:00:00'),
('QUOTA', 'LEVEL_2_INIT', '{"quota": 5}', '2026-03-15 10:00:00', '2026-03-15 10:00:00'),
('QUOTA', 'LEVEL_3_INIT', '{"quota": 10}', '2026-03-15 10:00:00', '2026-03-15 10:00:00'),
('QUOTA', 'LEVEL_4_INIT', '{"quota": 20}', '2026-03-15 10:00:00', '2026-03-15 10:00:00'),
('QUOTA', 'LEVEL_5_INIT', '{"quota": 50}', '2026-03-15 10:00:00', '2026-03-15 10:00:00'),
('QUOTA', 'UNLOCK_CONFIG', '[{"threshold": 10000, "quota": 2}, {"threshold": 50000, "quota": 5}, {"threshold": 100000, "quota": 10}]', '2026-03-15 10:00:00', '2026-03-15 10:00:00');
