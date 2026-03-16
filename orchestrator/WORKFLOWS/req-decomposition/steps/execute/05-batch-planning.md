# Step: 批次优先级排序

## 目的
制定批次执行计划。

## 输入
- `requirements_tree`: 需求树
- `dependency_graph`: 依赖关系图

## 输出
- `execution_plan`: 执行计划

## 排序规则

### 1. 拓扑排序

根据依赖关系进行拓扑排序：
- 无依赖的优先
- 被依赖多的优先

### 2. 优先级调整

在拓扑排序基础上调整：
- P0 优先于 P1
- 简单优先于复杂

### 3. 批次划分

```yaml
execution_plan:
  batches:
    - id: 1
      name: "基础配置"
      features: [F001, F003]
      dependencies: []
    - id: 2
      name: "业务功能"
      features: [F002, F004]
      dependencies: [1]
```
