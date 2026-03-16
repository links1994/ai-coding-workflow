# Step: 分析依赖关系

## 目的
分析 Feature 之间的依赖关系。

## 输入
- `requirements_tree`: 需求树

## 输出
- `dependency_graph`: 依赖关系图

## 依赖类型

### 1. 强依赖

- 数据依赖：需要前置 Feature 的数据
- 功能依赖：需要前置 Feature 的功能

### 2. 弱依赖

- 优化依赖：前置完成可优化实现
- 并行依赖：可同时开发

## 输出格式

```yaml
dependency_graph:
  nodes:
    - id: F001
      name: "{NameA}管理"
    - id: F002
      name: "{NameB}管理"
  edges:
    - source: F002
      target: F001
      type: strong
      reason: "{NameB}需要关联{NameA}"
```
