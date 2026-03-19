# Step: 生成数据库结构

## 目的
根据 tech-spec 中的数据模型定义，生成**建表 SQL**、**测试数据 SQL** 和 **Entity/DO 类**。

> **重要**：本步骤是数据库结构和 Entity 类的**唯一生成来源**。
> - SQL 文件和 Entity/DO 类必须在本步骤中**实际写入磁盘**。
> - 后续 `generate_application_layer` 步骤**直接引用**本步骤的产物，不会重复生成。

## 输入
- `tech_spec`: 技术规格书（包含数据模型章节）
- `generation_plan`: 代码生成计划

## 输出（必须全部完成）
- `database_schema`: 建表 SQL 文件（`outputs/data/sql/{table_name}.sql`）
- `entity_classes`: Entity/DO 类文件（`{app-service}/domain/entity/Aim{Name}DO.java`）
- `test_data_sql`: 测试数据 SQL（内嵌在建表 SQL 文件末尾）

## 执行步骤（必须按顺序完成，每步均需实际写入文件）

### 1. 解析数据模型

从 tech-spec 中提取：
- 表名（如：{table_name}）
- 字段定义（名称、类型、约束、注释）
- 索引定义
- 表关联关系

### 2. 生成建表 SQL（必须写入文件：`outputs/data/sql/{table_name}.sql`）

**命名规范**：`{table_name}.sql`

**SQL 内容**：
```sql
DROP TABLE IF EXISTS `{table_name}`;

CREATE TABLE IF NOT EXISTS `{table_name}` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    `name` VARCHAR(50) NOT NULL COMMENT '名称',
    `description` VARCHAR(200) DEFAULT NULL COMMENT '描述',
    `sort_order` INT DEFAULT 0 COMMENT '排序值',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用 1-启用',
    `is_deleted` TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除 1-已删除',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `creator_id` BIGINT DEFAULT NULL COMMENT '创建人ID',
    `updater_id` BIGINT DEFAULT NULL COMMENT '更新人ID',
    INDEX `idx_status` (`status`),
    INDEX `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='{Name}表';
```

### 3. 生成测试数据 SQL（追加到建表 SQL 文件末尾）

每个表至少生成 3 条测试数据：
- 正常数据
- 边界数据
- 特殊场景数据

```sql
-- 测试数据
INSERT INTO `{table_name}` (`name`, `description`, `sort_order`, `status`) VALUES
('测试数据1', '描述1', 1, 1),
('测试数据2', '描述2', 2, 1),
('测试数据3', '描述3', 3, 1);
```

> **说明**：测试数据 SQL 追加在建表 SQL 文件末尾，统一写入 `outputs/data/sql/{table_name}.sql`。

### 4. 生成 Entity/DO 类（必须写入文件：`{app-service}/domain/entity/Aim{Name}DO.java`）

**命名规范**：`Aim{Name}DO`

**类结构**：
```java
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("{table_name}")
public class Aim{Name}DO extends BaseDO {
    
    private static final long serialVersionUID = 1L;
    
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
    
    @TableField("creator_id")
    private Long creatorId;
    
    @TableField("updater_id")
    private Long updaterId;
}
```



## 输出文件（本步骤必须生成以下所有文件）

```
outputs/
└── data/
    └── sql/
        └── {table_name}.sql          ← 建表 SQL + 测试数据 SQL

repos/{app-service}/src/main/java/{package}/domain/entity/
└── Aim{Name}DO.java                  ← Entity/DO 类
```

> **检查点**：本步骤结束后，上述文件必须已实际写入磁盘，否则视为步骤未完成。

## 约束检查

**SQL 文件**：
- [ ] SQL 文件已写入 `outputs/data/sql/{table_name}.sql`
- [ ] 包含 `DROP TABLE IF EXISTS` 语句
- [ ] 包含 `CREATE TABLE IF NOT EXISTS` 语句
- [ ] 表名符合 `aim_{模块}_{业务名}` 规范
- [ ] 字符集为 `utf8mb4`，**不指定 COLLATE**
- [ ] 包含基础字段：`id`、`create_time`、`update_time`
- [ ] 所有字段有 `COMMENT`
- [ ] 外键字段已建索引
- [ ] 至少包含 3 条测试数据 INSERT 语句

**Entity/DO 文件**：
- [ ] DO 类文件已写入对应服务的 `domain/entity/` 目录
- [ ] DO 类名以 `Aim` 开头，以 `DO` 结尾
- [ ] 继承 `BaseDO`
- [ ] 有 `@TableName("{table_name}")` 注解
- [ ] `status` 字段存在时使用 `StatusEnum`，**禁止**魔法数字
- [ ] **禁止**在 DO 类上标注 `@JsonFormat`
- [ ] **禁止**在对应的 `Aim{Name}ServiceImpl` 上标注 `@Transactional`

## 错误处理

- 表已存在：提示用户确认是否覆盖
- 字段类型不支持：报错并列出支持的类型
- 缺少必填字段：列出缺失字段并要求补充
