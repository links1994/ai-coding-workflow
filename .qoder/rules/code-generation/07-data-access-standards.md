---
trigger: model_decision
description: 数据访问规范 - 生成 QueryService/ManageService/Mapper/XML 时适用
globs: [ "**/*.java", "**/*.xml" ]
---

# 数据访问规范（MyBatis-Plus 使用规范）

> **适用范围**：QueryService、ManageService、Mapper、XML 生成

---

## 1. MyBatis-Plus 使用原则

| 操作类型 | 实现方式 | 说明 |
|----------|----------|------|
| **增删改** | MyBatis-Plus IService 方法 | 使用 `save()` / `updateById()` / `removeById()` |
| **所有查询** | 原生 MyBatis XML | **禁止**使用任何 MP 查询方法 |

**禁止使用的 MP 查询方法**：`getById()`, `list()`, `page()`, `lambdaQuery()`, `QueryWrapper`, `LambdaQueryWrapper` 等所有查询相关 API。

---

## 2. Service 层调用链与职责约束

### 2.1 调用链总览

```
{Name}ApplicationService（编排层）
    ↓ 只允许调用 {Name}QueryService（查询） 或 {Name}ManageService（增删改）
    ↓ 禁止直接调用 Aim{Name}Service 或 Aim{Name}Mapper

{Name}QueryService / {Name}ManageService（数据访问层，二选一模式）
    ├── 模式 A：注入 Aim{Name}Service 接口（位于 service/mp/）
    │       增删改 → 调用 MP 方法（save/updateById/removeById）
    │       查询   → 调用 Aim{Name}ServiceImpl.baseMapper.xxx()（XML 原生 SQL）
    └── 模式 B：注入 Aim{Name}Mapper（直接原生 SQL，增删改查均可）

Aim{Name}ServiceImpl（位于 service/impl/mp/，继承 ServiceImpl）
    增删改 → 使用 MP 方法
    查询   → 使用 this.baseMapper.xxx() 调用原生 SQL（XML 中定义）
```

### 2.2 核心约束

**ApplicationService 约束**：
- `{Name}ApplicationService` 必须通过 `{Name}QueryService` 执行查询操作
- `{Name}ApplicationService` 必须通过 `{Name}ManageService` 执行增删改操作
- `{Name}ApplicationService` **禁止**直接注入 `Aim{Name}Service` 或 `Aim{Name}Mapper`

**QueryService / ManageService 数据访问二选一原则**：

| 模式 | 注入对象 | 适用场景 |
|------|----------|----------|
| 模式 A | `Aim{Name}Service`（MP Service 接口） | 增删改使用 MP 封装方法，查询使用 XML 原生 SQL |
| 模式 B | `Aim{Name}Mapper`（原生 Mapper） | 全部操作使用原生 XML SQL，不需要 MP 封装方法 |

> **互斥规则**：`{Name}QueryService` / `{Name}ManageService` 在同一实现类中**禁止同时注入** `Aim{Name}Service` 和 `Aim{Name}Mapper`，必须二选一。

**`Aim{Name}Service`（MP Service）事务约束**：
- `Aim{Name}Service` / `Aim{Name}ServiceImpl` **严禁标注 `@Transactional`**
- 事务注解只允许标注在 `{Name}ManageService` 的实现方法上
- 理由：`Aim{Name}ServiceImpl` 方法通常被同类或上层代理调用，`@Transactional` 在此层标注易导致 Spring AOP 代理失效（自调用问题）

**其他禁止事项**：
- `QueryService` / `ManageService` 中调用 `aim{Name}Service.getBaseMapper()`
- `QueryService` / `ManageService` 中直接依赖 `Aim{Name}ServiceImpl`（实现类）
- `{Name}ApplicationService` 直接操作数据库（绕过 Query/ManageService）

---

## 3. 代码示例

### 3.1 模式 A：QueryService / ManageService 注入 Aim{Name}Service

