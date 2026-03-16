---
trigger: model_decision
description: 服务层规范 - 生成 Controller/ApplicationService/Feign 接口/异常处理/日志时适用
globs: [ "**/*.java" ]
---

# 服务层规范

> **适用范围**：Controller、ApplicationService、Feign 接口、异常处理、日志

---

## 1. 异常处理规范

### 1.1 三种标准异常

仅允许使用以下三种标准异常类型：

| 异常类型 | 使用场景 |
|----------|----------|
| `MethodArgumentValidationException` | 参数校验失败 |
| `RemoteApiCallException` | 远程服务调用失败 |
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

### 1.3 远程调用结果处理规范

**适用层级**：`ApplicationService` 层（门面服务或应用服务均适用）

**核心分工原则**：

| 场景 | 处理方式 | 说明 |
|------|----------|------|
| 本地业务规则违反 | 抛出 `BusinessException` | 由全局异常处理器统一转换为失败响应 |
| 远程调用业务失败（对端返回非成功 `CommonResult`） | 调用 `CommonResult.failed(Long, String)` 直接透传 | 将远端错误码和错误消息原样返回，不抛异常 |
| 远程通信级别异常（网络超时、服务不可用） | 抛出 `RemoteApiCallException` | 由全局异常处理器统一转换为失败响应 |

**远端错误透传规则**：
- 在 `ApplicationService` 层调用 Feign 接口后，必须校验返回的 `CommonResult` 是否成功
- 若 `CommonResult` 标示业务失败（`!result.isSuccess()`），则直接返回 `CommonResult.failed(result.getCode(), result.getMessage())`
- **禁止**将远端业务失败包装为 `BusinessException` 抛出（会丢失原始错误码语义）
- **禁止**在 `QueryService` / `ManageService` 层处理远程调用结果

```java
// 正确：ApplicationService 层透传远端业务失败
public CommonResult<{Domain}ApiResponse> get{Domain}Detail(Long {domain}Id) {
    CommonResult<{Domain}ApiResponse> result = {domain}RemoteService.getById({domain}Id);
    if (!result.isSuccess()) {
        // 远端错误码透传，不抛异常
        return CommonResult.failed(result.getCode(), result.getMessage());
    }
    return result;
}

// 错误：将远端业务失败包装为本地 BusinessException（丢失原始错误码）
public CommonResult<{Domain}ApiResponse> get{Domain}Detail(Long {domain}Id) {
    CommonResult<{Domain}ApiResponse> result = {domain}RemoteService.getById({domain}Id);
    if (!result.isSuccess()) {
        throw new BusinessException({Domain}ErrorCodeEnum.SYSTEM_ERROR, result.getMessage()); // 错误
    }
    return result;
}

// 错误：未校验 CommonResult 直接取 data（可能 NPE 且忽略业务失败）
public {Domain}ApiResponse get{Domain}Detail(Long {domain}Id) {
    return {domain}RemoteService.getById({domain}Id).getData(); // 错误
}
```

---

## 2. 参数注解规范

### 2.1 门面服务参数规则

```java
// GET + 多个 RequestParam（适合简单查询）
@GetMapping("/list")
public CommonResult<CommonResult.PageData<{Domain}Response>> page{Domain}(
        @RequestParam(name = "keyword", required = false) String keyword,
        @RequestParam(name = "pageNum", defaultValue = "1") Integer pageNum,
        @RequestParam(name = "pageSize", defaultValue = "10") Integer pageSize) {
    // ...
}

// GET + PathVariable（仅允许1个，且必须放在 URL 最后）
@GetMapping("/detail/{id}")
public CommonResult<{Domain}Response> get{Domain}Detail(@PathVariable Long id) {
    // ...
}

// POST + RequestBody（复杂参数）
@PostMapping("/create")
public CommonResult<Long> create{Domain}(@RequestBody @Valid {Domain}CreateRequest request) {
    // ...
}
```

### 2.2 应用服务参数规则

