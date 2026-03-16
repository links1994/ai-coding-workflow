# Step: 验证依赖合理性

## 目的
验证依赖关系是否合理。

## 输入
- `dependency_graph`: 依赖关系图

## 输出
- `dependency_check`: 依赖检查结果

## 验证项

### 1. 循环依赖检查

检测是否存在循环依赖。

### 2. 依赖强度检查

验证依赖强度是否合理：
- 数据依赖应为强依赖
- 优化依赖应为弱依赖

### 3. 跨域依赖检查

检查跨业务域依赖是否必要。

## 输出格式

```yaml
dependency_check:
  status: passed
  cycles: []
  warnings:
    - "F003 和 F004 存在潜在循环依赖风险"
```
