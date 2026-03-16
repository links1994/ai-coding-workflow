---
trigger: model_decision
description: 数据库与实体规范 - 生成 DO 实体/建表 SQL/错误码枚举时适用
globs: [ "**/*.java", "**/*.sql" ]
---

# 数据库与实体规范

> **适用范围**：数据库表设计、DO 实体类生成、建表 SQL 生成

---

## 1. 表命名规范

**格式**：`aim_{模块}_{业务名}`（全小写，下划线分隔）

**示例**：
- `{table_name}`（{业务实体}表）
- `{table_name_2}`（{业务大类}表）
- `aim_{domain}_configs`（配置表）

---

## 2. DO 类命名规范

**强制格式**：`Aim{Name}DO`

- 必须以 `Aim` 开头，以 `DO` 结尾
- 中间部分为表业务名的大驼峰转换

| 表名 | DO 类名 |
|------|---------|
| `{table_name}` | `Aim{Domain}{Name}DO` |
| `{table_name_2}` | `Aim{Name}DO` |

---

## 3. 通用字段要求

所有业务表**必须**包含以下基础字段：

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | BIGINT PRIMARY KEY AUTO_INCREMENT | 主键，自增 |
| `create_time` | DATETIME DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| `update_time` | DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间，自动更新 |
| `creator_id` | BIGINT NULLABLE | 创建人 ID（可选） |
| `updater_id` | BIGINT NULLABLE | 更新人 ID（可选） |

**字符集**：统一使用 `DEFAULT CHARSET=utf8mb4`

---

## 4. 删除策略选择

表的删除机制须根据业务场景综合评估，**禁止**对所有表一律套用软删除。

### 4.1 删除策略分类

| 策略 | 删除字段 | 适用场景 |
|------|----------|----------|
| **软删除（审计型）** | `is_deleted TINYINT DEFAULT 0` | 需要审计溯源、数据恢复、关联数据完整性保护 |
| **时间戳软删除** | `deleted_at DATETIME NULL` | 同软删除场景，且需精确记录删除时间 |
| **物理删除** | 无删除字段 | 临时/缓存数据、GDPR强制合规、存储成本敏感场景 |
| **停用机制** | `is_active TINYINT DEFAULT 1` | 被其他表外键引用的配置类主数据表 |

### 4.2 策略选择决策流程

```
该表是被其他表外键引用的配置/主数据表？
  YES → 使用停用机制（is_active），删除用物理删除
  NO  ↓
数据是否需要审计溯源 / 有恢复价值 / 存在外键级联风险？
  YES → 使用软删除（优先选择 deleted_at，次选 is_deleted）
  NO  ↓
是否为临时/缓存数据 或 GDPR 强制物理清除？
  YES → 使用物理删除
  NO  → 默认使用软删除（is_deleted）
```

### 4.3 软删除字段规范

**`is_deleted` 方案**：
- 字段类型：`TINYINT DEFAULT 0`
- 注释：`COMMENT '逻辑删除：0-未删除 1-已删除'`
- Java DO 中使用枚举，**禁止**直接使用魔法数字
- 查询 SQL 必须包含过滤条件：`WHERE is_deleted = 0`

**`deleted_at` 方案**：
- 字段类型：`DATETIME NULL DEFAULT NULL`
- 注释：`COMMENT '删除时间，NULL 表示未删除'`
- Java DO 中使用 `LocalDateTime`
- 查询 SQL 必须包含过滤条件：`WHERE deleted_at IS NULL`

---

## 5. 字段类型映射

| SQL 类型 | Java 类型 | 说明 |
|----------|-----------|------|
| BIGINT | Long | 主键、ID、大整数 |
| INT | Integer | 普通整数、状态码 |
| TINYINT | Integer | 小范围整数（0/1 状态） |
| VARCHAR(n) | String | 字符串，需指定长度 |
| TEXT | String | 长文本 |
| DATETIME | LocalDateTime | 日期时间 |
| DATE | LocalDate | 日期 |
| DECIMAL(p,s) | BigDecimal | 金额、精确小数 |
| JSON | String / Object | JSON 数据 |

---

## 6. 索引规范

### 6.1 索引命名

| 索引类型 | 命名格式 | 示例 |
|----------|----------|------|
| 主键 | PRIMARY | PRIMARY |
| 唯一索引 | `uk_{字段名}` | `uk_name` |
| 普通索引 | `idx_{字段名}` | `idx_status` |
| 联合索引 | `idx_{字段1}_{字段2}` | `idx_tenant_id_name` |

### 6.2 索引设计原则

- 主键必须建立索引
- 外键字段必须建立索引
- 高频查询条件字段考虑建立索引
- 区分度低的字段（如状态字段只有0/1）谨慎建立索引
- 联合索引遵循最左前缀原则

---

## 7. 建表示例

**业务表（软删除 is_deleted 方案）**：

```sql
-- 先删除已存在的表（谨慎使用，生产环境请评估）
DROP TABLE IF EXISTS `{table_name}`;

-- 创建新表
CREATE TABLE IF NOT EXISTS `{table_name}` (
    `id`          BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `name`        VARCHAR(100) NOT NULL COMMENT '{参数名}',
    `description` VARCHAR(200) COMMENT '{业务实体}描述',
    `sort_order`  INT DEFAULT 0 COMMENT '排序值',
    `status`      TINYINT DEFAULT 1 COMMENT '状态：0-禁用 1-启用',
    `is_deleted`  TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除 1-已删除',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `creator_id`  BIGINT COMMENT '创建人ID',
    `updater_id`  BIGINT COMMENT '更新人ID',
    
    INDEX idx_status (status),
    INDEX idx_sort_order (sort_order),
    UNIQUE KEY uk_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='{业务实体}表';
```

**强制要求**：
- 所有建表 SQL 必须包含 `DROP TABLE IF EXISTS \`table_name\`;`
- 使用反引号包裹表名和字段名，防止关键字冲突
- `CREATE TABLE` 使用 `IF NOT EXISTS` 避免重复创建错误

---

## 8. DO 实体类规范

### 8.1 类定义

```java
@Data
@TableName("{table_name}")
public class Aim{Domain}{Name}DO extends BaseDO {
    
    @TableField("name")
    private String name;
    
    @TableField("description")
    private String description;
    
    @TableField("sort_order")
    private Integer sortOrder;
    
    @TableField("status")
    private Integer status;
    
    @TableField("is_deleted")
    private Integer isDeleted;
}
```

### 8.2 强制约束

- 必须继承 `BaseDO`（包含 id、createTime、updateTime 等基础字段）
- 必须使用 `@TableName` 注解指定表名
- 字段使用驼峰命名，与数据库下划线命名自动映射
- **禁止**在 DO 上使用 `@JsonFormat` 注解（DO 不直接返回给前端）
- 软删除字段使用 `DeleteStatusEnum`，禁止魔法数字

---

## 9. 术语定义

### 9.1 软删除（Audit Deletion）

使用 `is_deleted` 或 `deleted_at` 字段标记记录已删除，数据保留在表中。

适用场景：需要审计溯源、数据恢复、关联数据完整性保护。

### 9.2 物理删除（Physical Deletion）

直接从数据库中删除记录。

适用场景：临时/缓存数据、GDPR强制合规、存储成本敏感场景。

### 9.3 停用机制（Deactivation）

使用 `is_active` 字段标记记录是否启用，适用于配置类主数据表。

适用场景：被其他表外键引用的配置/主数据表。
