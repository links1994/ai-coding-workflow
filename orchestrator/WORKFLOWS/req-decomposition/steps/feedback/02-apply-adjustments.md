# Step: 应用调整

## 目的
根据用户反馈调整拆分结果。

## 输入
- `decomposition_report`: 拆分报告
- `user_feedback`: 用户反馈

## 输出
- `adjusted_report`: 调整后的报告

## 调整类型

### 1. 添加需求

在需求树中添加新节点。

### 2. 修改依赖

更新依赖关系图中的边。

### 3. 调整批次

重新计算批次划分。

## 输出格式

```yaml
adjusted_report:
  changes:
    - type: "add"
      target: "requirements_tree"
      details: "添加 F005 {Name}导入"
    - type: "modify"
      target: "dependency_graph"
      details: "F002 依赖 F001 改为弱依赖"
  version: "1.1"
```
