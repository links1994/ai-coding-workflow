---
trigger: model_decision
description: 项目技术架构设计 - 描述多端前后端分离架构的服务分层、调用关系及服务清单
globs: [ "**/*.java", "**/*.xml", "**/*.yml", "**/*.yaml" ]
---

# 项目技术架构设计

> **适用范围**：理解项目整体架构，指导服务划分和调用关系设计

---

## 1. 架构总览

本项目采用**前后端分离**架构，多端前端通过 API 网关统一接入后端服务体系。

```
┌──────────────────────────────────────────────┐
│               多端前端应用                       │
│   app移动端 / merchant商家端 / admin后台管理端      │
└──────────────────────┬───────────────────────┘
                       │ HTTP
                       ▼
              ┌─────────────────┐
              │    API 网关      │
              └────────┬────────┘
                       │
          ┌────────────┼────────────┬───────────┐
          ▼            ▼            ▼           ▼
    ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
    │{facade-service}│ │mall-tob  │ │mall-toc  │ │ {facade-service-4}  │
    │平台管理端 │ │ 商家管理端 │ │  APP端   │ │ AI对话   │
    └──────────┘ └──────────┘ └──────────┘ └──────────┘
         │            │            │            │
         └────────────┼────────────┘            │
    ┌───────────────── ▼ ─────────────────────────┘
    │              门面服务层（BFF/聚合层）编排转发
    └───────────────────────────────────────────────
                       │ Feign RPC
          ┌────────────┼────────────┐
          ▼            ▼            ▼
    ┌──────────────────────────────────────┐
    │            应用服务层                 │
    │  {app-service}（智能体）│
    │  mall-merchant（商家/商品）           │
    └──────────────┬───────────────────────┘
                   │ Feign RPC
          ┌────────┼────────────┐
          ▼        ▼            ▼            ▼
    ┌─────────┐ ┌──────────┐ ┌────────┐ ┌─────────────────┐
    │mall-    │ │mall-     │ │mall-   │ │mall-history-    │
    │product  │ │client    │ │basic-  │ │conversation     │
    │商品数据  │ │ 用户服务  │ │service │ │ 历史对话服务      │
    └─────────┘ └──────────┘ └────────┘ └─────────────────┘
    └──────────────────────────────────────────────────────┘
                     基础数据服务层（最底层）
```

---

## 2. 分层定义

### 2.1 门面服务层（BFF / Facade Layer）

**定义**：直接承接前端请求的服务，作为系统对外暴露的唯一入口（Backend For Frontend）。负责请求接收、参数校验、数据聚合编排，将多个后端应用服务的数据组装后返回给前端。

**核心约束**：
- **只有门面服务可以承接前端请求**，前端禁止直接调用应用服务层或基础数据服务层
- 门面服务内部进行**第一层数据编排**：可聚合多个应用服务或基础数据服务的响应数据
- 门面服务之间**禁止相互调用**

| 服务名称 | 职责说明 | 对应前端 | 接口路径前缀 |
|----------|----------|----------|--------------|
| `{facade-service}` | 平台管理端 BFF | admin 后台管理端 | `/admin/api/v1/` |
| `{facade-service-3}` | 商家管理端 BFF | merchant 商家端 | `/merchant/api/v1/` |
| `{facade-service-2}` | 消费者 APP 端 BFF | app 移动端 | `/app/api/v1/` |
| `{facade-service-4}` | AI 对话 BFF | AI 对话入口（多端） | `/ai/api/v1/` |

### 2.2 应用服务层（Application Service Layer）

**定义**：承载核心业务逻辑的后端服务，仅通过 OpenFeign RPC 被门面服务或其他应用服务调用，**不对前端直接暴露**。

**核心约束**：
- 应用服务之间**可以相互调用**（通过 Feign）
- 禁止调用门面服务
- 可以调用基础数据服务层

| 服务名称 | 职责说明 | 接口路径前缀 |
|----------|----------|--------------|
| `{app-service}` | 智能体{关联实体}核心业务 | `/inner/api/v1/` |
| `mall-merchant` | 商家管理、商品管理业务 | `/inner/api/v1/` |

### 2.3 基础数据服务层（Base Data Service Layer）

**定义**：提供基础业务数据的原子查询能力，是整个服务体系的最底层。各基础数据服务只提供自身数据域的能力，不包含复杂业务逻辑。

