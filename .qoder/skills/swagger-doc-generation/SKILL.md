---
name: swagger-doc-generation
description: 为门面服务 Controller 生成 Swagger 格式 API 文档，采用扁平化目录结构，统一归档至 outputs/swagger/{service-name}/{中文功能}-{ControllerName}Api.md
version: 1.0.0
workflow: feature-implementation
dependencies:
  - java-code-generation
---

# Swagger 文档生成 Skill

为门面服务 Controller 生成 Swagger 格式 API 文档。

## 文档规范（核心约束）

| 规范项 | 要求 |
|--------|------|
| **目录结构** | 扁平化目录结构 (Flat Directory Structure)：仅保留服务层级，省略 Controller 子目录 |
| **路径表示** | 完整路径表示 (Full Path Representation)：API 路径必须包含 `/{service-name}` 前缀 |
| **分页对齐** | DTO 字段对齐 (DTO Field Alignment)：分页响应严格使用 `totalCount` + `items` 字段名 |
| **认证模式** | 无认证文档模式 (Auth-less Documentation Mode)：文档中省略所有 `@RequestHeader` 参数和认证描述 |

---

## 触发条件

- Phase 8 功能归档已完成
- 当前 Program 涉及门面服务（`{facade-service-1}`、`{facade-service-2}`、`{facade-service-3}`）Controller 层接口的新增或变更
- 用户指令："生成 Swagger 文档" / "更新 API 文档"
- Phase 8 退出卡中标注"需进入 Phase 9"

**跳过条件**：当前 Program 属于应用服务或基础数据服务时，标记 Phase 9 为 `skipped`，不执行。

---

## 前置依赖（执行前必须读取）

| 文件 | 用途 |
|------|------|
| `workspace/tech-spec.md` | 技术规格书（获取接口清单、DTO 定义） |
| 门面服务 Controller 源文件 | 读取接口注解与方法签名 |
| 请求/响应 VO / DTO 源文件 | 读取字段定义与校验注解 |
| `outputs/swagger/{service-name}/{中文功能描述}-{ControllerName}Api.md` | 历史文档（如存在则增量更新） |
| `outputs/swagger/_TEMPLATE/{中文功能}-{ControllerName}Api.md` | 文档模板（首次生成时参考） |

---

## 输入

- 本 Program 涉及的门面服务 Controller 类（`{Name}AdminController` / `{Name}AppController` / `{Name}MerchantController`）
- 对应的请求/响应 VO、DTO 类
- Program ID（用于 Frontmatter `updated_by` 字段）

---

## 输出

```
outputs/swagger/{service-name}/{中文功能描述}-{ControllerName}Api.md
```

**产出粒度**：以 Controller 类为单位，每个 Controller 单独生成一份文档，统一归档至 `outputs/swagger/` 目录下，采用**扁平化目录结构**（Flat Directory Structure）。

**目录结构示例**：

```
outputs/swagger/
├── {facade-service-1}/
│   ├── {中文功能描述}-{ControllerName}Api.md
│   └── ...
├── {facade-service-2}/
│   └── ...
└── {facade-service-3}/
    └── ...
```

> **规范说明**：采用扁平化目录结构 (Flat Directory Structure)，文档直接存放于服务目录下，不再创建 Controller 子目录。

**命名规则**：`{中文功能描述}-{ControllerName}Api.md`

- `{中文功能描述}` 取 Controller 对应的需求功能中文名称（来源于 `@Tag(name=...)` 中最后一段，或 `tech-spec.md` 中的功能模块名称）
- `{ControllerName}` 取 Controller 类名去除 `Controller` 后缀后的 PascalCase 形式
- 两部分以短横线 `-` 连接

示例：
- `{Name}AdminController`（`@Tag` 描述：{中文功能描述}）→ `{中文功能描述}-{Name}AdminApi.md`
- `{Name}AppController`（`@Tag` 描述：{中文功能描述}）→ `{中文功能描述}-{Name}AppApi.md`

