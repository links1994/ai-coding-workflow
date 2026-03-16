---
trigger: model_decision
description: 服务分层架构规范 - 定义各服务层级与职责边界
globs: ["orchestrator/PROGRAMS/**/decomposition.md"]
alwaysApply: false
---

# 服务分层架构规范

本规范定义 mall 项目的服务分层架构，明确各层职责与协作关系。

---

## 1. 服务分层定义

### 1.1 三层架构映射

| 层级 | 标识 | 对应服务 | 职责 |
|------|------|----------|------|
| 门面层 | `facade` | {facade-service}, {facade-service-3}, {facade-service-2}, {facade-service-4} | 接口暴露、参数校验、数据聚合 |
| 应用层 | `application` | {app-service}, mall-merchant | 业务逻辑、流程编排 |
| 数据层 | `data` | mall-product, mall-client, mall-basic-service, mall-history-conversation | 数据访问、原子操作 |

### 1.2 服务清单

| 服务 | 层级 | 职责描述 |
|------|------|----------|
| {facade-service} | facade | 平台管理端 BFF |
| {facade-service-3} | facade | 商家管理端 BFF |
| {facade-service-2} | facade | 消费者 APP 端 BFF |
| {facade-service-4} | facade | AI 对话 BFF |
| {app-service} | application | 智能体{关联实体}核心业务 |
| mall-merchant | application | 商家/商品管理 |
| mall-product | data | 商品基础数据 |
| mall-client | data | 用户/客户数据 |
| mall-basic-service | data | 基础配置数据 |
| mall-history-conversation | data | 历史对话数据 |

---

## 2. 分层协作规则

### 2.1 调用关系

```
Feature 内部分层调用：

┌─────────────────────────────────────┐
│  门面层 (facade)                     │
│  - Controller + VO                  │
│  - 调用 ApplicationService          │
└──────────────┬──────────────────────┘
               │ Feign ({inner-api-service})
               ▼
┌─────────────────────────────────────┐
│  应用层 (application)                │
│  - ApplicationService               │
│  - 业务逻辑编排                      │
│  - 调用数据层 RemoteService          │
└──────────────┬──────────────────────┘
               │ Feign ({inner-api-service})
               ▼
┌─────────────────────────────────────┐
│  数据层 (data)                       │
│  - Entity + Mapper                  │
│  - Query/ManageService              │
│  - 数据库操作                        │
└─────────────────────────────────────┘
```

### 2.2 远程调用位置决策

根据依赖强度选择在哪一层发起 Feign 调用：

```
需要调用远程服务？
    ↓
是否是业务强依赖？（缺少该数据，当前功能无法完成）
    ├─ 是 → 在 ApplicationService 中调用（强依赖）
    └─ 否 → 仅用于数据增强/聚合展示？
        ├─ 是 → 在门面服务 ApplicationService 中调用，被调用方故障需有降级处理（弱依赖）
        └─ 否 → 重新评估必要性
```

**示例**：

| 场景 | 调用层级 | 原因 |
|------|----------|------|
| 订单详情需要商品信息 | ApplicationService（应用服务内） | 强依赖，无商品数据订单不完整 |
| 列表页需要显示商品缩略图 | 门面服务 ApplicationService | 弱依赖，图片加载失败仍可展示列表 |
| 仪表盘聚合多服务统计数据 | 门面服务 ApplicationService | 纯数据聚合，各服务数据独立 |

---

## 3. 接口定义集中管理

### 3.1 API 定义规范

```yaml
api_definitions:
  - module: mall-product-api           # {inner-api-service} 子模块
    feign: UserRemoteService           # Feign Client 类名
    base_path: /inner/api/v1/user      # 基础路径
    
    methods:
      - name: getUserById              # 方法名
        http_method: GET
        path: /{userId}
        description: 根据ID获取用户信息
        
        request:
          params:
            - name: userId
              type: Long
              required: true
              
        response:
          type: UserApiResponse
          description: 用户信息
          
      - name: listUsers
        http_method: POST
        path: /list
        description: 分页查询用户列表
        
        request:
          body: UserListApiRequest
          
        response:
          type: PageResult<UserApiResponse>
```

### 3.2 实现与调用的分离

| 角色 | 职责 | 代码位置 |
|------|------|----------|
| 接口定义 | 定义 Feign 接口、DTO | `{inner-api-service}/{module}-api/` |
| 接口实现 | 实现 Controller | 被调用服务的 `controller/inner/` |
| 接口调用 | 注入 RemoteService | 调用方的 ApplicationService |

---

## 4. 服务边界隔离原则

### 4.1 核心定义

服务边界隔离原则要求在代码生成和开发过程中，严格限定在当前服务域内操作，禁止跨越服务层级边界。

### 4.2 边界划分标准

| 服务层 | 职责范围 | 禁止操作 |
|------|----------|----------|
| 门面服务 | BFF层，对外API入口 | 不得生成应用服务的业务逻辑代码 |
| 应用服务 | 业务逻辑编排层 | 不得生成门面服务的接口代码 |
| 基础服务 | 数据访问层 | 不得生成上层业务代码 |

### 4.3 跨 Program 接口依赖检查

**核心规则**：

- **接口所有权归 Provider**：Feign 接口的 DTO（`ApiRequest`/`ApiResponse`）由提供实现的应用服务（Provider Program）负责在 Phase 4 代码生成时声明，Consumer Program **禁止自行创建** Provider 域内的 DTO 文件
- **Consumer 依赖检查前置**：Consumer Program 进入 Phase 4 代码生成前，必须确认所依赖的 Provider Feign 接口和 DTO 已存在
- **DTO 字段以 Provider 为准**：当 Consumer 因阻塞而临时自行声明 DTO 时，字段命名和结构必须与 Provider tech-spec 保持一致

### 4.4 模块内关联字段就近填充原则

**核心规则**：

- **模块内关联**（引用 id 所属表与当前表在**同一服务**内）：`ApiResponse` 必须同时返回 `id` 和对应的 `name`（即 `{Name}Id` + `{Name}Name`），由**当前模块的 ApplicationService 层**负责在构建 ApiResponse 时就近填充
- **跨模块关联**（引用 id 所属表在**另一个服务**内）：`ApiResponse` 仅返回 `id`；门面服务需要名称时，在门面层 ApplicationService 中通过 Feign 调用对方服务获取并组装

**决策树**：

```
需要在列表/详情中展示名称字段？
    ↓
该 id 关联的表是否在当前服务模块内？
    ├─ 是（模块内关联）→ 在本模块 ApplicationService 的 convertToApiResponse() 中就近填充 {Name}Name
    │                   ApiResponse 同时包含 {Name}Id + {Name}Name
    └─ 否（跨模块关联）→ ApiResponse 只返回 {Name}Id
                        门面层 ApplicationService 发起 Feign 调用填充名称
```
