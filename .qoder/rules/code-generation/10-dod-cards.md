---
trigger: always_on
description: DoD（Definition of Done）检查卡 - 代码生成后执行检查清单
globs: [ "**/*.java", "**/*.xml", "**/*.sql" ]
---

# DoD（Definition of Done）检查卡

> **适用范围**：代码生成后的质量检查，确保符合项目规范

---

## 1. 门面 Controller DoD 检查

> 适用服务：{facade-service} / {facade-service-3} / {facade-service-2} / {facade-service-4}

### 1.1 强制规则（违反 = 严重问题）

**分层约束**：
- [ ] Controller 只注入并调用 `ApplicationService`，**禁止**直接注入 `RemoteService`、`Mapper` 或任何数据层组件
- [ ] 不存在任何 `try-catch` 块（由 `GlobalExceptionHandler` 统一处理）
- [ ] 不存在业务逻辑代码（分支判断、数据转换、业务规则），只做参数接收和响应包装

**接口规范**：
- [ ] 包含 `@Tag(name = "一级标题/二级标题")` 注解，且使用 `/` 分隔符（二级分组格式）
- [ ] 每个写操作方法包含 `@RequestHeader(AuthConstant.USER_TOKEN_HEADER) String user` 参数
- [ ] 从 Header 解析操作人 ID：`UserInfoUtil.getUserInfo(user).getId()`
- [ ] 将 `operatorId` 写入 `{Name}ApiRequest`，通过 Feign 传递给应用服务

**参数与响应**：
- [ ] 请求入参使用 `{Name}Request`（以 `Request` 结尾）
- [ ] 响应出参使用 `{Name}Response` 或 `{Name}VO`（门面层自定义，**禁止**直接暴露 `{Name}ApiResponse` 给前端）
- [ ] POST/PUT/DELETE 方法：业务参数（排除 `@RequestHeader`、`pageNum`/`pageSize` 等常规参数）**> 2 个**时封装为 `@RequestBody`，≤ 2 个业务参数可用 `@RequestParam`；GET 多参数使用 `@RequestParam`
- [ ] 写操作（POST/PUT/DELETE）使用 `@Valid` + `jakarta.validation` 注解校验
- [ ] `{Name}Response` / `{Name}VO` 中的 `LocalDateTime` 字段必须标注 `@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")`
- [ ] `{Name}Request` 实现 `Serializable`，并声明 `@Serial private static final long serialVersionUID = -1L;`

**路径规范**：
- [ ] 路径前缀符合服务规范：`/admin/api/v1/`（管理端）、`/merchant/api/v1/`（商家端）、`/app/api/v1/`（APP端）
- [ ] 路径参数（`@PathVariable`）最多 1 个，且必须放在 URL 最后
- [ ] HTTP 方法语义完整（GET / POST / PUT / DELETE）

### 1.2 命名规则

| 元素 | 命名规范 | 示例 |
|------|---------|------|
| 类名（管理端） | `{Name}AdminController` | `{Name}AdminController` |
| 类名（APP端） | `{Name}AppController` | `OrderAppController` |
| 类名（商家端） | `{Name}MerchantController` | `ProductMerchantController` |
| 包路径 | `controller/{domain}/` | `controller/{domain}/` |
| 接口注解 | `@Tag(name = "业务大类/功能模块")` | `@Tag(name = "{业务大类}/{业务实体}")` |

### 1.3 警告规则（违反 = 警告问题）

- [ ] `@Operation(summary = "...")` 说明清晰，描述实际业务含义
- [ ] String 参数由 `ApplicationService` 层统一去空格（Controller 层不做 trim）
- [ ] 分页响应 `data` 使用 `CommonResult.PageData<{Name}Response>`（`totalCount` + `items` 字段名）
- [ ] `serialVersionUID` 统一设置为 `-1L`，且必须标注 `@Serial` 注解
- [ ] 使用 `new CommonResult.PageData<>(totalCount, items)` 构造时**参数顺序必须为 `totalCount` 在前、`items` 在后**；空分页结果使用 `new CommonResult.PageData<>(0L, Collections.emptyList())`，**禁止**省略任一参数

