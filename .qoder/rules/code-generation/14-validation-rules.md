# 验证规则规范

> **适用范围**：所有输入验证、参数校验、业务规则检查
>
> **关联规范**：
> - 门面服务 `@Valid` 校验规则详见 [`01-facade-service.md §2`](./01-facade-service.md)
> - 应用服务手动 `validate()` 规则详见 [`02-inner-service.md §2`](./02-inner-service.md)
> - 远程调用结果验证详见 [`00-common-constraints.md §2`](./00-common-constraints.md)
> - operatorId 规则详见 [`00-common-constraints.md §6`](./00-common-constraints.md)

---

## 验证分层

### 分层验证策略

| 层级 | 验证方式 | 验证内容 | 错误处理 |
|------|----------|----------|----------|
| **Controller（门面）** | `@Valid` + 注解（详见 `01-facade-service.md §2`） | 必填字段、格式、范围 | GlobalExceptionHandler 处理 |
| **Controller（内部）** | 手动 `validate()` 方法（详见 `02-inner-service.md §2`） | 必填字段、业务规则 | 返回业务错误码 |
| **ApplicationService** | 断言 + 业务校验 | 业务逻辑、权限 | 抛出 BusinessException |
| **ManageService** | 数据存在性校验 | 记录存在性、状态 | 抛出 BusinessException |
| **数据库** | 约束 | 唯一性、外键 | 数据库异常 |

### 验证顺序

```
请求 → Controller 参数校验 → ApplicationService 业务校验 → ManageService 数据校验 → 数据库
```

---

## 门面 Controller 验证

> `@Valid` 注解用法及常用验证注解详见 `01-facade-service.md §2`

### 常用验证注解（快速参考）

| 注解 | 用途 | 示例 |
|------|------|------|
| `@NotNull` | 非 null | `@NotNull(message = "ID不能为空")` |
| `@NotBlank` | 非空字符串 | `@NotBlank(message = "名称不能为空")` |
| `@NotEmpty` | 非空集合 | `@NotEmpty(message = "列表不能为空")` |
| `@Size` | 长度范围 | `@Size(min = 2, max = 50, message = "名称长度2-50")` |
| `@Min` / `@Max` | 数值范围 | `@Min(value = 0, message = "排序值不能小于0")` |
| `@Pattern` | 正则匹配 | `@Pattern(regexp = "^[a-zA-Z0-9]+$", message = "只能包含字母数字")` |
| `@Email` | 邮箱格式 | `@Email(message = "邮箱格式不正确")` |
| `@Positive` | 正数 | `@Positive(message = "必须为正数")` |

### 分组验证

```java
// 定义验证组
public interface CreateGroup {}
public interface UpdateGroup {}

// DTO 中使用分组
@Data
public class {Name}Request {
    @NotNull(groups = UpdateGroup.class, message = "更新时ID不能为空")
    private Long id;
    
    @NotBlank(groups = {CreateGroup.class, UpdateGroup.class}, message = "名称不能为空")
    private String name;
}

// Controller 中指定分组
@PostMapping("/create")
public CommonResult<Long> create(
        @RequestBody @Validated(CreateGroup.class) {Name}CreateRequest request) { }

@PostMapping("/update")
public CommonResult<Void> update(
        @RequestBody @Validated(UpdateGroup.class) {Name}UpdateRequest request) { }
```

---

## 内部 Controller 验证

> 手动 `validateXxx()` 方法的完整示例详见 `02-inner-service.md §2`

### 验证规则清单

**创建操作验证**：
- [ ] `operatorId` 不为 null
- [ ] 必填字段不为 null/blank
- [ ] 字符串字段长度在允许范围内
- [ ] 数值字段在有效范围内
- [ ] 枚举值在有效范围内

**更新操作验证**：
- [ ] `id` 不为 null
- [ ] `operatorId` 不为 null
- [ ] 记录存在性（在 Service 层验证）
- [ ] 状态合法性（如不允许修改已删除记录）

**删除操作验证**：
- [ ] `id` 不为 null
- [ ] `operatorId` 不为 null
- [ ] 记录存在性
- [ ] 无关联依赖（或级联删除策略）

**查询操作验证**：
- [ ] 分页参数合法性（pageNum >= 1, pageSize >= 1）
- [ ] 分页大小上限（pageSize <= 1000）
- [ ] 排序字段合法性（防 SQL 注入）

---

## ApplicationService 验证

> 远程调用结果验证（`CommonResult.isSuccess()` 判断、错误透传）详见 `00-common-constraints.md §2`

### 业务规则验证

```java
@Service
@RequiredArgsConstructor
public class {Name}ApplicationServiceImpl implements {Name}ApplicationService {

    @Override
    public Long create({Name}CreateRequest request) {
        // 1. 参数预处理（去空格等）
        String name = StringUtils.trim(request.getName());
        request.setName(name);
        
        // 2. 业务规则验证
        validateBusinessRules(request);
        
        // 3. 调用下游服务
        return remoteService.create(convertToApiRequest(request));
    }

    private void validateBusinessRules({Name}CreateRequest request) {
        // 唯一性检查
        if (queryService.existsByName(request.getName())) {
            throw new BusinessException("名称已存在");
        }
        
        // 关联数据存在性检查
        if (request.getCategoryId() != null) {
            if (!categoryService.existsById(request.getCategoryId())) {
                throw new BusinessException("分类不存在");
            }
        }
    }
}
```


---

## ManageService 验证

### 数据存在性验证

