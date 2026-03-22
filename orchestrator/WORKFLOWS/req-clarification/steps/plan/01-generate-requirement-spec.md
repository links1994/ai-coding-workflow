# Step: 生成需求文档

## 目的
将澄清阶段收集到的所有信息，整理成一份描述**单一 Feature** 的结构化需求文档（requirement-spec.md），作为 feature-implementation 流程的唯一输入源。

> **原则**：一次需求澄清对应一个 Feature。若 Feature 较复杂，feature-implementation 阶段通过增加步骤来实现，而不是在此处拆分为多个 Feature。

## 输入
- `clarification_confirmed`: 澄清完成确认
- `business_goal_answers`: 业务目标
- `functional_scope_answers`: 功能范围
- `data_requirements_answers`: 数据需求
- `business_rules_answers`: 业务规则
- `architecture_constraints`: 架构约束

## 输出
- `requirement_spec`: 需求规格文档（requirement-spec.md）

## 执行步骤

### 1. 确定服务范围

基于架构约束和功能范围，分析需求落地到哪些服务：

- **门面层**（facade）：管理端操作 → mall-admin；用户端操作 → mall-toc-service
- **应用层**（application）：业务逻辑所在服务
- **inner-api**：Feign 接口定义和 DTO 所在模块

### 2. 整理接口清单

根据功能范围，推导出接口列表：

| 操作 | HTTP方法 | 路径 | 层级 |
|------|----------|------|------|
| 分页查询 | POST | /admin/api/v1/{path}/page | facade |
| 新增 | POST | /admin/api/v1/{path}/create | facade |
| 编辑 | POST | /admin/api/v1/{path}/update | facade |
| 删除 | POST | /admin/api/v1/{path}/delete | facade |
| 详情 | GET  | /admin/api/v1/{path}/detail | facade |

同时推导内部接口（/inner/api/v1/）。

### 3. 整理数据模型

基于数据需求，生成数据模型草案：
- 表名、字段清单、索引建议
- DO 类名、关联关系

### 4. 写入 requirement-spec.md

按照模板结构生成文档，保存到：
`workspace/outputs/requirement-spec.md`

## 文档模板结构

```markdown
# 需求规格文档：{需求主题}

> 生成时间：{timestamp}

## 1. 需求概述

### 1.1 业务目标
### 1.2 用户角色
### 1.3 使用场景

## 2. 功能清单

### 2.1 管理端功能
### 2.2 用户端功能（如有）

## 3. 接口清单

### 3.1 门面层接口（/admin 或 /app）
### 3.2 应用层内部接口（/inner）

## 4. 数据模型

### 4.1 新建表
### 4.2 变更表（如有）

## 5. 业务规则

### 5.1 校验规则
### 5.2 状态流转
### 5.3 权限控制

## 6. 服务范围
```

## 注意事项

- 需求文档描述**一个完整的 Feature**，不做拆分
- 若功能点较多，全部写入同一个文档，feature-implementation 阶段按步骤分批实现
- 接口路径需符合项目命名规范（全小写、中划线分隔）
- 文档路径固定为 `workspace/outputs/requirement-spec.md`
