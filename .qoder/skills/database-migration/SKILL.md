---
name: database-migration
description: 生成数据库结构变更脚本（ALTER TABLE），管理数据库版本迁移。当表结构需要变更（新增字段、修改字段、添加索引等）时使用，支持版本控制和回滚脚本生成。
version: 1.0.0
workflow: feature-implementation
dependencies: []
---

# 数据库迁移 Skill

生成数据库结构变更脚本，管理数据库版本迁移。

---

## 触发条件

- 用户指令："生成迁移脚本"、"数据库变更"、"ALTER TABLE"
- 表结构需要变更时（新增字段、修改字段、添加索引）
- tech-spec 中数据模型与现有表结构不一致时

---

## 前置依赖（必须读取）

| 文件 | 路径 | 说明 |
|------|------|------|
| 数据库规范 | `.qoder/rules/code-generation/05-database-standards.md` | 表设计、字段类型规范 |
| 现有表结构 | `outputs/data/sql/{table_name}.sql` | 当前表结构定义 |
| 新的数据模型 | `workspace/outputs/tech-spec.md` | 新的表结构定义 |
| 命名规范 | `.qoder/rules/code-generation/04-naming-standards.md` | 字段命名规范 |

---

## 输入

| 输入项 | 类型 | 说明 |
|--------|------|------|
| table_name | string | 表名 |
| current_schema | file | 当前表结构 SQL 文件 |
| new_schema | object | 新的表结构定义 |
| change_type | string | 变更类型（add_column/modify_column/add_index等）|

---

## 输出

| 输出项 | 路径 | 说明 |
|--------|------|------|
| migration_script | `outputs/data/sql/migrations/{timestamp}_{table_name}_{change_type}.sql` | 迁移脚本 |
| rollback_script | `outputs/data/sql/migrations/{timestamp}_{table_name}_{change_type}_rollback.sql` | 回滚脚本 |
| migration_log | `outputs/data/sql/migrations/migration-log.yml` | 迁移日志 |

---

## 支持的变更类型

### 1. 新增字段（ADD COLUMN）

```sql
-- 迁移脚本
ALTER TABLE `aim_xxx_table` 
ADD COLUMN `new_field` VARCHAR(100) NOT NULL DEFAULT '' COMMENT '新字段';

-- 回滚脚本
ALTER TABLE `aim_xxx_table` 
DROP COLUMN `new_field`;
```

### 2. 修改字段（MODIFY COLUMN）

```sql
-- 迁移脚本
ALTER TABLE `aim_xxx_table` 
MODIFY COLUMN `existing_field` VARCHAR(200) NOT NULL COMMENT '修改后的字段说明';

-- 回滚脚本（需要保存原字段定义）
ALTER TABLE `aim_xxx_table` 
MODIFY COLUMN `existing_field` VARCHAR(100) NOT NULL COMMENT '原字段说明';
```

### 3. 添加索引（ADD INDEX）

```sql
-- 迁移脚本
ALTER TABLE `aim_xxx_table` 
ADD INDEX `idx_field_name` (`field_name`);

-- 或唯一索引
ALTER TABLE `aim_xxx_table` 
ADD UNIQUE INDEX `uk_field_name` (`field_name`);

-- 回滚脚本
ALTER TABLE `aim_xxx_table` 
DROP INDEX `idx_field_name`;
```

### 4. 删除字段（DROP COLUMN）

```sql
-- 迁移脚本
ALTER TABLE `aim_xxx_table` 
DROP COLUMN `obsolete_field`;

-- 回滚脚本（需要保存完整字段定义）
ALTER TABLE `aim_xxx_table` 
ADD COLUMN `obsolete_field` VARCHAR(100) COMMENT '已删除的字段';
```

### 5. 重命名字段（CHANGE COLUMN）

```sql
-- 迁移脚本
ALTER TABLE `aim_xxx_table` 
CHANGE COLUMN `old_name` `new_name` VARCHAR(100) NOT NULL COMMENT '字段说明';

-- 回滚脚本
ALTER TABLE `aim_xxx_table` 
CHANGE COLUMN `new_name` `old_name` VARCHAR(100) NOT NULL COMMENT '字段说明';
```

---

## 工作流程

### 步骤 1：读取表结构

1. 读取当前表结构（从现有 SQL 文件）
2. 读取新的表结构定义（从 tech-spec）
3. 对比差异

### 步骤 2：生成差异分析

对比当前表结构和新表结构，识别变更：

