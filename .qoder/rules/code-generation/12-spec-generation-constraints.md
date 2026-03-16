# 技术规格生成约束规范

> **适用范围**：tech-spec-generation Skill 生成规格时自动应用的约束
> **目的**：将 DoD（Definition of Done）检查前置到规格生成阶段，确保生成的技术规格本身符合代码生成规范，减少代码生成后的返工

---

## 1. 接口定义约束

### 1.1 门面接口约束（Facade Layer）

**Controller 命名约束**：
- 管理端 Controller 必须以 `AdminController` 结尾，如 `JobTypeAdminController`
- APP 端 Controller 必须以 `AppController` 结尾，如 `OrderAppController`
- 商家端 Controller 必须以 `MerchantController` 结尾，如 `ProductMerchantController`

**路径约束**：
- 管理端路径前缀必须是 `/admin/api/v1/`
- APP 端路径前缀必须是 `/app/api/v1/`
- 商家端路径前缀必须是 `/merchant/api/v1/`

**参数约束**：
- 写操作（POST/PUT/DELETE）必须包含 `@RequestHeader(AuthConstant.USER_TOKEN_HEADER) String user` 参数
- POST/PUT/DELETE 方法必须使用 `@RequestBody` 接收参数
- GET 多参数使用 `@RequestParam`，禁止使用 `@PathVariable`
- 写操作必须使用 `@Valid` 进行参数校验

**响应约束**：
- 响应必须使用门面层自定义的 Response DTO（`XxxResponse` / `XxxVO`）
- 禁止使用 `XxxApiResponse` 直接暴露给前端
- `LocalDateTime` 字段必须标注 `@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")`

**分层约束**：
- Controller 只能调用 `ApplicationService`
- 禁止直接注入 `RemoteService`、`Mapper` 或任何数据层组件
- 禁止包含业务逻辑代码（分支判断、数据转换）

### 1.2 内部接口约束（Inner/ Application Layer）

**Controller 命名约束**：
- 必须以 `InnerController` 结尾，如 `JobTypeInnerController`

**路径约束**：
- 路径前缀必须是 `/inner/api/v1/`
- 禁止使用 `@PathVariable` 路径参数

**参数约束**：
- 参数 ≤ 2 个且为基础类型：使用 `@RequestParam`
- 其他情况：一律使用 `@RequestBody`
- 禁止使用 `@Valid` / `jakarta.validation`，改用手动 `validateXxx()` 方法
- 操作人 ID 通过 `XxxApiRequest.operatorId` 接收，禁止解析 `@RequestHeader`

**响应约束**：
- 响应必须使用 `XxxApiResponse`（以 `ApiResponse` 结尾）
- 必须返回 `CommonResult<T>` 包装
- `LocalDateTime` 字段标注 `@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")`
- 实现 `Serializable`，`serialVersionUID = -1L`

**HTTP 方法约束**：
- 仅使用 GET / POST
- 禁止使用 PUT / DELETE

**分层约束**：
- Controller 只能调用 `QueryService` 和 `ManageService`
- 禁止直接注入 `Mapper` 或 `AimXxxService`

---

## 2. DTO 命名约束

### 2.1 门面层 DTO

| 类型 | 命名格式 | 示例 |
|------|---------|------|
| 请求 DTO | `{业务名}Request` | `JobTypeRequest` |
| 响应 DTO | `{业务名}Response` | `JobTypeResponse` |
| 列表响应 | `{业务名}VO` | `JobTypeVO` |

**约束**：
- 必须实现 `Serializable`，`serialVersionUID = -1L`
- 字段使用 `jakarta.validation` 注解进行校验
- String 字段添加长度限制（如 `@Size(max = 100)`）

### 2.2 内部层 DTO

| 类型 | 命名格式 | 示例 |
|------|---------|------|
| 请求 DTO | `{业务名}ApiRequest` | `JobTypeApiRequest` |
| 响应 DTO | `{业务名}ApiResponse` | `JobTypeApiResponse` |

**约束**：
- 必须实现 `Serializable`，`serialVersionUID = -1L`
- 写操作必须包含 `operatorId` 字段（Long 类型）
- 不使用 `jakarta.validation` 注解

---

## 3. Service 分层约束

### 3.1 ApplicationService 约束

**门面层 ApplicationService**：
- 只调用 `RemoteService`（Feign 接口）
- 负责将 `XxxRequest` 转换为 `XxxApiRequest`
- 负责将 `XxxApiResponse` 转换为 `XxxResponse`
- String 参数在入口处统一去空格

**应用层 ApplicationService**：
- 只调用 `QueryService` 和 `ManageService`
- 负责业务编排和 DTO 转换
- 涉及多个写操作的方法标注 `@Transactional(rollbackFor = Exception.class)`

**命名约束**：
- 接口名：`{Name}ApplicationService`
- 实现名：`{Name}ApplicationServiceImpl`

### 3.2 QueryService 约束

**职责约束**：
- 只包含只读查询操作
- 禁止使用 MyBatis-Plus 查询 API（`getById()`、`list()`、`page()` 等）
- 所有查询必须通过 XML Mapper 的原生 SQL 实现
- 禁止在 XML SQL 中使用 `SELECT *`
- 所有查询 SQL 必须包含删除过滤条件