---

## 2. 内部（应用/基础数据服务）Controller DoD 检查

> 适用服务：应用服务、基础数据服务

### 2.1 强制规则（违反 = 严重问题）

**分层约束**：
- [ ] Controller 只注入并调用 `ApplicationService`，**禁止**注入 `QueryService`、`ManageService`、`Mapper` 等
- [ ] 不存在任何 `try-catch` 块
- [ ] 不存在业务逻辑代码，只做参数接收和响应包装
- [ ] **禁止**解析 `@RequestHeader`，操作人 ID 通过 `{Name}ApiRequest.operatorId` 接收

**参数与响应**：
- [ ] 请求入参使用 `{Name}ApiRequest`（以 `ApiRequest` 结尾），**禁止**使用 `{Name}Request`
- [ ] 响应出参使用 `{Name}ApiResponse`（以 `ApiResponse` 结尾）
- [ ] 参数 ≤ 2 个且为基础类型：使用 `@RequestParam`；其他情况：**一律使用 `@RequestBody`**
- [ ] **禁止**使用 `@Valid` / `jakarta.validation`，改用手动 `validate{Name}()` 方法
- [ ] **禁止**使用 `@PathVariable` 路径参数
- [ ] HTTP 方法仅使用 GET / POST，**禁止** PUT / DELETE
- [ ] 所有写操作的 `{Name}ApiRequest` 包含 `operatorId` 字段（Long 类型）
- [ ] `{Name}ApiResponse` 实现 `Serializable`，并声明 `@Serial private static final long serialVersionUID = -1L;`
- [ ] `{Name}ApiResponse` 中的 `LocalDateTime` 字段标注 `@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")`

**路径与校验**：
- [ ] 路径前缀为 `/inner/api/v1/`
- [ ] 每个 Controller 方法包含手动参数校验方法 `validate{Name}(request)`
- [ ] `validate{Name}()` 中校验必填字段不为 null/blank，`operatorId` 不为 null

### 2.2 命名规则

| 元素 | 命名规范 | 示例 |
|------|---------|------|
| 类名 | `{Name}InnerController` | `{Name}InnerController` |
| 包路径 | `controller/inner/`（不建子域目录）| `controller/inner/` |
| 路径前缀 | `/inner/api/v1/` | `/inner/api/v1/{path}` |
| 接口注解 | `@Tag(name = "...")` 单一描述，无需二级分组 | `@Tag(name = "{业务实体}-内部接口")` |

### 2.3 警告规则（违反 = 警告问题）

- [ ] `@Operation(summary = "...")` 说明清晰
- [ ] Feign 接口（`{Name}RemoteService`）与 Controller 方法签名保持一致
- [ ] 分页响应使用 `CommonResult.PageData<{Name}ApiResponse>`（`totalCount` + `items` 字段名）
- [ ] 使用 `new CommonResult.PageData<>(totalCount, items)` 构造时**参数顺序必须为 `totalCount` 在前、`items` 在后**；空分页结果使用 `new CommonResult.PageData<>(0L, Collections.emptyList())`，**禁止**省略任一参数

---

## 3. QueryService DoD 检查

> 适用范围：应用服务 / 基础数据服务的查询层

### 3.1 强制规则（违反 = 严重问题）

**数据访问约束**：
- [ ] **禁止**使用任何 MyBatis-Plus 查询 API：`getById()`、`list()`、`page()`、`lambdaQuery()`、`QueryWrapper`、`LambdaQueryWrapper`
- [ ] 所有查询必须通过 XML Mapper 的原生 SQL 实现
- [ ] **禁止**在 XML SQL 中使用 `SELECT *`，必须明确列出字段
- [ ] 所有查询 SQL 必须包含删除过滤条件（根据表的删除策略）：`WHERE is_deleted = 0`（`is_deleted` 方案）或 `WHERE deleted_at IS NULL`（`deleted_at` 方案）；物理删除表和配置表无需此条件

