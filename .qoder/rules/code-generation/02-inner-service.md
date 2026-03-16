---
trigger: model_decision
description: 应用服务代码生成规范 - 生成应用服务/基础数据服务 Controller、QueryService、ManageService 时适用
globs: [ "**/*.java" ]
---

# 应用服务代码生成规范

> **适用服务**：应用服务（mall-{domain}-*/mall-merchant）、基础数据服务（mall-product/mall-history-conversation/mall-client/mall-basic-service）

---

## 1. 应用服务分层规范

### 1.1 标准分层结构

```
Controller（inner，供 Feign 调用）
    ↓
{Name}ApplicationService（业务编排层，接口+实现分离）
    ↓
    ├── {Name}QueryService（只读查询，接口+实现分离）
    └── {Name}ManageService（增删改，接口+实现分离）
              ↓
           Aim{Name}Service（MP 数据服务，service/mp/ 目录）
              ↓
           Aim{Name}Mapper（原生 MyBatis，所有查询走 XML）
```

> 目录结构、MyBatis-Plus 使用限制及对象命名约束详见 `.qoder/rules/tech-coding-standards.md`

### 1.2 服务边界隔离原则

#### 1.2.1 应用服务代码生成职责

应用服务代码生成任务需要承担双重责任：

- 生成应用服务域内的所有组件代码（Controller、ApplicationService实现、QueryService、ManageService、Mapper、DO、内部DTO）
- **同时负责生成对应的接口层代码**（Feign接口、ApiRequest/ApiResponse）
- 确保应用服务与接口层的一致性

#### 1.2.2 门面服务代码生成职责

门面服务代码生成任务专注于：

- 生成门面服务域内的组件代码（Controller、ApplicationService接口、DTO对象）
- **仅检查接口层代码是否缺失**，不主动生成
- 通过依赖检查确保接口层可用性

#### 1.2.3 跨层协作机制

- 应用服务开发者负责上下游接口的一致性
- 门面服务开发者聚焦于业务编排和数据转换
- 通过{inner-api-service}工程实现标准接口定义和共享

---

## 2. 跨 Program 接口依赖检查

**背景**：当多个 Program 并行开发时，Consumer Program（调用方）可能先于 Provider Program（实现方）完成代码生成，导致 Consumer 侧自行补充 DTO 声明或绕过 Provider 规格，造成接口契约分叉（Contract Divergence）。

**核心规则**：

- **接口所有权归 Provider**：Feign 接口的 DTO（`ApiRequest`/`ApiResponse`）由提供实现的应用服务（Provider Program）负责在 Phase 4 代码生成时声明，Consumer Program **禁止自行创建** Provider 域内的 DTO 文件
- **Consumer 依赖检查前置**：Consumer Program 进入 Phase 4 代码生成前，必须确认所依赖的 Provider Feign 接口和 DTO 已存在；若不存在，应先阻塞并通知 Provider Program 补充，或在代码中以 `// TODO: 依赖 {Provider Program} 提供 {Name}ApiRequest，待 Provider 实现后替换` 标注
- **DTO 字段以 Provider 为准**：当 Consumer 因阻塞而临时自行声明 DTO 时，字段命名和结构必须与 Provider tech-spec 保持一致，后续 Provider 实现后以 Provider 版本为准并删除 Consumer 侧临时文件

**识别方式**：

| 现象 | 问题类型 | 处置方式 |
|-------------------------------------------------------|-----------------------------------------------|---------------------------------------|
| Consumer Program 的 `{inner-api-service}` 下存在非本服务业务的 DTO 文件 | Consumer 越权声明（Contract Usurpation） | 确认是否为临时补丁，待 Provider 实现后删除或合并 |
| Provider tech-spec 定义的接口在 Controller 中无对应实现方法 | Provider 端缺口（Missing Provider Implementation） | 在 Provider Program 的下一个 Phase 4 中补充实现 |
| Consumer DTO 字段与 Provider tech-spec 字段名不一致 | 契约分岔（Contract Divergence） | 以 Provider 规格为准统一字段名 |

---

## 3. 模块内关联字段就近填充原则

**背景**：当一个模块内的业务对象（如 `ScriptTemplate`）引用了**同模块内另一张表**的主键（如 `{name}Id`），调用方往往还需要对应的名称（`{name}Name`）来展示。若 `ApiResponse` 只返回 id，门面层就不得不额外发起一次 Feign 调用来获取 id→name 映射，造成不必要的跨服务往返。

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

**示例**（话术模板 & {业务实体}，同属 {app-service}）：

```java
// ✅ 正确：ScriptTemplateApplicationServiceImpl 就近填充 {name}Name
private ScriptTemplateApiResponse convertToApiResponse(AimScriptTemplateDO entity) {
    ScriptTemplateApiResponse response = new ScriptTemplateApiResponse();
    response.set{Name}Id(entity.get{Name}Id());
    // 就近填充：同模块内 {Name}QueryService 直接可用
    Aim{Name}DO {name} = {name}QueryService.getById(entity.get{Name}Id());
    response.set{Name}Name({name} != null ? {name}.getName() : null);
    // ... 其他字段
    return response;
}

// ❌ 错误：ApiResponse 只返回 {name}Id，迫使门面层额外调一次 Feign 获取名称映射
private ScriptTemplateApiResponse convertToApiResponse(AimScriptTemplateDO entity) {
    ScriptTemplateApiResponse response = new ScriptTemplateApiResponse();
    response.set{Name}Id(entity.get{Name}Id());
    // 缺少 {name}Name → 门面层被迫发起额外 Feign 调用
    return response;
}
```

