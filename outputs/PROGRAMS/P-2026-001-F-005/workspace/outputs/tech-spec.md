# 话术模板管理 - 技术规格书

## 1. 功能概述

| 属性 | 值 |
|------|-----|
| 功能编号 | F-005 |
| 功能名称 | 话术模板管理 |
| 所属域 | 配置管理域 |
| 所属模块 | mall-agent-employee-service |
| 优先级 | P1 |
| 功能描述 | 管理端话术模板CRUD+xlsx批量导入，门面层聚合岗位类型名称 |

---

## 2. 接口清单

### 2.1 内部服务接口 (mall-agent-employee-service)

| 接口名称 | 请求路径 | 请求方法 | 说明 |
|----------|----------|----------|------|
| pageScriptTemplates | /inner/api/v1/script-templates/list | POST | 分页查询话术模板 |
| createScriptTemplate | /inner/api/v1/script-templates/create | POST | 创建话术模板 |
| updateScriptTemplate | /inner/api/v1/script-templates/update | POST | 更新话术模板 |
| updateScriptTemplateStatus | /inner/api/v1/script-templates/status | POST | 更新话术模板状态 |
| deleteScriptTemplate | /inner/api/v1/script-templates/delete | POST | 删除话术模板 |
| batchCreateScriptTemplates | /inner/api/v1/script-templates/batch-create | POST | 批量创建话术模板 |

### 2.2 门面服务接口 (mall-admin)

| 接口名称 | 请求路径 | 请求方法 | 说明 |
|----------|----------|----------|------|
| getImportTemplate | /admin/api/v1/script-templates/import-template | GET | 获取导入模板 |
| getJobTypes | /admin/api/v1/script-templates/job-types | GET | 获取岗位类型列表 |
| page | /admin/api/v1/script-templates/page | POST | 分页查询话术模板（聚合岗位类型名称） |
| create | /admin/api/v1/script-templates | POST | 创建话术模板 |
| update | /admin/api/v1/script-templates/{templateId} | PUT | 更新话术模板 |
| status | /admin/api/v1/script-templates/{templateId}/status | PUT | 更新话术模板状态 |
| delete | /admin/api/v1/script-templates/{templateId} | DELETE | 删除话术模板 |
| import | /admin/api/v1/script-templates/import | POST | 批量导入话术模板 |

---

## 3. 数据模型

### 3.1 话术模板表 (aim_agent_script_template)

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | BIGINT | 主键ID |
| name | VARCHAR(128) | 话术模板名称 |
| trigger_condition | VARCHAR(255) | 触发条件 |
| content | VARCHAR(500) | 话术内容 |
| job_type_id | BIGINT | 岗位类型ID |
| status | TINYINT | 状态：0-启用，1-禁用 |
| create_time | DATETIME | 创建时间 |
| update_time | DATETIME | 更新时间 |

---

## 4. 业务规则

| 规则名称 | 规则描述 |
|----------|----------|
| 删除约束 | 启用中的话术模板不可删除（status = 0 时禁止删除） |
| 门面聚合 | 门面层需两跳聚合：话术模板 → 岗位类型ID → 岗位类型名称 |

---

## 5. 时序图

### 5.1 分页查询话术模板（带聚合）

```mermaid
sequenceDiagram
    autonumber
    actor User as 管理端用户
    participant Admin as mall-admin<br/>ScriptTemplateController
    participant Feign as mall-inner-api<br/>ScriptTemplateFeign
    participant Inner as mall-agent-employee-service<br/>ScriptTemplateInnerController
    participant Query as QueryService
    participant JobTypeFeign as JobTypeFeign
    participant DB as 数据库

    User->>Admin: POST /admin/api/v1/script-templates/page
    Admin->>Admin: 构建分页请求参数
    Admin->>Feign: pageScriptTemplates(request)
    Feign->>Inner: POST /inner/api/v1/script-templates/list
    Inner->>Query: queryPage(request)
    Query->>DB: SELECT * FROM aim_agent_script_template
    DB-->>Query: 返回分页数据
    Query-->>Inner: 返回模板列表
    Inner-->>Feign: 返回CommonResult<PageResult>
    Feign-->>Admin: 返回模板列表
    Admin->>JobTypeFeign: 批量查询岗位类型名称
    JobTypeFeign-->>Admin: 返回岗位类型名称Map
    Admin->>Admin: 聚合岗位类型名称到响应DTO
    Admin-->>User: 返回分页结果（含岗位类型名称）
```

