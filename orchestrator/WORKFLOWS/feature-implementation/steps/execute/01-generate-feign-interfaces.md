# Step: 生成 Feign 接口

## 目的
生成 mall-inner-api 中的 Feign 接口定义，包括 RemoteService 和 ApiRequest/ApiResponse。

## 输入
- `feature_definition`: Feature 定义
- `validated_plan`: 验证后的生成计划

## 输出
- `feign_interfaces`: Feign 接口文件集合

## 生成规范

### 1. RemoteService 接口

**命名规范**：`{模块名}RemoteService`

**示例**：
```java
@FeignClient("mall-agent-employee-service")
public interface AgentEmployeeRemoteService {
    
    @PostMapping("/inner/api/v1/job-type/create")
    CommonResult<Long> createJobType(@RequestBody JobTypeCreateApiRequest request);
    
    @PostMapping("/inner/api/v1/job-type/update")
    CommonResult<Void> updateJobType(@RequestBody JobTypeUpdateApiRequest request);
    
    @GetMapping("/inner/api/v1/job-type/detail")
    CommonResult<JobTypeApiResponse> getJobTypeById(@RequestParam("id") Long id);
    
    @PostMapping("/inner/api/v1/job-type/page")
    CommonResult<CommonResult.PageData<JobTypeApiResponse>> pageJobTypes(
            @RequestBody JobTypePageApiRequest request);
}
```

**约束**：
- 使用 `@RequestParam` 而非 `@PathVariable`
- 查询类用 GET，操作类用 POST
- 返回类型统一包装为 `CommonResult`

### 2. ApiRequest

**命名规范**：`Xxx + ApiRequest`

**示例**：
```java
@Data
public class JobTypeCreateApiRequest {
    
    @NotNull(message = "操作人ID不能为空")
    private Long operatorId;
    
    @NotBlank(message = "岗位类型名称不能为空")
    private String name;
    
    private String description;
    
    @NotNull(message = "排序值不能为空")
    private Integer sortOrder;
}
```

**约束**：
- 写操作必须包含 `operatorId` 字段
- 使用 `jakarta.validation` 注解进行参数校验
- 字段类型与数据库表对应

### 3. ApiResponse

**命名规范**：`Xxx + ApiResponse`

**示例**：
```java
@Data
public class JobTypeApiResponse {
    
    private Long id;
    
    private String name;
    
    private String description;
    
    private Integer sortOrder;
    
    private Integer status;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;
    
    // 模块内关联字段就近填充
    private Integer employeeCount;
}
```

**约束**：
- 时间字段使用 `@JsonFormat` 注解
- 模块内关联字段（id + name）就近填充
- 跨模块关联只返回 id

## 生成步骤

1. **分析 Feature 接口需求**
   - 根据 acceptance_criteria 识别需要的接口
   - 确定 CRUD 操作类型

2. **生成 ApiRequest/ApiResponse**
   - 根据数据库表字段生成 DTO
   - 添加必要的校验注解
   - 处理关联字段

3. **生成 RemoteService 接口**
   - 定义方法签名
   - 添加 FeignClient 注解
   - 配置 URL 映射

4. **验证接口一致性**
   - 检查方法命名规范
   - 验证参数类型匹配
   - 确认返回类型正确

## 输出文件结构

```
mall-inner-api/
├── feign/
│   └── AgentEmployeeRemoteService.java
├── request/
│   ├── JobTypeCreateApiRequest.java
│   ├── JobTypeUpdateApiRequest.java
│   └── JobTypePageApiRequest.java
└── response/
    └── JobTypeApiResponse.java
```

## 可信源声明

**Feign 接口是本流程的可信源之一**：
- ApiRequest/ApiResponse 的字段定义以此为准
- 应用服务和门面服务必须遵循此接口契约
- 接口变更会触发下游代码的级联更新
