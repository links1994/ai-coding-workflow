# Feature 技术规格: {FeatureName}

## 1. Feature 基本信息

| 属性 | 值 |
|------|-----|
| ID | `{feature_id}` |
| 名称 | `{feature_name}` |
| 领域 | `{domain}` |
| 模块 | `{module}` |
| 优先级 | `{priority}` |
| 描述 | `{description}` |

---

## 2. 接口定义

### 2.1 Feign 接口（内部服务暴露）

**服务**: `{inner-api-service}`

| 接口名称 | 方法 | 路径 | 请求DTO | 响应DTO | 说明 |
|----------|------|------|---------|---------|------|
| `{name}` | `{method}` | `/inner/api/v1/{path}` | `{Name}ApiRequest` | `CommonResult<{Name}ApiResponse>` | {description} |

#### DTO 定义

**{Name}ApiRequest**:
```java
@Data
public class {Name}ApiRequest implements Serializable {
    private static final long serialVersionUID = -1L;
    // 字段定义
    private Long operatorId;  // 写操作必填
}
```

**{Name}ApiResponse**:
```java
@Data
public class {Name}ApiResponse implements Serializable {
    private static final long serialVersionUID = -1L;
    // 字段定义
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime createTime;
}
```

### 2.2 门面接口（Admin/App/Merchant）

**服务**: `{facade-service}` / `{facade-service-2}`

| 接口名称 | 方法 | 路径 | 请求DTO | 响应DTO | 说明 |
|----------|------|------|---------|---------|------|
| `{name}` | `{method}` | `/admin/api/v1/{path}` | `{Name}Request` | `CommonResult<{Name}Response>` | {description} |

#### DTO 定义

**{Name}Request**:
```java
@Data
public class {Name}Request implements Serializable {
    private static final long serialVersionUID = -1L;
    
    @NotBlank(message = "名称不能为空")
    @Size(max = 100)
    private String name;
    
    private Long operatorId;  // 从Header解析后设置
}
```

**{Name}Response / {Name}VO**:
```java
@Data
public class {Name}Response implements Serializable {
    private static final long serialVersionUID = -1L;
    
    private Long id;
    private String name;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private LocalDateTime createTime;
}
```

---

## 3. 数据模型

### 3.1 数据库表

**表名**: `{table_name}`

| 字段名 | 类型 | 长度 | 可空 | 默认值 | 说明 |
|--------|------|------|------|--------|------|
| `id` | BIGINT | - | 否 | 自增 | 主键 |
| `name` | VARCHAR | 100 | 否 | - | 名称 |
| `status` | TINYINT | - | 否 | 1 | 状态：0-禁用 1-启用 |
| `is_deleted` | TINYINT | - | 否 | 0 | 逻辑删除：0-未删除 1-已删除 |
| `create_time` | DATETIME | - | 否 | CURRENT_TIMESTAMP | 创建时间 |
| `update_time` | DATETIME | - | 否 | CURRENT_TIMESTAMP | 更新时间 |
| `creator_id` | BIGINT | - | 是 | - | 创建人ID |
| `updater_id` | BIGINT | - | 是 | - | 更新人ID |

**索引**:
| 索引名 | 字段 | 类型 |
|--------|------|------|
| `idx_status` | status | 普通索引 |
| `idx_create_time` | create_time | 普通索引 |

### 3.2 DO 实体

**类名**: `Aim{Domain}{Name}DO`

```java
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("{table_name}")
public class Aim{Domain}{Name}DO extends BaseDO {
    private static final long serialVersionUID = 1L;
    
    @TableField("name")
    private String name;
    
    @TableField("status")
    private Integer status;
    
    @TableField("is_deleted")
    private Integer isDeleted;
}
```

---

## 4. 业务规则

### 4.1 参数校验规则

| 字段 | 规则 | 错误提示 |
|------|------|----------|
| `name` | 必填，长度1-100 | 名称不能为空 |
| `status` | 可选，0或1 | 状态值不正确 |

