# {{feature_id}} {{feature_name}} - 调用时序图

## 1. 查询类接口时序图（{{query_api_name}}）

```mermaid
sequenceDiagram
    participant Client as 前端/调用方
    participant Facade as 门面Controller
    participant FacadeApp as 门面ApplicationService
    participant Remote as Feign RemoteService
    participant App as 应用Controller
    participant AppSvc as 应用ApplicationService
    participant Query as QueryService
    participant DB as 数据库

    Client->>Facade: GET /xxx/api/v1/xxx
    Facade->>FacadeApp: {{query_method}}({{query_request}})
    FacadeApp->>Remote: {{feign_method}}({{api_request}})
    Remote->>App: POST /inner/api/v1/xxx
    App->>AppSvc: {{app_method}}({{api_request}})
    AppSvc->>Query: {{query_service_method}}({{query_dto}})
    Query->>DB: SELECT * FROM {{table_name}} WHERE ...
    DB-->>Query: 查询结果
    Query-->>AppSvc: {{api_response}}
    AppSvc-->>App: CommonResult<{{api_response}}>
    App-->>Remote: CommonResult<{{api_response}}>
    Remote-->>FacadeApp: {{api_response}}
    FacadeApp->>FacadeApp: 转换为 {{response}}
    FacadeApp-->>Facade: {{response}}
    Facade-->>Client: CommonResult<{{response}}>
```

## 2. 写操作接口时序图（{{write_api_name}}）

```mermaid
sequenceDiagram
    participant Client as 前端/调用方
    participant Facade as 门面Controller
    participant FacadeApp as 门面ApplicationService
    participant Remote as Feign RemoteService
    participant App as 应用Controller
    participant AppSvc as 应用ApplicationService
    participant Manage as ManageService
    participant DB as 数据库

    Client->>Facade: POST /xxx/api/v1/xxx
    Facade->>Facade: 解析 operatorId from user token
    Facade->>FacadeApp: {{write_method}}({{write_request}})
    FacadeApp->>Remote: {{feign_method}}({{api_request}})
    Remote->>App: POST /inner/api/v1/xxx
    App->>App: validate{{write_method}}(request)
    App->>AppSvc: {{app_method}}({{api_request}})
    AppSvc->>Manage: {{manage_method}}({{dto}})
    Manage->>DB: INSERT/UPDATE {{table_name}}
    DB-->>Manage: id/affectedRows
    Manage-->>AppSvc: {{return_type}}
    AppSvc-->>App: {{return_type}}
    App-->>Remote: CommonResult<{{return_type}}>
    Remote-->>FacadeApp: {{return_type}}
    FacadeApp-->>Facade: {{return_type}}
    Facade-->>Client: CommonResult<{{return_type}}>
```

## 3. 跨服务依赖时序图（如有）

```mermaid
sequenceDiagram
    participant AppSvc as ApplicationService
    participant Remote as ExternalRemoteService
    participant External as 外部服务
    participant DB as 外部数据库

    AppSvc->>Remote: {{external_method}}({{params}})
    Remote->>External: POST /inner/api/v1/xxx
    External->>DB: 查询/操作
    DB-->>External: 结果
    External-->>Remote: {{external_response}}
    Remote-->>AppSvc: {{external_response}}
```

## 4. 特定业务时序图（根据Feature场景补充）

> 根据实际业务场景，补充以下类型的时序图：
> - 状态机流转图（如有状态变更）
> - 复杂校验链时序图（如有多步骤校验）
> - 批量操作时序图（如有批量导入）
> - 异步处理时序图（如有异步任务）
