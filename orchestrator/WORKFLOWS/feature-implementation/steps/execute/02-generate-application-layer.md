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

**命名规范**：`{Name}InnerController`

**示例**：
```java
@RestController
@RequiredArgsConstructor
@RequestMapping("/inner/api/v1/{path}")
public class {Name}InnerController {
    
    private final {Name}ApplicationService jobTypeApplicationService;
    
    @PostMapping("/create")
    public CommonResult<Long> create(@RequestBody {Name}CreateApiRequest request) {
        validateCreateRequest(request);
        return jobTypeApplicationService.create(request);
    }
    
    @PostMapping("/update")
    public CommonResult<Void> update(@RequestBody {Name}UpdateApiRequest request) {
        validateUpdateRequest(request);
        return jobTypeApplicationService.update(request);
    }
    
    @GetMapping("/detail")
    public CommonResult<{Name}ApiResponse> getById(@RequestParam("id") Long id) {
        if (id == null) {
            throw new BusinessException(AgentErrorCodeEnum.PARAM_ERROR, "ID不能为空");
        }
        return jobTypeApplicationService.getById(id);
    }
    
    @PostMapping("/page")
    public CommonResult<CommonResult.PageData<{Name}ApiResponse>> page(
            @RequestBody {Name}PageApiRequest request) {
        validatePageRequest(request);
        return jobTypeApplicationService.page(request);
    }
    
    // 手动校验方法
    private void validateCreateRequest({Name}CreateApiRequest request) {
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
- **禁止使用 `@Valid`**，必须手动编写 `validate{Name}()` 方法
- **禁止使用 `@PathVariable`**，使用 `@RequestParam`
- 仅支持 GET / POST，禁止 PUT / DELETE
- 写操作请求对象必须继承 `operatorId`

### 2. ApplicationService

**命名规范**：`{Name}ApplicationService` / `{Name}ApplicationServiceImpl`

**示例**：
```java
public interface {Name}ApplicationService {
    CommonResult<Long> create({Name}CreateApiRequest request);
    CommonResult<Void> update({Name}UpdateApiRequest request);
    CommonResult<{Name}ApiResponse> getById(Long id);
    CommonResult<CommonResult.PageData<{Name}ApiResponse>> page({Name}PageApiRequest request);
}

@Service
@RequiredArgsConstructor
public class {Name}ApplicationServiceImpl implements {Name}ApplicationService {
    
    private final {Name}QueryService jobTypeQueryService;
    private final {Name}ManageService jobTypeManageService;
    
    @Override
    public CommonResult<Long> create({Name}CreateApiRequest request) {
        // 业务编排
        Aim{Name}DO entity = convertToDO(request);
        jobTypeManageService.save(entity);
        return CommonResult.success(entity.getId());
    }
    
    @Override
    public CommonResult<{Name}ApiResponse> getById(Long id) {
        Aim{Name}DO entity = jobTypeQueryService.getById(id);
        if (entity == null) {
            return CommonResult.success(null);
        }
        return CommonResult.success(convertToApiResponse(entity));
    }
    
    // 转换方法
    private {Name}ApiResponse convertToApiResponse(Aim{Name}DO entity) {
        {Name}ApiResponse response = new {Name}ApiResponse();
        response.setId(entity.getId());
        response.setName(entity.getName());
        // ... 其他字段
        
        // 模块内关联字段就近填充
        Integer employeeCount = jobTypeQueryService.countEmployeesBy{Name}Id(entity.getId());
        response.setEmployeeCount(employeeCount);
        
        return response;
    }
}
```

### 3. QueryService

**命名规范**：`{Name}QueryService` / `{Name}QueryServiceImpl`

**职责**：
- 只读查询操作
- 封装复杂查询逻辑
- 返回 DO 或基础类型

### 4. ManageService

**命名规范**：`{Name}ManageService` / `{Name}ManageServiceImpl`

**职责**：
- 增删改操作
- 业务规则校验
- 数据持久化

### 5. Mapper

**命名规范**：`Aim{Name}Mapper`

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
{app-service}/
├── controller/
│   └── inner/
│       └── {Name}InnerController.java
├── service/
│   ├── {Name}ApplicationService.java
│   ├── {Name}ApplicationServiceImpl.java
│   ├── {Name}QueryService.java
│   ├── {Name}QueryServiceImpl.java
│   ├── {Name}ManageService.java
│   └── {Name}ManageServiceImpl.java
├── domain/
│   └── entity/
│       └── Aim{Name}DO.java
└── mapper/
    ├── {Name}Mapper.java
    └── xml/
        └── {Name}Mapper.xml
```

## 依赖检查

生成前必须检查：
1. Feign 接口是否已生成（ApiRequest/ApiResponse）
2. 数据库表是否存在
3. 依赖的其他服务接口是否可用