**中文描述提取优先级**：

1. 优先读取 Controller 上 `@Tag(name = "xxx/yyy")` 中的最后一段（`/` 之后的部分）
2. 次选 `tech-spec.md` 中对应模块的中文功能名
3. 以上均无时，使用 Controller 类名去掉 `Controller` 后缀作为兜底

**一个 Program 涉及多个 Controller 时**：为每个 Controller 分别生成对应文档，不合并为单文件。

---

## 工作流程

### 步骤 0：输出 Phase 9 进入卡（必须）

在执行任何文档生成操作前，必须输出进入卡并等待用户确认：

```
Phase 9 执行计划
- 当前阶段: Swagger 文档生成
- 执行方式: Skill/swagger-doc-generation（主 {Domain} 直接执行）
- 需要读取: 门面服务 Controller 源文件、请求/响应 VO/DTO 类
- 预期产出: workspace/artifacts/{ServiceName}Api.md
- 进入条件检查: Phase 8 已完成，当前 Program 涉及门面服务 Controller 变更

等待确认后开始执行 →
```

---

### 步骤 1：识别目标 Controller

- 扫描本 Program SCOPE.yml 中 `write` 允许的门面服务路径
- 找到所有 Controller 类（文件名含 `AdminController`、`AppController`、`MerchantController`）
- 记录每个 Controller 中的接口方法（路径、HTTP 方法、方法名、注释）

---

### 步骤 2：读取请求/响应结构

对每个接口方法：

- 提取方法参数类型（`@RequestBody` 参数 → 读取对应 DTO/VO 类全部字段）
- 提取返回值类型（`CommonResult<{Name}VO>` → 读取 `{Name}VO` 类全部字段）
- 从字段注解中提取校验约束：
  - `@NotNull` / `@NotBlank` → 是否必填：是
  - `@Size(max=N)` → 说明：最大长度 N
  - `@Min` / `@Max` → 说明：范围限制
  - `@Valid` 嵌套对象 → 递归读取内部字段

---

### 步骤 3：判断生成模式

检查 `outputs/swagger/{service-name}/{中文功能描述}-{ControllerName}Api.md` 是否存在：

- **不存在（首次生成）**：全量生成，包含该 Controller 所有接口
- **已存在（迭代更新）**：
  - 读取现有文档，保留**本次未涉及变更**的接口章节内容
  - 仅更新/新增本次变更的接口章节
  - 更新文件头 Frontmatter 中的 `version`、`updated_at`、`updated_by`
  - `module` 字段保持不变

---

### 步骤 4：生成文档

基于模板 `outputs/swagger/_TEMPLATE/{中文功能}-{ControllerName}Api.md`，写入 `outputs/swagger/{service-name}/{中文功能描述}-{ControllerName}Api.md`：