### 5.2 批量导入话术模板

```mermaid
sequenceDiagram
    autonumber
    actor User as 管理端用户
    participant Admin as mall-admin<br/>ScriptTemplateController
    participant AppSvc as ApplicationService
    participant Excel as Excel工具
    participant Feign as mall-inner-api<br/>ScriptTemplateFeign
    participant Inner as mall-agent-employee-service<br/>ScriptTemplateInnerController
    participant Manage as ManageService
    participant DB as 数据库

    User->>Admin: POST /admin/api/v1/script-templates/import<br/>(MultipartFile)
    Admin->>AppSvc: importTemplates(file)
    AppSvc->>Excel: 解析Excel文件
    Excel-->>AppSvc: 返回模板数据列表
    AppSvc->>AppSvc: 数据校验（名称非空、岗位类型存在等）
    AppSvc->>Feign: batchCreateScriptTemplates(dtoList)
    Feign->>Inner: POST /inner/api/v1/script-templates/batch-create
    Inner->>Manage: batchCreate(entities)
    Manage->>Manage: 逐条校验业务规则
    Manage->>DB: INSERT INTO aim_agent_script_template
    DB-->>Manage: 返回插入结果
    Manage-->>Inner: 返回成功数量
    Inner-->>Feign: 返回CommonResult
    Feign-->>AppSvc: 返回导入结果
    AppSvc-->>Admin: 返回导入成功/失败统计
    Admin-->>User: 返回导入结果
```

### 5.3 删除话术模板

```mermaid
sequenceDiagram
    autonumber
    actor User as 管理端用户
    participant Admin as mall-admin<br/>ScriptTemplateController
    participant Feign as mall-inner-api<br/>ScriptTemplateFeign
    participant Inner as mall-agent-employee-service<br/>ScriptTemplateInnerController
    participant Manage as ManageService
    participant DB as 数据库

    User->>Admin: DELETE /admin/api/v1/script-templates/{templateId}
    Admin->>Feign: deleteScriptTemplate(templateId)
    Feign->>Inner: POST /inner/api/v1/script-templates/delete
    Inner->>Manage: delete(templateId)
    Manage->>DB: SELECT status FROM aim_agent_script_template
    DB-->>Manage: 返回状态
    alt status = 0 (启用中)
        Manage-->>Inner: 抛出异常：启用中的话术模板不可删除
        Inner-->>Feign: 返回错误结果
        Feign-->>Admin: 返回错误
        Admin-->>User: 返回删除失败
    else status = 1 (禁用)
        Manage->>DB: DELETE FROM aim_agent_script_template WHERE id = ?
        DB-->>Manage: 返回删除结果
        Manage-->>Inner: 返回成功
        Inner-->>Feign: 返回CommonResult.success()
        Feign-->>Admin: 返回成功
        Admin-->>User: 返回删除成功
    end
```

---

## 6. 业务流程图

### 6.1 话术模板管理整体流程

```mermaid
flowchart TD
    subgraph 管理端操作
        A[管理端用户] --> B{操作类型}
        B -->|分页查询| C[查询话术模板列表]
        B -->|创建| D[创建话术模板]
        B -->|更新| E[更新话术模板]
        B -->|删除| F[删除话术模板]
        B -->|导入| G[批量导入话术模板]
        B -->|状态变更| H[启用/禁用语术模板]
    end

    subgraph 门面层 mall-admin
        C --> I[ScriptTemplateController]
        D --> I
        E --> I
        F --> I
        G --> I
        H --> I
        I --> J[ApplicationService]
        J --> K{是否需要聚合}
        K -->|是| L[查询岗位类型名称]
        K -->|否| M[直接调用内部服务]
        L --> M
    end

    subgraph 内部服务 mall-agent-employee-service
        M --> N[ScriptTemplateInnerController]
        N --> O{操作类型}
        O -->|查询| P[QueryService]
        O -->|增删改| Q[ManageService]
        P --> R[数据库]
        Q --> R
    end

    subgraph 业务规则校验
        Q --> S{删除校验}
        S -->|status=0| T[抛出异常]
        S -->|status=1| U[执行删除]
    end
```

