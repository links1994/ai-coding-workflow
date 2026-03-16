# DO 实体模板

## 约束清单（DoD）

- [ ] 类名严格遵循 `Aim{Name}DO` 格式：必须以 `Aim` 开头，以 `DO` 结尾
- [ ] 类名与表名对应：表名 `aim_{模块}_{业务名}` → 类名 `Aim{模块首字母大驼峰}{业务名首字母大驼峰}DO`
- [ ] **禁止**在 DO 类上标注 `@JsonFormat`（DO 不涉及序列化给前端）
- [ ] **禁止**在 DO 类或对应的 `AimXxxServiceImpl` 上标注 `@Transactional`
- [ ] 使用 `@Data` 注解（或 `@Getter`/`@Setter`）
- [ ] 必须继承 `BaseDO`（包含 id、createTime、updateTime 等基础字段）
- [ ] 包含所有基础通用字段：`id`（BIGINT 自增主键）、`createTime`、`updateTime`
- [ ] `status` 字段使用 `StatusEnum`（`1=启用`，`0=禁用`），**禁止**直接使用魔法数字 0/1
- [ ] 删除字段按删除策略选择：`isDeleted`（软删除）、`deletedAt`（时间戳软删除）、无（物理删除）、`isActive`（配置表停用）
- [ ] 对应 Mapper 命名：`Aim{Name}Mapper`
- [ ] 对应 MP Service 命名：`Aim{Name}Service` / `Aim{Name}ServiceImpl`

## 代码模板

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