```markdown
---
service: {service-name}
controller: {ControllerName}
module: {ControllerName 去掉 Controller 后缀的 PascalCase，如 {Name}Admin}
title: {中文功能描述}
version: v{N}.{M}.0
updated_at: {YYYY-MM-DD}
updated_by: {Program-ID}
---

# {中文功能描述} API 文档（{ControllerName}）

> 本文档由 Phase 9 Swagger 文档生成 Skill 自动生成，最后更新：{updated_at}

## 目录

- [接口模块一](#接口模块一)
  - [接口名称](#接口名称)
- ...

---

## {模块名称}（对应 Controller 类）

### {接口功能描述}

- **路径**：`{HTTP方法} /{service-name}{接口路径}`
- **描述**：{接口功能描述}

#### 请求参数

| 字段 | 类型 | 是否必填 | 说明 |
|------|------|---------|------|
| {field} | {type} | 是/否 | {描述 + 约束} |

#### 响应结构

```json
{
  "code": 200,
  "message": "success",
  "data": {
    // {{Name}VO 字段}
  }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| {field} | {type} | {描述} |
```

**格式规则**：

- 每个 Controller 类对应一个 `##` 二级章节
- 每个接口方法对应一个 `###` 三级章节
- 基础类型（`String`、`Long`、`Integer`、`Boolean`）直接标注，List 类型标注为 `Array<{元素类型}>`
- **完整路径表示 (Full Path Representation)**：API 路径必须包含 `/{service-name}` 前缀，如 `/{facade-service}/admin/api/v1/{path}`
- **无认证文档模式 (Auth-less Documentation Mode)**：文档中**不列出** `@RequestHeader` 参数（如 `X-User-Token`），也不在参数表中描述认证信息
- **DTO 字段对齐 (DTO Field Alignment)**：分页接口响应 data 内容必须严格按以下结构描述（字段命名不得替换）：

  ```json
  {
    "code": 200,
    "message": "success",
    "data": {
      "totalCount": 100,
      "items": [
        {
          // {{Name}VO 字段}
        }
      ]
    }
  }
  ```

  | 字段 | 类型 | 说明 |
  |------|------|------|
  | `totalCount` | Long | 总记录数，对应 `CommonResult.PageData.totalCount` |
  | `items` | Array\<{{Name}VO}\> | 分页数据列表，对应 `CommonResult.PageData.items` |

  > 严格遵循 `CommonResult.PageData<T>` 结构，禁止使用 `total`/`count`/`list`/`records`/`data` 等别名。

---

### 步骤 5：更新 STATUS.yml

将 Phase 9 状态更新为 `done`：

```yaml
phases:
  - name: Swagger 文档生成
    status: done
    checklist_passed: true
```

---

## Phase 9 退出 Checklist（强制）

- [ ] 每个涉及的 Controller 均已在 `outputs/swagger/{service-name}/` 下生成对应 `{中文功能描述}-{ControllerName}Api.md`（扁平化目录结构）
- [ ] 输出目录 `outputs/swagger/{service-name}/` 已按规则创建
- [ ] 每份文档均包含完整 Frontmatter（`service`、`controller`、`module`、`title`、`version`、`updated_at`、`updated_by`）
- [ ] 每份文档覆盖该 Controller 的全部接口（无遗漏）
- [ ] 请求参数表包含字段类型和是否必填标注（**不包含** `@RequestHeader` 认证参数）
- [ ] API 路径采用**完整路径表示**，包含 `/{service-name}` 前缀
- [ ] 分页响应严格遵循 **DTO 字段对齐**，使用 `totalCount` + `items` 字段名
- [ ] 响应结构描述完整（含 `data` 字段详细说明）
- [ ] 迭代更新场景：未变更的历史接口内容完整保留
- [ ] STATUS.yml 中 Phase 9 状态已更新为 `done`

---

## 返回格式

执行完成后返回以下格式：

```
Phase 9 完结

Swagger 文档生成（按 Controller 粒度，扁平化目录结构）：
  ✅ outputs/swagger/{service-name-1}/{中文功能描述-1}-{ControllerName-1}Api.md（v{version}，{N}个接口）
  ✅ outputs/swagger/{service-name-2}/{中文功能描述-2}-{ControllerName-2}Api.md（v{version}，{N}个接口）

产出：
  - API 文档：N 份（按 Controller 隔离）
  - 更新状态：STATUS.yml Phase 9 status = done

文档规范检查：
  - 扁平化目录结构：✅ 通过
  - 完整路径表示：✅ 通过
  - DTO 字段对齐（totalCount/items）：✅ 通过
  - 无认证文档模式：✅ 通过

结论：通过 → Phase 9 完成，Program 可进入收尾
```

---

## 相关文档

- **开发流程**：`orchestrator/ALWAYS/DEV-FLOW.md` §2.5、§2.6
- **核心工作协议**：`orchestrator/ALWAYS/CORE.md` §2.2 Phase 9
- **功能归档 Skill**：`.qoder/skills/08-feature-archiving/SKILL.md`
