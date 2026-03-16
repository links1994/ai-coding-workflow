-- ========================================================
-- 表名: aim_agent_product
-- 功能: F-004 代理商品配置
-- 服务: mall-agent-employee-service
-- 删除策略: 物理删除
-- 生成时间: 2026-03-16
-- ========================================================

-- --------------------------------------------------------
-- 建表语句
-- --------------------------------------------------------
DROP TABLE IF EXISTS `aim_agent_product`;
CREATE TABLE IF NOT EXISTS `aim_agent_product` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `spu_code` VARCHAR(64) NOT NULL COMMENT 'SPU编码',
    `spu_name` VARCHAR(255) NOT NULL COMMENT 'SPU名称',
    `backend_category_id` BIGINT NOT NULL COMMENT '后台类目ID',
    `backend_category_name` VARCHAR(128) NOT NULL COMMENT '后台类目名称',
    `price` DECIMAL(10,2) NOT NULL COMMENT '商品价格',
    `agent_status` TINYINT NOT NULL DEFAULT 0 COMMENT '代理状态：0-未代理 1-已代理',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_spu_code` (`spu_code`),
    KEY `idx_backend_category_id` (`backend_category_id`),
    KEY `idx_agent_status` (`agent_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='代理商品池表';

-- --------------------------------------------------------
-- 测试数据
-- --------------------------------------------------------
INSERT INTO `aim_agent_product` (`id`, `spu_code`, `spu_name`, `backend_category_id`, `backend_category_name`, `price`, `agent_status`, `create_time`, `update_time`) VALUES
(1, 'SPU2024000001', 'iPhone 15 Pro Max 256GB', 1001, '手机数码', 9999.00, 1, '2026-03-15 10:00:00', '2026-03-15 10:00:00'),
(2, 'SPU2024000002', 'MacBook Pro 14英寸 M3', 1002, '电脑办公', 14999.00, 1, '2026-03-15 10:05:00', '2026-03-15 10:05:00'),
(3, 'SPU2024000003', 'AirPods Pro 2代', 1003, '数码配件', 1899.00, 1, '2026-03-15 10:10:00', '2026-03-15 10:10:00'),
(4, 'SPU2024000004', 'iPad Air 5', 1004, '平板电脑', 4799.00, 0, '2026-03-15 10:15:00', '2026-03-15 10:15:00'),
(5, 'SPU2024000005', 'Apple Watch Series 9', 1005, '智能穿戴', 2999.00, 1, '2026-03-15 10:20:00', '2026-03-15 10:20:00');
