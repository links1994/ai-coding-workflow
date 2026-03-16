# Mapper 接口代码示例

> **规范参考**：[数据访问规范](../../../../.qoder/rules/code-generation/07-data-access-standards.md)
> **DoD检查**：[DoD检查卡](../../../../.qoder/rules/code-generation/10-dod-cards.md#8-mapper-xml-dod-检查)
> **模板规范**：[代码模板规范](../../../../.qoder/rules/code-generation/13-code-templates.md#24-mapper-接口模板)

## 代码结构示例

```java
package com.aim.mall.{service}.mapper;

import com.aim.mall.{service}.domain.dto.{Name}PageQuery;
import com.aim.mall.{service}.domain.dto.{Name}Query;
import com.aim.mall.{service}.domain.entity.Aim{Name}DO;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface Aim{Name}Mapper extends BaseMapper<Aim{Name}DO> {

    /**
     * 根据ID查询（包含已删除）
     */
    Aim{Name}DO selectById(@Param("id") Long id);

    /**
     * 根据名称查询
     */
    Aim{Name}DO selectByName(@Param("name") String name);

    /**
     * 根据条件查询列表
     */
    List<Aim{Name}DO> selectListByCondition(@Param("query") {Name}Query query);

    /**
     * 分页查询
     */
    List<Aim{Name}DO> selectPage(@Param("query") {Name}PageQuery query);

    /**
     * 根据条件计数
     */
    long countByCondition(@Param("query") {Name}Query query);

    /**
     * 根据名称计数（用于校验重复）
     */
    long countByName(@Param("name") String name, @Param("excludeId") Long excludeId);
}
```

## 命名规则

| 元素 | 命名规范 | 示例 |
|------|---------|------|
| Mapper 接口 | `Aim{Name}Mapper` | `AimAgentJobTypeMapper` |
| 包路径 | `mapper/` | `mapper/AimJobTypeMapper.java` |
| 查询单条 | `selectByXxx` | `selectByName` |
| 查询列表 | `selectListByXxx` | `selectListByCondition` |
| 分页查询 | `selectPage` | `selectPage` |
| 计数 | `countByXxx` | `countByCondition` |
