---
trigger: model_decision
description: 门面服务代码生成规范 - 生成门面服务 Controller/ApplicationService/DTO 时适用
globs: [ "**/*.java" ]
---

# 门面服务代码生成规范

> **适用服务**：{facade-service} / {facade-service-3} / {facade-service-2} / {facade-service-4}

---

## 1. 门面服务分层规范

### 1.1 分层结构（强制）

门面服务**必须**遵循以下三层结构，**禁止任何例外**：

```
Controller（接口层，参数校验）
    ↓ 只调用 ApplicationService
{Name}ApplicationService（编排层，数据聚合 & VO 组装）
    ↓ 通过 RemoteService（Feign）调用
应用服务 / 基础数据服务
```

### 1.2 各层职责与禁止事项

| 层级 | 命名规范 | 职责 | 严禁 |
|----------------------|-------------------------------------------------------|--------------------------------------|-----------------------------------------------|
| Controller | `{Name}AdminController` / `{Name}AppController` | 接收请求、参数校验、调用 ApplicationService、包装响应 | 禁止直接注入并调用 RemoteService；禁止业务逻辑；禁止 DTO 转换 |
| ApplicationService | `{Name}ApplicationService` / `{Name}ApplicationServiceImpl` | 业务编排、聚合多个 Feign 调用、数据转换、VO 组装 | 禁止直接访问数据库（Mapper/Repository）；禁止创建本地 Feign 包装类 |
| RemoteService（Feign） | 引用 `{inner-api-service}` 中定义的 `{Name}RemoteService` | 远程服务调用 | 禁止在门面服务中新建 feign 目录或本地 Feign 客户端 |

**常见错误（❌ 必须避免）**：

- ❌ Controller 中直接注入 `{Name}RemoteService` 并调用
- ❌ Controller 中进行 DTO 转换和业务编排
- ❌ 门面服务中存在 `feign/` 目录
- ❌ 门面服务中创建本地 `{Name}FeignClient` 包装类

---

## 2. 门面服务 vs 应用服务差异规范

### 2.1 参数校验规范

| 层级 | 校验方式 | 说明 |
|--------------------------|------------------------------------------------|-------------------------|
| 门面服务 Controller | 使用 `jakarta.validation`（`@Valid`、`@NotNull` 等） | 自动校验，快速失败 |
| 应用服务 / 基础数据服务 Controller | **禁止使用 `jakarta.validation`**，必须手动校验 | 手动编写 `validate{Name}()` 方法 |

### 2.2 完整差异对比

| 差异维度 | 门面服务 | 应用服务 / 基础数据服务 |
|---------------|---------------------------------------------------------------------|-------------------------------------------------|
| 路径参数 | 允许，最多 1 个，且必须放在 URL 最后 | **严禁**使用 `@PathVariable` |
| HTTP 方法 | 完整 RESTful（GET / POST / PUT / DELETE） | 仅 GET / POST，禁止 PUT / DELETE |
| 参数传递 | GET 用 `@RequestParam`；POST/PUT/DELETE：业务参数（排除 `@RequestHeader`、`pageNum`/`pageSize` 等常规参数）**> 2 个**时封装为 `@RequestBody`，≤ 2 个业务参数可用 `@RequestParam` | ≤ 2 个基础类型用 `@RequestParam`；其他一律用 `@RequestBody` |
| 参数校验 | 使用 `@Valid` + `jakarta.validation` 注解 | **禁止 `@Valid`**，手动编写 `validate{Name}()` 方法 |
| 请求对象 | `{Name}Request`（前端请求） | `{Name}ApiRequest`（写操作必含 `operatorId` 字段） |
| 返回对象 | `{Name}Response` / `{Name}VO`（含 `@JsonFormat`） | `{Name}ApiResponse`（含 `@JsonFormat`） |
| Controller 命名 | `{Name}AdminController` / `{Name}AppController` / `{Name}MerchantController` | `{Name}InnerController` |
| 包路径 | `controller/admin/` 或 `controller/app/` 等 | `controller/inner/` |
| 路径前缀 | `/admin/api/v1/` 等 | `/inner/api/v1/` |
| operatorId 来源 | 解析 Header → 写入 ApiRequest | 从 `ApiRequest.operatorId` 获取 |

### 2.3 应用服务手动校验完整示例

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

**常见错误（❌ 必须避免）**：

```java
// ❌ 错误：应用服务禁止使用 @Valid
@RequestBody
@Valid
{Name}CreateApiRequest request

// ❌ 错误：应用服务禁止直接解析 Header
@RequestHeader(AuthConstant.USER_TOKEN_HEADER)
String user

// ❌ 错误：应用服务 Controller 缺少 validate{Name}() 方法
public CommonResult<Long> create(@RequestBody {Name}CreateApiRequest request) {
    // 直接进入业务逻辑，无参数校验
}
```

