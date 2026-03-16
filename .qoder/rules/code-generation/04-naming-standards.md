---
trigger: model_decision
description: 对象命名规范 - 生成 DTO/Request/Response/VO/枚举/Service 类时适用
globs: [ "**/*.java" ]
---

# 对象命名规范

> **适用范围**：所有 Java 代码生成场景

---

## 1. 对象类型命名规范

### 1.1 对象分类与使用范围

| 对象类型 | 命名后缀 | 使用范围 | 代码位置 |
|----------|----------|----------|----------|
| 前端请求参数 | `{Name}Request` | Controller 层入参（门面服务） | `dto/request/` |
| 前端响应参数 | `{Name}Response` | Controller 层出参 | `dto/response/` |
| VO（视图聚合） | `{Name}VO` | 聚合多个 Response（**仅门面服务**） | `dto/vo/` |
| 内部查询参数 | `{Name}Query` / `{Name}PageQuery` | Service 层入参 | `dto/` |
| 内部传输对象 | `{Name}DTO` | Service 层内部传输 | `dto/` |
| 远程请求参数 | `{Name}ApiRequest` | Feign 调用入参 | `{inner-api-service}/request/` |
| 远程响应参数 | `{Name}ApiResponse` | Feign 调用返参 | `{inner-api-service}/response/` |

### 1.2 强制约束

- **Controller 层**：入参必须以 `Request` 结尾，出参必须以 `Response` 或 `VO` 结尾
- **Service 层**：入参以 `Query` / `DTO` 结尾，**禁止**直接接受 `Request` 类型
- **VO 仅限门面服务**：应用服务、基础数据服务禁止定义和使用 VO
- **序列化**：所有 Request / Response / ApiRequest / ApiResponse 必须实现 `Serializable`

### 1.3 门面服务本地对象与远程对象区分

| 对象类型 | 门面服务本地 | {inner-api-service} 定义 |
|----------|--------------|---------------------|
| 请求参数 | `{Name}Request` | `{Name}ApiRequest` |
| 响应参数 | `{Name}Response` | `{Name}ApiResponse` |

---

## 2. Service 命名规范

| 层级 | 命名格式 | 示例 |
|------|----------|------|
| ApplicationService | `{业务域}ApplicationService` | `{Name}ApplicationService` |
| QueryService | `{业务域}QueryService` | `{Name}QueryService` |
| ManageService | `{业务域}ManageService` | `{Name}ManageService` |

---

## 3. Controller 命名规范

| 服务类型 | 命名格式 | 示例 |
|----------|----------|------|
| 门面服务（Admin） | `{业务域}AdminController` | `{Name}AdminController` |
| 门面服务（App） | `{业务域}AppController` | `{Name}AppController` |
| 应用服务 | `{业务域}InnerController` | `{Name}InnerController` |

---

## 4. DO 命名规范

**强制格式**：`Aim{Name}DO`

- 必须以 `Aim` 开头，以 `DO` 结尾
- 中间部分为表业务名的大驼峰转换

| 表名 | DO 类名 |
|------|---------|
| `{table_name}` | `Aim{Domain}{Name}DO` |
| `{table_name_2}` | `Aim{Name}DO` |

---

## 5. Mapper 命名规范

**格式**：`{业务域}Mapper`

| 表名 | Mapper 接口名 |
|------|---------------|
| `{table_name}` | `{Name}Mapper` |
| `{table_name_2}` | `{Name}Mapper` |

---

## 6. Feign 接口命名规范

**格式**：`{业务域}RemoteService`

| 服务 | Feign 接口名 |
|------|--------------|
| {app-service} | `{Name}RemoteService` |
| mall-product | `ProductRemoteService` |

---

## 7. 跨层 DTO 透传与防腐层设计

### 7.1 DTO 透传（Passthrough）模式

**适用场景**：应用服务对查询结果**无任何内容增删改**，仅做请求转发

**做法**：
- Feign 接口直接引用 Provider 域的 `{Name}ApiResponse`
- 应用服务不新建内容相同的同名类
- 应用层实现中直接返回，无需转换

### 7.2 门面防腐（Anti-Corruption）模式

**适用场景**：门面服务面向**前端/用户**的响应对象

**做法**：
- 门面层 Controller 返回类型必须是**门面层自定义的 `{Name}Response`**
- 门面层 ApplicationService 负责将 `{Name}ApiResponse` 转换为 `{Name}Response`
- 即使字段完全相同，该转换也**不得省略**

**理由**：
- 前端契约稳定性：内部 API 进化不会直接影响前端
- 字段语义自主：门面层可对字段进行重命名、格式化、展开等加工

---

## 8. 术语定义

### 8.1 Request / Response

门面服务 Controller 使用的请求/响应对象。

- **Request**：前端请求参数，以 `Request` 结尾
- **Response**：前端响应参数，以 `Response` 结尾

### 8.2 ApiRequest / ApiResponse

Feign 接口和 InnerController 使用的远程请求/响应对象。

- **ApiRequest**：远程请求参数，以 `ApiRequest` 结尾，写操作必须包含 `operatorId`
- **ApiResponse**：远程响应参数，以 `ApiResponse` 结尾

### 8.3 DTO（Data Transfer Object）

Service 层内部传输对象，用于层间数据传递。

### 8.4 DO（Data Object）

数据库实体对象，对应数据库表结构。

命名格式：`Aim{Name}DO`，如 `Aim{Domain}{Name}DO`。

### 8.5 VO（View Object）

视图聚合对象，仅用于门面服务，聚合多个 Response。

### 8.6 Query

查询参数对象，用于 QueryService 方法入参。

包括：`{Name}Query`（单条查询）、`{Name}PageQuery`（分页查询）、`{Name}ListQuery`（列表查询）。
