# Step: 分析需求模糊点

## 目的
综合原始需求与架构约束，输出结构化分析报告，识别已知信息与待澄清项，为 decision 阶段的访谈提供问题基础。

## 输入
- `raw_requirement_context`: 原始需求上下文
- `architecture_constraints`: 架构约束

## 输出
- `requirement_analysis`: 需求分析报告

## 执行步骤

### 1. 已知信息整理

汇总从原始需求中已能识别的内容：
- 业务主题和目标
- 已明确的角色
- 已明确的操作（增删改查/审核/发布等）
- 涉及的数据实体

### 2. 模糊点识别

从以下维度逐项检查，找出需要澄清的问题：

| 维度 | 检查项 | 是否明确 |
|------|--------|----------|
| 业务目标 | 解决什么痛点 | ? |
| 用户角色 | 谁在用这个功能 | ? |
| 功能范围 | 增删改查哪些操作 | ? |
| 数据模型 | 需要哪些字段 | ? |
| 业务规则 | 有哪些约束和校验 | ? |
| 服务归属 | 落到哪些微服务 | ? |

### 3. 生成访谈问题清单

针对每个模糊点，生成对应的澄清问题，供 decision 阶段使用：

```yaml
requirement_analysis:
  known:
    topic: "需求主题"
    roles: []
    actions: []
  ambiguous:
    - dimension: business_goal
      issue: "未明确当前痛点"
      question: "这个功能要解决什么具体问题？"
    - dimension: functional_scope
      issue: "不确定是否需要用户端"
      question: "是否只有管理端，还是用户端也需要？"
  interview_priority:
    must_ask: [business_goal, roles, functional_scope]
    conditional: [batch_operations, import_export, notifications]
```
