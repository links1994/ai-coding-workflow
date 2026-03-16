---
name: prd-decomposition
description: 将 PRD 分解为可实现的子需求。在用户说"分解 PRD"、"拆分需求"或需要将产品需求分解为带有服务归属、依赖关系和验收标准的 Feature 项时使用。
---

# PRD 分解 Skill

基于已确认的编写范围，执行服务归属分析、Feature 生成、依赖矩阵分析，产出 `decomposition.md`。

> **前置规范**：执行前必须先读取 `.qoder/rules/req-decomposition/01-feature-definition.md` 和 `.qoder/rules/req-decomposition/02-service-layering.md`

---

## 输入

| 文件 | 路径 | 必须性 |
|------|------|------|
| PRD 文档 | 用户提供路径 | 必须 |
| 原型文档 | 用户提供路径（可选） | 可选 |
| Feature 定义规范 | `.qoder/rules/req-decomposition/01-feature-definition.md` | 必须 |
| 服务分层规范 | `.qoder/rules/req-decomposition/02-service-layering.md` | 必须 |
| 已确认的编写范围 | 由 {Domain} 步骤 3 确认后传入 | 必须 |

---

## 输出

- 分解文档 → `outputs/PROGRAMS/{program_id}/workspace/decomposition.md`
- 更新 STATUS.yml → `phases[1].status: done`

---

## 执行步骤

### 步骤 1：服务归属分析

基于 `.qoder/rules/req-decomposition/02-service-layering.md` 中的服务清单，确定每个需求的服务归属：

| 服务 | 层级 | 职责 |
|-----------------------------|--------|---------------|
| {facade-service} | facade | 平台管理端 BFF |
| {facade-service-3} | facade | 商家管理端 BFF |
| {facade-service-2} | facade | 消费者 APP 端 BFF |
| {facade-service-4} | facade | AI 对话 BFF |
| {app-service-example} | application | 应用服务示例 |
| mall-merchant | application | 商家/商品管理 |
| mall-product | data | 商品基础数据 |
| mall-client | data | 用户/客户数据 |
| mall-basic-service | data | 基础配置数据 |
| mall-history-conversation | data | 历史对话数据 |

### 步骤 2：生成 Feature 项

按规范中的 Feature 定义格式生成 Feature 项，包含：

- Feature ID、名称、描述、优先级
- 服务分层（各服务负责内容、接口列表）
- API 定义（{inner-api-service} 模块）
- 数据表归属
- 依赖关系（hard/soft）
- 验收标准

### 步骤 3：依赖分析

分析 Feature 之间的依赖关系（Hard 依赖 / Soft 依赖），生成依赖矩阵。

### 步骤 4：排序建议

按依赖关系和优先级输出开发顺序建议。

### 步骤 5：生成 decomposition.md

按以下结构生成完整文档，写入 `outputs/PROGRAMS/{program_id}/workspace/decomposition.md`：

```markdown
# PRD 功能聚合拆分文档

## 需求概述

- PRD 来源：{prd-path}
- Feature 总数：{count}
- 涉及服务：{service-list}

## Feature 列表

### F-{NNN}: {Feature 名称}

**描述**：{一句话描述业务价值}

**优先级**：P0/P1/P2

**服务分层**：

| 服务 | 层级 | 负责内容 | 接口数 |
|------|------|----------|--------|
| {service-name} | facade/application/data | {scope} | {count} |

**接口清单**（门面层）：

| 方法 | 路径 | 描述 |
|------|------|------|
| {METHOD} | {path} | {description} |

**API 定义**（{inner-api-service}）：

```yaml
module: {module-name}-api
feign: {{Name}RemoteService}
methods:
  - {method-signature}
```

**数据表**：

- {table-name}

**依赖**：

- 强依赖：{list}
- 软依赖：{list}

**验收标准**：

- [ ] {criteria-1}
- [ ] {criteria-2}

---

## 开发顺序建议

1. {F-XXX} {name}（{reason}）
2. {F-XXX} {name}（依赖 {F-XXX}）
3. ...

## 服务工作量汇总

| 服务 | 涉及 Feature 数 | 预估接口数 |
|------|----------------|------------|
| {service} | {count} | {count} |
```

### 步骤 6：更新 STATUS.yml

```yaml
phases:
  - name: PRD 功能聚合拆分
    status: done
    checklist_passed: true
```

---

## 返回格式

```
状态：已完成
产出：outputs/PROGRAMS/{program_id}/workspace/decomposition.md
Feature 数量：X
```
