---
name: java-code-generation
description: 根据技术规格书（tech-spec.md）生成符合项目规范的 Java 微服务代码。支持多服务并行生成、分层代码生成、DoD 检查。
---

# Java 代码生成 Skill

> **职责**：基于 tech-spec.md 生成完整的 Java 微服务代码，包括 Entity、Mapper、Service、Controller、Feign 接口及 HTTP 测试文件。
>
> **注意**：Swagger 文档生成由独立的 `swagger-doc-generation` Skill 负责，在 review 阶段后调用。

---

## 触发条件

- 用户指令："生成代码"、"开始代码生成"
- 进入 feature-implementation 流程的 execute 阶段
- 前置条件：tech-spec.md 已确认

---

## 前置依赖（必须读取）

| 文件 | 路径 | 说明 |
|------|------|------|
| 门面服务规范 | `.qoder/rules/code-generation/01-facade-service.md` | Controller、ApplicationService、DTO 规范 |
| 应用服务规范 | `.qoder/rules/code-generation/02-inner-service.md` | InnerController、Query/ManageService 规范 |
| Feign 接口规范 | `.qoder/rules/code-generation/03-feign-interface.md` | RemoteService、ApiRequest/ApiResponse 规范 |
| 命名规范 | `.qoder/rules/code-generation/04-naming-standards.md` | 对象命名、Service/Controller 命名规范 |
| 数据库规范 | `.qoder/rules/code-generation/05-database-standards.md` | 表命名、DO 实体、字段类型映射 |
| 错误码规范 | `.qoder/rules/code-generation/06-error-code-standards.md` | 错误码格式、系统/模块代码定义 |
| 数据访问规范 | `.qoder/rules/code-generation/07-data-access-standards.md` | MyBatis-Plus 使用、Query/ManageService 规范 |
| 服务层规范 | `.qoder/rules/code-generation/08-service-layer-standards.md` | 异常处理、参数注解、日志、操作人 ID |
| 目录结构规范 | `.qoder/rules/code-generation/09-directory-structure.md` | 包路径、目录结构、文件命名 |
| DoD 检查卡 | `.qoder/rules/code-generation/10-dod-cards.md` | 代码生成后检查清单 |
| 架构设计规范 | `.qoder/rules/code-generation/11-architecture-design.md` | 项目整体架构、服务分层、调用关系、技术栈 |
| **规格生成约束** | `.qoder/rules/code-generation/12-spec-generation-constraints.md` | **DoD 约束已前置到规格生成阶段** |
| 代码模板 | `_TEMPLATE/` | 各层代码模板 |

---

## 输入

| 输入项 | 类型 | 说明 |
|--------|------|------|
| tech_spec | file | 技术规格书（tech-spec.md，Markdown 格式） |
| generation_plan | object | 代码生成计划 |
| output_base_path | string | 代码输出基础路径 |

---

## 输出

| 输出项 | 路径 | 说明 |
|--------|------|------|
| generated_code | directory | 生成的代码目录结构 |
| generation_manifest | file | 生成清单（文件列表及状态） |

---

## 代码模板

本 Skill 依赖以下代码模板（位于 `_TEMPLATE/` 目录）：

| 模板文件 | 说明 | 强制约束 |
|----------|------|---------|
| `controller-admin.md` | 门面 Controller 模板 | 必须调用 ApplicationService，禁止直接调用 RemoteService |
| `controller-inner.md` | 内部 Controller 模板 | 必须调用 Query/ManageService，手动参数校验 |
| `service-application.md` | ApplicationService 模板 | 编排层，禁止业务逻辑 |
| `service-query.md` | QueryService 模板 | 只读查询，原生 SQL |
| `service-manage.md` | ManageService 模板 | 增删改，使用 MP |
| `entity-do.md` | DO 实体模板 | 继承 BaseDO |
| `mapper-java.md` | Mapper 接口模板 | 基础 CRUD + 自定义方法 |
| `mapper-xml.md` | Mapper XML 模板 | 必须包含 Base_Column_List |
| `feign-remote.md` | Feign 接口模板 | @FeignClient 配置 |
| `dto-request.md` | Request DTO 模板 | 校验注解 |
| `dto-response.md` | Response DTO 模板 | @JsonFormat 注解 |

---

## 工作流程

### 步骤 1：读取输入

1. 读取 tech-spec.yml
2. 读取代码生成规范
3. 读取各层代码模板
4. 扫描目标服务现有目录结构（适配存量项目）

### 步骤 2：生成任务列表

基于 tech-spec.yml 的 implementation.files 生成任务列表：

```yaml
tasks:
  - id: t1
    name: 生成 Feign 接口
    files:
      - {inner-api-service}/feign/{Name}RemoteService.java
      - {inner-api-service}/request/{Name}ApiRequest.java
      - {inner-api-service}/response/{Name}ApiResponse.java
    status: pending
    
  - id: t2
    name: 生成应用服务层
    files:
      - {app-service}/domain/entity/Aim{Name}DO.java
      - {app-service}/mapper/Aim{Name}Mapper.java
      - {app-service}/service/{Name}QueryService.java
      - {app-service}/service/{Name}ManageService.java
      - {app-service}/service/{Name}ApplicationService.java
      - {app-service}/controller/inner/{Name}InnerController.java
    status: pending
    
  - id: t3
    name: 生成门面服务层
    files:
      - {facade-service}/dto/request/{Name}Request.java
      - {facade-service}/dto/response/{Name}Response.java
      - {facade-service}/service/{Name}ApplicationService.java
      - {facade-service}/controller/admin/{Name}AdminController.java
    status: pending
    
  - id: t4
    name: 生成数据库脚本
    files:
      - outputs/data/sql/{table_name}.sql    # 按表名命名，如 {table_name}.sql
    naming_rule: 以数据库表名命名，包含建表语句和测试数据
    versioning: append                      # 追加模式，同一表追加测试数据
    status: pending
    
  - id: t5
    name: 生成 HTTP 测试文件
    files:
      - outputs/data/http/{module}-api.http  # 按功能模块命名，如 {path}-api.http
    naming_rule: 按功能模块命名，后续迭代直接修改旧文件
    versioning: append                      # 追加模式，同一模块追加接口
    status: pending
```

