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
- 管理后台：`XxxAdminController`
- C端/App：`XxxAppController`
- 商家端：`XxxMerchantController`

**示例**：
```java
@RestController
@RequiredArgsConstructor
@RequestMapping("/admin/api/v1/job-type")
@Tag(name = "岗位类型管理")
public class JobTypeAdminController {
    
    private final JobTypeApplicationService jobTypeApplicationService;
    
    @Operation(summary = "创建岗位类型")
    @PostMapping("/create")
    public CommonResult<Long> create(
            @RequestBody @Valid JobTypeCreateRequest request,
            @RequestHeader(AuthConstant.USER_TOKEN_HEADER) String user) {
        Long operatorId = TokenUtil.parseUserId(user);
        return jobTypeApplicationService.create(request, operatorId);
    }
    
    @Operation(summary = "更新岗位类型")
    @PostMapping("/update")
    public CommonResult<Void> update(
            @RequestBody @Valid JobTypeUpdateRequest request,
            @RequestHeader(AuthConstant.USER_TOKEN_HEADER) String user) {
        Long operatorId = TokenUtil.parseUserId(user);
        return jobTypeApplicationService.update(request, operatorId);
    }
    
    @Operation(summary = "获取岗位类型详情")
    @GetMapping("/detail")
    public CommonResult<JobTypeResponse> getById(@RequestParam("id") Long id) {
        return jobTypeApplicationService.getById(id);
    }
    
    @Operation(summary = "分页查询岗位类型")
    @PostMapping("/page")
    public CommonResult<CommonResult.PageData<JobTypeResponse>> page(
            @RequestBody @Valid JobTypePageRequest request) {
        return jobTypeApplicationService.page(request);
    }
}
```

**约束**：
- 使用 `@Valid` 进行参数校验
- 从 Header 解析 operatorId
- 仅调用 ApplicationService，禁止直接调用 RemoteService
- 返回门面层自定义的 Response DTO

### 2. ApplicationService

**命名规范**：`XxxApplicationService` / `XxxApplicationServiceImpl`

**示例**：
```java
@Service
@RequiredArgsConstructor
public class JobTypeApplicationServiceImpl implements JobTypeApplicationService {
    
    private final AgentEmployeeRemoteService agentEmployeeRemoteService;
    
    @Override
    public CommonResult<Long> create(JobTypeCreateRequest request, Long operatorId) {
        // String 参数去空格
        String trimmedName = StringUtils.trim(request.getName());
        String trimmedDescription = StringUtils.trim(request.getDescription());
        
        // 构建 ApiRequest
        JobTypeCreateApiRequest apiRequest = new JobTypeCreateApiRequest();
        apiRequest.setOperatorId(operatorId);
        apiRequest.setName(trimmedName);
        apiRequest.setDescription(trimmedDescription);
        apiRequest.setSortOrder(request.getSortOrder());
        
        // 调用 Feign 接口
        return agentEmployeeRemoteService.createJobType(apiRequest);
    }
    
    @Override
    public CommonResult<JobTypeResponse> getById(Long id) {
        // String 参数去空格
        Long trimmedId = id; // Long 类型无需去空格
        
        CommonResult<JobTypeApiResponse> result = agentEmployeeRemoteService.getJobTypeById(trimmedId);
        
        // 转换为门面层 Response
        if (result.getData() == null) {
            return CommonResult.success(null);
        }
        return CommonResult.success(convertToResponse(result.getData()));
    }
    
    // 转换方法（防腐层）
    private JobTypeResponse convertToResponse(JobTypeApiResponse apiResponse) {
        JobTypeResponse response = new JobTypeResponse();
        response.setId(apiResponse.getId());
        response.setName(apiResponse.getName());
        response.setDescription(apiResponse.getDescription());
        response.setSortOrder(apiResponse.getSortOrder());
        response.setStatus(apiResponse.getStatus());
        response.setEmployeeCount(apiResponse.getEmployeeCount()); // 模块内已填充
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

**命名规范**：`XxxRequest`

**示例**：
```java
@Data
public class JobTypeCreateRequest {
    
    @NotBlank(message = "岗位类型名称不能为空")
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

**命名规范**：`XxxResponse` / `XxxVO`

**示例**：
```java
@Data
public class JobTypeResponse {
    
    private Long id;
    
    private String name;
    
    private String description;
    
    private Integer sortOrder;
    
    private Integer status;
    
    private Integer employeeCount;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;
}
```

**约束**：
- 时间字段使用 `@JsonFormat`
- 字段与前端展示需求对齐
- 模块内关联字段（如 employeeCount）在应用层已填充

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
mall-admin/
├── controller/
│   └── admin/
│       └── JobTypeAdminController.java
├── service/
│   ├── JobTypeApplicationService.java
│   └── JobTypeApplicationServiceImpl.java
└── dto/
    ├── request/
    │   ├── JobTypeCreateRequest.java
    │   ├── JobTypeUpdateRequest.java
    │   └── JobTypePageRequest.java
    └── response/
        └── JobTypeResponse.java
```

## 常见错误避免

- ❌ Controller 中直接注入 RemoteService
- ❌ Controller 中进行 DTO 转换
- ❌ 门面服务中存在 `feign/` 目录
- ❌ String 参数未去空格
- ❌ 直接返回 ApiResponse 给前端
