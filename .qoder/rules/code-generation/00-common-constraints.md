---
trigger: always_on
description: 跨层通用约束 - 异常处理、远端透传、CommonResult、DTO透传原则、日志、operatorId
---

# 通用约束规范

> **适用范围**：所有服务层（Controller、ApplicationService、QueryService、ManageService、Feign）
>
> **说明**：本文件收录跨层共用的基础约束，避免在各规范文件中重复定义。各层专属规范参见对应文件。

---

## 1. 异常处理规范

### 1.1 三种标准异常类型

仅允许使用以下三种标准异常类型：

| 异常类型 | 使用场景 |
|----------|----------|
| `MethodArgumentValidationException` | 参数校验失败 |
| `RemoteApiCallException` | 远程服务调用失败（网络超时、服务不可用） |
| `BusinessException` | 业务规则违反 |

```java
// 仅错误码
throw new BusinessException(ErrorCodeEnum.AGENT_BUSINESS_ERROR);
// 错误码 + 自定义消息
throw new BusinessException(ErrorCodeEnum.AGENT_BUSINESS_ERROR, "{业务实体}不存在");
// 错误码 + 异常原因
throw new BusinessException(ErrorCodeEnum.AGENT_BUSINESS_ERROR, cause);
```

### 1.2 Controller 层不捕获异常

项目配置了 `GlobalExceptionHandler`，Controller 层**直接抛出**，由全局处理器统一处理。所有错误响应 HTTP 状态码均为 200，错误类型通过响应体 `code` 字段区分。

---

## 2. 远端失败透传规范

**适用层级**：`ApplicationService` 层（门面服务和应用服务均适用）

### 2.1 核心分工原则

| 场景 | 处理方式 | 说明 |
|------|----------|------|
| 本地业务规则违反 | 抛出 `BusinessException` | 由全局异常处理器统一转换为失败响应 |
| 远程调用业务失败（对端返回非成功 `CommonResult`） | 调用 `CommonResult.failed(Long, String)` 直接透传 | 将远端错误码和错误消息原样返回，不抛异常 |
| 远程通信级别异常（网络超时、服务不可用） | 抛出 `RemoteApiCallException` | 由全局异常处理器统一转换为失败响应 |

### 2.2 强制规则

- 在 `ApplicationService` 层调用 Feign 接口后，必须校验返回的 `CommonResult` 是否成功
- 若 `CommonResult` 标示业务失败（`!result.isSuccess()`），则直接返回 `CommonResult.failed(result.getCode(), result.getMessage())`
- **涉及远端失败透传的方法，返回类型必须是 `CommonResult<T>`**，禁止将远端失败状态降维为 `boolean`、`String` 等基础类型返回（降维会导致错误码语义永久丢失）
- **禁止**将远端业务失败包装为 `BusinessException` 抛出（会丢失原始错误码语义）
- **禁止**在 `QueryService` / `ManageService` 层处理远程调用结果

```java
// ✅ 正确：ApplicationService 层透传远端业务失败
public CommonResult<{Domain}ApiResponse> get{Domain}Detail(Long {domain}Id) {
    CommonResult<{Domain}ApiResponse> result = {domain}RemoteService.getById({domain}Id);
    if (!result.isSuccess()) {
        return CommonResult.failed(result.getCode(), result.getMessage());
    }
    return result;
}

// ❌ 错误：将远端业务失败包装为本地 BusinessException（丢失原始错误码）
public CommonResult<{Domain}ApiResponse> get{Domain}Detail(Long {domain}Id) {
    CommonResult<{Domain}ApiResponse> result = {domain}RemoteService.getById({domain}Id);
    if (!result.isSuccess()) {
        throw new BusinessException({Domain}ErrorCodeEnum.SYSTEM_ERROR, result.getMessage());
    }
    return result;
}

// ❌ 错误：未校验 CommonResult 直接取 data（可能 NPE 且忽略业务失败）
public {Domain}ApiResponse get{Domain}Detail(Long {domain}Id) {
    return {domain}RemoteService.getById({domain}Id).getData();
}
```

---

## 3. CommonResult 使用规范

### 3.1 响应格式

```java
// 成功响应
return CommonResult.success(data);

// 失败响应（使用错误码枚举，推荐）
return CommonResult.failed(ErrorCodeEnum.PARAM_ERROR);

// 失败响应（远端错误透传，仅允许在 ApplicationService 层透传 Feign 返回的原始错误）
return CommonResult.failed(result.getCode(), result.getMessage());

// 失败响应（本地业务判断，无错误码枚举时的兜底写法）
return CommonResult.failed("{detail message}");
```

### 3.2 `CommonResult.failed()` 调用规范

| 场景 | 正确用法 | 禁止用法 |
|------|---------|----------|
| 远端失败透传 | `failed(result.getCode(), result.getMessage())` | 任何拿魔法数字或字符串作错误码 |
| 有错误码枚举 | `failed(ErrorCodeEnum.XXX)` 或 `failed(ErrorCodeEnum.XXX, msg)` | `failed("500", msg)`、`failed(400L, msg)` |
| 无枚举时临时写法 | `failed("message")`（仅传消息） | `failed("500", msg)`、`failed(500L, msg)` |

