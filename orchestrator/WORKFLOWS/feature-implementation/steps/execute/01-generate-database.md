# Step: 生成数据库结构

## 目的
根据 tech-spec 中的数据模型定义，生成数据库表结构和实体类。

## 输入
- `tech_spec`: 技术规格书（包含数据模型章节）
- `generation_plan`: 代码生成计划

## 输出
- `database_schema`: 数据库表结构定义
- `entity_classes`: Entity/DO 类文件
- `test_data_sql`: 测试数据 SQL

## 执行步骤

### 1. 解析数据模型

从 tech-spec 中提取：
- 表名（如：{table_name}）
- 字段定义（名称、类型、约束、注释）
- 索引定义
- 表关联关系

### 2. 生成建表 SQL

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

### 3. 生成 Entity/DO 类

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

### 4. 生成测试数据

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

## 输出文件

```
outputs/
├── data/
│   └── sql/
│       └── {table_name}.sql
└── generated/
    └── {app-service}/
        └── domain/
            └── entity/
                └── Aim{Name}DO.java
```

## 约束检查

- [ ] 表名符合 `aim_{模块}_{业务名}` 规范
- [ ] 包含基础字段：id, create_time, update_time
- [ ] 字符集为 utf8mb4
- [ ] 所有字段有注释
- [ ] 外键字段有索引
- [ ] DO 类继承 BaseDO
- [ ] DO 类名以 Aim 开头，以 DO 结尾

## 错误处理

- 表已存在：提示用户确认是否覆盖
- 字段类型不支持：报错并列出支持的类型
- 缺少必填字段：列出缺失字段并要求补充