### 4.2 状态流转规则

| 当前状态 | 目标状态 | 触发条件 | 校验规则 |
|----------|----------|----------|----------|
| - | 启用 | 创建 | - |
| 启用 | 禁用 | 禁用操作 | - |
| 禁用 | 启用 | 启用操作 | - |

---

## 5. 调用时序图

### 5.1 查询类接口时序图

```
门面Controller → ApplicationService → RemoteService(Feign) 
    → InnerController → QueryService → Mapper(XML) → DB
```

### 5.2 写操作接口时序图

```
门面Controller(解析user→operatorId) → ApplicationService 
    → RemoteService(Feign, 传递operatorId) → InnerController
    → ManageService(写操作) → AimService.save/update/remove
```

---

## 6. 实现计划

### 6.1 生成顺序

1. **Feign 层**（{inner-api-service}）
2. **应用服务层**（{app-service}）
3. **门面服务层**（{facade-service}）

### 6.2 文件清单

| 序号 | 文件路径 | 类型 | 服务 | 分层 |
|------|----------|------|------|------|
| 1 | `feign/{Name}RemoteService.java` | Feign接口 | {inner-api-service} | feign |
| 2 | `dto/request/{Name}CreateApiRequest.java` | DTO | {inner-api-service} | dto |
| 3 | `dto/response/{Name}ApiResponse.java` | DTO | {inner-api-service} | dto |
| 4 | `domain/entity/Aim{Name}DO.java` | DO | {app-service} | entity |
| 5 | `mapper/Aim{Name}Mapper.java` | Mapper | {app-service} | mapper |
| 6 | `service/{Name}QueryService.java` | Service接口 | {app-service} | service |
| 7 | `service/impl/{Name}QueryServiceImpl.java` | Service实现 | {app-service} | service |
| 8 | `service/{Name}ManageService.java` | Service接口 | {app-service} | service |
| 9 | `service/impl/{Name}ManageServiceImpl.java` | Service实现 | {app-service} | service |
| 10 | `controller/inner/{Name}InnerController.java` | Controller | {app-service} | controller |
| 11 | `dto/request/{Name}CreateRequest.java` | DTO | {facade-service} | dto |
| 12 | `dto/response/{Name}Response.java` | DTO | {facade-service} | dto |
| 13 | `service/{Name}ApplicationService.java` | Service接口 | {facade-service} | service |
| 14 | `service/impl/{Name}ApplicationServiceImpl.java` | Service实现 | {facade-service} | service |
| 15 | `controller/{domain}/{Name}AdminController.java` | Controller | {facade-service} | controller |

---

## 7. 验收标准

### 7.1 功能验收

| ID | 验收项 | 验证方法 | 状态 |
|------|--------|----------|------|
| f-01 | 创建功能正常 | 接口测试 | pending |
| f-02 | 更新功能正常 | 接口测试 | pending |
| f-03 | 删除功能正常 | 接口测试 | pending |
| f-04 | 查询功能正常 | 接口测试 | pending |
| f-05 | 分页查询正常 | 接口测试 | pending |

### 7.2 代码质量

| ID | 验收项 | 验证方法 | 状态 |
|------|--------|----------|------|
| cq-01 | 代码符合项目规范 | DoD检查卡 | pending |
| cq-02 | 无严重级别问题 | quality-report审查 | pending |
| cq-03 | 所有接口通过HTTP测试 | HTTP测试文件执行 | pending |

---

## 8. 依赖与风险

### 8.1 上游依赖

| Feature ID | 类型 | 说明 |
|------------|------|------|
| - | - | - |

### 8.2 下游依赖

| Feature ID | 类型 | 说明 |
|------------|------|------|
| - | - | - |

### 8.3 风险

| ID | 风险描述 | 缓解措施 | 状态 |
|------|----------|----------|------|
| r-01 | - | - | open |