```yaml
differences:
  added_columns:
    - name: new_field
      type: VARCHAR(100)
      nullable: false
      default: ''
      comment: '新字段'
  
  modified_columns:
    - name: existing_field
      old_type: VARCHAR(100)
      new_type: VARCHAR(200)
      old_comment: '原说明'
      new_comment: '新说明'
  
  added_indexes:
    - name: idx_new_field
      type: index
      fields: [new_field]
  
  dropped_columns:
    - name: obsolete_field
      type: VARCHAR(100)
      comment: '已删除字段'
```

### 步骤 3：生成迁移脚本

基于差异分析生成迁移脚本：

**脚本头部注释：**
```sql
-- ========================================================
-- Migration Script
-- Program: {P-YYYY-NNN}
-- Table: {table_name}
-- Generated At: {YYYY-MM-DD HH:mm:ss}
-- Change Type: {change_type}
-- ========================================================
```

**脚本内容：**
- 按依赖顺序排列 ALTER 语句
- 先添加字段，再添加索引
- 删除操作放在最后

### 步骤 4：生成回滚脚本

为每个变更生成对应的回滚操作：

**回滚脚本头部：**
```sql
-- ========================================================
-- Rollback Script
-- Program: {P-YYYY-NNN}
-- Table: {table_name}
-- Generated At: {YYYY-MM-DD HH:mm:ss}
-- Change Type: {change_type}
-- ========================================================
```

**回滚策略：**
- 新增字段 → 删除字段
- 修改字段 → 恢复原字段定义
- 添加索引 → 删除索引
- 删除字段 → 重新添加字段（需保存完整定义）

### 步骤 5：更新迁移日志

记录迁移信息到 migration-log.yml：

```yaml
migrations:
  - id: {timestamp}
    program: P-YYYY-NNN
    table: {table_name}
    change_type: {type}
    script_path: migrations/{timestamp}_{table_name}_{type}.sql
    rollback_path: migrations/{timestamp}_{table_name}_{type}_rollback.sql
    generated_at: {YYYY-MM-DD HH:mm:ss}
    status: pending
    executed_at: null
    executed_by: null
```

---

## 命名规范

### 迁移脚本命名

```
{timestamp}_{table_name}_{change_type}.sql
```

- `timestamp`: YYYYMMDDHHMMSS 格式
- `table_name`: 表名（不含 aim_ 前缀）
- `change_type`: add_column / modify_column / add_index / drop_column / change_name

**示例：**
- `20260317143000_job_type_add_column.sql`
- `20260317143500_job_type_add_index.sql`

### 回滚脚本命名

```
{timestamp}_{table_name}_{change_type}_rollback.sql
```

---

## 安全约束

### 危险操作检查

以下操作需要额外确认：

| 操作 | 危险等级 | 确认要求 |
|------|----------|----------|
| DROP COLUMN | 高 | 必须确认数据已备份 |
| DROP INDEX | 中 | 确认无查询依赖 |
| MODIFY COLUMN（缩小长度） | 高 | 确认数据不会截断 |
| MODIFY COLUMN（改变类型） | 高 | 确认数据可转换 |

### 数据备份建议

执行迁移前建议备份：

```sql
-- 创建备份表
CREATE TABLE `aim_xxx_table_backup_{timestamp}` LIKE `aim_xxx_table`;
INSERT INTO `aim_xxx_table_backup_{timestamp}` SELECT * FROM `aim_xxx_table`;
```

---

## 返回格式

执行完成后返回以下格式：

```
状态：已完成

变更分析：
  - 新增字段：N 个
  - 修改字段：N 个
  - 添加索引：N 个
  - 删除字段：N 个
  - 重命名字段：N 个

产出：
  - 迁移脚本：outputs/data/sql/migrations/{timestamp}_{table}_{type}.sql
  - 回滚脚本：outputs/data/sql/migrations/{timestamp}_{table}_{type}_rollback.sql
  - 迁移日志：outputs/data/sql/migrations/migration-log.yml

安全检查：
  - 危险操作：N 个（已标记）
  - 建议备份：是 / 否

执行建议：
  1. 先执行回滚脚本验证（测试环境）
  2. 备份生产数据
  3. 执行迁移脚本
  4. 验证变更结果
```

---

## 相关文档

- 数据库规范：`.qoder/rules/code-generation/05-database-standards.md`
- 命名规范：`.qoder/rules/code-generation/04-naming-standards.md`
- 代码生成 Skill：`.qoder/skills/java-code-generation/SKILL.md`