**依赖注入二选一原则**：
- [ ] 同一实现类中**禁止同时注入** `Aim{Name}Service` 和 `Aim{Name}Mapper`，必须二选一：
  - 模式 A：注入 `Aim{Name}Service`（MP Service 接口），增删改用 MP 方法，查询走 `baseMapper`
  - 模式 B：直接注入 `Aim{Name}Mapper`，全部操作使用原生 XML SQL
- [ ] 注入 `Aim{Name}Service` 接口，**禁止**注入 `Aim{Name}ServiceImpl`（实现类）
- [ ] **禁止**调用 `aim{Name}Service.getBaseMapper()`

**调用链约束**：
- [ ] `QueryService` 不被 `ApplicationService` 以外的组件调用
- [ ] **禁止**在 `QueryService` 中发起 Feign 远程调用（远程调用只在 `ApplicationService` 层）
- [ ] 不标注 `@Transactional`（查询层无需事务）

**入参规范**：
- [ ] 方法入参使用 `{Name}Query` / `{Name}PageQuery` / `{Name}ListQuery`（不接受 `{Name}Request` / `{Name}ApiRequest`）

### 3.2 命名规则

| 元素 | 命名规范 | 示例 |
|------|---------|------|
| 接口 | `{Name}QueryService` | `{Name}QueryService` |
| 实现 | `{Name}QueryServiceImpl` | `{Name}QueryServiceImpl` |
| 包路径 | `service/`（直接平铺，不建子目录）| `service/{Name}QueryService.java` |
| 入参类型 | `{Name}Query` / `{Name}PageQuery` | `{Name}PageQuery` |

### 3.3 警告规则（违反 = 警告问题）

- [ ] 大表分页查询（预估 ≥ 100 万行）使用索引覆盖两阶段查询（先查 ID，再回表），并封装在 `Aim{Name}ServiceImpl` 内部
- [ ] XML Mapper 中使用 `<sql id="Base_Column_List">` 定义可复用字段片段
- [ ] 禁止在 `@Select`、`@Insert` 等注解中编写复杂 SQL（仅限极简单单表操作）
- [ ] 查询方法命名语义清晰：`getBy{Name}`（单条）、`listBy{Name}`（列表）、`pageBy{Name}`（分页）
- [ ] 提供关联名称批量查询方法（如 `buildNameMap(List<Long> ids)`），供上层 ApplicationService 防 N+1 填充使用

---

## 4. ManageService DoD 检查

> 适用范围：应用服务 / 基础数据服务的管理/写操作层

### 4.1 强制规则（违反 = 严重问题）

**数据访问约束**：
- [ ] 增删改操作使用 MyBatis-Plus IService 方法：`save()`、`updateById()`、`removeById()`
- [ ] **禁止**在 ManageService 中编写业务查询逻辑（查询应放在 QueryService）

**事务约束**：
- [ ] 写操作方法必须标注 `@Transactional(rollbackFor = Exception.class)`
- [ ] `Aim{Name}Service` / `Aim{Name}ServiceImpl` **严禁标注 `@Transactional`**

**依赖注入二选一原则**：
- [ ] 同一实现类中**禁止同时注入** `Aim{Name}Service` 和 `Aim{Name}Mapper`，必须二选一
- [ ] 注入 `Aim{Name}Service` 接口，**禁止**注入 `Aim{Name}ServiceImpl`（实现类）

**调用链约束**：
- [ ] `ManageService` 不被 `ApplicationService` 以外的组件调用
- [ ] **禁止**在 `ManageService` 中发起 Feign 远程调用

**入参规范**：
- [ ] 方法入参使用 `{Name}ApiRequest`（写操作必须包含 `operatorId`）
- [ ] 返回值为实体 ID（Long）或 void

### 4.2 命名规则

| 元素 | 命名规范 | 示例 |
|------|---------|------|
| 接口 | `{Name}ManageService` | `{Name}ManageService` |
| 实现 | `{Name}ManageServiceImpl` | `{Name}ManageServiceImpl` |
| 包路径 | `service/`（直接平铺，不建子目录）| `service/{Name}ManageService.java` |