**核心约束**：
- 基础数据服务之间**严禁相互调用**（平级隔离）
- 禁止调用应用服务层
- 禁止调用门面服务层

| 服务名称 | 职责说明 | 接口路径前缀 |
|----------|----------|--------------|
| `mall-product` | 商品基础数据服务 | `/inner/api/v1/` |
| `mall-history-conversation` | 历史对话数据服务 | `/inner/api/v1/` |
| `mall-client` | 用户/客户数据服务 | `/inner/api/v1/` |
| `mall-basic-service` | 基础配置数据服务（字典、系统配置等） | `/inner/api/v1/` |

### 2.4 公共基础设施

| 模块名称 | 类型 | 职责说明 |
|----------|------|----------|
| `mall-common` | 公共依赖库 | 整个项目的公共工具类、基础组件，被所有模块依赖 |
| `{inner-api-service}` | 聚合 API 工程 | 多模块聚合工程，包含各服务对外提供的 Feign 接口定义（`{Name}RemoteService`），供调用方依赖引入 |

---

## 3. 服务调用关系

```
调用方向：→ 表示可调用

前端应用
  → API 网关
    → 门面服务层（{facade-service} / {facade-service-3} / {facade-service-2} / {facade-service-4}）
        → 应用服务层（{app-service} / mall-merchant）
            → 基础业务数据服务层（mall-product / mall-history-conversation / mall-client / mall-basic-service）
                → 基础数据服务层（直接聚合数据，弱依赖场景）

禁止方向：
  ✗ 前端 → 应用服务层（跨层直调）
  ✗ 前端 → 基础数据服务层（跨层直调）
  ✗ 基础数据服务层 → 应用服务层（向上调用）
  ✗ 基础数据服务层 → 基础数据服务层（平级调用）
  ✗ 应用服务层 → 门面服务层（向上调用）
  ✗ 门面服务层 → 门面服务层（平级调用）
```

完整调用规则表：

| 调用方 | 可调用 | 禁止调用 |
|--------|--------|----------|
| 门面服务 | 应用服务、基础数据服务 | 其他门面服务 |
| 应用服务 | 其他应用服务、基础业务数据服务 | 门面服务 |
| 基础数据服务 | 基础配置（mall-basic-service） | 门面服务、应用服务、其他基础数据服务 |

> 所有跨服务调用必须通过 **OpenFeign** 实现，调用接口定义统一放在 `{inner-api-service}` 工程对应子模块中。

---

## 4. 请求链路全景

```
前端请求
  │
  ▼ HTTP
API 网关（鉴权、限流、路由）
  │
  ▼ HTTP
门面服务 Controller（参数校验 @Valid）
  │
  ▼ 调用 {Name}ApplicationService
门面服务 ApplicationService（第一层编排：聚合多个后端数据，组装 VO/Response）
  │
  ▼ Feign RPC（通过 {inner-api-service} 中定义的 {Name}RemoteService）
应用服务 Controller → ApplicationService → QueryService/ManageService → Mapper/DB
  │（可选，强依赖场景）
  ▼ Feign RPC
基础数据服务 Controller → Service → Mapper/DB
```

---

## 5. {inner-api-service} 工程规范

`{inner-api-service}` 是 Feign 接口的聚合声明工程，结构如下：

```
{inner-api-service}/
├── mall-account-api/       # 财务模块 Feign 接口
├── {facade-service}-api/         # 管理端模块 Feign 接口
├── mall-basic-api/         # 基础配置模块 Feign 接口
├── mall-client-api/        # 用户模块 Feign 接口
├── mall-merchant-api/      # 商家模块 Feign 接口
├── mall-notice-api/        # 通知模块 Feign 接口
├── mall-partner-api/       # 合作方模块 Feign 接口
├── mall-payment-api/       # 支付模块 Feign 接口
├── mall-product-api/       # 商品模块 Feign 接口
├── mall-promotion-api/     # 促销模块 Feign 接口
├── mall-third-api/         # 第三方集成模块 Feign 接口
└── mall-trade-api/         # 交易模块 Feign 接口
```

每个子模块内部结构：

