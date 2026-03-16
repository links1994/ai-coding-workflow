# DO 实体代码示例

> **规范参考**：[数据库规范](../../../../.qoder/rules/code-generation/05-database-standards.md)
> **DoD检查**：[DoD检查卡](../../../../.qoder/rules/code-generation/10-dod-cards.md#5-do-实体-dod-检查)
> **模板规范**：[代码模板规范](../../../../.qoder/rules/code-generation/13-code-templates.md#23-do-实体模板)

## 代码结构示例

```java
package com.aim.mall.{service}.domain.entity;

import com.aim.mall.common.core.entity.BaseDO;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("aim_{module}_{name}")
public class Aim{Name}DO extends BaseDO {

    private static final long serialVersionUID = 1L;

    /** 名称 */
    @TableField("name")
    private String name;

    /** 描述 */
    @TableField("description")
    private String description;

    /** 排序值 */
    @TableField("sort_order")
    private Integer sortOrder;

    /** 状态：0-禁用 1-启用 */
    @TableField("status")
    private Integer status;

    /** 逻辑删除：0-未删除 1-已删除 */
    @TableField("is_deleted")
    private Integer isDeleted;

    /** 创建人ID */
    @TableField("creator_id")
    private Long creatorId;

    /** 更新人ID */
    @TableField("updater_id")
    private Long updaterId;
}
```

## 对应建表 SQL 模板

```sql
CREATE TABLE aim_{module}_{name}
(
    id          BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '主键ID',
    name        VARCHAR(100) NOT NULL COMMENT '名称',
    description VARCHAR(200) COMMENT '描述',
    sort_order  INT DEFAULT 0 COMMENT '排序值',
    status      TINYINT DEFAULT 1 COMMENT '状态：0-禁用 1-启用',
    is_deleted  TINYINT DEFAULT 0 COMMENT '逻辑删除：0-未删除 1-已删除',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    creator_id  BIGINT COMMENT '创建人ID',
    updater_id  BIGINT COMMENT '更新人ID',
    
    INDEX idx_status (status),
    INDEX idx_sort_order (sort_order),
    UNIQUE KEY uk_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='{表注释}';
```

## 命名规则

| 元素 | 命名规范 | 示例 |
|------|---------|------|
| DO 类名 | `Aim{Name}DO` | `AimAgentJobTypeDO` |
| 对应表名 | `aim_{module}_{name}` | `aim_agent_job_type` |
| MP Service | `Aim{Name}Service` | `AimAgentJobTypeService` |
| MP ServiceImpl | `Aim{Name}ServiceImpl` | `AimAgentJobTypeServiceImpl` |
| Mapper | `Aim{Name}Mapper` | `AimAgentJobTypeMapper` |
| DO 包路径 | `domain/entity/` | `domain/entity/AimJobTypeDO.java` |