### 6.2 批量导入流程

```mermaid
flowchart LR
    A[上传Excel文件] --> B[解析Excel]
    B --> C[数据校验]
    C --> D{校验结果}
    D -->|校验失败| E[返回错误信息]
    D -->|校验通过| F[调用批量创建接口]
    F --> G[逐条处理]
    G --> H{处理结果}
    H -->|成功| I[成功计数+1]
    H -->|失败| J[失败计数+1]
    J --> K[记录失败原因]
    I --> L{是否还有数据}
    K --> L
    L -->|是| G
    L -->|否| M[返回导入结果]
    E --> N[结束]
    M --> N
```

---

## 7. 规范合规性检查清单

### 7.1 门面层 (mall-admin) 检查项

| 检查项 | 要求 | 状态 |
|--------|------|------|
| Controller 路径规范 | 使用 `/admin/api/v1/` 前缀 | ⬜ |
| 请求参数校验 | 使用 `@Valid` 进行参数校验 | ⬜ |
| Header 解析 | 正确解析 `userId`、`userName`、`tenantId` | ⬜ |
| 响应封装 | 返回统一响应格式 | ⬜ |
| 聚合逻辑 | 门面层负责岗位类型名称聚合 | ⬜ |
| RESTful 规范 | GET/POST/PUT/DELETE 使用正确 | ⬜ |

### 7.2 内部服务层 (mall-agent-employee-service) 检查项

| 检查项 | 要求 | 状态 |
|--------|------|------|
| Controller 路径规范 | 使用 `/inner/api/v1/` 前缀 | ⬜ |
| 参数接收 | 使用 `@RequestParam` 或 `@RequestBody` | ⬜ |
| 响应封装 | 返回 `CommonResult` 统一格式 | ⬜ |
| 业务校验 | ManageService 中实现业务规则校验 | ⬜ |
| 删除约束 | 启用状态禁止删除 | ⬜ |

### 7.3 数据访问层检查项

| 检查项 | 要求 | 状态 |
|--------|------|------|
| DO 继承 | 继承 `BaseDO` | ⬜ |
| 字段映射 | 与数据库表字段一一对应 | ⬜ |
| Mapper | 定义 `Base_Column_List` | ⬜ |
| SQL 规范 | 禁止使用 `SELECT *` | ⬜ |
| QueryService | 只读操作，可使用原生 SQL | ⬜ |
| ManageService | 使用 MyBatis-Plus 增删改 | ⬜ |

### 7.4 Feign 接口检查项

| 检查项 | 要求 | 状态 |
|--------|------|------|
| 注解 | 使用 `@FeignClient` | ⬜ |
| 参数传递 | 使用 `@RequestParam` / `@RequestBody` | ⬜ |
| 响应类型 | 返回 `CommonResult` | ⬜ |
| 路径匹配 | 与内部 Controller 路径一致 | ⬜ |

### 7.5 数据库脚本检查项

| 检查项 | 要求 | 状态 |
|--------|------|------|
| 表名 | 使用 `aim_agent_script_template` | ⬜ |
| 字段类型 | 与规格定义一致 | ⬜ |
| 注释 | 表和字段均需添加注释 | ⬜ |
| 索引 | 根据查询需求添加索引 | ⬜ |

---

## 8. 实现顺序

| 顺序 | 层级 | 说明 |
|------|------|------|
| 1 | Feign 接口 | mall-inner-api 定义远程调用接口 |
| 2 | 应用服务层 | mall-agent-employee-service 实现 CRUD |
| 3 | 门面服务层 | mall-admin 实现聚合和导入导出 |
| 4 | 数据库脚本 | schema.sql + test-data.sql |
| 5 | HTTP 测试 | .http 接口测试文件 |

---

## 9. 依赖关系

```mermaid
graph TD
    A[mall-admin<br/>门面层] -->|Feign调用| B[mall-inner-api<br/>API定义]
    B -->|实现| C[mall-agent-employee-service<br/>应用服务层]
    C -->|数据访问| D[数据库]
    A -->|查询岗位类型| E[mall-job-type-service]
```

---

*文档生成时间：2026-03-16*
*功能编号：F-005*
