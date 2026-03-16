-- ========================================================
-- 表名: aim_agent_job_type
-- 功能: F-001 岗位类型管理
-- 服务: mall-agent-employee-service
-- 删除策略: 物理删除
-- 生成时间: 2026-03-16
-- ========================================================

-- --------------------------------------------------------
-- 建表语句
-- --------------------------------------------------------
DROP TABLE IF EXISTS `aim_agent_job_type`;
CREATE TABLE IF NOT EXISTS `aim_agent_job_type` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `name` VARCHAR(64) NOT NULL COMMENT '岗位类型名称',
    `code` VARCHAR(32) NOT NULL COMMENT '岗位类型编码（系统自动生成）',
    `description` VARCHAR(255) DEFAULT NULL COMMENT '岗位描述',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：0-禁用 1-启用',
    `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序号',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `creator_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
    `updater_id` BIGINT DEFAULT NULL COMMENT '更新人ID',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_code` (`code`),
    KEY `idx_status` (`status`),
    KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='岗位类型表';

-- --------------------------------------------------------
-- 测试数据
-- --------------------------------------------------------
INSERT INTO `aim_agent_job_type` (`id`, `name`, `code`, `description`, `status`, `sort_order`, `create_time`, `update_time`, `creator_id`, `updater_id`) VALUES
(1, '客服专员', 'J2026000001', '负责客户咨询和问题解答', 1, 1, '2026-03-15 10:00:00', '2026-03-15 10:00:00', 10001, 10001),
(2, '销售顾问', 'J2026000002', '负责商品销售和客户转化', 1, 2, '2026-03-15 10:05:00', '2026-03-15 10:05:00', 10001, 10001),
(3, '售后专员', 'J2026000003', '负责售后问题处理和退换货', 1, 3, '2026-03-15 10:10:00', '2026-03-15 10:10:00', 10001, 10001),
(4, '运营专员', 'J2026000004', '负责店铺运营和活动策划', 0, 4, '2026-03-15 10:15:00', '2026-03-15 10:15:00', 10001, 10001),
(5, '这是一个测试用的超长岗位类型名称用于测试边界值情况下的系统表现情况', 'J2026000005', '测试超长名称', 1, 5, '2026-03-15 10:20:00', '2026-03-15 10:20:00', 10001, 10001);
