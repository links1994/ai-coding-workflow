# Step: 生成门面服务层

## 目的
生成门面服务层的代码，包括 AdminController/AppController、ApplicationService、Request/Response DTO。

## 输入
- `feature_definition`: Feature 定义
- `validated_plan`: 验证后的生成计划
- `feign_interfaces`: Feign 接口定义

## 输出
- `facade_layer_code`: 门面服务层代码集合

## 生成规范

### 1. AdminController / AppController

**命名规范**：
- 管理后台：`{Name}AdminController`
- C端/App：`{Name}AppController`
- 商家端：`{Name}MerchantController`

**示例**：
```java
@RestController
@RequiredArgsConstructor
@RequestMapping("/admin/api/v1/{path}")
@Tag(name = "{Name}管理")
public class {Name}AdminController {
    
    private final {Name}ApplicationService {name}ApplicationService;
    
    @Operation(summary = "创建{Name}")
    @PostMapping("/create")
    public CommonResult<Long> create(
            @RequestBody @Valid {Name}CreateRequest request,
            @RequestHeader(AuthConstant.USER_TOKEN_HEADER) String user) {
        Long operatorId = TokenUtil.parseUserId(user);
        return {name}ApplicationService.create(request, operatorId);
    }
    
    @Operation(summary = "更新{Name}")
    @PostMapping("/update")
    public CommonResult<Void> update(
            @RequestBody @Valid {Name}UpdateRequest request,
            @RequestHeader(AuthConstant.USER_TOKEN_HEADER) String user) {
        Long operatorId = TokenUtil.parseUserId(user);
        return {name}ApplicationService.update(request, operatorId);
    }
    
    @Operation(summary = "获取{Name}详情")
    @GetMapping("/detail")
    public CommonResult<{Name}Response> getById(@RequestParam("id") Long id) {
        return {name}ApplicationService.getById(id);
    }
    
    @Operation(summary = "分页查询{Name}")
    @PostMapping("/page")
    public CommonResult<CommonResult.PageData<{Name}Response>> page(
            @RequestBody @Valid {Name}PageRequest request) {
        return {name}ApplicationService.page(request);
    }
}
```

**约束**：
- 使用 `@Valid` 进行参数校验
- 从 Header 解析 operatorId
- 仅调用 ApplicationService，禁止直接调用 RemoteService
- 返回门面层自定义的 Response DTO

### 2. ApplicationService

**命名规范**：`{Name}ApplicationService` / `{Name}ApplicationServiceImpl`

**示例**：
```java
@Service
@RequiredArgsConstructor
public class {Name}ApplicationServiceImpl implements {Name}ApplicationService {
    
    private final {Name}RemoteService {name}RemoteService;
    
    @Override
    public CommonResult<Long> create({Name}CreateRequest request, Long operatorId) {
        // String 参数去空格
        String trimmedName = StringUtils.trim(request.getName());
        String trimmedDescription = StringUtils.trim(request.getDescription());
        
        // 构建 ApiRequest
        {Name}CreateApiRequest apiRequest = new {Name}CreateApiRequest();
        apiRequest.setOperatorId(operatorId);
        apiRequest.setName(trimmedName);
        apiRequest.setDescription(trimmedDescription);
        apiRequest.setSortOrder(request.getSortOrder());
        
        // 调用 Feign 接口
        return {name}RemoteService.create{Name}(apiRequest);
    }
    
    @Override
    public CommonResult<{Name}Response> getById(Long id) {
        // String 参数去空格
        Long trimmedId = id; // Long 类型无需去空格
        
        CommonResult<{Name}ApiResponse> result = {name}RemoteService.get{Name}ById(trimmedId);
        
        // 转换为门面层 Response
        if (result.getData() == null) {
            return CommonResult.success(null);
        }
        return CommonResult.success(convertToResponse(result.getData()));
    }
    
    // 转换方法（防腐层）
    private {Name}Response convertToResponse({Name}ApiResponse apiResponse) {
        {Name}Response response = new {Name}Response();
        response.setId(apiResponse.getId());
        response.setName(apiResponse.getName());
        response.setDescription(apiResponse.getDescription());
        response.setSortOrder(apiResponse.getSortOrder());
        response.setStatus(apiResponse.getStatus());
        response.set{关联字段}(apiResponse.get{关联字段}()); // 模块内已填充
        response.setCreateTime(apiResponse.getCreateTime());
        response.setUpdateTime(apiResponse.getUpdateTime());
        return response;
    }
}
```

**约束**：
- **String 参数去空格**：在 ApplicationService 入口统一处理
- **防腐层转换**：将 ApiResponse 转换为门面层 Response
- **禁止直接注入 RemoteService 到 Controller**

### 3. Request DTO

**命名规范**：`{Name}Request`

**示例**：
```java
@Data
public class {Name}CreateRequest {
    
    @NotBlank(message = "{Name}名称不能为空")
    @Size(max = 50, message = "名称长度不能超过50")
    private String name;
    
    @Size(max = 200, message = "描述长度不能超过200")
    private String description;
    
    @NotNull(message = "排序值不能为空")
    @Min(value = 0, message = "排序值不能小于0")
    private Integer sortOrder;
}
```

**约束**：
- 使用 `jakarta.validation` 注解
- **不包含 operatorId**（从 Header 解析）
- 字段命名与前端约定一致

### 4. Response DTO / VO

**命名规范**：`{Name}Response` / `{Name}VO`

**示例**：
```java
@Data
public class {Name}Response {
    
    private Long id;
    
    private String name;
    
    private String description;
    
    private Integer sortOrder;
    
    private Integer status;
    
    private Integer {关联字段};
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;
}
```

**约束**：
- 时间字段使用 `@JsonFormat`
- 字段与前端展示需求对齐
- 模块内关联字段（如 {关联字段}）在应用层已填充

## 生成步骤

1. **生成 Request/Response DTO**
   - 参考 Feign 接口的 ApiRequest/ApiResponse
   - 调整字段（如去掉 operatorId）
   - 添加校验注解

2. **生成 ApplicationService**
   - String 参数去空格处理
   - DTO 转换（Request → ApiRequest，ApiResponse → Response）
   - 调用 Feign 接口

3. **生成 Controller**
   - 注入 ApplicationService
   - 参数校验（@Valid）
   - Header 解析 operatorId
   - 包装返回结果

## 输出文件结构

```
{facade-service}/
├── controller/
│   └── admin/
│       └── {Name}AdminController.java
├── service/
│   ├── {Name}ApplicationService.java
│   └── {Name}ApplicationServiceImpl.java
└── dto/
    ├── request/
    │   ├── {Name}CreateRequest.java
    │   ├── {Name}UpdateRequest.java
    │   └── {Name}PageRequest.java
    └── response/
        └── {Name}Response.java
```

## 常见错误避免

- ❌ Controller 中直接注入 RemoteService
- ❌ Controller 中进行 DTO 转换
- ❌ 门面服务中存在 `feign/` 目录
- ❌ String 参数未去空格
- ❌ 直接返回 ApiResponse 给前端