**强制禁止**：
- **禁止**在任何地方使用魔法数字字符串作为错误码，如 `"500"`、`"400"`、`400L`、`500L`
- **禁止**在 `CommonResult.failed()` 错误码参数位传入任何局部定义的数字常量（必须通过枚举维护）
- **禁止**将远端错误码和本地错误码混用（透传用 `result.getCode()`，本地业务失败用枚举）

### 3.3 响应结构

```json
{
    "success": true,
    "code": 200,
    "message": "操作成功",
    "data": { ... }
}
```

```json
{
    "success": false,
    "code": 200101001,
    "message": "{参数名}不能为空",
    "data": null
}
```

### 3.4 使用约束

- Controller 层必须返回 `CommonResult<T>`
- 禁止直接返回原始对象（如 `{Domain}Response`）
- 分页数据使用 `CommonResult.PageData<T>`

---

## 4. DTO 透传与防腐层原则

### 4.1 DTO 透传（Passthrough）模式

**适用场景**：应用层将基础数据服务查询结果**无任何内容增删改**地原样透传给上层。

- 应用层 Feign 接口的返回类型**直接引用 Provider 域（如 mall-product-api）的 `{Name}ApiResponse`**
- 应用层内部实现**禁止**新建与 Provider DTO 字段完全相同的同名类（积极死码，无业务价值）
- 应用层内部禁止存在"逐字段拷贝"的无意义转换逻辑

### 4.2 门面防腐（Anti-Corruption Layer）模式

**适用场景**：门面服务面向前端/用户的响应对象。

- 门面层 Controller 返回类型必须是**门面层自定义的 `{Name}Response`**，不得直接返回 Feign 接口的 `{Name}ApiResponse`
- 门面层 ApplicationService 负责将上游 `{Name}ApiResponse` 转换为门面层定义的 `{Name}Response`
- 即使当前字段完全相同，该转换也**不得省略**（驱动原因：前端契约稳定性、内部实现封闭性）

| 层级 | DTO 外露形式 | 是否必须转换 |
|------|--------------|------------|
| 应用层内部透传 Provider 数据 | 直接引用 Provider `{Name}ApiResponse` | 否，直接透传 |
| 门面层对前端响应 | 门面层自定义 `{Name}Response` | 是，必须转换 |

---

## 5. 日志规范

### 5.1 日志级别使用

| 级别 | 使用场景 |
|------|----------|
| ERROR | 系统异常、需要立即处理的错误 |
| WARN | 业务异常、可预期的异常情况 |
| INFO | 业务流程关键节点、外部调用入参出参 |
| DEBUG | 详细调试信息、SQL 语句、方法入参 |

### 5.2 日志内容规范

```java
// 入口日志
log.info("[{业务实体}创建] operatorId={}, request={}", operatorId, request);

// 出口日志
log.info("[{业务实体}创建] 成功, result={}", result);

// 异常日志
log.error("[{业务实体}创建] 失败, operatorId={}, request={}", operatorId, request, e);

// 远程调用日志
log.info("[远程调用] service={}, method={}, param={}", "{domain}-service", "getById", {domain}Id);
```

### 5.3 禁止事项

- **禁止**在循环中打印日志
- **禁止**打印敏感信息（密码、Token、手机号等）
- **禁止**使用字符串拼接方式打印日志（使用占位符 `{}`）

---

## 6. operatorId 规范

### 6.1 来源与传递

| 层级 | operatorId 来源 | 传递方式 |
|------|----------------|----------|
| 门面服务 Controller | 解析 Header（`UserInfoUtil.getUserInfo(user).getId()`） | 写入 `{Name}Request.operatorId`，通过 Feign 传递给应用服务 |
| 应用服务 Controller | 从 `{Name}ApiRequest.operatorId` 获取 | 直接获取使用，**禁止**解析 `@RequestHeader` |

### 6.2 强制要求

- 所有写操作（增删改）必须包含 `operatorId`
- `operatorId` 字段在 `ApiRequest` 中必须存在（Long 类型）
- 门面服务负责解析并注入 `operatorId`，应用服务直接使用

### 6.3 代码示例

```java
// ✅ 门面服务 Controller：解析 Header → 写入 Request
@PostMapping("/create")
public CommonResult<Long> create(
        @RequestBody @Valid {Name}CreateRequest request,
        @RequestHeader(AuthConstant.USER_TOKEN_HEADER) String user) {
    Long operatorId = UserInfoUtil.getUserInfo(user).getId();
    request.setOperatorId(operatorId);
    return CommonResult.success(applicationService.create(request));
}

// ✅ 应用服务 Controller：从 ApiRequest 获取 operatorId
@PostMapping("/create")
public CommonResult<Long> create(@RequestBody {Name}CreateApiRequest request) {
    validateCreateRequest(request);
    Long operatorId = request.getOperatorId();
    // ... 业务逻辑
}

// ❌ 错误：应用服务 Controller 中解析 Header
@RequestHeader(AuthConstant.USER_TOKEN_HEADER) String user  // 应用服务禁止
```
