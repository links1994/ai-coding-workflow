# Step: 生成应用服务层

## 目的
生成应用服务层的完整代码，包括 InnerController、ApplicationService、QueryService、ManageService、Mapper。

## 输入
- `feature_definition`: Feature 定义
- `validated_plan`: 验证后的生成计划
- `feign_interfaces`: Feign 接口定义

## 输出
- `application_layer_code`: 应用服务层代码集合

## 生成规范

### 1. InnerController

**命名规范**：`XxxInnerController`

**示例**：
```java
@RestController
@RequiredArgsConstructor
@RequestMapping("/inner/api/v1/job-type")
public class JobTypeInnerController {
    
    private final JobTypeApplicationService jobTypeApplicationService;
    
    @PostMapping("/create")
    public CommonResult<Long> create(@RequestBody JobTypeCreateApiRequest request) {
        validateCreateRequest(request);
        return jobTypeApplicationService.create(request);
    }
    
    @PostMapping("/update")
    public CommonResult<Void> update(@RequestBody JobTypeUpdateApiRequest request) {
        validateUpdateRequest(request);
        return jobTypeApplicationService.update(request);
    }
    
    @GetMapping("/detail")
    public CommonResult<JobTypeApiResponse> getById(@RequestParam("id") Long id) {
        if (id == null) {
            throw new BusinessException(AgentErrorCodeEnum.PARAM_ERROR, "ID不能为空");
        }
        return jobTypeApplicationService.getById(id);
    }
    
    @PostMapping("/page")
    public CommonResult<CommonResult.PageData<JobTypeApiResponse>> page(
            @RequestBody JobTypePageApiRequest request) {
        validatePageRequest(request);
        return jobTypeApplicationService.page(request);
    }
    
    // 手动校验方法
    private void validateCreateRequest(JobTypeCreateApiRequest request) {
        if (request == null) {
            throw new BusinessException(AgentErrorCodeEnum.PARAM_ERROR, "请求参数不能为空");
        }
        if (StringUtils.isBlank(request.getName())) {
            throw new BusinessException(AgentErrorCodeEnum.PARAM_ERROR, "名称不能为空");
        }
        if (request.getOperatorId() == null) {
            throw new BusinessException(AgentErrorCodeEnum.PARAM_ERROR, "操作人ID不能为空");
        }
    }
}
```

**约束**：
- **禁止使用 `@Valid`**，必须手动编写 `validateXxx()` 方法
- **禁止使用 `@PathVariable`**，使用 `@RequestParam`
- 仅支持 GET / POST，禁止 PUT / DELETE
- 写操作请求对象必须继承 `operatorId`

### 2. ApplicationService

**命名规范**：`XxxApplicationService` / `XxxApplicationServiceImpl`

**示例**：
```java
public interface JobTypeApplicationService {
    CommonResult<Long> create(JobTypeCreateApiRequest request);
    CommonResult<Void> update(JobTypeUpdateApiRequest request);
    CommonResult<JobTypeApiResponse> getById(Long id);
    CommonResult<CommonResult.PageData<JobTypeApiResponse>> page(JobTypePageApiRequest request);
}

@Service
@RequiredArgsConstructor
public class JobTypeApplicationServiceImpl implements JobTypeApplicationService {
    
    private final JobTypeQueryService jobTypeQueryService;
    private final JobTypeManageService jobTypeManageService;
    
    @Override
    public CommonResult<Long> create(JobTypeCreateApiRequest request) {
        // 业务编排
        AimJobTypeDO entity = convertToDO(request);
        jobTypeManageService.save(entity);
        return CommonResult.success(entity.getId());
    }
    
    @Override
    public CommonResult<JobTypeApiResponse> getById(Long id) {
        AimJobTypeDO entity = jobTypeQueryService.getById(id);
        if (entity == null) {
            return CommonResult.success(null);
        }
        return CommonResult.success(convertToApiResponse(entity));
    }
    
    // 转换方法
    private JobTypeApiResponse convertToApiResponse(AimJobTypeDO entity) {
        JobTypeApiResponse response = new JobTypeApiResponse();
        response.setId(entity.getId());
        response.setName(entity.getName());
        // ... 其他字段
        
        // 模块内关联字段就近填充
        Integer employeeCount = jobTypeQueryService.countEmployeesByJobTypeId(entity.getId());
        response.setEmployeeCount(employeeCount);
        
        return response;
    }
}
```

### 3. QueryService

**命名规范**：`XxxQueryService` / `XxxQueryServiceImpl`

**职责**：
- 只读查询操作
- 封装复杂查询逻辑
- 返回 DO 或基础类型

### 4. ManageService

**命名规范**：`XxxManageService` / `XxxManageServiceImpl`

**职责**：
- 增删改操作
- 业务规则校验
- 数据持久化

### 5. Mapper

**命名规范**：`AimXxxMapper`

**约束**：
- 所有查询走 XML
- 禁止在 Mapper 接口上写 SQL 注解
- 复杂查询使用自定义 XML

## 生成步骤

1. **生成 Entity/DO**
   - 根据数据库表结构生成
   - 添加 MyBatis-Plus 注解

2. **生成 Mapper 接口和 XML**
   - 基础 CRUD 继承 BaseMapper
   - 自定义查询在 XML 中实现

3. **生成 QueryService/ManageService**
   - 接口与实现分离
   - 封装数据访问逻辑

4. **生成 ApplicationService**
   - 业务编排逻辑
   - DTO 转换方法
   - 模块内关联字段填充

5. **生成 InnerController**
   - 实现 Feign 接口对应的方法
   - 手动参数校验
   - 调用 ApplicationService

## 输出文件结构

```
mall-agent-employee-service/
├── controller/
│   └── inner/
│       └── JobTypeInnerController.java
├── service/
│   ├── JobTypeApplicationService.java
│   ├── JobTypeApplicationServiceImpl.java
│   ├── JobTypeQueryService.java
│   ├── JobTypeQueryServiceImpl.java
│   ├── JobTypeManageService.java
│   └── JobTypeManageServiceImpl.java
├── domain/
│   └── entity/
│       └── AimJobTypeDO.java
└── mapper/
    ├── JobTypeMapper.java
    └── xml/
        └── JobTypeMapper.xml
```

## 依赖检查

生成前必须检查：
1. Feign 接口是否已生成（ApiRequest/ApiResponse）
2. 数据库表是否存在
3. 依赖的其他服务接口是否可用
