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
XxxApplicationService（编排层）
    ↓ 只允许调用 XxxQueryService（查询） 或 XxxManageService（增删改）
    ↓ 禁止直接调用 AimXxxService 或 AimXxxMapper

XxxQueryService / XxxManageService（数据访问层，二选一模式）
    ├── 模式 A：注入 AimXxxService 接口（位于 service/mp/）
    │       增删改 → 调用 MP 方法（save/updateById/removeById）
    │       查询   → 调用 AimXxxServiceImpl.baseMapper.xxx()（XML 原生 SQL）
    └── 模式 B：注入 AimXxxMapper（直接原生 SQL，增删改查均可）

AimXxxServiceImpl（位于 service/impl/mp/，继承 ServiceImpl）
    增删改 → 使用 MP 方法
    查询   → 使用 this.baseMapper.xxx() 调用原生 SQL（XML 中定义）
```

### 2.2 核心约束

**ApplicationService 约束**：
- `XxxApplicationService` 必须通过 `XxxQueryService` 执行查询操作
- `XxxApplicationService` 必须通过 `XxxManageService` 执行增删改操作
- `XxxApplicationService` **禁止**直接注入 `AimXxxService` 或 `AimXxxMapper`

**QueryService / ManageService 数据访问二选一原则**：

| 模式 | 注入对象 | 适用场景 |
|------|----------|----------|
| 模式 A | `AimXxxService`（MP Service 接口） | 增删改使用 MP 封装方法，查询使用 XML 原生 SQL |
| 模式 B | `AimXxxMapper`（原生 Mapper） | 全部操作使用原生 XML SQL，不需要 MP 封装方法 |

> **互斥规则**：`XxxQueryService` / `XxxManageService` 在同一实现类中**禁止同时注入** `AimXxxService` 和 `AimXxxMapper`，必须二选一。

**`AimXxxService`（MP Service）事务约束**：
- `AimXxxService` / `AimXxxServiceImpl` **严禁标注 `@Transactional`**
- 事务注解只允许标注在 `XxxManageService` 的实现方法上
- 理由：`AimXxxServiceImpl` 方法通常被同类或上层代理调用，`@Transactional` 在此层标注易导致 Spring AOP 代理失效（自调用问题）

**其他禁止事项**：
- `QueryService` / `ManageService` 中调用 `aimXxxService.getBaseMapper()`
- `QueryService` / `ManageService` 中直接依赖 `AimXxxServiceImpl`（实现类）
- `XxxApplicationService` 直接操作数据库（绕过 Query/ManageService）

---

## 3. 代码示例

### 3.1 模式 A：QueryService / ManageService 注入 AimXxxService

```java
// AimXxxServiceImpl：增删改用 MP，查询用 this.baseMapper 原生 SQL
// 严禁在此类标注 @Transactional
@Service
public class AimJobTypeServiceImpl extends ServiceImpl<AimJobTypeMapper, AimJobTypeDO>
        implements AimJobTypeService {

    public AimJobTypeDO getByCode(String code) {
        return this.baseMapper.selectByCode(code); // 原生 SQL（XML 中定义）
    }
}

// QueryService：注入 AimXxxService 接口（模式 A），禁止同时注入 AimXxxMapper
@Service
@RequiredArgsConstructor
public class JobTypeQueryServiceImpl implements JobTypeQueryService {
    private final AimJobTypeService aimJobTypeService; // 注入接口

    public AimJobTypeDO getByCode(String code) {
        // 查询走原生 SQL（XML）
        return ((AimJobTypeServiceImpl) aimJobTypeService).getBaseMapper().selectByCode(code);
    }
}

// ManageService：注入 AimXxxService 接口（模式 A），事务在此层管理
@Service
@RequiredArgsConstructor
public class JobTypeManageServiceImpl implements JobTypeManageService {
    private final AimJobTypeService aimJobTypeService; // 注入接口

    @Transactional(rollbackFor = Exception.class)
    public Long create(JobTypeCreateApiRequest request) {
        // 增删改用 MP 方法
        AimJobTypeDO entity = convertToDO(request);
        aimJobTypeService.save(entity);
        return entity.getId();
    }
}
```

### 3.2 模式 B：QueryService / ManageService 直接注入 AimXxxMapper

```java
// QueryService：直接注入 AimXxxMapper（模式 B）
@Service
@RequiredArgsConstructor
public class JobTypeQueryServiceImpl implements JobTypeQueryService {
    private final AimJobTypeMapper aimJobTypeMapper; // 直接注入 Mapper

    public AimJobTypeDO getByCode(String code) {
        return aimJobTypeMapper.selectByCode(code); // 原生 SQL
    }
}

// ManageService：直接注入 AimXxxMapper（模式 B）
@Service
@RequiredArgsConstructor
public class JobTypeManageServiceImpl implements JobTypeManageService {
    private final AimJobTypeMapper aimJobTypeMapper; // 直接注入 Mapper

    @Transactional(rollbackFor = Exception.class)
    public Long create(JobTypeCreateApiRequest request) {
        AimJobTypeDO entity = convertToDO(request);
        aimJobTypeMapper.insert(entity); // 原生 SQL
        return entity.getId();
    }
}
```

---

## 4. Mapper XML 规范

### 4.1 XML 文件位置

- 应用服务：`src/main/resources/mapper/AimXxxMapper.xml`
- 基础数据服务：`src/main/resources/mapper/AimXxxMapper.xml`

### 4.2 XML 基本结构

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.aim.mall.agent.employee.mapper.AimJobTypeMapper">

    <!-- 结果映射 -->
    <resultMap id="BaseResultMap" type="com.aim.mall.agent.employee.domain.entity.AimJobTypeDO">
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
        FROM aim_agent_job_type
        WHERE code = #{code}
          AND is_deleted = 0
    </select>

    <!-- 分页查询 -->
    <select id="selectPage" resultMap="BaseResultMap">
        SELECT
        <include refid="Base_Column_List"/>
        FROM aim_agent_job_type
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
SELECT * FROM aim_agent_job_type 
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
public List<AimJobTypeDO> selectByCursor(Long lastId, Integer pageSize) {
    return aimJobTypeMapper.selectByCursor(lastId, pageSize);
}

// XML
<select id="selectByCursor" resultMap="BaseResultMap">
    SELECT
    <include refid="Base_Column_List"/>
    FROM aim_agent_job_type
    WHERE is_deleted = 0
      <if test="lastId != null">
          AND id < #{lastId}
      </if>
    ORDER BY id DESC
    LIMIT #{pageSize}
</select>
```