```java
// GET + RequestParam（≤2个基础类型参数）
@GetMapping("/detail")
public CommonResult<{Domain}ApiResponse> getById(@RequestParam Long id) {
    // ...
}

// POST + RequestBody（其他情况一律用 RequestBody）
@PostMapping("/create")
public CommonResult<Long> create(@RequestBody {Domain}CreateApiRequest request) {
    // ...
}

// 应用服务禁止 @PathVariable、@Valid
```

### 2.3 参数校验规则

| 层级 | 校验方式 | 说明 |
|------|----------|------|
| 门面服务 Controller | 使用 `jakarta.validation`（`@Valid`、`@NotNull` 等） | 自动校验，快速失败 |
| 应用服务 / 基础数据服务 Controller | **禁止使用 `jakarta.validation`**，必须手动校验 | 手动编写 `validate{Name}()` 方法 |

**应用服务手动校验示例**：

```java
@PostMapping("/create")
public CommonResult<Long> create(@RequestBody {Name}CreateApiRequest request) {
    validateCreateRequest(request);
    Long operatorId = request.getOperatorId();
    // ... 业务逻辑
}

private void validateCreateRequest({Name}CreateApiRequest request) {
    if (request == null) {
        throw new BusinessException({Domain}ErrorCodeEnum.PARAM_ERROR, "请求参数不能为空");
    }
    if (StringUtils.isBlank(request.getName())) {
        throw new BusinessException({Domain}ErrorCodeEnum.PARAM_ERROR, "名称不能为空");
    }
    if (request.getOperatorId() == null) {
        throw new BusinessException({Domain}ErrorCodeEnum.PARAM_ERROR, "操作人ID不能为空");
    }
}
```

---

## 3. 日志规范

### 3.1 日志级别使用

| 级别 | 使用场景 |
|------|----------|
| ERROR | 系统异常、需要立即处理的错误 |
| WARN | 业务异常、可预期的异常情况 |
| INFO | 业务流程关键节点、外部调用入参出参 |
| DEBUG | 详细调试信息、SQL 语句、方法入参 |

### 3.2 日志内容规范

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

### 3.3 禁止事项

- **禁止**在循环中打印日志
- **禁止**打印敏感信息（密码、Token、手机号等）
- **禁止**使用字符串拼接方式打印日志（使用占位符 `{}`）

---

## 4. 操作人 ID 规范

### 4.1 来源与传递

| 层级 | 操作人 ID 来源 | 传递方式 |
|------|----------------|----------|
| 门面服务 Controller | 解析 Header（如 `X-User-Id`） | 写入 Request 对象的 `operatorId` 字段 |
| 应用服务 Controller | 从 ApiRequest.operatorId 获取 | 直接获取使用 |

### 4.2 代码示例

```java
// 门面服务 Controller
@PostMapping("/create")
public CommonResult<Long> create(
        @RequestBody @Valid {Name}CreateRequest request,
        @RequestHeader(AuthConstant.USER_TOKEN_HEADER) String userToken) {
    // 解析 userToken 获取 operatorId
    Long operatorId = parseOperatorId(userToken);
    request.setOperatorId(operatorId);
    return {name}ApplicationService.create(request);
}

// 应用服务 Controller
@PostMapping("/create")
public CommonResult<Long> create(@RequestBody {Name}CreateApiRequest request) {
    Long operatorId = request.getOperatorId();
    // ... 业务逻辑
}
```

### 4.3 强制要求

- 所有写操作（增删改）必须包含 `operatorId`
- `operatorId` 字段在 `ApiRequest` 中必须存在
- 门面服务负责解析并注入 `operatorId`，应用服务直接使用

---

## 5. CommonResult 使用规范

### 5.1 响应格式

```java
// 成功响应
return CommonResult.success(data);

// 成功分页响应
return CommonResult.success(pageData);

// 失败响应（使用错误码枚举）
return CommonResult.failed(ErrorCodeEnum.PARAM_ERROR);

// 失败响应（自定义错误码和消息）
return CommonResult.failed(200101001, "{参数名}不能为空");
```

### 5.2 响应结构

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

### 5.3 使用约束

- Controller 层必须返回 `CommonResult<T>`
- 禁止直接返回原始对象（如 `{Domain}Response`）
- 分页数据使用 `CommonResult.PageData<T>`