**依赖约束**：
- 同一实现类中禁止同时注入 `AimXxxService` 和 `AimXxxMapper`，必须二选一
- 注入 `AimXxxService` 接口，禁止注入实现类
- 禁止调用 `aimXxxService.getBaseMapper()`
- 禁止发起 Feign 远程调用

**命名约束**：
- 接口名：`{Name}QueryService`
- 实现名：`{Name}QueryServiceImpl`
- 入参使用 `XxxQuery` / `XxxPageQuery`，不接受 `XxxRequest`

### 3.3 ManageService 约束

**职责约束**：
- 只包含增删改操作
- 使用 MyBatis-Plus IService 方法：`save()`、`updateById()`、`removeById()`
- 禁止编写业务查询逻辑
- 写操作方法必须标注 `@Transactional(rollbackFor = Exception.class)`

**依赖约束**：
- 同一实现类中禁止同时注入 `AimXxxService` 和 `AimXxxMapper`
- 禁止发起 Feign 远程调用

**命名约束**：
- 接口名：`{Name}ManageService`
- 实现名：`{Name}ManageServiceImpl`
- 入参使用 `XxxApiRequest`，必须包含 `operatorId`

---

## 4. 数据模型约束

### 4.1 DO 实体约束

**命名约束**：
- 类名严格遵循 `Aim{Name}DO` 格式
- 表名 `aim_{模块}_{业务名}` → 类名 `Aim{模块首字母大驼峰}{业务名首字母大驼峰}DO`
- 示例：`aim_agent_job_type` → `AimAgentJobTypeDO`

**字段约束**：
- 必须包含基础通用字段：`id`（BIGINT）、`createTime`、`updateTime`
- `status` 字段使用 `StatusEnum`（`1=启用`，`0=禁用`），禁止使用魔法数字
- 删除字段按策略选择：
  - 软删除（审计型）：使用 `isDeleted`，配合 `DeleteStatusEnum`
  - 时间戳软删除：使用 `deletedAt`（`LocalDateTime`，null = 未删除）
  - 物理删除：不添加删除字段
  - 配置表停用机制：使用 `isActive`

**注解约束**：
- 禁止使用 `@JsonFormat`（DO 不涉及序列化给前端）
- 禁止使用 `@Transactional`
- 使用 `@Data` 注解

### 4.2 Mapper 约束

**命名约束**：
- Mapper 必须以 `Aim` 开头，如 `AimJobTypeMapper`
- MP Service 接口位于 `service/mp/`，命名为 `AimXxxService`
- MP Service 实现位于 `service/impl/mp/`，命名为 `AimXxxServiceImpl`

**XML 约束**：
- 文件名：`Aim{Name}Mapper.xml`
- 必须包含 `resultMap` 定义
- 必须包含 `Base_Column_List` SQL 片段
- 禁止使用 `SELECT *`
- 使用 `#{}` 占位符，禁止使用 `${}`

### 4.3 数据库表约束

**表名约束**：
- 格式：`aim_{模块}_{业务名}`（全小写，下划线分隔）
- 字符集：`DEFAULT CHARSET=utf8mb4`，禁止指定 COLLATE

**字段约束**：
- 主键：`id BIGINT PRIMARY KEY AUTO_INCREMENT`
- 必须包含：`create_time`、`update_time`
- 所有字段必须有注释（`COMMENT '...'`）
- 字符串字段指定长度（如 `VARCHAR(100)`）
- 状态字段使用 `TINYINT`，默认值为 1

**索引约束**：
- 外键字段创建索引
- 高频查询条件字段考虑索引
- 索引命名：`uk_{字段名}`（唯一）、`idx_{字段名}`（普通）

---

## 5. Feign 接口约束

**命名约束**：
- 接口名：`{Name}RemoteService`
- Fallback 类名：`{Name}RemoteServiceFallback`

**注解约束**：
- 使用 `@FeignClient` 注解，指定 `name` 和 `fallback`
- 方法签名与对应 InnerController 完全一致

**参数约束**：
- 请求参数使用 `XxxApiRequest`
- 禁止使用 `@PathVariable`

**响应约束**：
- 返回类型为 `CommonResult<T>`
- 响应参数使用 `XxxApiResponse`

**路径约束**：
- 路径前缀为 `/inner/api/v1/`
- 路径与 InnerController 保持一致

---

## 6. 应用约束到 Tech Spec 生成

在生成 tech-spec.yml 时，必须应用以上约束：

1. **接口定义阶段**：
   - 自动根据服务分层确定路径前缀
   - 自动根据命名规范生成 Controller 类名
   - 自动确定参数校验方式（@Valid vs 手动校验）

2. **DTO 定义阶段**：
   - 自动根据分层确定 DTO 后缀（Request/Response vs ApiRequest/ApiResponse）
   - 自动添加 `operatorId` 字段到写操作的 ApiRequest

3. **Service 定义阶段**：
   - 自动根据操作类型确定 Service 类型（Query vs Manage）
   - 自动确定 ApplicationService 的分层归属

4. **数据模型阶段**：
   - 自动根据表名生成 DO 类名
   - 自动添加基础字段（id, createTime, updateTime）
   - 自动根据删除策略确定删除字段

5. **生成后自检**：
   - 检查所有接口定义是否符合约束
   - 检查所有 DTO 命名是否符合约束
   - 检查所有 Service 分层是否符合约束
   - 检查数据模型是否符合约束