### 步骤 3：按分层顺序执行生成

按照 tech-spec.implementation.layer_order 顺序执行：

**3.1 生成 Feign 接口（{inner-api-service}）**
- RemoteService 接口
- ApiRequest / ApiResponse DTO

**3.2 生成应用服务层**
- DO 实体类
- Mapper 接口和 XML
- QueryService / ManageService
- ApplicationService
- InnerController

**3.3 生成门面服务层**
- Request / Response DTO
- ApplicationService
- AdminController / AppController

**3.4 生成数据库脚本**
- 输出路径：`outputs/data/sql/{table_name}.sql`
- 命名规则：以数据库表名命名（如 `{table_name}.sql`）
- 内容格式：包含建表语句和测试数据
- SQL 格式要求：
  - 必须包含 `DROP TABLE IF EXISTS \`table_name\`;`
  - 使用 `CREATE TABLE IF NOT EXISTS \`table_name\``
  - 表名和字段名使用反引号包裹
- 迭代规则：
  - 新表：创建新的 SQL 文件
  - 已有表：追加测试数据到现有文件末尾

**3.5 生成 HTTP 测试文件**
- 输出路径：`outputs/data/http/{module}-api.http`
- 命名规则：按功能模块命名（如 `{path}-api.http`）
- 内容格式：包含 Admin、App、Inner 三个分组的接口测试
- 迭代规则：同一功能模块新增接口时，追加到现有文件

> **注意**：Swagger 文档生成由独立的 `swagger-doc-generation` Skill 在 review 阶段后执行。

### 步骤 4：DoD 检查（验证性检查）

> **注意**：由于 DoD 约束已前置到 spec 生成阶段（通过 12-spec-generation-constraints.md），
> 此处的 DoD 检查主要是**验证性检查**，确保生成的代码与规格定义一致。

每个文件生成后进行 DoD（Definition of Done）验证：

**门面 Controller DoD**：
- [ ] 命名符合 {Name}AdminController / {Name}AppController
- [ ] 使用 @Valid 进行参数校验
- [ ] 从 Header 解析 operatorId
- [ ] 只调用 ApplicationService，禁止直接调用 RemoteService
- [ ] 返回门面层自定义的 Response DTO

**内部 Controller DoD**：
- [ ] 命名符合 {Name}InnerController
- [ ] 手动编写 validate{Name}() 方法，禁止 @Valid
- [ ] 使用 @RequestParam，禁止 @PathVariable
- [ ] 只调用 QueryService / ManageService
- [ ] 返回 CommonResult 包装

**ApplicationService DoD**：
- [ ] 命名符合 {Name}ApplicationService
- [ ] String 参数在入口处统一去空格
- [ ] 门面层：将 Request 转换为 ApiRequest，ApiResponse 转换为 Response
- [ ] 应用层：业务编排，DTO 转换

**QueryService DoD**：
- [ ] 只读查询操作
- [ ] 复杂查询使用原生 SQL（XML）
- [ ] 返回 DO 或基础类型

**ManageService DoD**：
- [ ] 增删改操作
- [ ] 使用 MyBatis-Plus 的 save/update/remove
- [ ] 业务规则校验

**DO 实体 DoD**：
- [ ] 命名符合 Aim{Name}DO
- [ ] 继承 BaseDO
- [ ] 字段与数据库表对应
- [ ] 时间字段使用 LocalDateTime

**Mapper DoD**：
- [ ] 命名符合 {Name}Mapper
- [ ] 继承 BaseMapper<Aim{Name}DO>
- [ ] XML 包含 Base_Column_List
- [ ] 禁止 SELECT *

**Feign 接口 DoD**：
- [ ] 命名符合 {Name}RemoteService
- [ ] @FeignClient 配置正确
- [ ] 使用 @RequestParam，禁止 @PathVariable
- [ ] 返回 CommonResult

> **注意**：Swagger 文档 DoD 检查由 `swagger-doc-generation` Skill 负责。

### 步骤 5：生成清单

生成 generation-manifest.yml：

```yaml
program: {P-YYYY-NNN}
phase: execute
generated_at: {YYYY-MM-DDTHH:mm:ss}
files:
  - path: {inner-api-service}/feign/{Name}RemoteService.java
    type: feign
    service: {inner-api-service}
    status: created
    
  - path: {app-service}/domain/entity/Aim{Name}DO.java
    type: entity
    service: {app-service}
    status: created
    
  # ... 其他文件
```

---

## 返回格式

```
状态：已完成
产出：
  - 代码文件：N 个
  - 生成清单：workspace/artifacts/generation-manifest.yml
下一步：代码审查
后续步骤：Swagger 文档生成（由 swagger-doc-generation Skill 执行）
```

---

## 相关文档

- 流程定义：`orchestrator/WORKFLOWS/feature-implementation/workflow.yml`
- 门面服务规范：`.qoder/rules/code-generation/01-facade-service.md`
- 应用服务规范：`.qoder/rules/code-generation/02-inner-service.md`
- Feign 接口规范：`.qoder/rules/code-generation/03-feign-interface.md`
- **规格生成约束**：`.qoder/rules/code-generation/12-spec-generation-constraints.md`