**对 ApiResponse 设计的约束**：

- 若业务对象持有模块内关联 id（`{Name}Id`），`ApiResponse` 必须同时声明 `{Name}Name` 字段
- 若业务对象持有跨模块关联 id，`ApiResponse` 只声明 `{Name}Id` 字段，不声明 `{Name}Name`（名称由门面层聚合）

**分页场景优化**（N+1 问题预防）：

- 分页查询时禁止在循环内逐条查询关联名称（N+1）
- 应先将当前页所有关联 id 去重后**批量查询**，构建 `id → name` 的 Map，再统一填充到各 `ApiResponse`
- 若关联表数据量小且相对稳定（如{业务实体}），可将全量列表缓存在 Map 中一次性填充

```java
// ✅ 正确：批量构建 Map，一次性填充
List<Long> {name}Ids = entities.stream().map(AimScriptTemplateDO::get{Name}Id)
        .filter(Objects::nonNull).distinct().collect(Collectors.toList());
// {name}QueryService 提供批量查询或全量查询方法
Map<Long, String> {name}NameMap = {name}QueryService.buildNameMap({name}Ids);

List<ScriptTemplateApiResponse> items = entities.stream()
        .map(entity -> convertToApiResponse(entity, {name}NameMap))
        .collect(Collectors.toList());

// ❌ 错误：在循环内单条查询（N+1）
List<ScriptTemplateApiResponse> items = entities.stream()
        .map(entity -> {
            Aim{Name}DO {name} = {name}QueryService.getById(entity.get{Name}Id()); // N+1！
            // ...
        }).collect(Collectors.toList());
```

---

## 4. 跨层 DTO 透传与防腐层设计原则

**场景**：应用层将基础数据服务查询结果原样透传给门面层，涉及两空隔层的 DTO 处理策略。

**应用层（透传无增删改）——使用 DTO 透传（Passthrough）模式**

- 应用层 Feign 接口的返回类型**直接引用 Provider 域（如 mall-product-api）的 `{Name}ApiResponse`**
- 应用层内部实现**禁止**新建与 Provider DTO 字段完全相同的同名类（**积极死码**，无业务价值）
- 应用层内部禁止存在"逐字段拷贝"的无意义转换逻辑

**门面层（对外响应）——必须建立防腐层（Anti-Corruption Layer）**

- 门面层 Controller 返回类型必须是**门面层自定义的 `{Name}Response`**，不得直接返回 Feign 接口的 `{Name}ApiResponse`
- 门面层 ApplicationService 负责将上游 `{Name}ApiResponse` 转换为门面层定义的 `{Name}Response`
- 即使当前字段完全相同，该转换也不得省略（驱动原因：前端契约稳定性、内部实现封闭性）

| 层级 | DTO 外露形式 | 是否必须转换 |
|------|--------------|------------|
| 应用层内部透传 Provider 数据 | 直接引用 Provider `{Name}ApiResponse` | 否，直接透传 |
| 门面层对前端响应 | 门面层自定义 `{Name}Response` | 是，必须转换 |

---

## 5. HTTP 测试生成边界约束

服务边界隔离原则同样约束 Phase 5 HTTP 测试生成行为：

- **门面服务需求**：Phase 5 仅为门面服务 Controller（`{Name}AdminController` / `{Name}AppController` / `{Name}MerchantController`）生成 HTTP 测试文件，应用服务的 `{Name}InnerController` 不生成 HTTP 测试
- **应用服务需求**：Phase 5 仅为应用服务 `{Name}InnerController` 生成 HTTP 测试文件，门面服务 Controller 不生成 HTTP 测试
- **判断依据**：根据 `tech-spec.md` 中各 Controller 所在服务层级（路径前缀 `/admin`、`/inner` 等）进行区分

---

## 6. 术语定义

### 6.1 ApplicationService

应用服务接口，负责业务编排和协调。

门面服务：调用 RemoteService 进行远程调用。

应用服务：调用 QueryService 和 ManageService 进行数据操作。

### 6.2 QueryService

查询服务接口，负责所有查询操作。

约束：
- 禁止使用 MyBatis-Plus 查询 API
- 所有查询必须通过 XML Mapper 原生 SQL 实现
- 不标注 `@Transactional`

### 6.3 ManageService

管理服务接口，负责增删改操作。

约束：
- 增删改使用 MyBatis-Plus IService 方法
- 写操作方法必须标注 `@Transactional`

### 6.4 Aim{Name}Service

MyBatis-Plus Service 接口，继承 `IService<Aim{Name}DO>`。

位于 `service/mp/` 目录。

### 6.5 Aim{Name}ServiceImpl

MyBatis-Plus Service 实现，继承 `ServiceImpl<Aim{Name}Mapper, Aim{Name}DO>`。

位于 `service/impl/mp/` 目录。

**严禁标注 `@Transactional`**。