---

## 5. DO 实体 DoD 检查

> 适用范围：所有服务的数据库实体类

### 5.1 强制规则（违反 = 严重问题）

**命名约束**：
- [ ] 类名严格遵循 `Aim{Name}DO` 格式：必须以 `Aim` 开头，以 `DO` 结尾
- [ ] 类名与表名对应：表名 `aim_{模块}_{业务名}` → 类名 `Aim{模块首字母大驼峰}{业务名首字母大驼峰}DO`
  - 示例：`{table_name}` → `Aim{Domain}{Name}DO`

**注解约束**：
- [ ] **禁止**在 DO 类上标注 `@JsonFormat`（DO 不涉及序列化给前端）
- [ ] **禁止**在 DO 类或对应的 `Aim{Name}ServiceImpl` 上标注 `@Transactional`
- [ ] 使用 `@Data` 注解（或 `@Getter`/`@Setter`）

**继承与字段**：
- [ ] 包含所有基础通用字段：`id`（BIGINT 自增主键）、`createTime`、`updateTime`
- [ ] `status` 字段使用 `StatusEnum`（`1=启用`，`0=禁用`），**禁止**直接使用魔法数字 0/1
- [ ] 删除字段**按删除策略**选择（参考 `database-standards.md §9.4`），**禁止**对所有表一律添加 `isDeleted`：
  - **软删除（审计型）**：使用 `isDeleted`，配合 `DeleteStatusEnum`，**禁止**直接使用魔法数字
  - **时间戳软删除**：使用 `deletedAt`（`LocalDateTime`，null = 未删除）
  - **物理删除**：不添加任何删除字段
  - **配置表停用机制**：使用 `isActive` 替代 `isDeleted`，删除用物理删除

**数据库表规范**：
- [ ] 表名格式：`aim_{模块}_{业务名}`（全小写，下划线分隔）
- [ ] 字符集：`DEFAULT CHARSET=utf8mb4`，**禁止**指定 COLLATE
- [ ] 基础通用字段完整：`id`、`create_time`、`update_time`（`creator_id`、`updater_id` 可选）
- [ ] `create_time` 字段定义必须为：`DATETIME DEFAULT CURRENT_TIMESTAMP`
- [ ] `update_time` 字段定义必须为：`DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`
- [ ] 删除字段按策略决策选择，非所有表强制要求 `is_deleted`

**Mapper 命名**：
- [ ] 对应 Mapper 必须以 `Aim` 开头：`Aim{Name}Mapper`
- [ ] 对应 MP Service 接口位于 `service/mp/`，命名为 `Aim{Name}Service`
- [ ] 对应 MP Service 实现位于 `service/impl/mp/`，命名为 `Aim{Name}ServiceImpl`，继承 `ServiceImpl<Aim{Name}Mapper, Aim{Name}DO>`

### 5.2 命名规则

| 元素 | 命名规范 | 示例 |
|------|---------|------|
| DO 类名 | `Aim{Name}DO` | `Aim{Domain}{Name}DO` |
| 对应表名 | `aim_{模块}_{业务名}` | `{table_name}` |
| MP Service 接口 | `Aim{Name}Service` | `Aim{Domain}{Name}Service` |
| MP Service 实现 | `Aim{Name}ServiceImpl` | `Aim{Domain}{Name}ServiceImpl` |
| Mapper | `Aim{Name}Mapper` | `Aim{Domain}{Name}Mapper` |
| DO 包路径 | `domain/entity/` | `domain/entity/Aim{Name}DO.java` |

### 5.3 警告规则（违反 = 警告问题）

- [ ] DO/DTO 转换使用手动 `convertTo{Name}()` 方法，**禁止**使用 `BeanUtils.copyProperties`
- [ ] 禁止在循环中单条 CRUD，必须使用批量操作方法（`saveBatch`、`updateBatchById` 等）
- [ ] DO 中的 `LocalDateTime` 字段不标注 `@JsonFormat`（仅 Response/VO 需要）
- [ ] SQL 中字段注释完整（`COMMENT '...'`）