```
mall-{module}-api/
├── pom.xml
└── src/main/java/com/aim/mall/{module}/api/
    ├── dto/
    │   ├── request/          # ApiRequest 定义
    │   │   └── {Name}ApiRequest.java
    │   └── response/         # ApiResponse 定义
    │       └── {Name}ApiResponse.java
    ├── feign/                # Feign 接口定义
    │   └── {Name}RemoteService.java
    └── fallback/             # Feign 降级实现
        └── {Name}RemoteServiceFallback.java
```

---

## 6. 代码分层规范

### 6.1 门面服务代码结构

```
{facade-service}/src/main/java/com/aim/mall/admin/
├── controller/
│   └── {domain}/              # 按业务域分子目录
│       └── {Name}AdminController.java
├── service/
│   ├── {Name}ApplicationService.java      # 接口
│   └── impl/
│       └── {Name}ApplicationServiceImpl.java  # 实现
├── dto/
│   ├── request/{domain}/       # 请求 DTO
│   │   └── {Name}Request.java
│   └── response/{domain}/      # 响应 DTO
│       ├── {Name}Response.java
│       └── {Name}VO.java
└── convertor/
    └── {Name}Convertor.java       # 对象转换器
```

### 6.2 应用服务代码结构

```
{app-service}/src/main/java/com/aim/mall/{domain}/employee/
├── controller/
│   └── inner/                  # 内部 Controller，不分子目录
│       └── {Name}InnerController.java
├── service/
│   ├── mp/                     # MyBatis-Plus Service
│   │   └── Aim{Name}Service.java
│   ├── {Name}ApplicationService.java      # 应用服务接口
│   ├── {Name}QueryService.java            # 查询服务接口
│   └── {Name}ManageService.java           # 管理服务接口
├── service/impl/
│   ├── mp/                     # MP Service 实现
│   │   └── Aim{Name}ServiceImpl.java
│   ├── {Name}ApplicationServiceImpl.java
│   ├── {Name}QueryServiceImpl.java
│   └── {Name}ManageServiceImpl.java
├── mapper/
│   └── Aim{Name}Mapper.java
├── domain/
│   ├── entity/                 # DO 实体
│   │   └── Aim{Name}DO.java
│   └── dto/                    # 内部 DTO
│       ├── {Name}ApiRequest.java
│       ├── {Name}ApiResponse.java
│       └── {Name}Query.java
└── convertor/
    └── {Name}Convertor.java
```

---

## 7. 技术栈

| 层级 | 技术选型 |
|------|----------|
| 基础框架 | Spring Boot 3.x |
| 微服务框架 | Spring Cloud Alibaba |
| RPC 框架 | OpenFeign |
| 服务注册发现 | Nacos |
| 配置中心 | Nacos |
| 数据库 | MySQL 8.x |
| ORM 框架 | MyBatis-Plus |
| 缓存 | Redis |
| 消息队列 | RocketMQ |
| 网关 | Spring Cloud Gateway |
| 容器化 | Docker / Kubernetes |

---

## 8. 术语定义

本节定义本文档中使用的核心术语。

### 8.1 门面服务（Facade Service / BFF）

直接承接前端请求的服务层，作为系统对外唯一入口（Backend For Frontend）。

包括：`{facade-service}`、`{facade-service-3}`、`{facade-service-2}`、`{facade-service-4}`。

接口路径前缀：`/admin/api/v1/`、`/merchant/api/v1/`、`/app/api/v1/`、`/ai/api/v1/`。

### 8.2 应用服务（Application Service）

承载核心业务逻辑的后端服务，仅通过 Feign RPC 被调用，不对前端直接暴露。

包括：`{app-service}`、`mall-merchant`。

接口路径前缀：`/inner/api/v1/`。

### 8.3 基础数据服务（Base Data Service）

提供基础业务数据原子查询能力的最底层服务，平级服务间严禁相互调用。

包括：`mall-product`、`mall-history-conversation`、`mall-client`、`mall-basic-service`。

接口路径前缀：`/inner/api/v1/`。

### 8.4 业务域（Domain）

门面服务内按业务分类的子目录单元，用于 Controller/DTO 的目录分层。

示例：`{domain}`、`merchant`、`user`、`trade`。

### 8.5 业务域前缀（Domain Prefix）

应用服务/基础数据服务内用于区分不同业务模块的类名前缀。

示例：`{Domain}Script`、`{Name}`、`ScriptTemplate`。

用法：`{prefix}QueryService`、`{prefix}ManageService`、`{prefix}InnerController`。