```java
@Service
@RequiredArgsConstructor
public class {Name}ManageServiceImpl implements {Name}ManageService {

    private final Aim{Name}Service aim{Name}Service;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void update({Name}UpdateApiRequest request) {
        // 验证记录存在性
        Aim{Name}DO existing = aim{Name}Service.getById(request.getId());
        if (existing == null || existing.getIsDeleted() == 1) {
            throw new BusinessException("记录不存在或已删除");
        }
        
        // 验证状态合法性
        if (existing.getStatus() == StatusEnum.DISABLED.getCode()) {
            throw new BusinessException("已禁用的记录不能修改");
        }
        
        // 执行更新
        Aim{Name}DO entity = convertToEntity(request);
        entity.setUpdaterId(request.getOperatorId());
        aim{Name}Service.updateById(entity);
    }
}
```

### 批量操作验证

```java
@Override
@Transactional(rollbackFor = Exception.class)
public void batchDelete(List<Long> ids, Long operatorId) {
    // 验证参数
    if (CollectionUtils.isEmpty(ids)) {
        throw new BusinessException("ID列表不能为空");
    }
    if (ids.size() > 1000) {
        throw new BusinessException("批量删除数量不能超过1000");
    }
    
    // 验证所有记录存在性
    List<Aim{Name}DO> entities = aim{Name}Service.listByIds(ids);
    if (entities.size() != ids.size()) {
        throw new BusinessException("部分记录不存在");
    }
    
    // 执行删除
    aim{Name}Service.removeByIds(ids);
}
```

---

## 通用验证工具

### 验证工具类

```java
@Component
public class ValidationUtils {

    /**
     * 验证分页参数
     */
    public static void validatePageParams(Integer pageNum, Integer pageSize) {
        if (pageNum == null || pageNum < 1) {
            throw new BusinessException("页码必须大于等于1");
        }
        if (pageSize == null || pageSize < 1) {
            throw new BusinessException("每页数量必须大于等于1");
        }
        if (pageSize > 1000) {
            throw new BusinessException("每页数量不能超过1000");
        }
    }

    /**
     * 验证排序字段（防 SQL 注入）
     */
    public static void validateSortField(String sortField, Set<String> allowedFields) {
        if (StringUtils.isBlank(sortField)) {
            return;
        }
        // 去除可能的 ASC/DESC 后缀
        String field = sortField.replaceAll("\\s+(?i)(ASC|DESC)$", "");
        if (!allowedFields.contains(field)) {
            throw new BusinessException("非法的排序字段: " + field);
        }
    }

    /**
     * 验证 ID 列表
     */
    public static void validateIdList(List<Long> ids, int maxSize) {
        if (CollectionUtils.isEmpty(ids)) {
            throw new BusinessException("ID列表不能为空");
        }
        if (ids.size() > maxSize) {
            throw new BusinessException("ID数量不能超过" + maxSize);
        }
        if (ids.stream().anyMatch(id -> id == null || id <= 0)) {
            throw new BusinessException("ID列表包含非法值");
        }
    }
}
```

---

## 错误码规范

### 验证错误码范围

| 错误码范围 | 用途 | 示例 |
|------------|------|------|
| `400xxx` | 参数错误 | `400001` - 参数不能为空 |
| `4001xx` | 格式错误 | `400101` - 邮箱格式错误 |
| `4002xx` | 范围错误 | `400201` - 数值超出范围 |
| `4003xx` | 唯一性错误 | `400301` - 名称已存在 |
| `4004xx` | 关联错误 | `400401` - 关联记录不存在 |
| `4005xx` | 状态错误 | `400501` - 记录已删除 |

### 错误消息规范

```java
// 推荐：具体明确的错误消息
throw new BusinessException("岗位类型名称不能为空");
throw new BusinessException("排序值必须在 0-9999 之间");
throw new BusinessException("名称 '工程师' 已存在");

// 不推荐：模糊的错误消息
throw new BusinessException("参数错误");
throw new BusinessException("操作失败");
```

---

## 验证最佳实践

### DO

1. **尽早验证**：在 Controller 层完成参数格式验证
2. **分层验证**：每层验证不同维度的规则
3. **具体错误**：提供明确的错误消息，包含具体字段和值
4. **防注入**：所有动态查询参数必须验证或转义
5. **批量验证**：一次性返回所有验证错误（使用 `@Valid` 的默认行为）

### DON'T

1. **不要重复验证**：已在 Controller 验证的字段不在 Service 重复验证
2. **不要信任前端**：所有输入都必须服务端验证
3. **不要暴露内部**：错误消息不要暴露系统内部信息
4. **不要使用魔法值**：验证规则中的数值应定义为常量

---

## 验证检查清单

### Controller 层检查

- [ ] 请求参数使用 `@Valid` 或手动验证
- [ ] 验证注解包含明确的错误消息
- [ ] 分组验证正确使用（CreateGroup/UpdateGroup）
- [ ] 分页参数有范围限制
- [ ] 排序字段有白名单校验

### Service 层检查

- [ ] 业务规则验证在 ApplicationService 完成
- [ ] 数据存在性验证在 ManageService 完成
- [ ] 远程调用结果验证成功状态
- [ ] 批量操作有数量上限验证
- [ ] 所有验证失败抛出 BusinessException

### 全局检查

- [ ] 错误码符合规范
- [ ] 错误消息清晰明确
- [ ] 敏感信息不在错误消息中暴露
- [ ] 验证逻辑有单元测试覆盖

---

## 相关文档

- **门面服务规范**: [01-facade-service.md](./01-facade-service.md)
- **应用服务规范**: [02-inner-service.md](./02-inner-service.md)
- **服务层规范**: [08-service-layer-standards.md](./08-service-layer-standards.md)
- **错误码规范**: [06-error-code-standards.md](./06-error-code-standards.md)