---

## 6. Feign 接口 DoD 检查

> 适用范围：{inner-api-service} 模块

### 6.1 强制规则（违反 = 严重问题）

**接口定义**：
- [ ] 接口使用 `@FeignClient` 注解，指定 `name` 和 `fallback`
- [ ] 方法签名与对应 InnerController 完全一致
- [ ] 返回类型为 `CommonResult<T>`

**参数与响应**：
- [ ] 请求参数使用 `{Name}ApiRequest`
- [ ] 响应参数使用 `{Name}ApiResponse`
- [ ] `{Name}ApiRequest` 写操作必须包含 `operatorId` 字段

**路径规范**：
- [ ] 路径前缀为 `/inner/api/v1/`
- [ ] 路径与 InnerController 保持一致

### 6.2 命名规则

| 元素 | 命名规范 | 示例 |
|------|---------|------|
| 接口名 | `{Name}RemoteService` | `{Name}RemoteService` |
| 包路径 | `feign/` | `feign/{Name}RemoteService.java` |
| Fallback | `{Name}RemoteServiceFallback` | `{Name}RemoteServiceFallback` |

---

## 7. ApplicationService DoD 检查

> 适用范围：门面服务和应用服务

### 7.1 强制规则（违反 = 严重问题）

**分层约束**：
- [ ] 门面服务的 ApplicationService 只调用 `RemoteService`（Feign 接口）
- [ ] 应用服务的 ApplicationService 只调用 `QueryService` 和 `ManageService`
- [ ] **禁止**直接注入 `Mapper` 或 `Aim{Name}Service`

**事务约束**：
- [ ] 不涉及写操作的方法不标注 `@Transactional`
- [ ] 涉及多个写操作的方法标注 `@Transactional(rollbackFor = Exception.class)`

**远程调用处理**（详见 `00-common-constraints.md §2`）：
- [ ] 调用 Feign 接口后必须校验 `CommonResult.isSuccess()`
- [ ] 远端业务失败使用 `CommonResult.failed(result.getCode(), result.getMessage())` 透传，**禁止**包装为 `BusinessException`
- [ ] **涉及远端失败透传的方法，返回类型必须为 `CommonResult<T>`**，**禁止**将远端失败状态降维为 `boolean`、`String` 等基础类型返回（会丢失错误码语义）
- [ ] 远程通信异常（网络超时等）抛出 `RemoteApiCallException`
- [ ] `CommonResult.failed()` 错误码参数位**禁止**使用魔法数字或字符串（如 `"500"`、`"400"`、`400L`），必须使用枚举或透传 `result.getCode()`

**参数转换**：
- [ ] 门面层 ApplicationService 负责将 `{Name}ApiResponse` 转换为 `{Name}Response`
- [ ] 即使字段完全相同，转换也**不得省略**

**模块内关联字段就近填充**（仅限应用服务层 ApplicationService，门面层 `Response`/`VO` 关联字段结构不受此项约束）：
- [ ] **模块内关联**（引用 id 所属表与当前表在**同一服务**内）：`ApiResponse` 必须内嵌 `{Name}RefResponse` 关联引用对象（至少含 `id` + `name`），**禁止**将 `{Name}Id`、`{Name}Name` 直接平铺在 `ApiResponse` 中
- [ ] `{Name}RefResponse` **必须用引用对象来填充**：由 `ApplicationService.convertToApiResponse()` 通过 QueryService 返回的实体/DO 对象属性访问取值，**禁止**硬编码或字符串拼接
- [ ] 分页/列表场景中关联内嵌对象填充**禁止 N+1**：必须先批量查询所有关联 id 对应的 DO，构建 `Map<Long, DO>` 后统一填充，**禁止**在循环内单条查询
- [ ] **跨模块关联**（引用 id 所属表在另一个服务内）：`ApiResponse` 只声明 `{Name}Id` 字段，不声明任何关联对象字段，名称由门面层 ApplicationService 通过 Feign 调用聚合