```java
// Aim{Name}ServiceImpl：增删改用 MP，查询用 this.baseMapper 原生 SQL
// 严禁在此类标注 @Transactional
@Service
public class Aim{Name}ServiceImpl extends ServiceImpl<Aim{Name}Mapper, Aim{Name}DO>
        implements Aim{Name}Service {

    public Aim{Name}DO getByCode(String code) {
        return this.baseMapper.selectByCode(code); // 原生 SQL（XML 中定义）
    }
}

// QueryService：注入 Aim{Name}Service 接口（模式 A），禁止同时注入 Aim{Name}Mapper
@Service
@RequiredArgsConstructor
public class {Name}QueryServiceImpl implements {Name}QueryService {
    private final Aim{Name}Service aim{Name}Service; // 注入接口

    public Aim{Name}DO getByCode(String code) {
        // 查询走原生 SQL（XML）
        return ((Aim{Name}ServiceImpl) aim{Name}Service).getBaseMapper().selectByCode(code);
    }
}

// ManageService：注入 Aim{Name}Service 接口（模式 A），事务在此层管理
@Service
@RequiredArgsConstructor
public class {Name}ManageServiceImpl implements {Name}ManageService {
    private final Aim{Name}Service aim{Name}Service; // 注入接口

    @Transactional(rollbackFor = Exception.class)
    public Long create({Name}CreateApiRequest request) {
        // 增删改用 MP 方法
        Aim{Name}DO entity = convertToDO(request);
        aim{Name}Service.save(entity);
        return entity.getId();
    }
}
```

### 3.2 模式 B：QueryService / ManageService 直接注入 Aim{Name}Mapper

```java
// QueryService：直接注入 Aim{Name}Mapper（模式 B）
@Service
@RequiredArgsConstructor
public class {Name}QueryServiceImpl implements {Name}QueryService {
    private final Aim{Name}Mapper aim{Name}Mapper; // 直接注入 Mapper

    public Aim{Name}DO getByCode(String code) {
        return aim{Name}Mapper.selectByCode(code); // 原生 SQL
    }
}

// ManageService：直接注入 Aim{Name}Mapper（模式 B）
@Service
@RequiredArgsConstructor
public class {Name}ManageServiceImpl implements {Name}ManageService {
    private final Aim{Name}Mapper aim{Name}Mapper; // 直接注入 Mapper

    @Transactional(rollbackFor = Exception.class)
    public Long create({Name}CreateApiRequest request) {
        Aim{Name}DO entity = convertToDO(request);
        aim{Name}Mapper.insert(entity); // 原生 SQL
        return entity.getId();
    }
}
```

---

## 4. Mapper XML 规范

### 4.1 XML 文件位置

- 应用服务：`src/main/resources/mapper/Aim{Name}Mapper.xml`
- 基础数据服务：`src/main/resources/mapper/Aim{Name}Mapper.xml`

### 4.2 XML 基本结构

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="{base_package}.{domain}.employee.mapper.Aim{Name}Mapper">

    <!-- 结果映射 -->
    <resultMap id="BaseResultMap" type="{base_package}.{domain}.employee.domain.entity.Aim{Name}DO">
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

    <!-- 根据编码查询 -->
    <select id="selectByCode" resultMap="BaseResultMap">
        SELECT
        <include refid="Base_Column_List"/>
        FROM {table_name}
        WHERE code = #{code}
          AND is_deleted = 0
    </select>

    <!-- 分页查询 -->
    <select id="selectPage" resultMap="BaseResultMap">
        SELECT
        <include refid="Base_Column_List"/>
        FROM {table_name}
        WHERE is_deleted = 0
        <if test="keyword != null and keyword != ''">
            AND name LIKE CONCAT('%', #{keyword}, '%')
        </if>
        ORDER BY sort_order ASC, create_time DESC
    </select>

</mapper>
```

### 4.3 SQL 编写规范

- **必须**包含软删除过滤条件：`WHERE is_deleted = 0` 或 `WHERE deleted_at IS NULL`
- **必须**使用 `<include refid="Base_Column_List"/>` 避免硬编码列名
- 分页查询使用 MyBatis-Plus 的 `IPage` 参数
- 复杂查询优先使用 XML，避免在 Java 代码中拼接 SQL

---

## 5. 大表分页规范

对于数据量大的表（预估 > 100万条），分页查询必须遵循以下规范：

### 5.1 禁止深度分页

**禁止使用**：
```sql
-- 深度分页性能极差
SELECT * FROM {table_name} 
WHERE is_deleted = 0 
ORDER BY create_time DESC 
LIMIT 1000000, 20;
```

**推荐方案**：
- 使用游标分页（Cursor-based Pagination）
- 使用上次查询的最大 ID 作为查询条件
- 限制最大分页深度

### 5.2 游标分页示例

```java
// 请求参数包含 lastId
public List<Aim{Name}DO> selectByCursor(Long lastId, Integer pageSize) {
    return aim{Name}Mapper.selectByCursor(lastId, pageSize);
}

// XML
<select id="selectByCursor" resultMap="BaseResultMap">
    SELECT
    <include refid="Base_Column_List"/>
    FROM {table_name}
    WHERE is_deleted = 0
      <if test="lastId != null">
          AND id < #{lastId}
      </if>
    ORDER BY id DESC
    LIMIT #{pageSize}
</select>
```
