# Schema: aim_agent_job_type

## 表信息

| 属性 | 值 |
|------|-----|
| 表名 | aim_agent_job_type |
| 中文名 | 岗位类型表 |
| 所属服务 | mall-agent-employee-service |
| 删除策略 | 物理删除 |
| 设计 Feature | F-001 |

## 表结构

| 字段名 | 类型 | 可空 | 默认值 | 说明 |
|--------|------|------|--------|------|
| id | BIGINT | 否 | AUTO_INCREMENT | 主键ID |
| name | VARCHAR(64) | 否 | - | 岗位类型名称 |
| code | VARCHAR(32) | 否 | - | 岗位类型编码（系统生成） |
| description | VARCHAR(255) | 是 | NULL | 岗位描述 |
| status | TINYINT | 否 | 1 | 状态：0-禁用 1-启用 |
| sort_order | INT | 否 | 0 | 排序号 |
| create_time | DATETIME | 否 | CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | 否 | CURRENT_TIMESTAMP | 更新时间 |
| creator_id | BIGINT | 是 | NULL | 创建人ID |
| updater_id | BIGINT | 是 | NULL | 更新人ID |

## 索引

| 索引名 | 字段 | 类型 |
|--------|------|------|
| uk_code | code | UNIQUE |
| idx_status | status | INDEX |
| idx_sort_order | sort_order | INDEX |

## 建表 SQL

```sql
CREATE TABLE aim_agent_job_type
(
    id          BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    name        VARCHAR(64)  NOT NULL COMMENT '岗位类型名称',
    code        VARCHAR(32)  NOT NULL COMMENT '岗位类型编码',
    description VARCHAR(255) COMMENT '岗位描述',
    status      TINYINT      DEFAULT 1 COMMENT '状态：0-禁用 1-启用',
    sort_order  INT          DEFAULT 0 COMMENT '排序号',
    create_time DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    creator_id  BIGINT COMMENT '创建人ID',
    updater_id  BIGINT COMMENT '更新人ID',
    UNIQUE INDEX uk_code (code),
    INDEX idx_status (status),
    INDEX idx_sort_order (sort_order)
) COMMENT '岗位类型表'
    DEFAULT CHARSET = utf8mb4;
```

## 变更历史

| 版本 | 日期 | Program | 变更说明 |
|------|------|---------|----------|
| 1.0 | 2026-03-08 | P-2026-001-F-001 | 初始建表 |
