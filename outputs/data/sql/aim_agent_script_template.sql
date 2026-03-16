-- ========================================================
-- 表名: aim_agent_script_template
-- 功能: F-005 话术模板管理
-- 服务: mall-agent-employee-service
-- 删除策略: 物理删除
-- 生成时间: 2026-03-16
-- ========================================================

-- --------------------------------------------------------
-- 建表语句
-- --------------------------------------------------------
DROP TABLE IF EXISTS `aim_agent_script_template`;
CREATE TABLE IF NOT EXISTS `aim_agent_script_template` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `name` VARCHAR(128) NOT NULL COMMENT '话术模板名称',
    `trigger_condition` VARCHAR(255) DEFAULT NULL COMMENT '触发条件',
    `content` VARCHAR(500) NOT NULL COMMENT '话术内容',
    `job_type_id` BIGINT NOT NULL COMMENT '岗位类型ID',
    `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-启用，1-禁用',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_job_type_id` (`job_type_id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='话术模板表';

-- --------------------------------------------------------
-- 测试数据
-- --------------------------------------------------------
INSERT INTO `aim_agent_script_template` (`id`, `name`, `trigger_condition`, `content`, `job_type_id`, `status`, `create_time`, `update_time`) VALUES
(1, '欢迎语-客服', '用户进入会话', '您好！欢迎来到AI智能导购平台，我是您的专属客服小助手，请问有什么可以帮助您的吗？', 1, 0, '2026-03-15 10:00:00', '2026-03-15 10:00:00'),
(2, '商品推荐-销售', '用户询问商品', '根据您的需求，我为您推荐以下商品：{{productName}}，售价{{price}}元，性价比非常高！', 2, 0, '2026-03-15 10:05:00', '2026-03-15 10:05:00'),
(3, '售后处理-售后', '用户申请售后', '非常抱歉给您带来不便，请您提供订单号和问题描述，我会尽快为您处理。', 3, 0, '2026-03-15 10:10:00', '2026-03-15 10:10:00'),
(4, '活动推广-运营', '促销活动期', '限时特惠！全场满199减50，快来选购吧！', 4, 1, '2026-03-15 10:15:00', '2026-03-15 10:15:00'),
(5, '结束语-通用', '会话结束', '感谢您的咨询，如有其他问题随时联系，祝您购物愉快！', 1, 0, '2026-03-15 10:20:00', '2026-03-15 10:20:00');