### 7.2 命名规则

| 元素 | 命名规范 | 示例 |
|------|---------|------|
| 接口名 | `{Name}ApplicationService` | `{Name}ApplicationService` |
| 实现名 | `{Name}ApplicationServiceImpl` | `{Name}ApplicationServiceImpl` |
| 包路径 | `service/` | `service/{Name}ApplicationService.java` |

---

## 8. Mapper XML DoD 检查

> 适用范围：所有服务的 MyBatis Mapper XML

### 8.1 强制规则（违反 = 严重问题）

**SQL 规范**：
- [ ] **禁止**使用 `SELECT *`，必须明确列出字段
- [ ] 所有查询 SQL 必须包含删除过滤条件（根据表的删除策略）
- [ ] 使用 `<sql id="Base_Column_List">` 定义可复用字段片段
- [ ] 使用 `#{}` 占位符，**禁止**使用 `${}` 拼接（防 SQL 注入）

**XML 结构**：
- [ ] 包含 `resultMap` 定义，字段映射完整
- [ ] 包含 `Base_Column_List` SQL 片段
- [ ] namespace 与 Mapper 接口全限定名一致

### 8.2 命名规则

| 元素 | 命名规范 | 示例 |
|------|---------|------|
| 文件名 | `Aim{Name}Mapper.xml` | `Aim{Name}Mapper.xml` |
| 文件位置 | `resources/mapper/` | `resources/mapper/Aim{Name}Mapper.xml` |
| namespace | Mapper 接口全限定名 | `{base_package}.{domain}.employee.mapper.Aim{Name}Mapper` |

---

## 9. 数据库脚本 DoD 检查

> 适用范围：建表 SQL 和测试数据 SQL

### 9.1 强制规则（违反 = 严重问题）

**表结构**：
- [ ] 表名格式：`aim_{模块}_{业务名}`（全小写，下划线分隔）
- [ ] 字符集：`DEFAULT CHARSET=utf8mb4`，**禁止**指定 COLLATE
- [ ] 包含基础通用字段：`id`、`create_time`、`update_time`
- [ ] `create_time` 字段定义必须为：`DATETIME DEFAULT CURRENT_TIMESTAMP`
- [ ] `update_time` 字段定义必须为：`DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`
- [ ] 主键：`id BIGINT PRIMARY KEY AUTO_INCREMENT`
- [ ] 删除字段按策略选择，非所有表强制要求 `is_deleted`

**SQL 语句格式**：
- [ ] 必须包含 `DROP TABLE IF EXISTS \`table_name\`;`
- [ ] 使用 `CREATE TABLE IF NOT EXISTS \`table_name\``
- [ ] 表名和字段名使用反引号包裹

**字段规范**：
- [ ] 所有字段必须有注释（`COMMENT '...'`）
- [ ] 字符串字段指定长度（如 `VARCHAR(100)`）
- [ ] 状态字段使用 `TINYINT`，默认值为 1（启用）

**索引规范**：
- [ ] 主键自动创建索引
- [ ] 外键字段创建索引
- [ ] 高频查询条件字段考虑索引
- [ ] 索引命名规范：`uk_{字段名}`（唯一）、`idx_{字段名}`（普通）

**测试数据**：
- [ ] 每个表至少包含 3 条测试数据
- [ ] 测试数据覆盖典型场景（正常、边界、异常）
- [ ] 测试数据中的时间字段使用合理的值

### 9.2 文件命名与输出路径

**输出目录**：
- SQL 文件：`outputs/data/sql/{table_name}.sql`
- HTTP 测试文件：`outputs/data/http/{module}-api.http`

**文件命名规则**：
| 产物类型 | 命名格式 | 示例 |
|----------|----------|------|
| SQL 脚本 | `{table_name}.sql` | `{table_name}.sql` |
| HTTP 测试 | `{module}-api.http` | `{path}-api.http` |

**迭代更新规则**：
- SQL 文件按表名唯一，新 Feature 使用已有表时追加测试数据
- HTTP 文件按功能模块唯一，新接口追加到现有文件