---

## 3. String 参数去空格转换规范

**适用对象**：门面服务（{facade-service} / {facade-service-3} / {facade-service-2} / {facade-service-4}）的 ApplicationService 层

**核心原则**：门面服务从前端接收的 String 类型参数，在传递给下游方法前必须进行去空格处理。

### 3.1 转换职责

| 层级 | 职责 | 禁止事项 |
|-------------------------|--------------------------------|----------------------------|
| Controller | 接收原始请求，不做任何字符串处理 | 禁止在 Controller 层进行 trim 操作 |
| ApplicationService | 统一进行 String 参数去空格转换，再传递给下游方法调用 | 禁止将未去空格的 String 参数传递给下游方法 |
| 应用服务 / 基础数据服务（Feign 调用） | 接收已去空格的参数，不再重复处理 | 禁止假设参数可能包含前后空格 |

### 3.2 转换规则

**需要去空格的场景**：

- 所有 String 类型的查询参数（keyword、name、code 等）
- 所有 String 类型的排序字段（sortBy、orderBy 等）
- 所有 String 类型的枚举值（status、type 等）
- 所有 String 类型的标识符（id 的 String 形式、bizCode 等）

**不需要去空格的场景**：

- 文本内容字段（description、content、remark 等多字符富文本）
- 经过验证的 token、signature 等安全相关字段
- Base64 编码的字符串
- URL、文件路径等对空格敏感的字段

### 3.3 实现示例

```java
// ✅ 正确：ApplicationService 层统一去空格
@Service
@RequiredArgsConstructor
public class {Domain}ApplicationServiceImpl implements {Domain}ApplicationService {
    private final {Domain}QueryService {domain}QueryService;

    public CommonResult<{Domain}Response> get{Domain}ByName(String name) {
        // ApplicationService 层进行去空格转换
        String trimmedName = StringUtils.trim(name);
        return {domain}QueryService.get{Domain}ByName(trimmedName);
    }

    public CommonResult.PageData<{Domain}Response> page{Domain}s(
            String keyword,
            String sortBy,
            String status) {
        // 所有 String 参数统一去空格
        String trimmedKeyword = StringUtils.trim(keyword);
        String trimmedSortBy = StringUtils.trim(sortBy);
        String trimmedStatus = StringUtils.trim(status);

        {Domain}PageQuery query = new {Domain}PageQuery();
        query.setKeyword(trimmedKeyword);
        query.setSortBy(trimmedSortBy);
        query.setStatus(trimmedStatus);

        return {domain}QueryService.page{Domain}s(query);
    }
}

// ❌ 错误：未去空格直接传递
public CommonResult<{Domain}Response> get{Domain}ByName(String name) {
    // 直接将原始参数传递给下游，可能导致查询结果不准确
    return {domain}QueryService.get{Domain}ByName(name);
}

// ❌ 错误：在 Controller 层去空格
@PostMapping("/search")
public CommonResult<{Domain}Response> search{Domain}(
        @RequestBody @Valid {Domain}SearchRequest request) {
    // 不应该在 Controller 层做去空格逻辑
    String trimmedKeyword = StringUtils.trim(request.getKeyword());
    return {domain}ApplicationService.search{Domain}(trimmedKeyword);
}
```

### 3.4 工具类使用

推荐使用 Apache Commons Lang 的 `StringUtils`：

```java
import org.apache.commons.lang3.StringUtils;

// 安全处理 null 值
String trimmed = StringUtils.trim(str);  // null 返回 null，不会 NPE
String trimmedToEmpty = StringUtils.defaultString(StringUtils.trim(str), "");  // null 返回 ""
```

**禁止行为**：

- ❌ 使用 `str.trim()`（可能 NPE）
- ❌ 在多个位置重复去空格（应在 ApplicationService 入口统一处理）
- ❌ 只去空格不校验（去空格后应检查是否为空）

### 3.5 与参数校验的配合

去空格后应立即进行参数校验：

```java
public CommonResult<{Domain}Response> get{Domain}ByCode(String code) {
    // Step 1: 去空格
    String trimmedCode = StringUtils.trim(code);

    // Step 2: 校验（去空格后检查）
    if (StringUtils.isBlank(trimmedCode)) {
        throw new BusinessException({Domain}ErrorCodeEnum.PARAM_ERROR, "{业务实体}代码不能为空");
    }

    // Step 3: 传递给下游
    return {domain}QueryService.get{Domain}ByCode(trimmedCode);
}
```
