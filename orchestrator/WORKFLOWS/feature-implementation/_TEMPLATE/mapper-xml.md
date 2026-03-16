# Mapper XML 代码示例

> **规范参考**：[数据访问规范](../../../../.qoder/rules/code-generation/07-data-access-standards.md)
> **DoD检查**：[DoD检查卡](../../../../.qoder/rules/code-generation/10-dod-cards.md#8-mapper-xml-dod-检查)
> **模板规范**：[代码模板规范](../../../../.qoder/rules/code-generation/13-code-templates.md#25-mapper-xml-模板)

## 代码结构示例

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.aim.mall.{service}.mapper.Aim{Name}Mapper">

    <!-- 结果映射 -->
    <resultMap id="BaseResultMap" type="com.aim.mall.{service}.domain.entity.Aim{Name}DO">
        <id column="id" property="id"/>
        <result column="name" property="name"/>
        <result column="description" property="description"/>
        <result column="sort_order" property="sortOrder"/>
        <result column="status" property="status"/>
        <result column="is_deleted" property="isDeleted"/>
        <result column="create_time" property="createTime"/>
        <result column="update_time" property="updateTime"/>
        <result column="creator_id" property="creatorId"/>
        <result column="updater_id" property="updaterId"/>
    </resultMap>

    <!-- 基础列 -->
    <sql id="Base_Column_List">
        id, name, description, sort_order, status, is_deleted, 
        create_time, update_time, creator_id, updater_id
    </sql>

    <!-- 根据ID查询 -->
    <select id="selectById" resultMap="BaseResultMap">
        SELECT
        <include refid="Base_Column_List"/>
        FROM aim_{module}_{name}
        WHERE id = #{id}
          AND is_deleted = 0
    </select>

    <!-- 根据名称查询 -->
    <select id="selectByName" resultMap="BaseResultMap">
        SELECT
        <include refid="Base_Column_List"/>
        FROM aim_{module}_{name}
        WHERE name = #{name}
          AND is_deleted = 0
    </select>

    <!-- 根据条件查询列表 -->
    <select id="selectListByCondition" resultMap="BaseResultMap">
        SELECT
        <include refid="Base_Column_List"/>
        FROM aim_{module}_{name}
        WHERE is_deleted = 0
        <if test="query.name != null and query.name != ''">
            AND name LIKE CONCAT('%', #{query.name}, '%')
        </if>
        <if test="query.status != null">
            AND status = #{query.status}
        </if>
        ORDER BY sort_order ASC, create_time DESC
    </select>

    <!-- 分页查询 -->
    <select id="selectPage" resultMap="BaseResultMap">
        SELECT
        <include refid="Base_Column_List"/>
        FROM aim_{module}_{name}
        WHERE is_deleted = 0
        <if test="query.name != null and query.name != ''">
            AND name LIKE CONCAT('%', #{query.name}, '%')
        </if>
        <if test="query.status != null">
            AND status = #{query.status}
        </if>
        ORDER BY sort_order ASC, create_time DESC
        LIMIT #{query.offset}, #{query.pageSize}
    </select>

    <!-- 根据条件计数 -->
    <select id="countByCondition" resultType="long">
        SELECT COUNT(*)
        FROM aim_{module}_{name}
        WHERE is_deleted = 0
        <if test="query.name != null and query.name != ''">
            AND name LIKE CONCAT('%', #{query.name}, '%')
        </if>
        <if test="query.status != null">
            AND status = #{query.status}
        </if>
    </select>

    <!-- 根据名称计数（用于校验重复） -->
    <select id="countByName" resultType="long">
        SELECT COUNT(*)
        FROM aim_{module}_{name}
        WHERE name = #{name}
          AND is_deleted = 0
        <if test="excludeId != null">
          AND id != #{excludeId}
        </if>
    </select>

</mapper>
```

## 命名规则

| 元素 | 命名规范 | 示例 |
|------|---------|------|
| 文件名 | `Aim{Name}Mapper.xml` | `AimAgentJobTypeMapper.xml` |
| 文件位置 | `resources/mapper/` | `resources/mapper/AimJobTypeMapper.xml` |
| namespace | Mapper 接口全限定名 | `com.aim.mall.agent.employee.mapper.AimJobTypeMapper` |
| resultMap | `BaseResultMap` | `BaseResultMap` |
| SQL片段 | `Base_Column_List` | `Base_Column_List` |
